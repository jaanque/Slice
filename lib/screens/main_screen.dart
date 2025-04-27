// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:slice/services/auth_service.dart';
import 'package:slice/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  final UserModel user;
  
  const MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late UserModel _currentUser;
  late final AuthService _authService;
  
  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _authService = AuthService(Supabase.instance.client);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
          ),
        ],
      ),
      body: Container(
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                          Text(
                            '¡Bienvenido, ${_currentUser.username}!',
                            style: Theme.of(context).textTheme.headlineMedium,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}