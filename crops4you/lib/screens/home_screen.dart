import 'package:flutter/material.dart';
import 'package:crops4you/screens/dashboard/dashboard_screen.dart';
import 'package:crops4you/screens/parcelas/parcelas_screen.dart';
import 'package:crops4you/screens/clima/clima_screen.dart';
import 'package:crops4you/screens/ia/ia_screen.dart';
import 'package:crops4you/screens/recordatorios/recordatorios_screen.dart';
import 'package:crops4you/screens/perfil/perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ParcelasScreen(),
    ClimaScreen(),
    IaScreen(),
    RecordatoriosScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1D7F3C).withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFF1D7F3C)),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.terrain_outlined),
            selectedIcon: Icon(Icons.terrain, color: Color(0xFF1D7F3C)),
            label: 'Parcelas',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud, color: Color(0xFF1D7F3C)),
            label: 'Clima',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt, color: Color(0xFF1D7F3C)),
            label: 'IA',
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm, color: Color(0xFF1D7F3C)),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF1D7F3C)),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
