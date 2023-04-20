import 'package:rudo_app_clone/data/model/gallery/album.dart';

abstract class AlbumEvent{}
class InitAlbum extends AlbumEvent{
  Album album;
  InitAlbum({required this.album});
}