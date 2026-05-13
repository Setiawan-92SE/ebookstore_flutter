import 'package:flutter/material.dart';
import '../database/database.helper.dart';
import '../models/user.dart';

class EarningsScreen extends StatefulWidget {
  final User user;
  const EarningsScreen({super.key, required this.user});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final _db = DatabaseHelper();
  double _totalEarnings = 0;
  int _completedOrders = 0;
  int _pendingOrders = 0;
  List<Map<String, dynamic>> _recentOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final earnings = await _db.getTotalEarnings(widget.user.id!);
      final orders = await _db.getOrdersForSeller(widget.user.id!);
      final completed = orders.where((o) => o['status'] == 'completed').length;
      final pending = orders.where((o) => o['status'] == 'pending' || o['status'] == 'processing').length;
      if (mounted) setState(() {
        _totalEarnings = earnings;
        _completedOrders = completed;
        _pendingOrders = pending;
        _recentOrders = orders.take(5).toList();
        _isLoading = false;
      });
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
              onRefresh: _loadData,
              color: const Color(0xFFB8973A),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEarningsCard(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Pesanan Selesai', '$_completedOrders', Icons.check_circle, Colors.green)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Menunggu', '$_pendingOrders', Icons.hourglass_bottom, Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('TRANSAKSI TERBARU', style: TextStyle(color: Color(0xFFB8973A), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    if (_recentOrders.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Belum ada transaksi', style: TextStyle(color: Colors.white38))))
                    else
                      ..._recentOrders.map(_buildTransactionTile),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFB8973A), Color(0xFF8D6E08)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Pendapatan', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Rp ${_totalEarnings.toStringAsFixed(0)}', style: const TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 4),
          Text('Dari $_completedOrders pesanan selesai', style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order['judul'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${order['quantity']} x Rp ${(order['total'] / (order['quantity'] as num)).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Text('Rp ${(order['total'] as num).toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFB8973A), fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
