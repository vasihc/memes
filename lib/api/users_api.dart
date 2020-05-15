import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memes/database/database_hepler.dart';
import 'package:memes/database/model/user.dart';
import 'package:memes/constants/api.dart';

void createOrUpdate(Map usr) async {
  var db = new DatabaseHelper();
  var user = await db.getUserByLogin(usr["login"]);
  if (user != null) {
    db.updateUser(new User.fromMap(usr));
  } else {
    db.saveUser(new User.fromMap(usr));
  }
}

Future<bool> signIn(String login, String password) async {
  var usr = {'login': login.toString(), 'password': password.toString()};
  final response = await http.post(Uri.https(BASE_URL, SIGN_IN), body: usr);

  if (response.statusCode == 200) {
    var token =
        json.decode(response.body)["message"]["password_digest"].toString();
    usr["token"] = token;
    createOrUpdate(usr);
    return true;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    // throw Exception('Failed to sign in');
    return false;
  }
}

Future<bool> signUp(String login, String password) async {
  var usr = {'login': login.toString(), 'password': password.toString()};
  print(usr);
  final response = await http.post(Uri.https(BASE_URL, SIGN_UP), body: usr);

  if (response.statusCode == 200) {
    var token =
        json.decode(response.body)["message"]["password_digest"].toString();
    usr["token"] = token;
    print(usr);
    createOrUpdate(usr);
    return true;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    // throw Exception('Failed to sign up');
    return false;
  }
}
