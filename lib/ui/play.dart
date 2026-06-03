import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:maydrama/utils/server.dart';
import 'package:video_player/video_player.dart';

class MayDramaPlay extends StatefulWidget {
  final String id, title;
  final int index, currentEpsIndex, totalEpsIndex;

  const MayDramaPlay({
    super.key,
    required this.id,
    required this.title,
    required this.index,
    required this.currentEpsIndex,
    required this.totalEpsIndex
  });

  @override
  State<MayDramaPlay> createState() => MayDramaPlayState();
}

class MayDramaPlayState extends State<MayDramaPlay> {
  late PageController pageController;
  int currentIndex = 0;
  bool isPlayerControlsVisible = true;

  void jumpToEpisode(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut
    );
  }

  void onVideoFinished() {
    if (currentIndex < widget.totalEpsIndex - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.decelerate
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua episode sudah dilihat")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentEpsIndex;
    pageController = PageController(initialPage: widget.currentEpsIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            scrollDirection: .vertical,
            itemCount: widget.totalEpsIndex,
            onPageChanged: (idx) => setState(() => currentIndex = idx),
            itemBuilder: (context, index) {
              return MayVideoPlayer(
                id: widget.id,
                index: widget.index,
                currentIndex: index,
                isActive: index == currentIndex,
                onVideoEnded: onVideoFinished,
                onControlsChnaged: (isVisible) => setState(() => isPlayerControlsVisible = isVisible),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 8,
            child: IgnorePointer(
              ignoring: !isPlayerControlsVisible,
              child: AnimatedOpacity(
                opacity: isPlayerControlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "${widget.title} - Eps ${currentIndex + 1}",
                      style: TextStyle(color: Colors.white, fontWeight: .w400),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 8,
            child: IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: .vertical(top: .circular(20)),
                  ),
                  builder: (context) {
                    return Container(
                      padding: const .all(20),
                      height: 150,
                      child: Column(
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            "${widget.title} - Episode ke ${currentIndex + 1} / ${widget.totalEpsIndex}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: .bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 45,
                            child: ListView.builder(
                              scrollDirection: .horizontal,
                              padding: const .symmetric(horizontal: 16),
                              itemCount: widget.totalEpsIndex,
                              itemBuilder: (context, index) {
                                final isSelected = index == currentIndex;
                                return GestureDetector(
                                  onTap: () => jumpToEpisode(index),
                                  child: Container(
                                    margin: const .symmetric(horizontal: 6),
                                    padding: const .symmetric(horizontal: 18),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                                      borderRadius: .circular(15),
                                    ),
                                    alignment: .center,
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                                        fontWeight: isSelected ? .bold : .normal
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: Icon(Icons.more_horiz, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class MayVideoPlayer extends StatefulWidget {
  final String id;
  final int index, currentIndex;
  final VoidCallback onVideoEnded;
  final Function(bool) onControlsChnaged;
  final bool isActive;

  const MayVideoPlayer({
    super.key,
    required this.id,
    required this.currentIndex,
    required this.index,
    required this.isActive,
    required this.onVideoEnded,
    required this.onControlsChnaged,
  });

  @override
  State<MayVideoPlayer> createState() => MayVideoPlayerState();
}

class MayVideoPlayerState extends State<MayVideoPlayer> {
  final ApiService apiService = ApiService();
  final ServerManager serverManager = ServerManager();

  VideoPlayerController? videoPlayerController;
  Future<void>? futureInitializeVideo;

  List<MaySubtitleItem> subtitleList = [];
  String currentSubtitleText = "";
  Map<String, String> allSubtitle = {};
  String selectedLang = "Off";

  Timer? controlTimer;
  bool isShowControls = true;
  bool isFastForwarding = false;

  @override
  void initState() {
    super.initState();
    futureInitializeVideo = initializeVideo();
  }

  Future<void> initializeVideo() async {
    String token = await serverManager.getAccessToken();
    var res = await apiService.fetchData(serverManager.servers[widget.index].getVideo(
      id: widget.id,
      eps: widget.currentIndex,
      token: token
    ));
    final videoUrl = res["data"]["videoUrl"].toString();

    if (res["data"]["subtitles"] != null) {
      final List<dynamic> subList = res["data"]["subtitles"];
      Map<String, String> tempSubs = {};

      for (var sub in subList) {
        tempSubs[sub["lang"].toString()] = sub["url"].toString();
      }

      setState(() {
        allSubtitle = tempSubs;
        if (allSubtitle.containsKey("id_ID")) {
          selectedLang = "id_ID";
        } else if (allSubtitle.isNotEmpty) {
          selectedLang = allSubtitle.keys.first;
        }
      });
    }

    if (selectedLang != "Off") {
      await fetchAndParseSubtitle(allSubtitle[selectedLang]!);
    }

    final fileInfo = await DefaultCacheManager().getSingleFile(videoUrl);
    videoPlayerController = VideoPlayerController.file(fileInfo);

    await videoPlayerController!.initialize();
    videoPlayerController!.setLooping(false);
    if (widget.isActive && mounted) {
      videoPlayerController!.play();
    }
    videoPlayerController!.addListener(() {
      if (!mounted) return;
      if (videoPlayerController!.value.position >= videoPlayerController!.value.duration && videoPlayerController!.value.duration != Duration.zero && widget.isActive) {
        widget.onVideoEnded();
        return;
      }
      if (selectedLang != "Off" && subtitleList.isNotEmpty) {
        final currentPosition = videoPlayerController!.value.position;
        final matchingSub = subtitleList.firstWhere(
          (sub) => currentPosition >= sub.start && currentPosition <= sub.end,
          orElse: () => MaySubtitleItem(start: Duration.zero, end: Duration.zero, text: ""),
        );
        if (currentSubtitleText != matchingSub.text) {
          setState(() => currentSubtitleText = matchingSub.text);
        }
      } else {
        if (currentSubtitleText.isNotEmpty) {
          setState(() => currentSubtitleText = "");
        }
      }
    });
    if (widget.isActive && mounted) {
      resetControlsTimer();
      widget.onControlsChnaged(true);
    }
    setState(() {});
  }

  Future<void> fetchAndParseSubtitle(String url) async {
    try {
      final data = await apiService.fetchDynamicData(url);
      subtitleList = MaySubtitleVideo.parseSubtitleText(data);
    } catch (e) {
      debugPrint("Failed download subtitle: $e");
      subtitleList = [];
    }
  }

  void changeSubtitleLanguage(String key) async {
    Navigator.pop(context);
    setState(() {
      selectedLang = key;
      currentSubtitleText = "";
      subtitleList = [];
    });
    if (key != "Off") {
      await fetchAndParseSubtitle(allSubtitle[key]!);
    }
  }

  void showSubtitleSelection() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: .min,
            children: [
              Padding(
                padding: const .all(16),
                child: Text(
                  "Pilih Subtitle",
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 16, fontWeight: .bold),
                ),
              ),
              //Divider(color: Theme.of(context).colorScheme.secondary, height: 1),
              ListTile(
                leading: Icon(
                  Icons.subtitles_off,
                  color: selectedLang == "Off" ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.secondary
                ),
                title: Text("Matikan Subtitle (Off)", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                trailing: selectedLang == "Off" ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary) : null,
                onTap: () => changeSubtitleLanguage("Off"),
              ),
              ...allSubtitle.keys.map((key) {
                final isSelected = selectedLang == key;
                String readableLang = key;
                if (key == "id_ID") readableLang = "Bahasa Indonesia";
                if (key == "en_US") readableLang = "English";
                return ListTile(
                  leading: Icon(Icons.subtitles, color: isSelected ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.secondary),
                  title: Text(readableLang, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary)),
                  trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary) : null,
                  onTap: () => changeSubtitleLanguage(key),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void toggleControls() {
    setState(() {
      isShowControls = !isShowControls;
    });
    widget.onControlsChnaged(isShowControls);
    if (isShowControls) resetControlsTimer();
  }

  void resetControlsTimer() {
    controlTimer?.cancel();
    controlTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => isShowControls = false);
        widget.onControlsChnaged(false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MayVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
      if (widget.isActive && !oldWidget.isActive) {
        videoPlayerController!.play();
      } else if (!widget.isActive && oldWidget.isActive) {
        videoPlayerController!.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: futureInitializeVideo,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || videoPlayerController == null || !videoPlayerController!.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          final errMessage = snapshot.error.toString().replaceAll("Exception", "");
          return Center(child: Text("Error: $errMessage", style: TextStyle(color: Colors.white)));
        }
        return GestureDetector(
          onTap: () {
            toggleControls();
            videoPlayerController!.value.isPlaying ? videoPlayerController!.pause() : videoPlayerController!.play();
          },
          onLongPressStart: (details) {
            if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
              videoPlayerController!.setPlaybackSpeed(2.0);
              setState(() {
                isFastForwarding = true;
                isShowControls = false;
              });
            }
          },
          onLongPressEnd: (details) {
            if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
              videoPlayerController!.setPlaybackSpeed(1.0);
              setState(() {
                isFastForwarding = false;
                isShowControls = true;
                resetControlsTimer();
              });
              widget.onControlsChnaged(true);
            }
          },
          child: Container(
            color: Colors.black,
            child: Stack(
              alignment: .center,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: videoPlayerController!.value.aspectRatio,
                    child: VideoPlayer(videoPlayerController!),
                  ),
                ),
                if (isFastForwarding) Positioned(
                  top: 40,
                  child: Container(
                    padding: const .symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: .circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.fast_forward, color: Colors.amber, size: 20),
                        SizedBox(width: 6),
                        Text(
                          "2x Kecepatan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: .bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedLang != "Off" && currentSubtitleText.isNotEmpty) Positioned(
                  bottom: 120,
                  left: 24,
                  right: 24,
                  child: Text(
                    currentSubtitleText,
                    textAlign: .center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: .bold,
                      shadows: [Shadow(offset: Offset(1, 1), blurRadius: 4, color: Colors.black)],
                      height: 1.4,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: IgnorePointer(
                    ignoring: !isShowControls,
                    child: AnimatedOpacity(
                      opacity: isShowControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.black45,
                            child: IconButton(
                              onPressed: () {
                                showSubtitleSelection();
                                controlTimer?.cancel();
                              },
                              icon: Icon(
                                selectedLang == "Off" ? Icons.closed_caption_disabled : Icons.closed_caption,
                                color: selectedLang == "Off" ? Colors.white54 : Colors.yellowAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  ignoring: !isShowControls,
                  child: AnimatedOpacity(
                    opacity: isShowControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: CircleAvatar(
                      backgroundColor: Colors.black45,
                      radius: 35,
                      child: Icon(
                        videoPlayerController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controlTimer?.cancel();
    videoPlayerController?.dispose();
    super.dispose();
  }
}

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
}