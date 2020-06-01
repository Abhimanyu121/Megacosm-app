import 'dart:async';
import 'package:floor/floor.dart';
import 'package:bluzelle/DBUtils/NetworkModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
part 'DBHelper.g.dart';
@Database(version: 1, entities: [Network])
abstract class AppDatabase extends FloorDatabase {
  NetworkDao get networkDao;
}