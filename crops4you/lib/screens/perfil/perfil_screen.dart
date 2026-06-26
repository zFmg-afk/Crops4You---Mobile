import 'package:flutter/material.dart';
import 'package:crops4you/screens/auth/login_screen.dart';
import 'package:crops4you/services/auth_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _authService = AuthService();

  String get _nombre => _authService.getUserName();
  String get _email => _authService.currentUser?.email ?? '';

  String get _iniciales {
    if (_nombre.isEmpty) return 'U';
    return _nombre[0].toUpperCase();
  }

  bool _notificaciones = true;
  bool _climaAutomatico = true;

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 40,
                bottom: 30,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1D7F3C), Color(0xFF145C2B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB81C),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _iniciales,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferencias',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Notificaciones'),
                          subtitle: const Text(
                            'Recibir alertas de recordatorios',
                            style: TextStyle(fontSize: 12),
                          ),
                          secondary: const Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFF1D7F3C),
                          ),
                          value: _notificaciones,
                          activeColor: const Color(0xFF1D7F3C),
                          onChanged: (v) => setState(() => _notificaciones = v),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Clima automático'),
                          subtitle: const Text(
                            'Actualizar clima al abrir la app',
                            style: TextStyle(fontSize: 12),
                          ),
                          secondary: const Icon(
                            Icons.cloud_outlined,
                            color: Color(0xFF1D7F3C),
                          ),
                          value: _climaAutomatico,
                          activeColor: const Color(0xFF1D7F3C),
                          onChanged: (v) =>
                              setState(() => _climaAutomatico = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _cerrarSesion,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Crops4You v1.0.0',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
