import 'package:equatable/equatable.dart';
import 'package:rudo_app_clone/data/model/sesame/check_type.dart';

abstract class SesameEvent extends Equatable{}
class Link extends SesameEvent{

  Link();
  
  @override
  List<Object?> get props => [];
}

class InitSesame extends SesameEvent{
  
  
  @override
  List<Object?> get props => [];

}

class AddCheck extends SesameEvent{
  final CheckType checkType;
  AddCheck(this.checkType);
  
  @override
  List<Object?> get props => [checkType];
}