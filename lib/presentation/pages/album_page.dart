import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/gallery/album.dart';
import 'package:rudo_app_clone/data/model/gallery/photo.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/bloc/album/album_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/album/album_state.dart';
import 'package:rudo_app_clone/presentation/bloc/gallery/gallery_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/login/login_bloc.dart';
import 'package:rudo_app_clone/presentation/pages/images_detail.dart';
import 'package:rudo_app_clone/presentation/widgets/app_bar.dart';
import 'package:rudo_app_clone/presentation/widgets/error_widget.dart';

import '../bloc/album/album_event.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key, required this.album, required this.user});

  final Album album;
  final UserData user;

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {


  @override
  void initState() {
    super.initState();
    context.read<AlbumBloc>().add(InitAlbum(album: widget.album));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBar: AppBar(),
        title: 'Detalles album',
        canPop: true,
        backgroundColor: AppColors.backgroundColorScaffold,
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.add_circle_outline))
        ],
      ) ,
      body: BlocConsumer<AlbumBloc, AlbumState>(
        builder: (context, state) {
          if(state is Loading){
            return  _buildLoading();
          }else if(state is AlbumLoaded){
            if(state.album.photos!.isEmpty){
              return _buildEmpty();
            }else{
              return _buildPhotos(state.album.photos!);
            }
          }else{
            return _buildError();
          }
        }, 
        listener: (context, state) {
          
        },
      )
    );
  }

   Widget _buildError(){
    return ContentErrorWidget(callback:(){context.read<AlbumBloc>().add(InitAlbum(album: widget.album));});
  }

  Widget _buildEmpty(){
    double aspectRatio = MediaQuery.of(context).devicePixelRatio;
    return  CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Stack(
            children: [
              Align(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 55,vertical: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/empty_album.png', cacheHeight: (aspectRatio*120).round(),),
                    const SizedBox(height: 40,),
                    const Text('Aún no hay fotografías',style: CustomTextStyles.titleAppbar,),
                    const SizedBox(height: 12,),
                    const Text('Este álbum aún está vacío, sé la primera persona en subir una foto de este día. ',style: CustomTextStyles.bodySmall,textAlign: TextAlign.center,),
                    ],
                  ),
                ),  
              
              ),

              _buildTitle(),
          
            ]
          ),
        )
      ],

    );
    
  }

  Widget _buildLoading(){
    return const Center(child: CircularProgressIndicator(),);
  }

  Widget _buildTitle(){
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.album.name,style: CustomTextStyles.title1,),
          const SizedBox(height: 8,),
          Row(
            children: [
              Image.asset('assets/images/red_calendar.png'),
              const SizedBox(width: 8,),
              Text(widget.album.created.toStringDataNameDayMonthAbvYear())
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPhotos(List<Photo> photos){
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      return ListView(
        children: [
          _buildTitle(),
          Flexible(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                mainAxisSpacing: 16
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => 
                    ImagesDetail(
                      title: widget.album.created.toStringDayMonthYear(),
                      startsAt:index,
                      photos: photos,
                      user: widget.user
                    ),));
                  },
                  child: Image.network(photos[index].midSize,fit: BoxFit.cover,cacheHeight: (devicePixelRatio*150).round() ,cacheWidth: (devicePixelRatio*150).round(),));
              },
            ),
          ),
        ],
      );
  }
}


