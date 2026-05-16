import 'package:flutter/material.dart';
import 'package:nav_bars/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nav_bars/core/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLogin = true;
  String? _selectedClub;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'USTAWKA.IO',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: -2,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.email,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.emailRequired;
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return AppLocalizations.of(context)!.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.passwordRequired;
                        }
                        if (value.length < 6) {
                          return AppLocalizations.of(context)!.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedClub,
                        decoration: const InputDecoration(
                          labelText: 'Wybierz swoje barwy',
                          prefixIcon: Icon(Icons.shield_outlined),
                        ),
                        items: AppConstants.popularClubs.map((String club) {
                          return DropdownMenuItem(
                            value: club,
                            child: Text(club),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedClub = newValue;
                          });
                        },
                        validator: (value) {
                          if (!_isLogin && (value == null || value.isEmpty)) {
                            return 'Musisz wybrać swoje barwy klubowe!';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : FilledButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);
                                try {
                                  if (_isLogin) {
                                    await Supabase.instance.client.auth.signInWithPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );
                                  } else {
                                    await Supabase.instance.client.auth.signUp(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      data: {'club': _selectedClub},
                                    );
                                  }

                                  _saveUserLogged(_emailController);
                                  if (context.mounted) {
                                    Navigator.pushReplacementNamed(context, '/home');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Błąd: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => _isLoading = false);
                                }
                              }
                            },
                            child: Text(
                              _isLogin ? AppLocalizations.of(context)!.login : 'ZAREJESTRUJ SIĘ',
                            ),
                          ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin 
                            ? 'Nie masz konta? Zarejestruj się' 
                            : 'Masz już konto? Zaloguj się',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveUserLogged(TextEditingController emailController) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('email', emailController.text);

    //debugPrint(prefs.getString('email'));
  }
}
