import 'package:equatable/equatable.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/google_response_status.dart';

abstract class HomeEvent extends Equatable{}
class InitHome extends HomeEvent{
  final bool fromMemory;
  InitHome({required this.fromMemory});
  @override
  List<Object?> get props => [fromMemory];
}

class UpdateEvent extends HomeEvent{
  final Event event;
  final ResponseStatus status;
  UpdateEvent({required this.event, required this.status});
  @override
  List<Object?> get props => [event, status];
}
