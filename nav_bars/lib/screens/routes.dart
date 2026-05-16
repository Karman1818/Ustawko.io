import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'home_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String register = '/register';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        home: (context) => const HomeScreen(),
        register: (context) => const RegisterScreen(),
      };
}
