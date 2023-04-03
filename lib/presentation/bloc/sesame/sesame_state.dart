import 'package:equatable/equatable.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';

abstract class SesameState extends Equatable{}

class Loading extends SesameState{
  @override
  List<Object?> get props => [];
}
class Error extends SesameState{
  final String message;
  Error(this.message);
  @override
  List<Object?> get props => [message];
}
class NoContent extends SesameState{
  @override
  List<Object?> get props => [];
}
class Loged extends SesameState{
  final UserData user;
  Loged(this.user);
  
  @override
  List<Object?> get props => [user];
}