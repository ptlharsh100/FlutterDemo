import 'dart:io';
import 'package:mydemoapp/userdata.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:path/path.dart';


final String tableWords = 'words';
final String columnId = '_id';
final String columnWord = 'word';
final String columnFrequency = 'frequency';

class DatabaseHelper {
  String tableName = 'TableNotes';
  String id = 'id';
  String email = 'email';
  String firstName = 'first_name';
  String lastName = 'last_name';

  static DatabaseHelper databaseHelper;
  static Database _database;
  DatabaseHelper._createInstance();
  factory DatabaseHelper() {
    if (databaseHelper == null) {
      databaseHelper = DatabaseHelper._createInstance();
    }
    return databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initlizeDatabase();
    }
    return _database;
  }

  Future<Database> initlizeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';
    var noteDatabase =
        await openDatabase(path, version: 1, onCreate: _createDB);
    return noteDatabase;
  }

  void _createDB(Database db, int newVesrion) async {
    await db.execute(
        'CREATE TABLE $tableName($id INTEGER PRIMARY KEY AUTOINCREMENT, $email TEXT, $firstName TEXT,$lastName TEXT)');
  }

  Future<List<Map<String, dynamic>>> getUserMapList() async {
    Database db = await this.database;
    var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<UserData>> getUserList() async {
    var userMapList = await getUserMapList();
    int count = userMapList.length;
    List<UserData> userList = List<UserData>();
    for (int i = 0; i < count; i++) {
      UserData user = UserData(
          id: userMapList[i]['id'],
          email: userMapList[i]['email'],
          firstName: userMapList[i]['first_name'],
          lastName: userMapList[i]['last_name']);

      userList.add(user);
    }
    return userList;
  }

  Future<int> insertUser(UserData user) async {
    Database db = await this.database;
    var result = await db.insert(tableName, user.toMap());
    return result;
  }

  Future<int> deleteUser(int noteid) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $tableName WHERE $id = $id');
    return result;
  }

  Future<int> updateUser(UserData user) async {
    var db = await this.database;
    var result = await db.update(tableName, user.toMap(),
        where: '$id = ?', whereArgs: [user.id]);
    return result;
  }
}