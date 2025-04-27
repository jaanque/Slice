import 'package:flutter/material.dart';
import 'package:slice/screens/create_screen.dart';
import 'package:slice/screens/home_screen.dart';
import 'package:slice/screens/profile_screen.dart';
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
  int _selectedIndex = 0;
  late UserModel _currentUser;
  late final AuthService _authService;
  
  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _authService = AuthService(Supabase.instance.client);
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lista de páginas para navegar
    final List<Widget> _pages = [
      const HomeScreen(),
      const CreateScreen(),
      ProfileScreen(user: _currentUser),
    ];
    
    // Títulos de las páginas
    final List<String> _titles = ['Inicio', 'Crear', 'Perfil'];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            topLeft: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              spreadRadius: 0,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: BottomNavigationBar(
            backgroundColor: AppTheme.primaryColor,
            selectedItemColor: AppTheme.accentColor,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: 'Crear',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}