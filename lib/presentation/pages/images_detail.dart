import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/gallery/photo.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/widgets/app_bar.dart';

class ImagesDetail extends StatefulWidget {
  const ImagesDetail({super.key, required this.photos, required this.startsAt, required this.title,required this.user});

  final List<Photo> photos;
  final int startsAt;
  final String title;
  final UserData user;


  @override
  State<ImagesDetail> createState() => _ImagesDetailState();
}

class _ImagesDetailState extends State<ImagesDetail> {

 late PageController _pageController;

 Future<void> savePhoto(String filename) async {
  try {
    // Saved with this method.
    var imageId = await ImageDownloader.downloadImage(filename);
    if (imageId == null) {
     throw PlatformException(code: '');
    }

    // TODO guardar imagne, este plugin funciona bien o es mejor otro????  
    //fileName = await ImageDownloader.findPath(imageId);
  } on PlatformException catch (error) {
    Utils.showSnakError('No se ha podido descargar la imagen', context);
  }
}

  



 @override
  void initState() {
    super.initState();
   _pageController = PageController(initialPage: widget.startsAt);
   ImageDownloader.callback(onProgressUpdate: (imageId, progress) {
      log(progress.toString());
      log(imageId.toString());
   },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColorScaffold,
      appBar: CustomAppBar(
        appBar: AppBar(), 
        title: widget.title, 
        backgroundColor: AppColors.backgroundColorScaffold, 
        canPop: true,
        actions: [
          IconButton(onPressed: (){savePhoto(widget.photos[_pageController.page!.round()].file);}, icon: const Icon(Icons.download_for_offline_outlined)),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom:AppBar().preferredSize.height),
        child: PageView.builder(
          itemCount: widget.photos.length,
          controller: _pageController,
          itemBuilder: (context, index) {
            //log('ES MIA: ${widget.user.firstName == widget.photos[index].user.firstName}');
            return  PinchZoom(child: Image.network(widget.photos[index].fullSize));
          },
        ),
      ),
    );
  }
}
