import 'package:flutter/material.dart';
import 'package:maydrama/app/search.dart';
import 'package:maydrama/ui/core.dart';
import 'package:maydrama/utils/apis.dart';
import 'package:maydrama/utils/keys.dart';

class MayDrama extends StatefulWidget {
  final int appIndex;
  const MayDrama({super.key, required this.appIndex});

  @override
  State<MayDrama> createState() => MayDramaState();
}

class MayDramaState extends State<MayDrama> {
  final ApiService apiService = ApiService();
  Future<Map<String, dynamic>>? futureData;
  Future<Map<String, dynamic>> initFetchData() async => apiService.fetchData(apiService.servers[widget.appIndex].getPopular());

  @override
  void initState() {
    super.initState();
    futureData = initFetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(apiService.appList[widget.appIndex].name),
        actions: [
          IconButton(
            onPressed: () => UI.go(context, MaySearchDrama(appIndex: widget.appIndex)),
            icon: Icon(Icons.search_sharp),
          ),
        ],
      ),
      body: FutureBuilder(
        future: futureData,
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator()) : snapshot.hasError
            ? Center(child: Text(snapshot.error.toString())) : snapshot.hasData
            ? viewData(context, snapshot.data!) : const Center(child: Text("Tidak ada data"));
        },
      ),
    );
  }

  Widget viewData(BuildContext context, Map<String, dynamic> data) {
    final drama = MayNetshort(data: data);
    drama.setDataName();

    return drama.data.isNotEmpty ? GridView.builder(
      padding: const .all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // jumlah kolom
        crossAxisSpacing: 12, // jarak horizontal
        mainAxisSpacing: 12, // jarak vertical
        childAspectRatio: 0.64, // rasio w/h
      ),
      itemCount: drama.data.length,
      itemBuilder: (context, index) {
        drama.setIndex(index);
        return MayCoreWidget.viewDramaCard(
          context: context,
          goToWidget: MayDramaDescription(appIndex: widget.appIndex, dramaId: drama.getId()),
          imageCoverUrl: drama.getImageCover(),
          likeCount: drama.getLikeCount(),
          title: drama.getTitle(),
          label: drama.getLabels(),
        );
      },
    ) : const Center(child: Text("Tidak ada drama yang tersedia!"));
  }
}

class MayDramaDescription extends StatefulWidget {
  final String dramaId;
  final int appIndex;
  const MayDramaDescription({super.key, required this.appIndex, required this.dramaId});

  @override
  State<MayDramaDescription> createState() => MayDramaDescriptionState();
}

class MayDramaDescriptionState extends State<MayDramaDescription> {
  final ApiService apiService = ApiService();
  Future<Map<String, dynamic>>? futureDescriptionData;
  Future<Map<String, dynamic>> initFetchDescriptionData() async => apiService.fetchData(apiService.servers[widget.appIndex].getDescription(id: widget.dramaId));

  @override
  void initState() {
    super.initState();
    futureDescriptionData = initFetchDescriptionData();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(
        title: Text("Desc"),
      ),
    );
  }
}