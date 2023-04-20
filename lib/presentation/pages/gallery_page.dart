import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/data/model/gallery/album.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';
import 'package:rudo_app_clone/presentation/widgets/app_bar.dart';
import 'package:rudo_app_clone/presentation/widgets/primary_button.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBar: AppBar(), 
        title: 'Galería', 
        backgroundColor: AppColors.backgroundColorScaffold, 
        canPop: false
      ),
      body: FutureBuilder(
        future: RudoApiService().getAlbums(), // TODO cambiar a BLOC
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return Stack(
              children: [
                SingleChildScrollView(
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
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          
                          return _buildAlbumItem(snapshot.data![index]);
                        },
                      ),
                
                      const SizedBox(height: 64,),
                    ],
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

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }


  Widget _buildAlbumItem(Album album){
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            height: 156,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(image: NetworkImage(album.coverThumbnail,),fit: BoxFit.cover),
              
            ),
          ),
        ),
        const Spacer(),
        Text(album.name,style: CustomTextStyles.title4,),
        Text('${album.imageCounter} fotos'),
      ],
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