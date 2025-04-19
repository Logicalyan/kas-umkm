import 'package:flutter/material.dart';
import 'package:kas_umkm/screens/category_page.dart';
import 'package:kas_umkm/screens/dashboard_page.dart';
import 'package:kas_umkm/screens/history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),   // Total income, expense, net total
    HistoryPage(),     // Edit/delete + group by date
    CategoryPage(),    // Tambah dan kelola kategori
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Kategori'),
        ],
      ),
    );
  }
}
