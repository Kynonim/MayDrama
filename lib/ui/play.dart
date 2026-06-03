import 'package:flutter/foundation.dart';
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
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  "${widget.title} - Eps ${currentIndex + 1}"
                )
              ],
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
  final bool isActive;

  const MayVideoPlayer({
    super.key,
    required this.id,
    required this.currentIndex,
    required this.index,
    required this.isActive,
    required this.onVideoEnded
  });

  @override
  State<MayVideoPlayer> createState() => MayVideoPlayerState();
}

class MayVideoPlayerState extends State<MayVideoPlayer> {
  final ApiService apiService = ApiService();
  final ServerManager serverManager = ServerManager();

  VideoPlayerController? videoPlayerController;
  Future<void>? futureInitializeVideo;

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
    final fileInfo = await DefaultCacheManager().getSingleFile(videoUrl);
    videoPlayerController = VideoPlayerController.file(fileInfo);

    await videoPlayerController!.initialize();
    videoPlayerController!.setLooping(false);
    if (widget.isActive && mounted) {
      videoPlayerController!.play();
    }
    videoPlayerController!.addListener(() {
      if (videoPlayerController!.value.position >= videoPlayerController!.value.duration && videoPlayerController!.value.duration != Duration.zero && widget.isActive && mounted) {
        widget.onVideoEnded();
      }
    });
    setState(() {});
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
          onTap: () => videoPlayerController!.value.isPlaying ? videoPlayerController!.pause() : videoPlayerController!.play(),
          child: Container(
            color: Colors.black,
            alignment: .center,
            child: AspectRatio(
              aspectRatio: videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(videoPlayerController!),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }
}