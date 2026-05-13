import 'package:flutter/material.dart';
import '../database/database.helper.dart';
import '../models/user.dart';
import 'package:ebookstore/models/book.dart';

class CartScreen extends StatefulWidget {
  final User user;
  const CartScreen({super.key, required this.user});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _db = DatabaseHelper();
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    try {
      final items = await _db.getCartWithBooks(widget.user.id!);
      if (mounted) setState(() { _cartItems = items; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkout() async {
    if (_cartItems.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        content: Text('Pesan ${_cartItems.length} item? Total: Rp ${_getTotal().toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB8973A), foregroundColor: Colors.black),
            child: const Text('Pesan'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      for (final item in _cartItems) {
        final book = Book.fromMap(item);
        await _db.createOrder(widget.user.id!, book.id!, item['quantity'] as int, book.harga * (item['quantity'] as int));
      }
      await _db.clearCart(widget.user.id!);
      if (!mounted) return;
      _showSnackbar('Pesanan berhasil dibuat!', true);
      _loadCart();
    } catch (e) {
      _showSnackbar('Gagal checkout: $e', false);
    }
  }

  double _getTotal() {
    double total = 0;
    for (final item in _cartItems) {
      final book = Book.fromMap(item);
      total += book.harga * (item['quantity'] as int);
    }
    return total;
  }

  void _showSnackbar(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? const Color(0xFFB8973A) : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8973A)))
          : _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.white24),
                      const SizedBox(height: 12),
                      const Text('Keranjang kosong', style: TextStyle(color: Colors.white38, fontSize: 15)),
                      const SizedBox(height: 4),
                      const Text('Tambahkan buku dari katalog', style: TextStyle(color: Colors.white24, fontSize: 13)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) => _buildCartItem(_cartItems[index]),
                      ),
                    ),
                    _buildBottomBar(),
                  ],
                ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    final book = Book.fromMap(item);
    final qty = item['quantity'] as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 70, height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: _getCoverColors(book.kategori)),
            ),
            child: Center(child: Text(book.judul.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif'))),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.judul, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('Rp ${book.harga.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFB8973A), fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.white38, size: 20),
                        onPressed: qty > 1 ? () async {
                          await _db.updateCartQuantity(item['cart_id'], qty - 1);
                          _loadCart();
                        } : null,
                      ),
                      Text('$qty', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFFB8973A), size: 20),
                        onPressed: () async {
                          await _db.updateCartQuantity(item['cart_id'], qty + 1);
                          _loadCart();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () async {
              await _db.removeFromCart(item['cart_id']);
              _loadCart();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Total', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  Text('Rp ${_getTotal().toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFB8973A), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                ],
              ),
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8973A),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
