import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.id}, ${widget.currentEpsIndex}, ${widget.totalEpsIndex}"),
      ),
    );
  }
}