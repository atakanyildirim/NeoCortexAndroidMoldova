import 'package:neocortexapp/entities/image.dart';
import 'package:neocortexapp/entities/picture_v1.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DbHelper {
  static final DbHelper _dbHelper = DbHelper._internal();
  String tblProduct = "product";
  String colId = "id";
  String colName = "name";
  String colVersion = "version";

  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  static Database? _db;
  Future<Database?> get db async {
    _db ??= await initializeDb();
    return _db;
  }

  Future<Database> initializeDb() async {
    //Get path of the directory for android and iOS.
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'neocortex.db');

    //open/create database at a given path
    var cardDatabase = await openDatabase(path, version: 5, onCreate: _createDb);

    return cardDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute("CREATE TABLE product(id INTEGER PRIMARY KEY, name TEXT, version TEXT,fullName TEXT)");
    await db.execute(
        "CREATE TABLE picture( id INTEGER PRIMARY KEY, customerCode TEXT ,imageType INTEGER, image TEXT,orderNumber INTEGER,udate TEXT,status INTEGER)");
  }

  Future<int?> insertTodo(ImageDB product) async {
    Database? db = await this.db;
    var result = await db?.insert(tblProduct, product.toMap());
    return result;
  }

  Future<List<Map<String, Object?>>?> getTodos(String name) async {
    Database? db = await this.db;
    var result = await db?.rawQuery("SELECT * FROM product where name = '$name'");
    return result;
  }

  Future<List<Map<String, Object?>>?> getFull() async {
    Database? db = await this.db;
    var result = await db?.rawQuery("SELECT * FROM product ");
    return result;
  }

  Future<int?> updateTodo(version, id, fullName) async {
    Database? db = await this.db;
    var result = await db?.rawUpdate("update product set version = '$version',fullName= '$fullName'  where id = $id");
    return result;
  }

  Future<int?> deleteTodo(String name) async {
    Database? db = await this.db;
    var result = await db?.delete(tblProduct, where: "$colName = ?", whereArgs: [name]);
    return result;
  }

  Future<int?> insertPicture(PictureV1 picture) async {
    Database? db = await this.db;
    var result = await db?.insert("picture", picture.toMap());
    return result;
  }

  Future<List<Map<String, Object?>>?> getPictures(String customerCode) async {
    Database? db = await this.db;
    var result = await db?.rawQuery("SELECT * FROM picture where customerCode = '$customerCode'");
    return result;
  }

  Future<int?> deletePictures(String image) async {
    Database? db = await this.db;
    var result = await db?.delete("picture", where: "image = ?", whereArgs: [image]);
    return result;
  }

  Future<int?> deleteAllPictures(String customerCode) async {
    Database? db = await this.db;
    var result = await db?.delete("picture", where: "customerCode = ?", whereArgs: [customerCode]);
    return result;
  }
}
