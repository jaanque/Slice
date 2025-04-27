// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:slice/services/auth_service.dart';
import 'package:slice/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingUsername = false;
  String? _usernameError;
  
  late final AuthService _authService;
  
  @override
  void initState() {
    super.initState();
    _authService = AuthService(Supabase.instance.client);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Método para verificar disponibilidad del nombre de usuario
  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty) return;
    
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

  Future<void> _register() async {
    // Si estamos comprobando el nombre de usuario, esperar
    if (_isCheckingUsername) return;
    
    // Si hay error en el nombre de usuario, evitar registro
    if (_usernameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_usernameError!), backgroundColor: Colors.red.shade800),
      );
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.signUp(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Mostrar un mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro exitoso. Ahora puedes iniciar sesión.'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
          
          // Navegar a la página de inicio de sesión
          Navigator.of(context).pop();
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
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("../assets/images/forest_background.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black87, 
              BlendMode.darken
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Logo más pequeño en la página de registro
                  const Text(
                    "slice",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Formulario de registro
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Registro",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre de usuario',
                              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.accentColor),
                              suffixIcon: _isCheckingUsername 
                                ? const SizedBox(
                                    width: 20, 
                                    height: 20, 
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentColor),
                                  )
                                : _usernameError != null
                                    ? const Icon(Icons.error, color: Colors.redAccent)
                                    : _usernameController.text.isNotEmpty
                                        ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                                        : null,
                              errorText: _usernameError,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese un nombre de usuario';
                              }
                              if (_usernameError != null) {
                                return _usernameError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.accentColor),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su correo electrónico';
                              }
                              if (!value.contains('@')) {
                                return 'Por favor, ingrese un correo electrónico válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.accentColor),
                            ),
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese una contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar contraseña',
                              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.accentColor),
                            ),
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, confirme su contraseña';
                              }
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: AppTheme.backgroundColor)
                                : const Text('Registrarse'),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                '¿Ya tienes cuenta? Inicia sesión',
                                style: TextStyle(color: AppTheme.accentColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}