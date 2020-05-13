import 'package:flutter/material.dart';
import 'package:memes/animations/spinner_animation.dart';
import 'package:memes/components/scrollList/audio_spinner_icon.dart';
import 'package:memes/components/scrollList/controls/video_control_action.dart';

Widget onScreenControls() {
  return Container(
    child: Row(
      children: <Widget>[
        // Expanded(flex: 5, child: videoDesc()),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.only(bottom: 60, right: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                videoControlAction(icon: Icons.favorite, label: 'like'),
                videoControlAction(icon: Icons.report, label: "report"),
                videoControlAction(
                    icon: Icons.share, label: "Share", size: 27),
                SpinnerAnimation(body: audioSpinner())
              ],
            ),
          ),
        )
      ],
    ),
  );
}
