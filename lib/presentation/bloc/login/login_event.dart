import 'package:equatable/equatable.dart';

abstract class LogInEvent extends Equatable{}

class InitLogIn extends LogInEvent{

  InitLogIn();
  
  @override
  List<Object?> get props => [];
}

class LogIn extends LogInEvent{

  LogIn();
  
  @override
  List<Object?> get props => [];
}

class LogOut extends LogInEvent{

  LogOut();
  
  @override
  List<Object?> get props => [];
}
