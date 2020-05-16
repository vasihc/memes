import 'package:flutter/material.dart';

Widget videoControlAction(
    {IconData icon, String label, double size = 35, Function onPress}) {
  return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
              size: size,
            ),
          ],
        ),
        onPressed: onPress,
      ));
}
