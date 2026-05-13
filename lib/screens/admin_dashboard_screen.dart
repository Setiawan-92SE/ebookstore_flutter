import 'package:flutter/material.dart';
import '../database/database.helper.dart';
import '../models/user.dart';

class AdminDashboardScreen extends StatefulWidget {
  final User user;
  const AdminDashboardScreen({super.key, required this.user});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _db = DatabaseHelper();
  bool _isLoading = true;

  int _totalBooks = 0;
  int _totalUsers = 0;
  int _totalSellers = 0;
  int _totalBuyers = 0;
  int _pendingBooks = 0;
  int _pendingOrders = 0;
  int _completedOrders = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _totalBooks = await _db.countAllBooks();
      _totalUsers = await _db.getTotalUsersCount();
      _totalSellers = await _db.countUsersByRole('seller');
      _totalBuyers = await _db.countUsersByRole('buyer');
      _pendingBooks = await _db.countBooksByStatus('pending');
      _pendingOrders = await _db.countOrdersByStatus('pending');
      _completedOrders = await _db.countOrdersByStatus('completed');
      if (mounted) setState(() => _isLoading = false);
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
                    const SizedBox(height: 8),
                    const Text('LAPORAN & ANALITIK', style: TextStyle(color: Color(0xFFB8973A), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _buildStatCard('Total Buku', '$_totalBooks', Icons.menu_book, const Color(0xFFB8973A))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Total Pengguna', '$_totalUsers', Icons.people, Colors.blueAccent)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _buildStatCard('Seller', '$_totalSellers', Icons.store, Colors.greenAccent)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Buyer', '$_totalBuyers', Icons.person, Colors.purpleAccent)),
                    ]),
                    const SizedBox(height: 24),
                    const Text('ANALITIK', style: TextStyle(color: Color(0xFFB8973A), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    _buildAnalyticBar('Buku Menunggu Persetujuan', _pendingBooks, _totalBooks > 0 ? _pendingBooks / _totalBooks : 0, Colors.orange),
                    const SizedBox(height: 12),
                    _buildAnalyticBar('Pesanan Menunggu', _pendingOrders, (_pendingOrders + _completedOrders) > 0 ? _pendingOrders / (_pendingOrders + _completedOrders) : 0, Colors.redAccent),
                    const SizedBox(height: 12),
                    _buildAnalyticBar('Pesanan Selesai', _completedOrders, (_pendingOrders + _completedOrders) > 0 ? _completedOrders / (_pendingOrders + _completedOrders) : 0, Colors.green),
                  ],
                ),
              ),
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
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAnalyticBar(String label, int count, double ratio, Color color) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
              Text('$count', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
