import 'image.dart';

class Rank {
  String? name;
  String? description;
  Image? image;

  Rank({this.name, this.description, this.image});

  factory Rank.fromJson(Map<String, dynamic> json) {
    return Rank(
      name: json['name'],
      description: json['description'],
      image: json['image'] != null ? Image.fromJson(json['image']) : null
    );
  }

}