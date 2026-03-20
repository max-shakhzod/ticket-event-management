// ignore_for_file: prefer_conditional_assignment, avoid_print

import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class DBAdmin {
  static final DBAdmin _instance = DBAdmin._();
  DBAdmin._();
  factory DBAdmin() {
    return _instance;
  }

  Database? _myDatabase;

  Future<Database?> _checkDatabase() async {
    if (_myDatabase == null) {
      _myDatabase = await _initDatabase();
    }
    return _myDatabase;
  }

  Future<Database> _initDatabase() async {
    Directory myDirectory = await getApplicationDocumentsDirectory();
    String pathDatabase = join(myDirectory.path, "QrDB.db");
    return await openDatabase(
      pathDatabase,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            "CREATE TABLE QR(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, observation TEXT, url TEXT, datetime TEXT)");
      },
    );
  }

  Future<List<QRModel>> getQRList() async {
    final Database? db = await _checkDatabase();
    List data = await db!.query("QR");
    print(data);
    List<QRModel> qrList = data.map((e) => QRModel.fromJson(e)).toList();
    return qrList;
  }

  Future<int> insertQR(QRModel model) async {
    final Database? db = await _checkDatabase();
    int value = await db!.insert(
      "QR",
      model.toJson(),
    );
    return value;
  }
}
