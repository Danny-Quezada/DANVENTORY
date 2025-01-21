import 'package:danventory/ui/pages/category_page.dart';
import 'package:danventory/ui/pages/principal_page.dart';
import 'package:danventory/ui/pages/setting_page.dart';
import 'package:danventory/ui/widgets/safe_scaffold.dart';
import 'package:flutter/material.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        fixedColor: Colors.blue,
        elevation: 0,
        enableFeedback: true,
        type: BottomNavigationBarType.shifting,
        unselectedItemColor: Colors.grey.shade400,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined), label: "Categorías"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      return PrincipalPage();
    } else if (_currentIndex == 1) {
      return PrincipalPage();
    } else if (_currentIndex == 2) {
      return const CategoryPage();
    }
    return SettingPage();
  }
}
