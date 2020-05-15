import 'package:flutter/material.dart';
import 'package:memes/database/database_hepler.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String login = 'login';

  @override
  void initState() {
    super.initState();

    // getUser().then((user) {
    //   setState(() {
    //     login = user.name
    //   });
    // });
  }

  Widget _userLogin() {
    return Container(child: Text('Login:'));
  }

  Widget _logout() {
    return Container(
        child: FloatingActionButton(
      child: Text('Logout'),
      onPressed: () {
        // var user =await getUser();
        // deleteUser(user);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(children: <Widget>[
        _logout(),
        _userLogin(),
      ])),
    );
  }
}
