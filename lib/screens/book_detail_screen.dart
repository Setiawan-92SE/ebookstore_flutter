import 'package:flutter/material.dart';
import '../models/book.dart';
import 'book_form_screen.dart';

/// Layar Detail Buku — menampilkan informasi lengkap satu buku
class BookDetailScreen extends StatelessWidget {
  final Book book;
  final VoidCallback? onUpdate;

  const BookDetailScreen({super.key, required this.book, this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        slivers: [
          // Header dengan cover buku
          SliverAppBar(
            backgroundColor: const Color(0xFF0F0F0F),
            expandedHeight: 280,
            pinned: true,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getCoverColors(book.kategori),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            book.judul.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookFormScreen(book: book),
                    ),
                  );
                  if (result == true) {
                    onUpdate?.call();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),

          // Detail konten
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  book.judul,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  book.penulis,
                  style: const TextStyle(
                    color: Color(0xFFB8973A),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),

                // Badge kategori
                Wrap(
                  spacing: 8,
                  children: [
                    _buildBadge(book.kategori),
                    _buildBadge(
                      book.stok > 0 ? 'Tersedia' : 'Habis',
                      color: book.stok > 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Info grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Harga',
                        'Rp ${_formatHarga(book.harga)}',
                        Icons.sell_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        'Stok',
                        '${book.stok} buku',
                        Icons.inventory_2_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'DESKRIPSI',
                  style: TextStyle(
                    color: Color(0xFFB8973A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.deskripsi,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8973A),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text(
                      'BELI SEKARANG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, {Color? color}) {
    final c = color ?? const Color(0xFFB8973A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(color: c, fontSize: 13)),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFB8973A), size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatHarga(double harga) {
    final h = harga.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < h.length; i++) {
      if (i > 0 && (h.length - i) % 3 == 0) buffer.write('.');
      buffer.write(h[i]);
    }
    return buffer.toString();
  }

  List<Color> _getCoverColors(String kategori) {
    switch (kategori) {
      case 'Fiksi':
        return [const Color(0xFF1565C0), const Color(0xFF0D47A1)];
      case 'Non-Fiksi':
        return [const Color(0xFF2E7D32), const Color(0xFF1B5E20)];
      case 'Pengembangan Diri':
        return [const Color(0xFFB8973A), const Color(0xFF8D6E08)];
      case 'Teknologi':
        return [const Color(0xFF6A1B9A), const Color(0xFF4A148C)];
      default:
        return [const Color(0xFF37474F), const Color(0xFF263238)];
    }
  }
}
