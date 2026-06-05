import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:maydrama/ui/core.dart';
import 'package:maydrama/ui/play.dart';
import 'package:maydrama/utils/apis.dart';
import 'package:maydrama/utils/keys.dart';
import 'package:video_player/video_player.dart';

class MayDramaPlay extends StatefulWidget {
  final String id, title;
  final int appIndex, currentEpsIndex, totalEpsIndex;
  const MayDramaPlay({
    super.key,
    required this.id,
    required this.title,
    required this.appIndex,
    required this.currentEpsIndex,
    required this.totalEpsIndex,
  });

  @override
  State<MayDramaPlay> createState() => MayDramaPlayState();
}

class MayDramaPlayState extends State<MayDramaPlay> {
  late PageController pageController;
  int currentIndex = 0;
  bool isPlayerControlsVisible = true;

  void jumpTpEpisode(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onVidioFinished() {
    if (currentIndex < widget.totalEpsIndex - 1) {
      pageController.nextPage(
        curve: Curves.decelerate,
        duration: const Duration(milliseconds: 500),
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
            onPageChanged: (value) => setState(() => currentIndex = value),
            itemBuilder: (context, index) {
              return MayVideoPlayer(
                id: widget.id,
                appIndex: widget.appIndex,
                currentIndex: index,
                isActive: index == currentIndex,
                onVideoFinished: onVidioFinished,
                onControlsChanged: (visible) => setState(() => isPlayerControlsVisible = visible),
              );
            },
          ),
          Positioned(
            left: 8,
            right: 8,
            top: MediaQuery.of(context).padding.top + 10,
            child: IgnorePointer(
              ignoring: !isPlayerControlsVisible,
              child: AnimatedOpacity(
                opacity: isPlayerControlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => UI.back(context),
                    ),
                    Expanded(
                      child: Text(
                        "${widget.title} - ",
                        overflow: .ellipsis,
                        maxLines: 1,
                        style: const TextStyle(color: Colors.white, fontWeight: .w500),
                      ),
                    ),
                    Text(
                      "Eps ${currentIndex + 1}",
                      maxLines: 1,
                      style: TextStyle(color: Colors.white, fontWeight: .w500),
                    ),
                    IconButton(
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
                                          onTap: () => jumpTpEpisode(index),
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
                                                fontWeight: isSelected ? .bold : .normal,
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
                  ],
                ),
              ),
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
  final int appIndex, currentIndex;
  final VoidCallback onVideoFinished;
  final Function(bool) onControlsChanged;
  final bool isActive;

  const MayVideoPlayer({
    super.key,
    required this.id,
    required this.appIndex,
    required this.currentIndex,
    required this.isActive,
    required this.onControlsChanged,
    required this.onVideoFinished
  });

  @override
  MayVideoPlayerState createState() => MayVideoPlayerState();
}

class MayVideoPlayerState extends State<MayVideoPlayer> {
  final ApiService apiService = ApiService();
  VideoPlayerController? videoController;
  Future<void>? futureInitVideo;

  List<MaySubtitleItem> subtitleList = [];
  Map<String, String> allSubtitles = {};
  String currentSubtitleText = "", selectedLang = "Off";

  Timer? controlTimer;
  bool isShowControls = true, isFastForwarding = false;

  Future<void> initializeVideo() async {
    final token = await apiService.getAccessToken();
    final res = await apiService.fetchData(apiService.servers[widget.appIndex].getVideo(
      id: widget.id,
      eps: widget.currentIndex + 1,
      token: token,
    ));
    final videoUrl = MayNetshort.getVideo(video: res);
    if (MayNetshort.getSubtitlesList(video: res) != null) {
      final List<dynamic> subsList = MayNetshort.getSubtitlesList(video: res);
      Map<String, String> tempSubs = {};
      for (final sub in subsList) {
        tempSubs[sub["lang"].toString()] = sub["url"].toString(); // fix !!!
      }
      setState(() {
        allSubtitles = tempSubs;
        selectedLang = allSubtitles.containsKey("id_ID") ? "id_ID" : allSubtitles.isNotEmpty ? allSubtitles.keys.first : "Off";
      });
    }
    if (selectedLang != "Off") await fetchAndParseSubtitles(allSubtitles[selectedLang]!);

    final fileInfo = await DefaultCacheManager().getSingleFile(videoUrl);
    videoController = VideoPlayerController.file(fileInfo);
    await videoController!.initialize();
    videoController!.setLooping(false);
    if (widget.isActive && mounted) videoController!.play();
    videoController!.addListener(() {
      if (!mounted) return;
      if (videoController!.value.position >= videoController!.value.duration && videoController!.value.duration != Duration.zero && widget.isActive) {
        widget.onVideoFinished();
        return;
      }
      if (selectedLang != "Off" && subtitleList.isNotEmpty) {
        final currentPosition = videoController!.value.position;
        final matchingSubtitle = subtitleList.firstWhere(
          (sub) => currentPosition >= sub.start && currentPosition <= sub.end,
          orElse: () => MaySubtitleItem(start: Duration.zero, end: Duration.zero, text: ""),
        );
        if (currentSubtitleText != matchingSubtitle.text) setState(() => currentSubtitleText = matchingSubtitle.text);
      } else {
        if (currentSubtitleText.isNotEmpty) setState(() => currentSubtitleText = "");
      }
    });
    if (widget.isActive && mounted) {
      resetControlsTimer();
      widget.onControlsChanged(true);
    }
    setState(() {});
  }

  Future<void> fetchAndParseSubtitles(String url) async {
    try {
      final data = await apiService.fetchDynamicData(url);
      subtitleList = MaySubtitleVideo.parseSubtitleText(data);
    } catch (e) {
      subtitleList = [];
      debugPrintStack(label: e.toString());
    }
  }

  void toggleControls() {
    setState(() => isShowControls = !isShowControls);
    widget.onControlsChanged(isShowControls);
    if (isShowControls) resetControlsTimer();
  }

  void resetControlsTimer() {
    controlTimer?.cancel();
    controlTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => isShowControls = false);
        widget.onControlsChanged(false);
      }
    });
  }

  void changeSubtitleLanguage({String key = "Off"}) async {
    UI.back(context);
    setState(() {
      selectedLang = key;
      currentSubtitleText = "";
      subtitleList = [];
    });
    if (key != "Off") await fetchAndParseSubtitles(allSubtitles[key]!);
  }

  void showSubtitlesSelection() {
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
              ListTile(
                leading: Icon(
                  Icons.subtitles_off,
                  color: selectedLang == "Off" ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.secondary,
                ),
                title: Text("Default (Off)", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                trailing: selectedLang == "Off" ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary) : null,
                onTap: () => changeSubtitleLanguage(),
              ),
              ...allSubtitles.keys.map((key) {
                final isSelected = selectedLang == key;
                String readableLang = key == "id_ID" ? "Bahasa Indonesia"
                  : key == "en_US" ? "English"
                  : key == "zh_CN" ? "中国語" : key;
                return ListTile(
                  leading: Icon(Icons.subtitles, color: isSelected ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.secondary),
                  title: Text(readableLang, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary)),
                  trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary) : null,
                  onTap: () => changeSubtitleLanguage(key: key),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget buildVideoPlayer() {
    return GestureDetector(
      onTap: () {
        toggleControls();
        videoController!.value.isPlaying ? videoController!.pause() : videoController!.play();
      },
      onLongPressStart: (details) {
        if (videoController != null && videoController!.value.isInitialized) {
          videoController!.setPlaybackSpeed(2.0);
          setState(() {
            isFastForwarding = true;
            isShowControls = false;
          });
        }
      },
      onLongPressEnd: (details) {
        if (videoController != null && videoController!.value.isInitialized) {
          videoController!.setPlaybackSpeed(1.0);
          setState(() {
            isFastForwarding = false;
            isShowControls = true;
            resetControlsTimer();
          });
          widget.onControlsChanged(true);
        }
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: .center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: videoController!.value.aspectRatio,
                child: VideoPlayer(videoController!),
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
                    Text("2x Kecepatan", style: const TextStyle(color: Colors.white, fontWeight: .bold, fontSize: 14)),
                  ],
                ),
              ),
            ),
            if (selectedLang != "Off" && currentSubtitleText.isNotEmpty) Positioned(
              left: 24,
              right: 24,
              bottom: 120,
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
              bottom: 32,
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
                            showSubtitlesSelection();
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
                    videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: IgnorePointer(
                ignoring: !isShowControls,
                child: AnimatedOpacity(
                  opacity: isShowControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: .start,
                        children: [
                          Text(
                            MaySubtitleVideo.formatDuration(videoController!.value.position),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(" / ", style: const TextStyle(fontWeight: .bold)),
                          Text(
                            MaySubtitleVideo.formatDuration(videoController!.value.duration),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        behavior: .opaque,
                        onHorizontalDragStart: (details) => controlTimer?.cancel(),
                        onHorizontalDragEnd: (details) => resetControlsTimer(),
                        child: VideoProgressIndicator(
                          videoController!,
                          allowScrubbing: true,
                          padding: const .symmetric(vertical: 8),
                          colors: VideoProgressColors(
                            playedColor: Theme.of(context).colorScheme.primary,
                            bufferedColor: Colors.white24,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    futureInitVideo = initializeVideo();
  }

  @override
  void didUpdateWidget(covariant MayVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (videoController != null && videoController!.value.isInitialized) {
      if (widget.isActive && !oldWidget.isActive) {
        videoController!.play();
      } else if (!widget.isActive && oldWidget.isActive){
        videoController!.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureInitVideo,
      builder: (context, snapshot) {
        return snapshot.connectionState == ConnectionState.waiting || videoController == null || !videoController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator()) : snapshot.hasError
          ? Center(child: Text(snapshot.error.toString())) : snapshot.hasData
          ? buildVideoPlayer() : const Center(child: Text("Tidak ada data"));
      },
    );
  }

  @override
  void dispose() {
    controlTimer?.cancel();
    videoController?.dispose();
    super.dispose();
  }
}