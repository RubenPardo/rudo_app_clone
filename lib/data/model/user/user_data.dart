import 'package:rudo_app_clone/data/model/user/image.dart';
import 'package:rudo_app_clone/data/model/user/rank.dart';
import 'package:rudo_app_clone/data/model/user/tech.dart';

class UserData {
  String? firstName;
  String? lastName;
  String? email;
  Image? image;
  Tech? tech;
  bool? isSesameOk;
  Rank? rank;
  String? joinDate;
  bool? isTrip;

  UserData(
      {this.firstName,
      this.lastName,
      this.email,
      this.image,
      this.tech,
      this.isSesameOk,
      this.rank,
      this.joinDate,
      this.isTrip});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      image: json['image'] != null ? Image.fromJson(json['image']) : null,
      tech: json['tech'] != null ? Tech.fromJson(json['tech']) : null,
      isSesameOk: json['is_sesame_ok'],
      rank: json['rank'] != null ?  Rank.fromJson(json['rank']) : null,
      joinDate: json['join_date'],
      isTrip: json['is_trip'],
    );
  }

  
}
