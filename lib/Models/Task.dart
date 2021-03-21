// To parse this JSON data, do
//
//     final task = taskFromJson(jsonString);

import 'dart:convert';

List<Task> taskFromJson(String str) => List<Task>.from(json.decode(str).map((x) => Task.fromJson(x)));

String taskToJson(List<Task> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Task {
  Task({
    this.taskid,
    this.createtask,
    this.subject,
    this.description,
    this.statustaskid,
    this.departmentid,
    this.dmname,
    this.assignment,
    this.name,
    this.file,
    this.assignDate,
    this.dueDate,
  });

  int taskid;
  String createtask;
  String subject;
  String description;
  int statustaskid;
  String assignment;
  int departmentid;
  String dmname;
  String name;
  dynamic file;
  DateTime assignDate;
  DateTime dueDate;

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    taskid: json["taskid"],
    createtask: json["createtask"],
    subject: json["subject"],
    description: json["description"],
    statustaskid: json["statustaskid"],
    departmentid: json["departmentid"],
    dmname: json["dmname"],
    assignment: json["assignment"],
    name: json["name"],
    file: json["file"],
    assignDate: DateTime.parse(json["assign_date"]),
    dueDate: DateTime.parse(json["due_date"]),
  );

  Map<String, dynamic> toJson() => {
    "taskid": taskid,
    "createtask": createtask,
    "subject": subject,
    "description": description,
    "statustaskid": statustaskid,
    "departmentid": departmentid,
    "dmname": dmname,
    "assignment": assignment,
    "name": name,
    "file": file,
    "assign_date": assignDate.toIso8601String(),
    "due_date": dueDate.toIso8601String(),
  };
}
