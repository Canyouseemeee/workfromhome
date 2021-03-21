// To parse this JSON data, do
//
//     final department = departmentFromJson(jsonString);

import 'dart:convert';

List<Department> departmentFromJson(String str) => List<Department>.from(json.decode(str).map((x) => Department.fromJson(x)));

String departmentToJson(List<Department> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Department {
  Department({
    this.departmentid,
    this.dmname,
  });

  int departmentid;
  String dmname;

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    departmentid: json["departmentid"],
    dmname: json["dmname"],
  );

  Map<String, dynamic> toJson() => {
    "departmentid": departmentid,
    "dmname": dmname,
  };
}
