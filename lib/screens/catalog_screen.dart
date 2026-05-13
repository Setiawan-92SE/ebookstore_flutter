import 'package:flutter/material.dart';
import '../database/database.helper.dart';
import '../models/book.dart';
import '../models/user.dart';
import 'book_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  final User user;
  const CatalogScreen({super.key, required this.user});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _db = DatabaseHelper();
  final _searchCtrl = TextEditingController();
  List<Book> _books = [];
  List<Book> _filtered = [];
  bool _isLoading = true;
  String _selectedKategori = 'Semua';

  final List<String> _kategoriFilter = ['Semua', 'Fiksi', 'Non-Fiksi', 'Pengembangan Diri', 'Teknologi', 'Bisnis', 'Sains', 'Sejarah', 'Agama'];

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

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final books = await _db.getBooksByStatus('approved');
      if (mounted) setState(() { _books = books; _applyFilter(); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    final keyword = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filtered = _books.where((b) {
        final matchKategori = _selectedKategori == 'Semua' || b.kategori == _selectedKategori;
        final matchSearch = keyword.isEmpty || b.judul.toLowerCase().contains(keyword) || b.penulis.toLowerCase().contains(keyword);
        return matchKategori && matchSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildKategoriFilter(),
          Expanded(child: _buildBookList()),
        ],
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
          hintText: 'Cari buku atau penulis...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFB8973A)),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear, color: Colors.white38), onPressed: () { _searchCtrl.clear(); _applyFilter(); })
              : null,
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFB8973A))),
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
              label: Text(kategori, style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              selected: isSelected,
              onSelected: (_) { setState(() => _selectedKategori = kategori); _applyFilter(); },
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
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFB8973A)));
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 12),
            Text(_books.isEmpty ? 'Belum ada buku tersedia' : 'Tidak ada hasil', style: const TextStyle(color: Colors.white38, fontSize: 15)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadBooks,
      color: const Color(0xFFB8973A),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _filtered.length,
        itemBuilder: (context, index) => _buildBookCard(_filtered[index]),
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book, showEdit: false))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 80, height: 110,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: _getCoverColors(book.kategori)),
              ),
              child: Center(child: Text(book.judul.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'serif'))),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.judul, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(book.penulis, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFB8973A).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFB8973A).withValues(alpha: 0.3))),
                        child: Text(book.kategori, style: const TextStyle(color: Color(0xFFB8973A), fontSize: 11)),
                      ),
                      const Spacer(),
                      Text('Rp ${book.harga.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFB8973A), fontWeight: FontWeight.bold, fontSize: 14)),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getCoverColors(String kategori) {
    switch (kategori) {
      case 'Fiksi': return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
      case 'Non-Fiksi': return [const Color(0xFF2E7D32), const Color(0xFF66BB6A)];
      case 'Pengembangan Diri': return [const Color(0xFFB8973A), const Color(0xFFFFD54F)];
      case 'Teknologi': return [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)];
      case 'Bisnis': return [const Color(0xFF880E4F), const Color(0xFFEC407A)];
      default: return [const Color(0xFF37474F), const Color(0xFF78909C)];
    }
  }
}
