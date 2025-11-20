import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for Windows/Linux/macOS
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;

    // On Windows, use AppData directory instead of getDatabasesPath()
    // to avoid permission issues in Program Files
    if (Platform.isWindows) {
      final appDataEnv = Platform.environment['APPDATA'];
      if (appDataEnv == null) {
        throw Exception('APPDATA environment variable not found');
      }
      dbPath = join(appDataEnv, 'CashMemo');
      // Create directory if it doesn't exist
      final dir = Directory(dbPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      dbPath = await getDatabasesPath();
    }

    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE ${AppConstants.productsTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        unit TEXT NOT NULL,
        stock_quantity INTEGER NOT NULL,
        barcode TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE ${AppConstants.customersTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Cash Memos table
    await db.execute('''
      CREATE TABLE ${AppConstants.cashMemosTable} (
        id TEXT PRIMARY KEY,
        memo_number TEXT NOT NULL UNIQUE,
        date TEXT NOT NULL,
        customer_id TEXT,
        customer_name TEXT,
        customer_phone TEXT,
        customer_address TEXT,
        subtotal REAL NOT NULL,
        discount REAL NOT NULL DEFAULT 0,
        tax REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Cash Memo Items table
    await db.execute('''
      CREATE TABLE ${AppConstants.cashMemoItemsTable} (
        id TEXT PRIMARY KEY,
        cash_memo_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        price REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (cash_memo_id) REFERENCES ${AppConstants.cashMemosTable} (id) ON DELETE CASCADE
      )
    ''');

    // Shop Settings table
    await db.execute('''
      CREATE TABLE ${AppConstants.shopSettingsTable} (
        id TEXT PRIMARY KEY,
        shop_name TEXT NOT NULL,
        tagline TEXT,
        address TEXT,
        website TEXT,
        terms TEXT,
        phone TEXT,
        email TEXT,
        gst_number TEXT,
        logo_path TEXT,
        invoice_by_name TEXT,
        invoice_by_role TEXT,
        invoice_by_contact TEXT
      )
    ''');

    // Insert default shop settings
    await db.insert(AppConstants.shopSettingsTable, {
      'id': '1',
      'shop_name': 'My Grocery Shop',
      'tagline': '',
      'address': '',
      'website': '',
      'terms': '',
      'phone': '',
      'email': '',
      'gst_number': '',
      'logo_path': null,
      'invoice_by_name': '',
      'invoice_by_role': '',
      'invoice_by_contact': '',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Upgrade from v1 to v2: Add new columns to shop_settings table
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${AppConstants.shopSettingsTable} ADD COLUMN tagline TEXT',
      );
      await db.execute(
        'ALTER TABLE ${AppConstants.shopSettingsTable} ADD COLUMN website TEXT',
      );
      await db.execute(
        'ALTER TABLE ${AppConstants.shopSettingsTable} ADD COLUMN terms TEXT',
      );
      await db.execute(
        'ALTER TABLE ${AppConstants.shopSettingsTable} ADD COLUMN invoice_by_name TEXT',
      );
      await db.execute(
        'ALTER TABLE ${AppConstants.shopSettingsTable} ADD COLUMN invoice_by_role TEXT',
      );
      await db.execute(
        'ALTER TABLE ${AppConstants.shopSettingsTable} ADD COLUMN invoice_by_contact TEXT',
      );
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
