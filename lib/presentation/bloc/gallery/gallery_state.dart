import 'package:equatable/equatable.dart';
import 'package:rudo_app_clone/data/model/gallery/album.dart';

abstract class GalleryState extends Equatable{}

class GalleryUninitailized extends GalleryState{
  @override
  List<Object?> get props => [];
}

class AlbumLoaded extends GalleryState{
  final List<Album> albumes;
  AlbumLoaded({required this.albumes});
  @override
  List<Object?> get props => [albumes];
}

class Loading extends GalleryState{
  @override
  List<Object?> get props => [];
}

class Error extends GalleryState{
  final String message;

  Error({required this.message});
  @override
  List<Object?> get props => [message];
}