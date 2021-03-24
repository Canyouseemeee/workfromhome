// To parse this JSON data, do
//
//     final solvework = solveworkFromJson(jsonString);

import 'dart:convert';

List<Solvework> solveworkFromJson(String str) => List<Solvework>.from(json.decode(str).map((x) => Solvework.fromJson(x)));

String solveworkToJson(List<Solvework> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Solvework {
  Solvework({
    this.solveworkid,
    this.taskid,
    this.createsolvework,
    this.subject,
    this.statussolveworkid,
    this.departmentid,
    this.dmname,
    this.assignment,
    this.name,
    this.file,
    this.assignDate,
    this.dueDate,
    this.closeDate,
  });

  int solveworkid;
  int taskid;
  String createsolvework;
  String subject;
  int statussolveworkid;
  int departmentid;
  String dmname;
  String assignment;
  String name;
  dynamic file;
  DateTime assignDate;
  DateTime dueDate;
  dynamic closeDate;

  factory Solvework.fromJson(Map<String, dynamic> json) => Solvework(
    solveworkid: json["solveworkid"],
    taskid: json["taskid"],
    createsolvework: json["createsolvework"],
    subject: json["subject"],
    statussolveworkid: json["statussolveworkid"],
    departmentid: json["departmentid"],
    dmname: json["dmname"],
    assignment: json["assignment"],
    name: json["name"],
    file: json["file"],
    assignDate: DateTime.parse(json["assign_date"]),
    dueDate: DateTime.parse(json["due_date"]),
    closeDate: json["close_date"],
  );

  Map<String, dynamic> toJson() => {
    "solveworkid": solveworkid,
    "taskid": taskid,
    "createsolvework": createsolvework,
    "subject": subject,
    "statussolveworkid": statussolveworkid,
    "departmentid": departmentid,
    "dmname": dmname,
    "assignment": assignment,
    "name": name,
    "file": file,
    "assign_date": assignDate.toIso8601String(),
    "due_date": dueDate.toIso8601String(),
    "close_date": closeDate,
  };
}
