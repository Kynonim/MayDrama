import 'package:flutter/material.dart';
import 'package:maydrama/utils/server.dart';

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
  final PageController pageController = PageController();
  int currentIndex = 0;

  void jumpToEpisode(int index) {
    setState(() => currentIndex = index);
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
              return VideoPlayer(
                episodeId: widget.id,
                index: widget.index,
                episodeIndex: index,
                onVideoEnded: onVideoFinished,
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Column(
              mainAxisSize: .min,
              children: [
                Text(
                  "Episode ke-${currentIndex + 1}",
                  style: const TextStyle(color: Colors.white, fontWeight: .bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: .horizontal,
                    padding: const .symmetric(horizontal: 16),
                    itemCount: widget.totalEpsIndex,
                    itemBuilder: (ctx, idx) {
                      final isSelected = idx == currentIndex;
                      return GestureDetector(
                        onTap: () => jumpToEpisode(idx),
                        child: Container(
                          margin: const .symmetric(horizontal: 6),
                          padding: const .symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.red : Colors.white24,
                            borderRadius: .circular(25)
                          ),
                          alignment: .center,
                          child: Text(
                            "Eps ${idx + 1}",
                            style: TextStyle(
                              color: Colors.white,
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

class VideoPlayer extends StatefulWidget {
  final String episodeId;
  final int index, episodeIndex;
  final VoidCallback onVideoEnded;

  const VideoPlayer({
    super.key,
    required this.episodeId,
    required this.episodeIndex,
    required this.index,
    required this.onVideoEnded
  });

  @override
  State<VideoPlayer> createState() => VideoPlayerState();
}

class VideoPlayerState extends State<VideoPlayer> {
  final ApiService apiService = ApiService();
  final ServerManager serverManager = ServerManager();
  Future<Map<String, dynamic>>? episodeVideoData;

  String token = "null";

  @override
  void initState() {
    super.initState();
    episodeVideoData = initializeData();
  }

  Future<Map<String, dynamic>> initializeData() async {
    token = await serverManager.getAccessToken();
    if (token == "null" || token.isEmpty) {
      throw Exception("Access Key belum diisi atau tidak valid");
    }
    return apiService.fetchData(serverManager.servers[widget.index].getVideo(
      id: widget.episodeId,
      eps: widget.episodeIndex,
      token: token
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: episodeVideoData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          final errMessage = snapshot.error.toString().replaceAll("Exception", "");
          return Center(child: Text("Error: $errMessage"));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          return Text("$data");
        }
        return const Center(child: Text("Tidak ada data"));
      },
    );
  }
}