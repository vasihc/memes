import 'package:flutter/material.dart';
import 'package:memes/components/scrollList/controls/video_control_action.dart';
import 'package:mixpanel_analytics/mixpanel_analytics.dart';
import 'package:memes/models/meme.dart';
import 'package:flutter_share/flutter_share.dart';

Widget onScreenControls(MixpanelAnalytics _mixPanel, Meme currentMem) {
  like() async {
    await _mixPanel.track(event: 'like_mem', properties: {
      'mem_id': currentMem.id,
      'feed': 'scroll',
      'method': 'button',
    });
  }

  report() async {
     await _mixPanel.track(event: 'report_mem', properties: {
      'mem_id': currentMem.id,
      'feed': 'scroll', 
    });
  }

  Future<void> share() async {
    await _mixPanel
        .track(event: 'share_mem', properties: {'mem_id': currentMem.id});
    await FlutterShare.share(
        title: 'Top Kek memes',
        text: 'Top Kek memes',
        linkUrl: currentMem.fileUrl,
        chooserTitle: 'Memes app');
  }

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
                videoControlAction(
                    icon: Icons.favorite, label: 'like', onPress: like),
                videoControlAction(
                    icon: Icons.report, label: "report", onPress: report),
                videoControlAction(
                    icon: Icons.share,
                    label: "Share",
                    size: 27,
                    onPress: share),
              ],
            ),
          ),
        )
      ],
    ),
  );
}
