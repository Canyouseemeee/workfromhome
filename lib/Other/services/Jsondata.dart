import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workfromhome/Models/Checkin.dart';
import 'package:workfromhome/Models/Historycin.dart';
import 'package:workfromhome/Models/Solvework.dart';
import 'package:workfromhome/Models/Task.dart';
import 'package:workfromhome/Other/constants.dart';

class Jsondata{

  static Future<List<Checkin>> getCheckin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id = sharedPreferences.getString("userid");
    Map data = {'userid': id};
    var jsonData = null;
    const String url = Apiurl+"/api/getcheckin";
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<Checkin> checkins = checkinFromJson(response.body);
          return checkins;
        }
      } else {
        return List<Checkin>();
      }
    } catch (e) {
      return List<Checkin>();
    }
  }

  static Future<List<Checkin>> getHistoryCheckin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id = sharedPreferences.getString("userid");
    Map data = {'userid': id};
    const String url = Apiurl+"/api/history";
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<Checkin> historycin = checkinFromJson(response.body);
          return historycin;
        }
      } else {
        return List<Checkin>();
      }
    } catch (e) {
      return List<Checkin>();
    }
  }

  static Future<List<Task>> getTask() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id = sharedPreferences.getString("userid");
    Map data = {'userid': id};
    var jsonData = null;
    const String url = Apiurl+"/api/gettask";
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<Task> tasks = taskFromJson(response.body);
          return tasks;
        }
      } else {
        return List<Task>();
      }
    } catch (e) {
      return List<Task>();
    }
  }

  static Future<List<Task>> getAssignTask() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id = sharedPreferences.getString("userid");
    Map data = {'userid': id};
    var jsonData = null;
    const String url = Apiurl+"/api/getassigntask";
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<Task> tasks = taskFromJson(response.body);
          return tasks;
        }
      } else {
        return List<Task>();
      }
    } catch (e) {
      return List<Task>();
    }
  }

  static Future<List<Task>> getHistoryAssignTask() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id = sharedPreferences.getString("userid");
    Map data = {'userid': id};
    var jsonData = null;
    const String url = Apiurl+"/api/gethistoryassigntask";
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<Task> tasks = taskFromJson(response.body);
          return tasks;
        }
      } else {
        return List<Task>();
      }
    } catch (e) {
      return List<Task>();
    }
  }

  static Future<List<Solvework>> getHistorysolvework() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id = sharedPreferences.getString("userid");
    Map data = {'userid': id};
    var jsonData = null;
    const String url = Apiurl+"/api/gethistoryassigntask";
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<Solvework> tasks = solveworkFromJson(response.body);
          return tasks;
        }
      } else {
        return List<Solvework>();
      }
    } catch (e) {
      return List<Solvework>();
    }
  }


}