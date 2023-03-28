import 'package:equatable/equatable.dart';

abstract class LogInEvent extends Equatable{}
class LogIn extends LogInEvent{

  LogIn();
  
  @override
  List<Object?> get props => [];
}
