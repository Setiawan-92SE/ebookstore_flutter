import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String _dbName = 'ebookstore.db';
  static const int _dbVersion = 2;

  static const String tableBooks = 'books';
  static const String colId = 'id';
  static const String colJudul = 'judul';
  static const String colPenulis = 'penulis';
  static const String colKategori = 'kategori';
  static const String colHarga = 'harga';
  static const String colDeskripsi = 'deskripsi';
  static const String colCoverUrl = 'cover_url';
  static const String colStok = 'stok';
  static const String colSellerId = 'seller_id';
  static const String colStatusBuku = 'status';

  static const String tableUsers = 'users';
  static const String colName = 'name';
  static const String colEmail = 'email';
  static const String colPassword = 'password';
  static const String colRole = 'role';
  static const String colCreatedAt = 'created_at';

  static const String tableCart = 'cart';
  static const String colUserId = 'user_id';
  static const String colBookId = 'book_id';
  static const String colQuantity = 'quantity';

  static const String tableOrders = 'orders';
  static const String colTotal = 'total';
  static const String colStatusOrder = 'status';
  static const String colOrderDate = 'order_date';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableBooks (
        $colId       INTEGER PRIMARY KEY AUTOINCREMENT,
        $colJudul    TEXT    NOT NULL,
        $colPenulis  TEXT    NOT NULL,
        $colKategori TEXT    NOT NULL,
        $colHarga    REAL    NOT NULL DEFAULT 0,
        $colDeskripsi TEXT  NOT NULL,
        $colCoverUrl TEXT,
        $colStok     INTEGER NOT NULL DEFAULT 0,
        $colSellerId INTEGER,
        $colStatusBuku TEXT DEFAULT 'approved'
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableUsers (
        $colId       INTEGER PRIMARY KEY AUTOINCREMENT,
        $colName     TEXT    NOT NULL,
        $colEmail    TEXT    NOT NULL UNIQUE,
        $colPassword TEXT    NOT NULL,
        $colRole     TEXT    NOT NULL,
        $colCreatedAt TEXT   NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCart (
        $colId       INTEGER PRIMARY KEY AUTOINCREMENT,
        $colUserId   INTEGER NOT NULL,
        $colBookId   INTEGER NOT NULL,
        $colQuantity INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY ($colUserId) REFERENCES $tableUsers($colId),
        FOREIGN KEY ($colBookId) REFERENCES $tableBooks($colId)
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrders (
        $colId       INTEGER PRIMARY KEY AUTOINCREMENT,
        $colUserId   INTEGER NOT NULL,
        $colBookId   INTEGER NOT NULL,
        $colQuantity INTEGER NOT NULL,
        $colTotal    REAL    NOT NULL,
        $colStatusOrder TEXT NOT NULL DEFAULT 'pending',
        $colOrderDate  TEXT    NOT NULL,
        FOREIGN KEY ($colUserId) REFERENCES $tableUsers($colId),
        FOREIGN KEY ($colBookId) REFERENCES $tableBooks($colId)
      )
    ''');

    await _insertSeedAdmin(db);
    await _insertSeedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableBooks ADD COLUMN $colSellerId INTEGER',
      );
      await db.execute(
        "ALTER TABLE $tableBooks ADD COLUMN $colStatusBuku TEXT DEFAULT 'approved'",
      );
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableUsers (
          $colId       INTEGER PRIMARY KEY AUTOINCREMENT,
          $colName     TEXT    NOT NULL,
          $colEmail    TEXT    NOT NULL UNIQUE,
          $colPassword TEXT    NOT NULL,
          $colRole     TEXT    NOT NULL,
          $colCreatedAt TEXT   NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableCart (
          $colId       INTEGER PRIMARY KEY AUTOINCREMENT,
          $colUserId   INTEGER NOT NULL,
          $colBookId   INTEGER NOT NULL,
          $colQuantity INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY ($colUserId) REFERENCES $tableUsers($colId),
          FOREIGN KEY ($colBookId) REFERENCES $tableBooks($colId)
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableOrders (
          $colId       INTEGER PRIMARY KEY AUTOINCREMENT,
          $colUserId   INTEGER NOT NULL,
          $colBookId   INTEGER NOT NULL,
          $colQuantity INTEGER NOT NULL,
          $colTotal    REAL    NOT NULL,
          $colStatusOrder TEXT NOT NULL DEFAULT 'pending',
          $colOrderDate  TEXT    NOT NULL,
          FOREIGN KEY ($colUserId) REFERENCES $tableUsers($colId),
          FOREIGN KEY ($colBookId) REFERENCES $tableBooks($colId)
        )
      ''');
      await _insertSeedAdmin(db);
    }
  }

  Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _insertSeedAdmin(Database db) async {
    await db.insert(tableUsers, {
      colName: 'Admin',
      colEmail: 'admin@ebookstore.com',
      colPassword: 'admin123',
      colRole: 'admin',
      colCreatedAt: DateTime.now().toIso8601String(),
    });
  }

  // ─── Seed data awal ───────────────────────────────────────────────────────
  Future<void> _insertSeedData(Database db) async {
    final List<Map<String, dynamic>> seedBooks = [
      {
        colJudul: 'Laskar Pelangi',
        colPenulis: 'Andrea Hirata',
        colKategori: 'Fiksi',
        colHarga: 85000.0,
        colDeskripsi:
            'Novel tentang semangat anak-anak Belitung mengejar mimpi.',
        colCoverUrl: null,
        colStok: 50,
      },
      {
        colJudul: 'Atomic Habits',
        colPenulis: 'James Clear',
        colKategori: 'Pengembangan Diri',
        colHarga: 120000.0,
        colDeskripsi:
            'Cara membangun kebiasaan baik dan menghilangkan kebiasaan buruk.',
        colCoverUrl: null,
        colStok: 30,
      },
      {
        colJudul: 'Sapiens',
        colPenulis: 'Yuval Noah Harari',
        colKategori: 'Non-Fiksi',
        colHarga: 135000.0,
        colDeskripsi:
            'Sejarah singkat umat manusia dari zaman purba hingga kini.',
        colCoverUrl: null,
        colStok: 25,
      },
    ];

    for (final book in seedBooks) {
      await db.insert(tableBooks, book);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CRUD OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  // ─── CREATE — Insert() ────────────────────────────────────────────────────
  /// Menambahkan buku baru ke database.
  /// Mengembalikan ID baris yang baru dimasukkan.
  Future<int> insertBook(Book book) async {
    final db = await database; // getWritableDatabase()
    final map = book.toMap()..remove('id'); // id di-auto-generate
    return await db.insert(
      tableBooks,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── READ — Query semua buku ──────────────────────────────────────────────
  /// Mengambil seluruh data buku (Cursor → List<Book>)
  Future<List<Book>> getAllBooks() async {
    final db = await database; // getReadableDatabase()
    final List<Map<String, dynamic>> maps = await db.query(
      tableBooks,
      orderBy: '$colJudul ASC',
    );
    // Cursor: konversi setiap baris map ke objek Book
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  // ─── READ — Query buku berdasarkan ID ────────────────────────────────────
  Future<Book?> getBookById(int id) async {
    final db = await database;
    final maps = await db.query(
      tableBooks,
      where: '$colId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Book.fromMap(maps.first);
  }

  // ─── READ — Pencarian buku ────────────────────────────────────────────────
  /// Mencari buku berdasarkan judul atau nama penulis (LIKE query)
  Future<List<Book>> searchBooks(String keyword) async {
    final db = await database;
    final maps = await db.query(
      tableBooks,
      where: '$colJudul LIKE ? OR $colPenulis LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: '$colJudul ASC',
    );
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  // ─── READ — Filter berdasarkan kategori ──────────────────────────────────
  Future<List<Book>> getBooksByKategori(String kategori) async {
    final db = await database;
    final maps = await db.query(
      tableBooks,
      where: '$colKategori = ?',
      whereArgs: [kategori],
      orderBy: '$colJudul ASC',
    );
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  // ─── UPDATE — Update() ────────────────────────────────────────────────────
  /// Memperbarui data buku berdasarkan ID.
  /// Mengembalikan jumlah baris yang diperbarui.
  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update(
      tableBooks,
      book.toMap(),
      where: '$colId = ?',
      whereArgs: [book.id],
    );
  }

  // ─── UPDATE — Perbarui stok saja ─────────────────────────────────────────
  Future<int> updateStok(int id, int stokBaru) async {
    final db = await database;
    return await db.update(
      tableBooks,
      {colStok: stokBaru},
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // ─── DELETE — Delete() ────────────────────────────────────────────────────
  /// Menghapus buku berdasarkan ID.
  /// Mengembalikan jumlah baris yang dihapus.
  Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete(tableBooks, where: '$colId = ?', whereArgs: [id]);
  }

  // ─── DELETE — Hapus semua data ────────────────────────────────────────────
  Future<int> deleteAllBooks() async {
    final db = await database;
    return await db.delete(tableBooks);
  }

  // ─── execSQL — Raw SQL ────────────────────────────────────────────────────
  /// Mengeksekusi sintaks SQL secara langsung (setara execSQL di Android)
  Future<void> execRawSQL(String sql) async {
    final db = await database;
    await db.execute(sql);
  }

  // ─── Count ────────────────────────────────────────────────────────────────
  Future<int> countBooks() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $tableBooks',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // USER OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<int> insertUser(User user) async {
    final db = await database;
    final map = user.toMap()..remove('id');
    return await db.insert(tableUsers, map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> loginUser(String email, String password) async {
    final db = await database;
    final maps = await db.query(
      tableUsers,
      where: '$colEmail = ? AND $colPassword = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      tableUsers,
      where: '$colEmail = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query(tableUsers, orderBy: '$colCreatedAt DESC');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<List<User>> getUsersByRole(String role) async {
    final db = await database;
    final maps = await db.query(
      tableUsers,
      where: '$colRole = ?',
      whereArgs: [role],
      orderBy: '$colName ASC',
    );
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(tableUsers, where: '$colId = ?', whereArgs: [id]);
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      tableUsers,
      user.toMap(),
      where: '$colId = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> countUsersByRole(String role) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $tableUsers WHERE $colRole = ?',
      [role],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CART OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<int> addToCart(int userId, int bookId, int quantity) async {
    final db = await database;
    final existing = await db.query(
      tableCart,
      where: '$colUserId = ? AND $colBookId = ?',
      whereArgs: [userId, bookId],
    );
    if (existing.isNotEmpty) {
      final currentQty = existing.first[colQuantity] as int;
      return await db.update(
        tableCart,
        {colQuantity: currentQty + quantity},
        where: '$colUserId = ? AND $colBookId = ?',
        whereArgs: [userId, bookId],
      );
    }
    return await db.insert(tableCart, {
      colUserId: userId,
      colBookId: bookId,
      colQuantity: quantity,
    });
  }

  Future<List<Map<String, dynamic>>> getCartWithBooks(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.$colId as cart_id, c.$colQuantity, b.*
      FROM $tableCart c
      INNER JOIN $tableBooks b ON c.$colBookId = b.$colId
      WHERE c.$colUserId = ?
    ''', [userId]);
  }

  Future<int> updateCartQuantity(int cartId, int quantity) async {
    final db = await database;
    return await db.update(
      tableCart,
      {colQuantity: quantity},
      where: '$colId = ?',
      whereArgs: [cartId],
    );
  }

  Future<int> removeFromCart(int cartId) async {
    final db = await database;
    return await db.delete(tableCart, where: '$colId = ?', whereArgs: [cartId]);
  }

  Future<int> clearCart(int userId) async {
    final db = await database;
    return await db.delete(tableCart, where: '$colUserId = ?', whereArgs: [userId]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDER OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<int> createOrder(int userId, int bookId, int quantity, double total) async {
    final db = await database;
    return await db.insert(tableOrders, {
      colUserId: userId,
      colBookId: bookId,
      colQuantity: quantity,
      colTotal: total,
      colStatusOrder: 'pending',
      colOrderDate: DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getOrdersByBuyer(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT o.*, b.$colJudul, b.$colCoverUrl
      FROM $tableOrders o
      INNER JOIN $tableBooks b ON o.$colBookId = b.$colId
      WHERE o.$colUserId = ?
      ORDER BY o.$colOrderDate DESC
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getOrdersForSeller(int sellerId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT o.*, b.$colJudul, u.$colName as buyer_name
      FROM $tableOrders o
      INNER JOIN $tableBooks b ON o.$colBookId = b.$colId
      INNER JOIN $tableUsers u ON o.$colUserId = u.$colId
      WHERE b.$colSellerId = ?
      ORDER BY o.$colOrderDate DESC
    ''', [sellerId]);
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT o.*, b.$colJudul, u.$colName as buyer_name
      FROM $tableOrders o
      INNER JOIN $tableBooks b ON o.$colBookId = b.$colId
      INNER JOIN $tableUsers u ON o.$colUserId = u.$colId
      ORDER BY o.$colOrderDate DESC
    ''');
  }

  Future<int> updateOrderStatus(int orderId, String status) async {
    final db = await database;
    return await db.update(
      tableOrders,
      {colStatusOrder: status},
      where: '$colId = ?',
      whereArgs: [orderId],
    );
  }

  Future<double> getTotalEarnings(int sellerId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(o.$colTotal), 0) as total
      FROM $tableOrders o
      INNER JOIN $tableBooks b ON o.$colBookId = b.$colId
      WHERE b.$colSellerId = ? AND o.$colStatusOrder = 'completed'
    ''', [sellerId]);
    return (result.first['total'] as num).toDouble();
  }

  Future<int> countOrdersByStatus(String status) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $tableOrders WHERE $colStatusOrder = ?',
      [status],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countBooksByStatus(String status) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $tableBooks WHERE $colStatusBuku = ?',
      [status],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalUsersCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM $tableUsers');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Book>> getBooksByStatus(String status) async {
    final db = await database;
    final maps = await db.query(
      tableBooks,
      where: '$colStatusBuku = ?',
      whereArgs: [status],
      orderBy: '$colJudul ASC',
    );
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  Future<int> updateBookStatus(int bookId, String status) async {
    final db = await database;
    return await db.update(
      tableBooks,
      {colStatusBuku: status},
      where: '$colId = ?',
      whereArgs: [bookId],
    );
  }

  Future<int> countAllBooks() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM $tableBooks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
