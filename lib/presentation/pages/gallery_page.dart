import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/data/model/gallery/album.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';
import 'package:rudo_app_clone/presentation/bloc/gallery/gallery_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/gallery/gallery_event.dart';
import 'package:rudo_app_clone/presentation/bloc/gallery/gallery_state.dart';
import 'package:rudo_app_clone/presentation/pages/album_page.dart';
import 'package:rudo_app_clone/presentation/widgets/app_bar.dart';
import 'package:rudo_app_clone/presentation/widgets/error_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/primary_button.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {

  @override
  void initState() {
    super.initState();

    context.read<GalleryBloc>().add(InitGallery(fromMemory: context.read<GalleryBloc>().galleryLoaded));
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBar: AppBar(), 
        title: 'Galería', 
        backgroundColor: AppColors.backgroundColorScaffold, 
        canPop: false
      ),
      body: BlocConsumer<GalleryBloc,GalleryState>(
        builder: (context, state) {
            
          if(state is Loading){
            return  _buildLoading();
          }else if(state is AlbumLoaded){
            return _buildBody(state.albumes);
          }else{
            return _buildError();
          }
    
        },
        listener: (context, state) {
          
        },
      ),
    );
  }

  Widget _buildError(){
    return ContentErrorWidget(callback:(){context.read<GalleryBloc>().add(InitGallery(fromMemory: false));});
  }

  Widget _buildLoading(){
    return const Center(child: CircularProgressIndicator(),);
  }

  Widget _buildBody(List<Album> albumes){
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Stack(
        children: [
          RefreshIndicator(
            onRefresh: (){context.read<GalleryBloc>().add(InitGallery(fromMemory: false)); return Future(() => null);},
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      childAspectRatio: MediaQuery.of(context).size.height > 700 ? 0.79: 0.75,// TODO revisar esto
                      mainAxisSpacing: 8
                    ),
                    itemCount: albumes.length,
                    itemBuilder: (context, index) {
                      
                      return _buildAlbumItem(albumes[index],devicePixelRatio);
                    },
                  ),
            
                  const SizedBox(height: 64,),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildFAB(),
            ),
          )
        ],
      );
  }

  Widget _buildAlbumItem(Album album, double devicePixelRatio){
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AlbumPage(album: album),)),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              
              borderRadius: BorderRadius.circular(16),
              child: Image.network(album.midSize,fit: BoxFit.cover, cacheHeight: (devicePixelRatio*100).round(),),
            ),
          ),
          const Spacer(),
          Text(album.name,style: CustomTextStyles.title4,),
          Text('${album.imageCounter} fotos'),
        ],
      ),
    );
  }

  Widget _buildFAB(){
    return PrimaryButton(
      color: AppColors.primaryColor,
      onPressed: (){},
      text: 'Añadir foto',
    );
  }
}