import 'package:flutter/material.dart';
import '../models/user.dart';
import 'book_list_screen.dart';
import 'order_list_screen.dart';
import 'earnings_screen.dart';
import 'seller_profile_screen.dart';

class MainSellerScreen extends StatefulWidget {
  final User user;
  const MainSellerScreen({super.key, required this.user});

  @override
  State<MainSellerScreen> createState() => _MainSellerScreenState();
}

class _MainSellerScreenState extends State<MainSellerScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const BookListScreen(),
      OrderListScreen(user: widget.user),
      EarningsScreen(user: widget.user),
      SellerProfileScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0F0F0F),
        indicatorColor: const Color(0xFFB8973A).withValues(alpha: 0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFFB8973A)),
            label: 'Buku Saya',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_outlined),
            selectedIcon: Icon(Icons.receipt, color: Color(0xFFB8973A)),
            label: 'Daftar Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.attach_money_outlined),
            selectedIcon: Icon(Icons.attach_money, color: Color(0xFFB8973A)),
            label: 'Pendapatan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFFB8973A)),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
