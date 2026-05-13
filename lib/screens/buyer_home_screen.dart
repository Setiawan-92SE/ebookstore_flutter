import 'package:flutter/material.dart';
import '../database/database.helper.dart';
import '../models/book.dart';
import '../models/user.dart';
import 'book_detail_screen.dart';

class BuyerHomeScreen extends StatefulWidget {
  final User user;
  const BuyerHomeScreen({super.key, required this.user});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  final _db = DatabaseHelper();
  List<Book> _featuredBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final all = await _db.getBooksByStatus('approved');
      all.shuffle();
      if (mounted) setState(() { _featuredBooks = all.take(10).toList(); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8973A)))
          : RefreshIndicator(
              onRefresh: _loadBooks,
              color: const Color(0xFFB8973A),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildSectionTitle('Rekomendasi Buku'),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _featuredBooks.length,
                        itemBuilder: (context, index) => _buildBookCard(_featuredBooks[index]),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1500), Color(0xFF0F0F0F)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Halo, ${widget.user.name}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 4),
          const Text('Temukan buku favorit Anda', style: TextStyle(color: Colors.white54, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif')),
    );
  }

  Widget _buildBookCard(Book book) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book, showEdit: false))),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                gradient: LinearGradient(
                  colors: _getCoverColors(book.kategori),
                ),
              ),
              child: Center(
                child: Text(book.judul.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'serif')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.judul, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('Rp ${book.harga.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFB8973A), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
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
