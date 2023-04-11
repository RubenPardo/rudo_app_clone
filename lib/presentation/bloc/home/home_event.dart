import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable{}
class InitHome extends HomeEvent{
  final bool fromMemory;
  InitHome({required this.fromMemory});
  @override
  List<Object?> get props => [fromMemory];
}
