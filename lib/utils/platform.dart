import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const supportPlatform = "kynonim_maydrama_support_platform";

class AppPlatforms {
  static List<AppPlatformModels> supportPlatformDefault() {
    return [
      AppPlatformModels(
        id: "netshort",
        name: "NetShort",
        status: PlatformStatusType.active,
        url: "https://netshort.dramabos.online",
        logo: "https://api.dramabuzz.sbs/logos/netshort.svg",
        isSupport: true,
      ),
      AppPlatformModels(
        id: "dramabite",
        name: "DramaBite",
        status: PlatformStatusType.active,
        url: "https://dramabite.dramabos.online",
        logo: "https://api.dramabuzz.sbs/logos/dramabite.svg",
        isSupport: true,
      ),
      AppPlatformModels(
        id: "netshort",
        name: "NetShort",
        status: PlatformStatusType.active,
        url: "https://netshort.dramabos.online",
        logo: "https://api.dramabuzz.sbs/logos/netshort.svg",
        isSupport: true,
      ),
      AppPlatformModels(
        id: "netshort",
        name: "NetShort",
        status: PlatformStatusType.active,
        url: "https://netshort.dramabos.online",
        logo: "https://api.dramabuzz.sbs/logos/netshort.svg",
        isSupport: true,
      ),
      AppPlatformModels(
        id: "netshort",
        name: "NetShort",
        status: PlatformStatusType.active,
        url: "https://netshort.dramabos.online",
        logo: "https://api.dramabuzz.sbs/logos/netshort.svg",
        isSupport: true,
      ),
    ];
  }

  static bool checkIfSupport(String id) {
    return supportPlatformDefault().any((platform) {
      return platform.id.isNotEmpty && platform.id.toLowerCase() == id.toLowerCase();
    });
  }

  static Future<List<AppPlatformModels>> loadSupportPlatform() async {
    final prefs = await SharedPreferences.getInstance();
    final platform = prefs.getString(supportPlatform);
    if (platform == null || platform.isEmpty) {
      return [];
    }
    final decode = jsonDecode(platform) as List<dynamic>;
    return decode.cast<AppPlatformModels>();
  }

  static Future<bool> saveSupportPlatform(List<AppPlatformModels> listPlatform) async {
    final prefs = await SharedPreferences.getInstance();
    final platform = jsonEncode(listPlatform);
    return await prefs.setString(supportPlatform, platform);
  }

  static String formatUrl(String url) {
    if (url.isEmpty) return "";

    final uri = Uri.parse(url);
    return uri.origin;
  }
}

class AppPlatformModels {
  final bool isSupport;
  final String id, name, url, logo;
  final PlatformStatusType status;

  AppPlatformModels({
    required this.id,
    required this.name,
    required this.status,
    required this.url,
    required this.logo,
    required this.isSupport,
  });

  factory AppPlatformModels.fromJson(dynamic data) {
    return AppPlatformModels(
      id: data["id"],
      name: data["name"],
      status: data["status"] == "active" ? PlatformStatusType.active : PlatformStatusType.maintenance,
      url: AppPlatforms.formatUrl(data["api"]),
      logo: data["logo"],
      isSupport: AppPlatforms.checkIfSupport(data["id"]),
    );
  }
}

enum PlatformStatusType { active, maintenance }