import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/data/model/gallery/album.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';
import 'package:rudo_app_clone/presentation/bloc/gallery/gallery_event.dart';
import 'package:rudo_app_clone/presentation/bloc/gallery/gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent,GalleryState>{
  
  bool galleryLoaded = false;
  
  GalleryBloc() : super (GalleryUninitailized()){
    
    List<Album> albumes = [];



    
    // get all the albumes
    on<InitGallery>((event, emit) async{
      try{
        emit(Loading());
        if(event.fromMemory){
          emit(AlbumLoaded(albumes: albumes));
        }else{
          albumes = await RudoApiService().getAlbums();
          emit(AlbumLoaded(albumes: albumes));
          
        }
        galleryLoaded = true;
      }catch(e){
        emit(Error(message: 'Error al obtener los albumes'));
      }
    });
    
  }
  
}