import 'package:flutter/material.dart';
import 'package:memes/widgets/welcomePage.dart';
import 'package:memes/widgets/settingsPage.dart';
import 'package:memes/database/database_hepler.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isSignIn = false;
  @override
  void initState() {
    super.initState();

    getToken().then((token) {
      setState(() {
        isSignIn = token != null;
      });
    });
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
          child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Material(
            child: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.transparent,
          ),
        )),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: _backButton(),
      ),
      backgroundColor: Colors.white,
      body: isSignIn ? SettingsPage() : WelcomePage(),
    );
  }
}
