import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slice/models/post_model.dart';
import 'package:slice/services/post_service.dart';
import 'package:slice/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PostService _postService;
  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _postService = PostService(Supabase.instance.client);
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await _postService.getAllPosts();
      setState(() {
        _posts = posts;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar publicaciones: ${e.toString()}'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        image: DecorationImage(
          image: const AssetImage("../assets/images/forest_background.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.85),
            BlendMode.darken
          ),
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadPosts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _posts.isEmpty
                ? Center(
                    child: Text(
                      'No hay publicaciones disponibles',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return _buildPostCard(post);
                    },
                  ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    // Formatear la fecha de creación
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(post.createdAt);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del post con nombre de usuario y fecha
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.accentColor,
                  radius: 20,
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: AppTheme.backgroundColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username ?? 'Usuario',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Contenido del post
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                post.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}