import 'package:flutter/material.dart';
import '../database/database.helper.dart';
import '../models/user.dart';

class OrderListScreen extends StatefulWidget {
  final User user;
  const OrderListScreen({super.key, required this.user});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final _db = DatabaseHelper();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _db.getOrdersForSeller(widget.user.id!);
      if (mounted) setState(() { _orders = orders; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'processing': return const Color(0xFFB8973A);
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8973A)))
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.white24),
                      const SizedBox(height: 12),
                      const Text('Belum ada pesanan', style: TextStyle(color: Colors.white38, fontSize: 15)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  color: const Color(0xFFB8973A),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
                  ),
                ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(order['judul'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor(status).withValues(alpha: 0.4)),
                  ),
                  child: Text(status.toUpperCase(), style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.person_outline, color: Colors.white38, size: 16),
              const SizedBox(width: 6),
              Text(order['buyer_name'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.shopping_bag_outlined, color: Colors.white38, size: 16),
              const SizedBox(width: 6),
              Text('${order['quantity']} x Rp ${(order['total'] / (order['quantity'] as num)).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.monetization_on_outlined, color: Color(0xFFB8973A), size: 16),
              const SizedBox(width: 6),
              Text('Rp ${(order['total'] as num).toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFB8973A), fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _db.updateOrderStatus(order['id'], 'processing');
                          _loadOrders();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB8973A),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Proses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: () async {
                          await _db.updateOrderStatus(order['id'], 'cancelled');
                          _loadOrders();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
