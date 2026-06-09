import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maydrama/utils/platform.dart';

Widget buildAppPlatformsList(BuildContext context, List<AppPlatformModels> list) {
  if (list.isEmpty) return const Center(child: Text("Tidak ada platforms"));

  return ListView.builder(
    scrollDirection: .vertical,
    itemCount: list.length,
    itemBuilder: (context, index) {
      return Card(
        margin: const .symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          title: Text(list[index].name, style: TextStyle(fontSize: 18)),
          leading: CircleAvatar(
            child: ClipOval(
              child: AppPlatforms.checkIsSVG(list[index].logo) ? SvgPicture.network(
                list[index].logo,
                fit: .cover,
                placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
                errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
              ) : CachedNetworkImage(
                imageUrl: list[index].logo,
                fit: .cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.broken_image),
              ),
            ),
          ),
          subtitle: Text(
            list[index].status == PlatformStatusType.active ? "Active" : "Maintenance",
            style: TextStyle(color: list[index].status == PlatformStatusType.active ? Colors.green : Colors.amber),
          ),
          tileColor: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: .circular(16),
          ),
          trailing: Icon(list[index].isSupport ? Icons.check_circle : null),
          hoverColor: Theme.of(context).colorScheme.surface,
        ),
      );
    },
  );
}