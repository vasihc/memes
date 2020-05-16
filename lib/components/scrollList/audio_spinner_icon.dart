import 'package:flutter/material.dart';

Widget audioSpinner() {
  return Container();
}

LinearGradient get audioDiscGradient => LinearGradient(colors: [
      Colors.grey[800],
      Colors.grey[900],
      Colors.grey[900],
      Colors.grey[800]
    ], stops: [
      0.0,
      0.4,
      0.6,
      1.0
    ], begin: Alignment.bottomLeft, end: Alignment.topRight);
