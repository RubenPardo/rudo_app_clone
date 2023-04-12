import 'package:equatable/equatable.dart';
import 'package:rudo_app_clone/data/model/alert.dart';
import 'package:rudo_app_clone/data/model/event.dart';

abstract class AlertState extends Equatable{}

class InitState extends AlertState{
  @override
  List<Object?> get props => [];
}

class Loading extends AlertState{
  @override
  List<Object?> get props => [];
}

class Error extends AlertState{
  final String message;
  Error({required this.message});
  @override
  List<Object?> get props => [message];
}

class Loaded extends AlertState{
  final List<Alert> alerts; // TODO cambiar a modelo Alert

  Loaded({required this.alerts});

  @override
  List<Object?> get props => [alerts];
}