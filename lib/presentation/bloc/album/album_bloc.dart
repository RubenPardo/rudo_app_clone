import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';
import 'package:rudo_app_clone/presentation/bloc/album/album_event.dart';
import 'package:rudo_app_clone/presentation/bloc/album/album_state.dart';

class AlbumBloc extends Bloc<AlbumEvent,AlbumState>{
  
  
  AlbumBloc() : super (AlbumUninitailized()){
    
    //Album albumes = [];

    // get the photos of an album
    on<InitAlbum>((event, emit) async {
      try{
        emit(Loading());
        if(event.album.hasPhotos){
          emit(AlbumLoaded(album: event.album));
        }else{
          event.album.setPhotos = await RudoApiService().getAlbumPhotosById(event.album.id.toString());
          emit(AlbumLoaded(album: event.album));
        }
      }catch(e){
        log(e.toString());
        emit(Error(message: 'Error al obtener las photos del album'));
      }
    });
    
  }
  
}