import 'package:flutter/material.dart';
import 'package:memes/models/meme.dart';

class ScrollCard extends StatelessWidget {
  final Meme meme;
  ScrollCard(this.meme);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.network(this.meme.fileUrl),
    );
  }
}
