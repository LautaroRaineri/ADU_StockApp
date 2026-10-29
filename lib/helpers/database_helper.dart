import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventario.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        cantidad TEXT NOT NULL
      )
    ''');
  }

  // Insertar producto
  Future<int> insertProduct(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('productos', row);
  }

  // Obtener todos los productos
  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await instance.database;
    return await db.query('productos', orderBy: 'id DESC');
  }

  // Eliminar producto por ID
  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }
}