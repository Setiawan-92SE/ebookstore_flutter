import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

/// DatabaseHelper — setara dengan SQLiteOpenHelper di Android
/// Menyediakan: onCreate(), onUpgrade(), getWritableDatabase(),
/// getReadableDatabase(), serta operasi CRUD (Insert, Update, Delete, Query)
class DatabaseHelper {
  // Singleton pattern agar hanya ada 1 instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Konfigurasi database — tersimpan otomatis di path internal aplikasi
  // Setara dengan: data/data/nama_package/database/nama_database
  static const String _dbName = 'ebookstore.db';
  static const int _dbVersion = 1;

  // Nama tabel & kolom
  static const String tableBooks = 'books';
  static const String colId = 'id';
  static const String colJudul = 'judul';
  static const String colPenulis = 'penulis';
  static const String colKategori = 'kategori';
  static const String colHarga = 'harga';
  static const String colDeskripsi = 'deskripsi';
  static const String colCoverUrl = 'cover_url';
  static const String colStok = 'stok';

  // ─── getWritableDatabase / getReadableDatabase ───────────────────────────
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // ─── Inisialisasi database ────────────────────────────────────────────────
  Future<Database> _initDatabase() async {
    // Path: data/data/<package>/databases/ebookstore.db
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate, // Dipanggil jika belum ada database
      onUpgrade: _onUpgrade, // Dipanggil jika versi database berubah
      onOpen: _onOpen, // Dipanggil jika database sudah terbuka
    );
  }

  // ─── onCreate() — buat tabel saat pertama kali ───────────────────────────
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
        $colStok     INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Seed data awal
    await _insertSeedData(db);
  }

  // ─── onUpgrade() — ubah skema jika versi beda ────────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Contoh: jika upgrade dari v1 ke v2, tambah kolom baru
    if (oldVersion < 2) {
      // await db.execute('ALTER TABLE $tableBooks ADD COLUMN rating REAL DEFAULT 0');
    }
    // Strategi sederhana: drop & recreate (gunakan hanya untuk development)
    // await db.execute('DROP TABLE IF EXISTS $tableBooks');
    // await _onCreate(db, newVersion);
  }

  // ─── onOpen() — dipanggil saat database sudah terbuka ────────────────────
  Future<void> _onOpen(Database db) async {
    // Aktifkan foreign keys jika dibutuhkan
    await db.execute('PRAGMA foreign_keys = ON');
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

  // ─── Tutup database ───────────────────────────────────────────────────────
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
