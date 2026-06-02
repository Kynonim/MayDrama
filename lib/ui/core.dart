import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          } else if (snap.hasData) {
            var data = snap.data!;
            List<dynamic> drama = data["data"]["contentInfos"];
            if (drama.isEmpty) {
              return const Center(child: Text("Tidak ada drama yang tersedia !"));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // jumlah kolom
                crossAxisSpacing: 12, // jarak horizontal
                mainAxisSpacing: 12, // jarak vertical
                childAspectRatio: 0.64 // rasio w.h
              ),
              itemCount: drama.length,
              itemBuilder: (context, index) {
                String title = drama[index]["shortPlayName"].toString();
                String thumbnail = drama[index]["shortPlayCover"].toString();

                return GestureDetector(
                  onTap: () {
                    // tap
                  },
                  child: ClipRRect(
                    borderRadius: .circular(8),
                    child: Container(
                      color: Colors.grey[900],
                      child: Column(
                        crossAxisAlignment: .stretch,
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: thumbnail,
                              fit: .cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: .ellipsis,
                              style: const TextStyle(fontSize: 14, fontWeight: .bold),
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