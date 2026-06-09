import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const accessKey = "kynonim_maydrama_access_token";
const appPlatforms = "https://api.dramabuzz.sbs/api/status?key=";

class ApiService {
  String appPlatformUrl(String token) => "$appPlatforms$token";

  Future<String> loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessKey) ?? "null";
  }

  Future<bool> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(accessKey, token);
  }

  Future<T> fetchData<T>(String apiUrl) async {
    final url = Uri.parse(apiUrl);
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as T;
      } else {
        throw Exception("failed_load_data. code: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("an_error_occurred: $e");
    }
  }
}

// bypas ssl
class MayHttpBypass extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context) // not safe
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}