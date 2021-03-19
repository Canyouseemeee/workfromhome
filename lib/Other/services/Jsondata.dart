import 'package:http/http.dart' as http;
import 'package:workfromhome/Models/Checkin.dart';
import 'package:workfromhome/Models/Historycin.dart';
import 'package:workfromhome/Other/constants.dart';

class Jsondata{

  static Future<List<Checkin>> getCheckin() async {
    const String url = Apiurl+"/api/getcheckin";
    try {
      final response = await http.get(url);
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
    const String url = Apiurl+"/api/history";
    try {
      final response = await http.get(url);
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

}