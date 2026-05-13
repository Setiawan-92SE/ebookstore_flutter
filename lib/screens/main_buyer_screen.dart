import 'package:flutter/material.dart';
import '../models/user.dart';
import 'buyer_home_screen.dart';
import 'catalog_screen.dart';
import 'cart_screen.dart';
import 'buyer_profile_screen.dart';

class MainBuyerScreen extends StatefulWidget {
  final User user;
  const MainBuyerScreen({super.key, required this.user});

  @override
  State<MainBuyerScreen> createState() => _MainBuyerScreenState();
}

class _MainBuyerScreenState extends State<MainBuyerScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      BuyerHomeScreen(user: widget.user),
      CatalogScreen(user: widget.user),
      CartScreen(user: widget.user),
      BuyerProfileScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0F0F0F),
        indicatorColor: Colors.blueAccent.withValues(alpha: 0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.blueAccent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books, color: Colors.blueAccent),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart, color: Colors.blueAccent),
            label: 'Keranjang',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.blueAccent),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
