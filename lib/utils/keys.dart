class MayNetshort {
  dynamic data;
  Map<dynamic, dynamic> currentMap = {};
  MayNetshort({required this.data});

  void setIndex(int index) {
    if (data is List && index < data.length) {
      currentMap = data[index] ?? {};
    } else if (data is Map) {
      currentMap = data;
    }
  }

  void setDataName({String name = "data"}) {
    if (data is Map) {
      data = data[name]?["dataList"]
        ?? data[name]?["searchCodeSearchResult"]
        ?? data[name]?["contentInfos"]
        ?? data;
    }
  }

  void setDataDesc({String name = "data"}) {
    if (data is Map && data.containsKey("shortPlayId")) {
      currentMap = data;
    }
    currentMap = data[name];
  }

  dynamic getValue(String key) {
    if (currentMap.containsKey(key)) {
      return currentMap[key];
    }
    return null;
  }

  String cleanText(String text) {
    return text.replaceAll("<em>", "").replaceAll("</em>", "");
  }

  String getId() => getValue("shortPlayId") ?? "null";
  String getTitle() => cleanText(getValue("shortPlayName") ?? "null");
  String getImageCover() => getValue("shortPlayCover") ?? "null";
  String getLikeCount() => getValue("heatScore") ?? getValue("scoreShow") ?? getValue("heatScoreShow") ?? "null";

  String getLabels() {
    var labelList = getValue("labelNameList");
    if (labelList is List && labelList.isNotEmpty) {
      return cleanText(labelList[0]);
    }
    return cleanText(getValue("scriptName") ?? "MayDrama");
  }

  String getDescription() => cleanText(getValue("shortPlayDescription") ?? "Tidak ada deskripsi");
  List<dynamic> getLabelList() => getValue("shortPlayLabels") ?? ["MayDrama"];
  List<dynamic> getEpisodes() => getValue("shortPlayEpisodeList") ?? [];
  int getTotalEpisode() => getValue("totalEpisode") ?? 0;

  String getEpisodeImageCover({int index = 0}) {
    var episodes = getEpisodes();
    if (episodes.isNotEmpty && index < episodes.length) {
      return episodes[index]["episodeCover"] ?? getValue("shortPlayCover") ?? "null";
    }
    return getValue("shortPlayCover") ?? "null";
  }
}