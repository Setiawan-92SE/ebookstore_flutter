import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:ebookstore/database/database.helper.dart';
import 'book_form_screen.dart';
import 'book_detail_screen.dart';

/// Layar Daftar Buku — menampilkan seluruh data dari database (Cursor → ListView)
/// Setara dengan tampilan tabel di slide "Tampilan Utama"
class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final _dbHelper = DatabaseHelper();
  final _searchCtrl = TextEditingController();

  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = true;
  String _selectedKategori = 'Semua';

  final List<String> _kategoriFilter = [
    'Semua',
    'Fiksi',
    'Non-Fiksi',
    'Pengembangan Diri',
    'Teknologi',
    'Bisnis',
    'Sains',
    'Sejarah',
    'Agama',
  ];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Load semua buku (getReadableDatabase + Query) ────────────────────────
  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      // Query — mengambil data dari database (Cursor)
      final books = await _dbHelper.getAllBooks();
      setState(() {
        _books = books;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data: $e', isSuccess: false);
    }
  }

  // ─── Filter & Search ──────────────────────────────────────────────────────
  void _applyFilter() {
    final keyword = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filteredBooks = _books.where((book) {
        final matchKategori =
            _selectedKategori == 'Semua' || book.kategori == _selectedKategori;
        final matchSearch =
            keyword.isEmpty ||
            book.judul.toLowerCase().contains(keyword) ||
            book.penulis.toLowerCase().contains(keyword);
        return matchKategori && matchSearch;
      }).toList();
    });
  }

  // ─── Navigasi ke form Tambah ──────────────────────────────────────────────
  Future<void> _tambahBuku() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const BookFormScreen()),
    );
    if (result == true) _loadBooks(); // Refresh setelah insert
  }

  // ─── Navigasi ke form Ubah ────────────────────────────────────────────────
  Future<void> _ubahBuku(Book book) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => BookFormScreen(book: book)),
    );
    if (result == true) _loadBooks(); // Refresh setelah update/delete
  }

  // ─── Hapus cepat via swipe ────────────────────────────────────────────────
  Future<void> _hapusBuku(Book book) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Hapus Buku', style: TextStyle(color: Colors.white)),
        content: Text(
          'Hapus "${book.judul}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    // DELETE — menghapus baris dari database
    final result = await _dbHelper.deleteBook(book.id!);
    if (result > 0) {
      _showSnackBar('Buku dihapus!', isSuccess: true);
      _loadBooks();
    }
  }

  void _showSnackBar(String msg, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? const Color(0xFFB8973A) : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
        ],
        body: Column(
          children: [
            _buildSearchBar(),
            _buildKategoriFilter(),
            Expanded(child: _buildBookList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahBuku,
        backgroundColor: const Color(0xFFB8973A),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah Buku',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0F0F0F),
      expandedHeight: 120,
      floating: true,
      snap: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Katalog Buku',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1500), Color(0xFF0F0F0F)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => _applyFilter(),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari judul buku atau penulis...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFB8973A)),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white38),
                  onPressed: () {
                    _searchCtrl.clear();
                    _applyFilter();
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB8973A)),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildKategoriFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _kategoriFilter.length,
        itemBuilder: (context, index) {
          final kategori = _kategoriFilter[index];
          final isSelected = _selectedKategori == kategori;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(
                kategori,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedKategori = kategori);
                _applyFilter();
              },
              backgroundColor: const Color(0xFF1E1E1E),
              selectedColor: const Color(0xFFB8973A),
              checkmarkColor: Colors.black,
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFB8973A)),
      );
    }

    if (_filteredBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 12),
            Text(
              _books.isEmpty
                  ? 'Belum ada buku.\nTambahkan buku pertama Anda!'
                  : 'Tidak ada hasil untuk pencarian ini.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBooks,
      color: const Color(0xFFB8973A),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _filteredBooks.length,
        itemBuilder: (context, index) {
          return _buildBookCard(_filteredBooks[index]);
        },
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    return Dismissible(
      key: Key('book_${book.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white),
            Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        await _hapusBuku(book);
        return false; // Handled manually via _loadBooks()
      },
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailScreen(book: book, onUpdate: _loadBooks),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              // Cover placeholder
              Container(
                width: 80,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getCoverColors(book.kategori),
                  ),
                ),
                child: Center(
                  child: Text(
                    book.judul.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
              ),
              // Info buku
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.judul,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.penulis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB8973A).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFB8973A).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              book.kategori,
                              style: const TextStyle(
                                color: Color(0xFFB8973A),
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Rp ${book.harga.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFB8973A),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stok: ${book.stok}',
                        style: TextStyle(
                          color: book.stok > 0 ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Tombol Edit
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white38),
                onPressed: () => _ubahBuku(book),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getCoverColors(String kategori) {
    switch (kategori) {
      case 'Fiksi':
        return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
      case 'Non-Fiksi':
        return [const Color(0xFF2E7D32), const Color(0xFF66BB6A)];
      case 'Pengembangan Diri':
        return [const Color(0xFFB8973A), const Color(0xFFFFD54F)];
      case 'Teknologi':
        return [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)];
      case 'Bisnis':
        return [const Color(0xFF880E4F), const Color(0xFFEC407A)];
      default:
        return [const Color(0xFF37474F), const Color(0xFF78909C)];
    }
  }
}
