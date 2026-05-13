import 'package:flutter/material.dart';
import '../database/database.helper.dart';
import '../models/book.dart';
import '../models/user.dart';
import 'book_detail_screen.dart';

class BookApprovalScreen extends StatefulWidget {
  final User user;
  const BookApprovalScreen({super.key, required this.user});

  @override
  State<BookApprovalScreen> createState() => _BookApprovalScreenState();
}

class _BookApprovalScreenState extends State<BookApprovalScreen> {
  final _db = DatabaseHelper();
  List<Book> _pendingBooks = [];
  List<Book> _allBooks = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final pending = await _db.getBooksByStatus('pending');
      final all = await _db.getAllBooks();
      if (mounted) setState(() { _pendingBooks = pending; _allBooks = all; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8973A)))
            : _selectedTab == 0 ? _buildPendingList() : _buildAllBooksList()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTab(0, 'Menunggu (${_pendingBooks.length})'),
          _buildTab(1, 'Semua Buku (${_allBooks.length})'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFB8973A) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold, fontSize: 13,
          )),
        ),
      ),
    );
  }

  Widget _buildPendingList() {
    if (_pendingBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: Colors.white24),
            const SizedBox(height: 12),
            const Text('Tidak ada buku yang menunggu', style: TextStyle(color: Colors.white38, fontSize: 15)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadBooks,
      color: const Color(0xFFB8973A),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: _pendingBooks.length,
        itemBuilder: (context, index) => _buildPendingCard(_pendingBooks[index]),
      ),
    );
  }

  Widget _buildAllBooksList() {
    if (_allBooks.isEmpty) {
      return const Center(child: Text('Tidak ada buku', style: TextStyle(color: Colors.white38)));
    }
    return RefreshIndicator(
      onRefresh: _loadBooks,
      color: const Color(0xFFB8973A),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: _allBooks.length,
        itemBuilder: (context, index) => _buildBookCard(_allBooks[index]),
      ),
    );
  }

  Widget _buildPendingCard(Book book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
                  child: const Text('MENUNGGU', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(book.judul, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'serif')),
            const SizedBox(height: 4),
            Text('Penulis: ${book.penulis}  |  Kategori: ${book.kategori}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Harga: Rp ${book.harga.toStringAsFixed(0)}  |  Stok: ${book.stok}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _db.updateBookStatus(book.id!, 'approved');
                        _loadBooks();
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Terima', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _db.updateBookStatus(book.id!, 'rejected');
                        _loadBooks();
                      },
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 60, height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(colors: _getCoverColors(book.kategori)),
              ),
              child: Center(child: Text(book.judul.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif'))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.judul, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('Rp ${book.harga.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFB8973A), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor(book.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _statusColor(book.status).withValues(alpha: 0.3)),
              ),
              child: Text(book.status.toUpperCase(), style: TextStyle(color: _statusColor(book.status), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'pending': return Colors.orange;
      default: return Colors.grey;
    }
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
