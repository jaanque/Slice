import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slice/models/post_model.dart';
import 'package:slice/screens/login_screen.dart';
import 'package:slice/services/auth_service.dart';
import 'package:slice/services/post_service.dart';
import 'package:slice/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel _currentUser;
  late final AuthService _authService;
  late final PostService _postService;
  List<PostModel> _userPosts = [];
  bool _isLoadingPosts = true;
  
  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _authService = AuthService(Supabase.instance.client);
    _postService = PostService(Supabase.instance.client);
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final posts = await _postService.getUserPosts(_currentUser.id);
      if (mounted) {
        setState(() {
          _userPosts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar las publicaciones: ${e.toString()}'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }
  
  void _showEditUsernameDialog() {
    final TextEditingController _usernameController = TextEditingController(text: _currentUser.username);
    String? _usernameError;
    bool _isCheckingUsername = false;
    bool _isUpdating = false;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _checkUsernameAvailability(String username) async {
              if (username.isEmpty || username == _currentUser.username) return;
              
              setState(() {
                _isCheckingUsername = true;
                _usernameError = null;
              });
              
              try {
                bool isAvailable = await _authService.isUsernameAvailable(username);
                setState(() {
                  _isCheckingUsername = false;
                  if (!isAvailable) {
                    _usernameError = 'Este nombre de usuario ya está en uso';
                  }
                });
              } catch (e) {
                setState(() {
                  _isCheckingUsername = false;
                });
              }
            }
            
            Future<void> _updateUsername() async {
              if (_usernameController.text.trim().isEmpty) {
                setState(() {
                  _usernameError = 'El nombre de usuario no puede estar vacío';
                });
                return;
              }
              
              if (_usernameController.text.trim() == _currentUser.username) {
                Navigator.of(context).pop();
                return;
              }
              
              if (_usernameError != null) return;
              
              setState(() {
                _isUpdating = true;
              });
              
              try {
                final updatedUser = await _authService.updateUsername(
                  _currentUser.id, 
                  _usernameController.text.trim()
                );
                
                // Actualizar el usuario en el estado parent
                if (mounted) {
                  Navigator.of(context).pop(updatedUser);
                }
              } catch (e) {
                setState(() {
                  _isUpdating = false;
                  _usernameError = e.toString();
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red.shade800,
                  ),
                );
              }
            }
            
            return AlertDialog(
              backgroundColor: AppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              title: const Text(
                'Editar nombre de usuario',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: const OutlineInputBorder(),
                      errorText: _usernameError,
                      suffixIcon: _isCheckingUsername 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      // Verificar disponibilidad después de un retraso
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_usernameController.text == value) {
                          _checkUsernameAvailability(value);
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _isUpdating || _isCheckingUsername ? null : _updateUsername,
                  child: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.backgroundColor,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    ).then((updatedUser) {
      if (updatedUser != null) {
        setState(() {
          _currentUser = updatedUser;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nombre de usuario actualizado con éxito'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    });
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
            // Encabezado del post con fecha
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
                        _currentUser.username,
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
        onRefresh: _loadUserPosts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Sección de información del usuario
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.accentColor,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.backgroundColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '¡Bienvenido, ${_currentUser.username}!',
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppTheme.accentColor,
                              size: 20,
                            ),
                            onPressed: _showEditUsernameDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentUser.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _authService.signOut();
                          if (mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Contador de publicaciones
                Container(
                  margin: const EdgeInsets.only(top: 24, bottom: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.article_outlined,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${_userPosts.length} publicaciones",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Sección de publicaciones del usuario
                Container(
                  width: double.infinity,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 16),
                        child: Text(
                          "Mis publicaciones",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      // Lista de publicaciones
                      _isLoadingPosts
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _userPosts.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.article_outlined,
                                          color: AppTheme.accentColor,
                                          size: 48,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Aún no has publicado nada",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _userPosts.length,
                                  itemBuilder: (context, index) {
                                    return _buildPostCard(_userPosts[index]);
                                  },
                                ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}