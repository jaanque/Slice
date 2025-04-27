// lib/services/auth_service.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabaseClient;

  AuthService(this._supabaseClient);

  // Método para verificar si un nombre de usuario ya existe
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select('username')
          .eq('username', username)
          .maybeSingle();
      
      // Si no hay respuesta, el nombre de usuario está disponible
      return response == null;
    } catch (e) {
      throw Exception('Error al verificar nombre de usuario: $e');
    }
  }

  // Método para actualizar el nombre de usuario
  Future<UserModel> updateUsername(String userId, String newUsername) async {
    try {
      // Primero verificamos si el nuevo nombre de usuario está disponible
      final isAvailable = await isUsernameAvailable(newUsername);
      if (!isAvailable) {
        throw Exception('Este nombre de usuario ya está en uso');
      }
      
      // Actualizar en la base de datos
      await _supabaseClient
          .from('users')
          .update({'username': newUsername})
          .eq('id', userId);
      
      // Obtener datos actualizados del usuario
      final userData = await _supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Error al actualizar nombre de usuario: $e');
    }
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Verificar si el nombre de usuario ya existe
      final isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        throw Exception('Este nombre de usuario ya está en uso');
      }
      
      // Registrar usuario con email y contraseña
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Guardar el nombre de usuario en la tabla users
        await _supabaseClient.from('users').insert({
          'id': response.user!.id,
          'username': username,
          'email': email,
        });
      }
    } catch (e) {
      throw Exception('Error durante el registro: $e');
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Obtener datos del usuario desde la tabla users
        final userData = await _supabaseClient
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();

        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      throw Exception('Error durante el inicio de sesión: $e');
    }
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser != null) {
      try {
        final userData = await _supabaseClient
            .from('users')
            .select()
            .eq('id', currentUser.id)
            .single();
        return UserModel.fromJson(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}