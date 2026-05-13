import 'package:flutter/material.dart';
import '../models/user.dart';
import 'admin_dashboard_screen.dart';
import 'user_list_screen.dart';
import 'book_approval_screen.dart';
import 'admin_profile_screen.dart';

class MainAdminScreen extends StatefulWidget {
  final User user;
  const MainAdminScreen({super.key, required this.user});

  @override
  State<MainAdminScreen> createState() => _MainAdminScreenState();
}

class _MainAdminScreenState extends State<MainAdminScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      AdminDashboardScreen(user: widget.user),
      UserListScreen(user: widget.user),
      BookApprovalScreen(user: widget.user),
      AdminProfileScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0F0F0F),
        indicatorColor: Colors.redAccent.withValues(alpha: 0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Colors.redAccent),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: Colors.redAccent),
            label: 'Pengguna',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Colors.redAccent),
            label: 'Daftar Buku',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.redAccent),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
