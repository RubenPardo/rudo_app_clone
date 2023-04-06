import 'package:equatable/equatable.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';

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
class NoLinked extends SesameState{
  @override
  List<Object?> get props => [];
}
class Loaded extends SesameState{
  
  Loaded();
  
  @override
  List<Object?> get props => [];
}