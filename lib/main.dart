import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/book_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const EBookStoreApp());
}

class EBookStoreApp extends StatelessWidget {
  const EBookStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-BookStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFB8973A),
          surface: const Color(0xFF1A1A1A),
          background: const Color(0xFF0F0F0F),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BookListScreen(),
    // Tambahkan screen lain (Beranda, Keranjang, dll) sesuai kebutuhan
    _PlaceholderScreen(label: 'Beranda'),
    _PlaceholderScreen(label: 'Keranjang'),
    _PlaceholderScreen(label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0F0F0F),
        indicatorColor: const Color(0xFFB8973A).withOpacity(0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFFB8973A)),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFFB8973A)),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart, color: Color(0xFFB8973A)),
            label: 'Keranjang',
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

class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 18),
        ),
      ),
    );
  }
}
