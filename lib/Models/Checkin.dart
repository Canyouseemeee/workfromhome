// To parse this JSON data, do
//
//     final checkin = checkinFromJson(jsonString);

import 'dart:convert';

List<Checkin> checkinFromJson(String str) => List<Checkin>.from(json.decode(str).map((x) => Checkin.fromJson(x)));

String checkinToJson(List<Checkin> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Checkin {
  Checkin({
    this.checkinid,
    this.name,
    this.dateStart,
    this.dateEnd,
    this.status,
    this.file,
    this.latitude,
    this.longitude,
  });

  int checkinid;
  String name;
  DateTime dateStart;
  dynamic dateEnd;
  int status;
  String file;
  String latitude;
  String longitude;

  factory Checkin.fromJson(Map<String, dynamic> json) => Checkin(
    checkinid: json["checkinid"],
    name: json["name"],
    dateStart: DateTime.parse(json["date_start"]),
    dateEnd: json["date_end"],
    status: json["status"],
    file: json["file"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "checkinid": checkinid,
    "name": name,
    "date_start": dateStart.toIso8601String(),
    "date_end": dateEnd,
    "status": status,
    "file": file,
    "latitude": latitude,
    "longitude": longitude,
  };
}
