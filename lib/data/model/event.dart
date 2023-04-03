

import 'dart:developer';

import 'package:rudo_app_clone/data/model/user/user_data.dart';

class Event {
  String? kind;
  String? etag;
  String? id;
  String? status;
  String? htmlLink;
  String? created;
  String? updated;
  late String summary;
  Creator? creator;
  Organizer? organizer;
  late DateTime start;
  late DateTime end;
  late bool hasTime;
  List<String>? recurrence;
  String? transparency;
  String? iCalUID;
  int? sequence;
  Reminders? reminders;
  String? eventType;
  Null? me;
  late List<UserData> confirmedAttendees;
  late String totalAttendees;
  late List<Attendees> attendees;
  String? hangoutLink;
  ConferenceData? conferenceData;
  String? recurringEventId;
  OriginalStartTime? originalStartTime;

  Event(
      {this.kind,
      this.etag,
      this.id,
      this.status,
      this.htmlLink,
      this.created,
      this.updated,
      required this.summary,
      this.creator,
      this.organizer,
      required this.start,
      required this.end,
      this.recurrence,
      this.transparency,
      this.iCalUID,
      this.sequence,
      this.reminders,
      this.eventType,
      this.me,
      required this.confirmedAttendees,
      required this.totalAttendees,
      required this.attendees,
      this.hangoutLink,
      this.conferenceData,
      this.recurringEventId,
      this.originalStartTime});

  Event.fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    
    etag = json['etag'];

    id = json['id'];

    status = json['status'];

    htmlLink = json['htmlLink'];

    created = json['created'];

    updated = json['updated'];

    summary = json['summary'] ?? "";

    creator =
        json['creator'] != null ? Creator.fromJson(json['creator']) : null;

    organizer = json['organizer'] != null
        ? Organizer.fromJson(json['organizer'])
        : null;

    if(json['start'] != null){
      if(json['start']['date']!=null){
        hasTime = false;
        start = DateTime.parse('${json['start']['date']} 00:00:00');
      }else{
        hasTime = true;
        start = DateTime.parse('${json['start']['dateTime']}');
      }
    }
    if(json['end'] != null){
      if(json['end']['date']!=null){
        end = DateTime.parse('${json['end']['date']} 00:00:00');
      }else{
        end = DateTime.parse('${json['end']['dateTime']}');
      }
    }
   


    transparency = json['transparency'];

    iCalUID = json['iCalUID'];

    sequence = json['sequence'];

    reminders = json['reminders'] != null
        ? Reminders.fromJson(json['reminders'])
        : null;
    eventType = json['eventType'];
    me = json['me'];

    if (json['confirmedAttendees'] != null) {
      confirmedAttendees = <UserData>[];
      json['confirmedAttendees'].forEach((v) {
        confirmedAttendees.add(UserData.fromJson(v));
      });
    }
    totalAttendees = json['totalAttendees'] != null ? json['totalAttendees'].toString() : "0";

    if (json['attendees'] != null) {
      attendees = <Attendees>[];
      json['attendees'].forEach((v) {
        attendees.add(Attendees.fromJson(v));
      });
    }else{
      attendees = [];
    }
    hangoutLink = json['hangoutLink'];
    conferenceData = json['conferenceData'] != null
        ? ConferenceData.fromJson(json['conferenceData'])
        : null;
    recurringEventId = json['recurringEventId'];
    originalStartTime = json['originalStartTime'] != null
        ? OriginalStartTime.fromJson(json['originalStartTime'])
        : null;
  }

}

class Creator {
  String? email;

  Creator({this.email});

  Creator.fromJson(Map<String, dynamic> json) {
    email = json['email'];
  }
}

class Organizer {
  String? email;
  String? displayName;
  bool? self;

  Organizer({this.email, this.displayName, this.self});

  Organizer.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    displayName = json['displayName'];
    self = json['self'];
  }

}

class Start {
  String? date;
  String? dateTime;
  String? timeZone;

  Start({this.date, this.dateTime, this.timeZone});

  Start.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    dateTime = json['dateTime'];
    timeZone = json['timeZone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['dateTime'] = this.dateTime;
    data['timeZone'] = this.timeZone;
    return data;
  }
}

