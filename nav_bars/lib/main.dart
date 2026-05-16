import 'package:flutter/material.dart';
//language and theme
import 'package:nav_bars/l10n/app_localizations.dart';
import 'package:nav_bars/core/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//screens
import 'package:nav_bars/screens/routes.dart';
//storage
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Załadowanie zmiennych z .env
  await dotenv.load(fileName: ".env");

  // Inicjalizacja Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  final prefs = await SharedPreferences.getInstance();
  final String? email = prefs.getString('email');

  // We no longer try to sign in anonymously here because it's disabled.
  // The user should log in via LoginScreen to get a real Supabase session.

  final String initialRoute = email != null ? AppRoutes.home : AppRoutes.login;

  runApp(MainApp(initialRoute: initialRoute));
}

class MainApp extends StatefulWidget {
  final String initialRoute;
  const MainApp({super.key, required this.initialRoute});

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MainAppState>();
    state?.setLocale(newLocale);
  }

  static void setThemeMode(BuildContext context, ThemeMode themeMode) {
    var state = context.findAncestorStateOfType<_MainAppState>();
    state?.setThemeMode(themeMode);
  }

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      themeMode: _themeMode,
      theme: BrutalistTheme.darkTheme,
      darkTheme: BrutalistTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: widget.initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
