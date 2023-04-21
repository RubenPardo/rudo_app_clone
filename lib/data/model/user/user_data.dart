import 'package:equatable/equatable.dart';
import 'package:rudo_app_clone/data/model/user/image.dart';
import 'package:rudo_app_clone/data/model/user/rank.dart';
import 'package:rudo_app_clone/data/model/user/tech.dart';

class UserData extends Equatable{
  String? firstName;
  String? lastName;
  String? email;
  Image? image;
  Tech? tech;
  bool? isSesameOk;
  Rank? rank;
  DateTime? joinDate;
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
    DateTime? joinDate;
    if(json['join_date']!=null){
      // 20-03-2023 -> 2023-03-20
      var dateSplited = (json['join_date'] as String).split('-');
      dateSplited = [dateSplited[2],dateSplited[1],dateSplited[0]];
      String dateWellFomrated = dateSplited.join('-');
      joinDate = DateTime.parse('$dateWellFomrated 00:00:00');
    }
    
    return UserData(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      image: json['image'] != null ? Image.fromJson(json['image']) : null,
      tech: json['tech'] != null ? Tech.fromJson(json['tech']) : null,
      isSesameOk: json['is_sesame_ok'],
      rank: json['rank'] != null ?  Rank.fromJson(json['rank']) : null,
      joinDate: joinDate,
      isTrip: json['is_trip'],
    );
  }
  

  @override
  // TODO: implement props
  List<Object?> get props => [];

  

  
}
