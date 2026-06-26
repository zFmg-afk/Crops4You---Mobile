import 'package:crops4you/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = supabase;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'nombre': nombre},
      );
      return response;
    } catch (e) {
      throw Exception('Error al registrar: $e');
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  // Obtener nombre del usuario
  String getUserName() {
    final user = currentUser;
    if (user?.userMetadata?['nombre'] != null) {
      return user!.userMetadata!['nombre'];
    }
    return user?.email?.split('@')[0] ?? 'Usuario';
  }
}
