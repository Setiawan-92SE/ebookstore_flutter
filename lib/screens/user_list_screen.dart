import 'package:flutter/material.dart';
import '../database/database.helper.dart';
import '../models/user.dart';

class UserListScreen extends StatefulWidget {
  final User user;
  const UserListScreen({super.key, required this.user});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _db = DatabaseHelper();
  List<User> _users = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      List<User> users;
      if (_selectedFilter == 'Semua') {
        users = await _db.getAllUsers();
      } else {
        users = await _db.getUsersByRole(_selectedFilter.toLowerCase());
      }
      if (mounted) setState(() { _users = users; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Hapus Pengguna', style: TextStyle(color: Colors.white)),
        content: Text('Hapus "${user.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deleteUser(user.id!);
      _loadUsers();
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return Colors.redAccent;
      case 'seller': return const Color(0xFFB8973A);
      case 'buyer': return Colors.blueAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8973A)))
                : _users.isEmpty
                    ? const Center(child: Text('Tidak ada pengguna', style: TextStyle(color: Colors.white38)))
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        color: const Color(0xFFB8973A),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _users.length,
                          itemBuilder: (context, index) => _buildUserCard(_users[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: ['Semua', 'Admin', 'Seller', 'Buyer'].map((f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f, style: TextStyle(fontSize: 12, color: isSelected ? Colors.black : Colors.white70)),
              selected: isSelected,
              onSelected: (_) { setState(() => _selectedFilter = f); _loadUsers(); },
              backgroundColor: const Color(0xFF1E1E1E),
              selectedColor: const Color(0xFFB8973A),
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _roleColor(user.role).withValues(alpha: 0.2),
            child: Icon(user.role == 'admin' ? Icons.admin_panel_settings : user.role == 'seller' ? Icons.store : Icons.person, color: _roleColor(user.role), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(user.email, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _roleColor(user.role).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _roleColor(user.role).withValues(alpha: 0.3)),
            ),
            child: Text(user.role.toUpperCase(), style: TextStyle(color: _roleColor(user.role), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          if (user.role != 'admin')
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _deleteUser(user),
            ),
        ],
      ),
    );
  }
}
