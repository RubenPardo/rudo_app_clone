import 'package:equatable/equatable.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/office_day.dart';

abstract class HomeState extends Equatable{}


class InitState extends HomeState{
  @override
  List<Object?> get props => [];
}

class Loading extends HomeState{
  @override
  List<Object?> get props => [];
}
class Error extends HomeState{
  final String message;
  Error(this.message);
  @override
  List<Object?> get props => [message];
}

class LoadedContent extends HomeState{
  final List<Event> events;
  final List<OfficeDay> officeDays;
  LoadedContent({required this.events, required this.officeDays});
  
  @override
  List<Object?> get props => [events, officeDays];
}