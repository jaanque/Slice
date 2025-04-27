import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

class PostService {
  final SupabaseClient _supabaseClient;

  PostService(this._supabaseClient);

  // Crear una nueva publicación
  Future<PostModel> createPost(String content) async {
    try {
      // Obtener el ID del usuario actual
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No hay un usuario autenticado');
      }

      // Crear el post en la base de datos
      final data = {
        'user_id': currentUser.id,
        'content': content,
      };

      final response = await _supabaseClient
          .from('posts')
          .insert(data)
          .select()
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear la publicación: $e');
    }
  }

  // Obtener todas las publicaciones con info de usuario
  Future<List<PostModel>> getAllPosts() async {
    try {
      final response = await _supabaseClient
          .from('posts')
          .select('*, users:user_id(username)')
          .order('created_at', ascending: false);

      return response.map<PostModel>((post) {
        // Extraer el nombre de usuario de la relación anidada
        final userData = post['users'] as Map<String, dynamic>?;
        final username = userData?['username'] as String?;
        
        // Crear una copia del post sin la información de usuario anidada
        final postData = Map<String, dynamic>.from(post);
        postData.remove('users');
        
        // Crear el modelo con la información extraída
        final postModel = PostModel.fromJson(postData);
        postModel.username = username;
        
        return postModel;
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener las publicaciones: $e');
    }
  }

  // Obtener publicaciones de un usuario específico
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final response = await _supabaseClient
          .from('posts')
          .select('*, users:user_id(username)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<PostModel>((post) {
        // Extraer el nombre de usuario de la relación anidada
        final userData = post['users'] as Map<String, dynamic>?;
        final username = userData?['username'] as String?;
        
        // Crear una copia del post sin la información de usuario anidada
        final postData = Map<String, dynamic>.from(post);
        postData.remove('users');
        
        // Crear el modelo con la información extraída
        final postModel = PostModel.fromJson(postData);
        postModel.username = username;
        
        return postModel;
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener las publicaciones del usuario: $e');
    }
  }

  // Eliminar una publicación
  Future<void> deletePost(String postId) async {
    try {
      await _supabaseClient
          .from('posts')
          .delete()
          .eq('id', postId);
    } catch (e) {
      throw Exception('Error al eliminar la publicación: $e');
    }
  }
}