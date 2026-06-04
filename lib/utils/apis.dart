import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';

const String apiNetshort = "https://netshort.dramabos.online";

class ApisConfig {
  final int id;
  final String baseUrl;
  final bool isActive;
  final String Function({String lang}) getNew;
  final String Function({required String query, String lang, int page}) getSearch;
  final String Function({String lang})? getCategories;
  final String Function({required String id, String lang}) getDescription;
  final String Function({required String id, required int eps, String lang, required String token}) getVideo;
  final String Function({int page, String lang}) getPopular;

  ApisConfig({
    required this.id,
    required this.baseUrl,
    required this.getNew,
    required this.getSearch,
    required this.getDescription,
    required this.getVideo,
    required this.getPopular,
    this.getCategories,
    this.isActive = true,
  });
}

class ApiService {

  Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_key") ?? "null";
  }

  List<ApisConfig> servers = [
    ApisConfig(
      id: 0,
      baseUrl: apiNetshort,
      getNew: ({lang = "in"}) => "$apiNetshort/api/home/1?lang=$lang",
      getSearch: ({lang = "in", page = 1, required query}) => "$apiNetshort/api/search?lang=$lang&q=$query&page=$page",
      getCategories: ({lang = "in"}) => "$apiNetshort/api/categories?lang=$lang",
      getDescription: ({required id, lang = "in"}) => "$apiNetshort/api/drama/$id?lang=$lang",
      getVideo: ({required eps, required id, lang = "in", required token}) => "$apiNetshort/api/watch/$id/$eps?lang=$lang&code=$token",
      getPopular: ({lang = "in", page = 1}) => "$apiNetshort/api/list/$page?lang=$lang",
    ),
  ];

  final List<AppList> appList = [
    AppList(name: "NetShort"),
    AppList(name: "DramaBox", isActive: false),
    AppList(name: "FreeReels", isActive: false),
    AppList(name: "DramaWave", isActive: false)
  ];

  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    final url = Uri.parse(endpoint);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
         return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception("Gagal memmuat data, code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  Future<dynamic> fetchDynamicData(String url) async {
    final uri = Uri.parse(url);
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        return res.body;
      } else {
        throw Exception("Error status code: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}

class AppList {
  final String name;
  final bool isActive;
  AppList({required this.name, this.isActive = true});
}