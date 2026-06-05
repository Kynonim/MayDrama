import 'package:flutter/material.dart';

class MaySubtitleItem {
  final Duration start;
  final Duration end;
  final String text;

  MaySubtitleItem({required this.start, required this.end, required this.text});
}

class MaySubtitleVideo {
  static List<MaySubtitleItem> parseSubtitleText(String text) {
    final List<MaySubtitleItem> list = [];
    final blocks = text.replaceAll("\r", "").split(RegExp(r'\n\s*\n'));

    for (var block in blocks) {
      final lines = block.split("\n").where((ls) => ls.trim().isNotEmpty).toList();
      if (lines.isEmpty) continue;
      if (lines.first.trim().startsWith("WEBVTT")) continue;

      String timeLine = "";
      String textLine = "";

      //times
      for (var line in lines) {
        if (line.contains("-->")) {
          timeLine = line;
          final currentIndex = lines.indexOf(line);
          textLine = lines.sublist(currentIndex + 1).join("\n");
          break;
        }
      }

      if (timeLine.isNotEmpty && textLine.isNotEmpty) {
        final times = timeLine.split("-->");
        if (times.length == 2) {
          try {
            final start = parseDuration(times[0].trim());
            final end = parseDuration(times[1].trim());
            list.add(MaySubtitleItem(start: start, end: end, text: textLine.trim()));
          } catch (e) {
            debugPrint("Failed parsing: $timeLine, error: $e");
          }
        }
      }
    }
    return list;
  }

  static Duration parseDuration(String input) {
    final parts = input.split(":");
    int hours = 0, minutes = 0, seconds = 0, miliseconds = 0;
    if (parts.length == 3) {
      //format default hh:mm:ss.mmm
      hours = int.parse(parts[0]);
      minutes = int.parse(parts[1]);

      final secParts = parts[2].split(".");
      seconds = int.parse(secParts[0]);
      if (secParts.length > 1) miliseconds = int.parse(secParts[1].padRight(3, "0").substring(0, 3));
    } else if (parts.length == 2) {
      //format optional mm:ss.mmm
      minutes= int.parse(parts[0]);

      final secParts = parts[1].split(".");
      seconds = int.parse(secParts[0]);
      if (secParts.length > 1) miliseconds = int.parse(secParts[1].padRight(3, "0").substring(0, 3));
    }
    return Duration(hours: hours, minutes: minutes, seconds: seconds, milliseconds: miliseconds);
  }

  static String formatDuration(Duration duration) {
    String digits(int n) => n.toString().padLeft(2, "0");
    String digitMinutes = digits(duration.inMinutes.remainder(60));
    String digitSeconds = digits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${digits(duration.inHours)}:$digitMinutes:$digitSeconds";
    }
    return "$digitMinutes:$digitSeconds";
  }
}