import 'package:flutter/material.dart';
import 'package:maydrama/ui/core.dart';
import 'package:maydrama/utils/server.dart';

class MaySearchDrama extends StatefulWidget {
  final int index;
  const MaySearchDrama({
    super.key,
    required this.index,
  });

  @override
  State<MaySearchDrama> createState() => MaySearchDramaState();
}

class MaySearchDramaState extends State<MaySearchDrama> {
  final ApiService apiService = ApiService();
  final ServerManager serverManager = ServerManager();
  final TextEditingController searchController = TextEditingController();
  bool isSearching = true, isShowRecomendation = false;
  Future<Map<String, dynamic>>? futureSearchData;

  final List<String> searchHistory = [
    "CEO Jatuh Cinta",
    "Romantis",
    "Action",
    "Balas Dendam Istri"
  ];

  Future<void> initializeSearch() async {
    if (searchController.text.isNotEmpty) {
      futureSearchData = apiService.fetchData(serverManager.servers[widget.index].getSearch(query: searchController.text));
    }
  }

  Widget buildSearchHistory() {
    return !isShowRecomendation ? Container(
      padding: const .all(16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text("Pencarian Terakhir", style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    setState(() => searchHistory.clear());
                  },
                  child: Text("Hapus Semua", style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
                )
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: searchHistory.map((text) {
                return InkWell(
                  onTap: () {
                    searchController.text = text;
                    setState(() => isSearching = true);
                  },
                  child: Container(
                    padding: const .symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.4),
                      borderRadius: .circular(16),
                    ),
                    child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 14)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          TextButton(
            onPressed: () => setState(() => isShowRecomendation = !isShowRecomendation),
            child: Container(
              padding: const .symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),
                borderRadius: .circular(16),
              ),
              child: Text("Rekomendasi untukmu", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: .bold)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ) : buildSearchPopular();
  }

  Widget buildSearchPopular() {
    final Future<Map<String, dynamic>> fetchPopularData = apiService.fetchData(serverManager.servers[widget.index].getPopular());
    return MayDramaWidget.mayDramaList(context, fetchPopularData, widget.index);
  }

  Widget buildSearchResult() {
    return MayDramaWidget.mayDramaList(context, futureSearchData, widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
            borderRadius: .circular(24),
          ),
          child: TextField(
            controller: searchController,
            style: TextStyle(fontSize: 15),
            textInputAction: .search,
            onChanged: (value) {
              setState(() => isSearching = value.isNotEmpty);
            },
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                initializeSearch();
                setState(() => searchHistory.add(value));
              }
            },
            decoration: InputDecoration(
              hintText: "Cari drama...",
              hintStyle: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
              border: .none,
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.error, size: 20),
              suffixIcon: isSearching ? IconButton(
                icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.error, size: 18),
                onPressed: () {
                  searchController.clear();
                  setState(() => isSearching = false);
                },
              ) : null,
              contentPadding: const .symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: futureSearchData != null ? buildSearchResult() : buildSearchHistory(),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}