class Reminders {
  bool? useDefault;

  Reminders({this.useDefault});

  Reminders.fromJson(Map<String, dynamic> json) {
    useDefault = json['useDefault'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['useDefault'] = this.useDefault;
    return data;
  }
}
class Image {
  String? file;
  String? thumbnail;
  String? midsize;
  String? fullsize;

  Image({this.file, this.thumbnail, this.midsize, this.fullsize});

  Image.fromJson(Map<String, dynamic> json) {
    file = json['file'];
    thumbnail = json['thumbnail'];
    midsize = json['midsize'];
    fullsize = json['fullsize'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file'] = this.file;
    data['thumbnail'] = this.thumbnail;
    data['midsize'] = this.midsize;
    data['fullsize'] = this.fullsize;
    return data;
  }
}

class Tech {
  String? name;
  Image? image;
  String? color;

  Tech({this.name, this.image, this.color});

  Tech.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'] != null ? new Image.fromJson(json['image']) : null;
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.image != null) {
      data['image'] = this.image!.toJson();
    }
    data['color'] = this.color;
    return data;
  }
}

class Attendees {
  String? email;
  String? responseStatus;
  String? displayName;

  Attendees({this.email, this.responseStatus, this.displayName});

  Attendees.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    responseStatus = json['responseStatus'];
    displayName = json['displayName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['responseStatus'] = this.responseStatus;
    data['displayName'] = this.displayName;
    return data;
  }
}

class ConferenceData {
  List<EntryPoints>? entryPoints;
  ConferenceSolution? conferenceSolution;
  String? conferenceId;

  ConferenceData(
      {this.entryPoints, this.conferenceSolution, this.conferenceId});

  ConferenceData.fromJson(Map<String, dynamic> json) {
    if (json['entryPoints'] != null) {
      entryPoints = <EntryPoints>[];
      json['entryPoints'].forEach((v) {
        entryPoints!.add(new EntryPoints.fromJson(v));
      });
    }
    conferenceSolution = json['conferenceSolution'] != null
        ? new ConferenceSolution.fromJson(json['conferenceSolution'])
        : null;
    conferenceId = json['conferenceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.entryPoints != null) {
      data['entryPoints'] = this.entryPoints!.map((v) => v.toJson()).toList();
    }
    if (this.conferenceSolution != null) {
      data['conferenceSolution'] = this.conferenceSolution!.toJson();
    }
    data['conferenceId'] = this.conferenceId;
    return data;
  }
}

class EntryPoints {
  String? entryPointType;
  String? uri;
  String? label;
  String? pin;
  String? regionCode;

  EntryPoints(
      {this.entryPointType, this.uri, this.label, this.pin, this.regionCode});

  EntryPoints.fromJson(Map<String, dynamic> json) {
    entryPointType = json['entryPointType'];
    uri = json['uri'];
    label = json['label'];
    pin = json['pin'];
    regionCode = json['regionCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['entryPointType'] = this.entryPointType;
    data['uri'] = this.uri;
    data['label'] = this.label;
    data['pin'] = this.pin;
    data['regionCode'] = this.regionCode;
    return data;
  }
}

class ConferenceSolution {
  Key? key;
  String? name;
  String? iconUri;

  ConferenceSolution({this.key, this.name, this.iconUri});

  ConferenceSolution.fromJson(Map<String, dynamic> json) {
    key = json['key'] != null ? new Key.fromJson(json['key']) : null;
    name = json['name'];
    iconUri = json['iconUri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.key != null) {
      data['key'] = this.key!.toJson();
    }
    data['name'] = this.name;
    data['iconUri'] = this.iconUri;
    return data;
  }
}

class Key {
  String? type;

  Key({this.type});

  Key.fromJson(Map<String, dynamic> json) {
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    return data;
  }
}

class OriginalStartTime {
  String? dateTime;
  String? timeZone;

  OriginalStartTime({this.dateTime, this.timeZone});

  OriginalStartTime.fromJson(Map<String, dynamic> json) {
    dateTime = json['dateTime'];
    timeZone = json['timeZone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dateTime'] = this.dateTime;
    data['timeZone'] = this.timeZone;
    return data;
  }
}
