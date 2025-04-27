import 'package:flutter/material.dart';
import 'package:slice/services/post_service.dart';
import 'package:slice/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController _contentController = TextEditingController();
  bool _isPosting = false;
  late final PostService _postService;

  @override
  void initState() {
    super.initState();
    _postService = PostService(Supabase.instance.client);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    // Validar que el contenido no esté vacío
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El contenido de la publicación no puede estar vacío'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      await _postService.createPost(content);
      
      // Limpiar el campo de texto después de publicar
      _contentController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Publicación creada con éxito!'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Contenedor para la entrada de texto
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Crear nueva publicación",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: '¿Qué está pasando?',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines: 5,
                    maxLength: 280, // Limite de caracteres similar a Twitter
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isPosting ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: _isPosting
                        ? const CircularProgressIndicator(color: AppTheme.backgroundColor)
                        : const Text('Publicar'),
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