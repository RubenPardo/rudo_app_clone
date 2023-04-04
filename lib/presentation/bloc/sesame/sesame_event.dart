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

class CheckIn extends SesameEvent{
  final CheckType checkType = CheckType.checkIn;
  CheckIn();
  
  @override
  List<Object?> get props => [checkType];
}

class CheckOut extends SesameEvent{
  final CheckType checkType = CheckType.checkout;
  CheckOut();
  
  @override
  List<Object?> get props => [checkType];
}

class Pause extends SesameEvent{
  final CheckType checkType = CheckType.pause;
  Pause();
  
  @override
  List<Object?> get props => [checkType];
}