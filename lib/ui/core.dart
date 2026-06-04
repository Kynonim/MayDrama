import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UI {
  static void go(BuildContext context, Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => widget));
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

  static viewDramaDescription({
    required BuildContext context
  }) {

  }
}