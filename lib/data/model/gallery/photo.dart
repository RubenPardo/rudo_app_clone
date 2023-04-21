import 'package:rudo_app_clone/data/model/user/user_data.dart';

class Photo{
  final int id;
 final String file, thumbnail, midSize, fullSize;
 final List<UserData> taggedUsers;
 final UserData user;

 Photo({
  required this.id,
  required this.file,
  required this.thumbnail,
  required this.midSize,
  required this.fullSize,
  required this.taggedUsers,
  required this.user
 });


  factory Photo.fromJson(Map<String, dynamic> json){
    return Photo(
      id: json['id'], 
      file: json['image']['file'], 
      thumbnail: json['image']['thumbnail'], 
      midSize: json['image']['midsize'], 
      fullSize: json['image']['fullsize'], 
      taggedUsers: json['publishers']!=null ? (json['publishers'] as List).map<UserData>((e) => UserData.fromJson(e)).toList() : [],
      user: UserData(
        firstName: json['user']['name'],
      )
    );
  }

}