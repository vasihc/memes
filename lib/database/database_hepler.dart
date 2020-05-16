import 'dart:async';
import 'dart:io' as io;
import 'package:memes/database/model/settings.dart';
import 'package:memes/database/model/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute("CREATE TABLE User(login TEXT PRIMARY KEY, token TEXT)");
  }

  Future<int> saveUser(User user) async {
    var dbClient = await db;
    int res = await dbClient.insert("User", user.toMap());
    return res;
  }

  Future<int> saveSettings(Settings settings) async {
    var dbClient = await db;
    int res = await dbClient.insert("Settings", settings.toMap());
    return res;
  }

  Future<User> getUser() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM User');
    if (list.length > 0) {
      return new User.fromMap(list[0]);
    } else {
      return null;
    }
  }

  Future<Settings> getSettings() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Settings');
    if (list.length > 0) {
      return new Settings.fromMap(list[0]);
    } else {
      return null;
    }
  }

  Future<User> getUserByLogin(String login) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM User WHERE login = ?', [login]);
    if (list.length > 0) {
      return new User.fromMap(list[0]);
    } else {
      return null;
    }
  }

  Future<Settings> getSettingsValue(String key) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Settings WHERE key = ?', [key]);
    if (list.length > 0) {
      return new Settings.fromMap(list[0]);
    } else {
      return null;
    }
  }

  Future<int> deleteUsers() async {
    var dbClient = await db;

    int res = await dbClient.delete('User');
    return res;
  }

  Future<bool> updateUser(User user) async {
    var dbClient = await db;

    int res = await dbClient.update("User", user.toMap(),
        where: "login = ?", whereArgs: <String>[user.login]);

    return res > 0 ? true : false;
  }

  Future<bool> updateSettings(Settings settings) async {
    var dbClient = await db;

    int res = await dbClient.update("Settings", settings.toMap(),
        where: "key = ?", whereArgs: <String>[settings.key]);

    return res > 0 ? true : false;
  }
}

Future<String> getToken() async {
  var db = new DatabaseHelper();
  var user = await db.getUser();
  return user != null ? user.token : null;
}
