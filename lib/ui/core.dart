import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maydrama/ui/play.dart';
import 'package:maydrama/utils/server.dart';

class MayDrama extends StatefulWidget {
  final int index;
  const MayDrama({super.key, required this.index});

  @override
  State<MayDrama> createState() => MayDramaState();
}

class MayDramaState extends State<MayDrama> {

  bool isLoading = true;
  String get appName => ServerManager().appList[widget.index].name;

  final ApiService apiService = ApiService();
  final ServerManager serverManager = ServerManager();
  late Future<Map<String, dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = apiService.fetchData(serverManager.servers[widget.index].getRecomendation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
        actions: [
          IconButton(
            onPressed: () {
              //search
            },
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          } else if (snap.hasData) {
            var data = snap.data!;
            List<dynamic> drama = data["data"]["contentInfos"];
            if (drama.isEmpty) {
              return const Center(child: Text("Tidak ada drama yang tersedia !"));
            }
            return GridView.builder(
              padding: const .all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // jumlah kolom
                crossAxisSpacing: 12, // jarak horizontal
                mainAxisSpacing: 12, // jarak vertical
                childAspectRatio: 0.64 // rasio w.h
              ),
              itemCount: drama.length,
              itemBuilder: (context, index) {
                final title = drama[index]["shortPlayName"].toString();
                final thumbnail = drama[index]["shortPlayCover"].toString();
                final likeCount = drama[index]["heatScoreShow"].toString();
                final type = drama[index]["scriptName"].toString();
                final id = drama[index]["shortPlayId"].toString();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => MayDescription(id: id, index: widget.index)));
                  },
                  child: ClipRRect(
                    borderRadius: .circular(8),
                    child: Container(
                      color: Theme.of(context).cardColor,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: thumbnail,
                              fit: .cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.6),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.85)
                                  ],
                                  begin: .topCenter,
                                  end: .bottomCenter,
                                  stops: const [0.0, 0.4, 1.0] //titik gradient
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: .symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: .circular(12)
                              ),
                              child: Row(
                                mainAxisSize: .min,
                                children: [
                                  const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                                  const SizedBox(width: 4),
                                  Text(likeCount, style: TextStyle(fontSize: 11, fontWeight: .bold, color: Colors.white))
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: .symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: .circular(12)
                              ),
                              child: Text(type, style: TextStyle(fontSize: 11, fontWeight: .bold, color: Colors.yellowAccent)),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: .ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: .bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(offset: Offset(0.5, 0.5), blurRadius: 2.0, color: Colors.black)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Tidak ada data"));
        },
      ),
    );
  }
}

class MayDescription extends StatefulWidget {
  final String id;
  final int index;
  const MayDescription({super.key, required this.id, required this.index});

  @override
  State<MayDescription> createState() => MayDescriptionState();
}

class MayDescriptionState extends State<MayDescription> {
  final ApiService apiService = ApiService();
  final ServerManager serverManager = ServerManager();
  late Future<Map<String, dynamic>> futureData;

  @override
  void initState() {
    futureData = apiService.fetchData(serverManager.servers[widget.index].getDescription(id: widget.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            final data = snapshot.data!["data"];
            final id = data["shortPlayId"].toString();
            final title = data["shortPlayName"].toString();
            final thumbnail = data["shortPlayCover"].toString();
            final List<dynamic> label = data["shortPlayLabels"];
            final List<dynamic> eps = data["shortPlayEpisodeList"];
            final int totalEps = data["totalEpisode"];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 350,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: thumbnail,
                          fit: .cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: .topCenter,
                              end: .bottomCenter,
                              colors: [
                                Colors.transparent,
                                bgColor.withValues(alpha: 0.5),
                                bgColor
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const .symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 24, fontWeight: .bold),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: label.map((teks) {
                            return Container(
                              padding: const .symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: .circular(20),
                                border: .all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                teks,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: .w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          label: Text("Play", style: const TextStyle(fontSize: 18, fontWeight: .bold)),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (ctx) => MayDramaPlay(
                              id: id,
                              title: title,
                              index: widget.index,
                              currentEpsIndex: 0,
                              totalEpsIndex: eps.length,
                            )));
                          },
                          icon: Icon(Icons.play_circle),
                        ),
                        const SizedBox(height: 15),
                        const Text("Sinposis", style: TextStyle(fontSize: 16, fontWeight: .bold)),
                        const SizedBox(height: 6),
                        Text(
                          data["shortPlayDescription"] ?? "Tidak ada deskripsi",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            const Text("Daftar Episode", style: TextStyle(fontSize: 16, fontWeight: .bold)),
                            Container(
                              padding: const .symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: .circular(20),
                                border: .all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                              ),
                              child: Text("$totalEps Episode", style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: eps.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.6
                          ),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (ctx) => MayDramaPlay(
                                  id: id,
                                  title: title,
                                  index: widget.index,
                                  currentEpsIndex: index,
                                  totalEpsIndex: eps.length,
                                )));
                              },
                              borderRadius: .circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: .circular(8),
                                  border: .all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                                ),
                                child:
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const .vertical(top: .circular(8)),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: CachedNetworkImage(
                                            imageUrl: eps[index]["episodeCover"] ?? data["shortPlayCover"],
                                            fit: .cover,
                                            placeholder: (context, url) => const Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 20),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Container(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            child: const Icon(
                                              Icons.play_circle,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          right: 8,
                                          child: Row(
                                            mainAxisAlignment: .spaceBetween,
                                            children: [
                                              Text(
                                                "Episode ${index + 1}",
                                                style: const TextStyle(fontSize: 13, fontWeight: .bold),
                                              ),
                                              Icon(Icons.check_circle_outline, size: 14, color: Colors.grey.withValues(alpha: 0.6)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("Tidak ada data"));
        },
      ),
    );
  }
}