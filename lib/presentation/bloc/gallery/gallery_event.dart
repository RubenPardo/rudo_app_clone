import 'package:rudo_app_clone/data/model/gallery/album.dart';

abstract class GalleryEvent{}

class InitGallery extends GalleryEvent{
  final bool fromMemory;
  InitGallery({required this.fromMemory});
}
