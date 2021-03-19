// To parse this JSON data, do
//
//     final historycin = historycinFromJson(jsonString);

import 'dart:convert';

List<Historycin> historycinFromJson(String str) => List<Historycin>.from(json.decode(str).map((x) => Historycin.fromJson(x)));

String historycinToJson(List<Historycin> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Historycin {
  Historycin({
    this.checkinid,
    this.name,
    this.dateStart,
    this.dateEnd,
  });

  int checkinid;
  String name;
  DateTime dateStart;
  DateTime dateEnd;

  factory Historycin.fromJson(Map<String, dynamic> json) => Historycin(
    checkinid: json["checkinid"],
    name: json["name"],
    dateStart: DateTime.parse(json["date_start"]),
    dateEnd: DateTime.parse(json["date_end"]),
  );

  Map<String, dynamic> toJson() => {
    "checkinid": checkinid,
    "name": name,
    "date_start": dateStart.toIso8601String(),
    "date_end": dateEnd.toIso8601String(),
  };
}
