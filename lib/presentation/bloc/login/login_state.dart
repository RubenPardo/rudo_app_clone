import 'package:equatable/equatable.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';

abstract class LogInState extends Equatable{}

class Loading extends LogInState{
  @override
  List<Object?> get props => [];
}
class Error extends LogInState{
  final String message;
  Error(this.message);
  @override
  List<Object?> get props => [message];
}
class NoContent extends LogInState{
  @override
  List<Object?> get props => [];
}
class Loged extends LogInState{
  final UserData user;
  Loged(this.user);
  
  @override
  List<Object?> get props => [user];
}

class LogedOut extends LogInState{

  LogedOut();
  
  @override
  List<Object?> get props => [];
}