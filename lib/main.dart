import 'package:flutter/material.dart';
import 'nutrition_screen.dart';
import 'growth_screen.dart';
import 'beneficiary_screen.dart';
import 'update_service.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen()),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // This triggers the check as soon as the app screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkForUpdates(context);
    });
  }

  int _currentIndex = 0;

  // The three screens we designed
  final List<Widget> _screens = [
    const NutritionScreen(),
    const GrowthScreen(),
    const BeneficiaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Growth',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Beneficiaries',
          ),
        ],
      ),
    );
  }
}
