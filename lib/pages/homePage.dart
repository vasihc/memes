import 'package:flutter/material.dart';
import 'package:memes/widgets/swipeList.dart';
// import 'package:memes/widgets/scrollList.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:memes/components/face_recognition/face_detection_camera.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   bool scrollList = true;

  _sendFeedback() async {
    const url = 'mailto:vasihc@gmail.com?subject=Memes%20feedback';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: Icon(Icons.person, color: Colors.grey)),
        title: Switch(
          onChanged: (bool value) => setState(() => scrollList = value),
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
      body: scrollList ? FaceDetectionFromLiveCamera() : SwipeList(context),
    );
  }
}