import 'package:equatable/equatable.dart';
import 'package:rudo_app_clone/data/model/gallery/album.dart';

abstract class AlbumState extends Equatable{}

class AlbumUninitailized extends AlbumState{
  @override
  List<Object?> get props => [];
}

class AlbumLoaded extends AlbumState{
  final Album album;

  AlbumLoaded({required this.album});

  @override
  List<Object?> get props => [album];
}

class Loading extends AlbumState{
  @override
  List<Object?> get props => [];
}

class Error extends AlbumState{
  final String message;

  Error({required this.message});
  @override
  List<Object?> get props => [message];
}