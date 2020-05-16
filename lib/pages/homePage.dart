import 'package:flutter/material.dart';
// import 'package:memes/database/database_hepler.dart';
// import 'package:memes/database/model/settings.dart';
import 'package:memes/widgets/swipeList.dart';
import 'package:memes/widgets/scrollList.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:memes/components/face_recognition/face_detection_camera.dart';
import 'package:mixpanel_analytics/mixpanel_analytics.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _user$ = StreamController<String>.broadcast();

  MixpanelAnalytics _mixpanel;

  bool scrollList = false;

  @override
  void initState() {
    super.initState();

    _mixpanel = MixpanelAnalytics(
      token: 'e28bf9b75c9895878a9eb63704b1fc92',
      userId$: _user$.stream,
      verbose: true,
      shouldAnonymize: true,
      shaFn: (value) => value,
      onError: (e) => print(e),
    );
  }

  @override
  void dispose() {
    _user$.close();
    super.dispose();
  }

  _sendFeedback() async {
    const url = 'mailto:vasihc@gmail.com?subject=Memes%20feedback';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
    await _mixpanel.track(event: 'send_feedback', properties: null);
  }

  _changeFeedView(bool value) async {
    setState(() => scrollList = value);
    var feed = value ? 'scroll' : 'swipe';
    await _mixpanel.track(
        event: 'change_feed_view',
        properties: {'feed': feed});
    // var db = new DatabaseHelper();
    // var feedValue = await db.getSettingsValue('feed');
    // if (feedValue != null) {
    //    await db.updateSettings(new Settings.fromMap({'key': 'feed', 'value': feed}));
    //   } else {
    //     db.saveSettings(new Settings.fromMap({'key': 'feed', 'value': feed}));
    //   }
  }

  _navigateToProfile() async {
    Navigator.pushNamed(context, '/profile');
    await _mixpanel
        .track(event: 'navigate_profile', properties: {'page': 'home'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: _navigateToProfile,
            icon: Icon(Icons.person, color: Colors.grey)),
        title: Switch(
          onChanged: _changeFeedView,
          value: scrollList,
          activeColor: Colors.orange,
        ),
        actions: <Widget>[
          IconButton(
              onPressed: _sendFeedback,
              icon: Icon(Icons.question_answer, color: Colors.grey)),
        ],
      ),
      backgroundColor: Colors.white,
      body: scrollList ? ScrollList() : SwipeList(context),
    );
  }
}
