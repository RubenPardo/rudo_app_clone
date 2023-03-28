import 'package:rudo_app_clone/data/model/user/image.dart';

class Tech {
  String? name;
  Image? image;
  String? color;

  Tech({this.name, this.image, this.color});

  factory Tech.fromJson(Map<String, dynamic> json) {
    return Tech(
      name: json['name'],
      image: json['image'] != null ? Image.fromJson(json['image']) : null,
      color: json['color'],
    );
  }
}