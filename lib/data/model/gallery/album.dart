import 'package:rudo_app_clone/data/model/user/user_data.dart';

class Album{
  final int id;
  final String name;
  final DateTime created;

  final String coverFile, coverThumbnail, midSize, fullSize;

  final int imageCounter;

  final List<UserData> userData;

  Album({
    required this.id,
    required this.name,
    required this.created,
    required this.coverFile,
    required this.coverThumbnail,
    required this.midSize,
    required this.fullSize,
    required this.imageCounter,
    required this.userData
  });

  factory Album.fromJson(Map<String, dynamic> json){
    return Album(
      id: json['id'], 
      name: json['name'], 
      created: DateTime.parse(json['created']), 
      coverFile: json['cover']['file'], 
      coverThumbnail: json['cover']['thumbnail'], 
      midSize: json['cover']['midsize'], 
      fullSize: json['cover']['fullsize'], 
      imageCounter: json['image_counter'],
      userData: (json['publishers'] as List).map<UserData>((e) => UserData.fromJson(e)).toList()
    );
  }



}