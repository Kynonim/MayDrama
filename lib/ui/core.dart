import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maydrama/app/play.dart';
import 'package:maydrama/utils/keys.dart';

class UI {
  static void go(BuildContext context, Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => widget));
  }

  static void back(BuildContext context) {
    Navigator.pop(context);
  }
}

class MayCoreWidget {
  static Widget viewDramaCard({
    required Widget goToWidget,
    required BuildContext context,
    required String imageCoverUrl,
    String likeCount = "0",
    String label = "MayDrama",
    String title = "<untitled>"
  }) {
    return GestureDetector(
      onTap: () => UI.go(context, goToWidget),
      child: ClipRRect(
        borderRadius: .circular(8),
        child: Container(
          color: Theme.of(context).cardColor,
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: imageCoverUrl,
                  fit: .cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.broken_image, color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      begin: .topCenter,
                      end: .bottomCenter,
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const .symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: .circular(12),
                  ),
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(likeCount, style: const TextStyle(fontSize: 11, fontWeight: .bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const .symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: .circular(12),
                  ),
                  child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: .bold, color: Colors.yellowAccent)),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: .ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: .bold,
                    color: Colors.white,
                    shadows: [Shadow(offset: Offset(0.5, 0.5), blurRadius: 2.0, color: Colors.black)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget viewDramaDescription(BuildContext context, int appIndex, Map<String, dynamic> data) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final drama = MayNetshort(data: data);
    drama.setDataDesc();

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
                  imageUrl: drama.getImageCover(),
                  fit: .cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        bgColor.withValues(alpha: 0.5),
                        bgColor,
                      ],
                      begin: .topCenter,
                      end: .bottomCenter,
                    )
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  child: IconButton(
                    onPressed: () => UI.back(context),
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
                  drama.getTitle(),
                  style: const TextStyle(fontSize: 24, fontWeight: .bold),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: drama.getLabelList().map((teks) {
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
                  label: const Text("Play", style: TextStyle(fontSize: 20, fontWeight: .bold)),
                  onPressed: () {
                    UI.go(context, MayDramaPlay(
                      id: drama.getId(),
                      title: drama.getTitle(),
                      appIndex: appIndex,
                      currentEpsIndex: 0,
                      totalEpsIndex: drama.getTotalEpisode(),
                    ));
                  },
                  icon: Icon(Icons.play_circle),
                ),
                const SizedBox(height: 15),
                const Text("Sinopsis", style: TextStyle(fontSize: 16, fontWeight: .bold)),
                const SizedBox(height: 6),
                Text(
                  drama.getDescription(),
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
                      child: Text("${drama.getTotalEpisode()} Episode", style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: drama.getTotalEpisode(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.6,
                  ),
                  itemBuilder: (context, index) {
                    //drama.setIndex(index);
                    return InkWell(
                      onTap: () {
                        UI.go(context, MayDramaPlay(
                          id: drama.getId(),
                          title: drama.getTitle(),
                          appIndex: appIndex,
                          currentEpsIndex: index,
                          totalEpsIndex: drama.getTotalEpisode(),
                        ));
                      },
                      borderRadius: .circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: .circular(8),
                          border: .all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                        ),
                        child: ClipRRect(
                          borderRadius: const .vertical(top: .circular(8)),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CachedNetworkImage(
                                  imageUrl: drama.getEpisodeImageCover(index: index),
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
                                left: 8,
                                right: 8,
                                bottom: 8,
                                child: Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: [
                                    Text(
                                      "Episode ${index + 1}",
                                      style: const TextStyle(fontSize: 13, fontWeight: .bold, color: Colors.white),
                                    ),
                                    Icon(Icons.check_circle_outline, size: 14, color: Colors.grey.withValues(alpha: 0.6)),
                                  ],
                                ),
                              ),
                            ],
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
}