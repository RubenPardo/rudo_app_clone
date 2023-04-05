

import 'dart:developer';

import 'package:rudo_app_clone/data/model/google_response_status.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';

class Event {
    final String eventId;
    final String title;
    final String imageUrl;
    final String text;
    final String description;
    final String user;
    final DateTime start;
    final DateTime end;
    final List<UserData> confirmedAttendees;
    final ResponseStatus responseStatus;
    bool isFeatured;

  Event(
      {required this.eventId,
      required this.title,
      required this.imageUrl,
      required this.text,
      required this.description,
      required this.user,
      required this.start,
      required this.end,
      required this.confirmedAttendees,
      required this.responseStatus,
      required this.isFeatured,
      });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'], 
      title: json['title'], 
      imageUrl: json['image'] ?? '', 
      text: json['text'], 
      description: json['description'] ?? '', 
      user: json['user'], 
      start: DateTime.parse('${json['start']}'), 
      end: DateTime.parse('${json['end']}'), 
      confirmedAttendees: json['confirmedAttendees'] != null ? (json['confirmedAttendees'] as List).map<UserData>((v) {return UserData.fromJson(v);}).toList() : [], 
      responseStatus: ResponseStatus.fromString(json['responseStatus']), 
      isFeatured: json['is_featured']);
    
  
    }

}

