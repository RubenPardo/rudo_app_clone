import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable{}
class InitHome extends HomeEvent{
  InitHome();
  @override
  List<Object?> get props => [];
}
