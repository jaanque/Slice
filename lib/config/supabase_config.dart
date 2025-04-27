import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://vrxpmesbotxvpmsiideb.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZyeHBtZXNib3R4dnBtc2lpZGViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU2Nzg0NzcsImV4cCI6MjA2MTI1NDQ3N30.p7zOAk2R-VQ7DMKSJ8iUP8KIFZcUiLPuHaEHpjrL-rQ';
  
  // Singleton para acceder al cliente de Supabase
  static final supabase = Supabase.instance.client;
}

// Importamos la librería para que pueda ser usada en este archivo