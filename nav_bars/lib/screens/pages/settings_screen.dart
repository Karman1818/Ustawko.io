import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nav_bars/l10n/app_localizations.dart';
import 'package:nav_bars/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final _url = Uri.parse('https://flutter.dev');

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        StreamBuilder<Map<String, dynamic>?>(
          stream: SupabaseService().getMyProfileStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            final profile = snapshot.data;
            if (profile == null) {
              return const SizedBox.shrink(); // Profil nie istnieje jeszcze
            }

            final club = profile['club'] ?? 'Brak';
            final isOnL4 = profile['is_on_l4'] ?? false;
            final l4Until = profile['l4_until'] != null ? DateTime.parse(profile['l4_until']) : null;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: isOnL4 ? Colors.red.shade900 : Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'PROFIL WOJOWNIKA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: isOnL4 ? Colors.white : Theme.of(context).colorScheme.primary
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('BARWY: $club', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOnL4 ? Colors.white : Theme.of(context).colorScheme.error,
                        foregroundColor: isOnL4 ? Colors.red : Colors.white,
                      ),
                      onPressed: () async {
                        try {
                          await SupabaseService().toggleL4Status(!isOnL4);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
                          }
                        }
                      },
                      child: Text(isOnL4 ? 'WYPISZ Z L4 (GOTOWY DO WALKI)' : 'ZGŁOŚ L4 (KONTUZJA)'),
                    ),
                    if (isOnL4 && l4Until != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Zwolnienie do: ${l4Until.day.toString().padLeft(2,'0')}.${l4Until.month.toString().padLeft(2,'0')} ${l4Until.hour.toString().padLeft(2,'0')}:${l4Until.minute.toString().padLeft(2,'0')}', 
                        textAlign: TextAlign.center, 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            AppLocalizations.of(context)!.account,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: Text(AppLocalizations.of(context)!.passwordAndSecurity),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _launchUrl(_url);
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications_none),
          title: Text(AppLocalizations.of(context)!.notifications),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            AppLocalizations.of(context)!.application,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode_outlined),
          title: Text(AppLocalizations.of(context)!.darkTheme),
          trailing: Switch(
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (val) {
              MainApp.setThemeMode(
                context,
                val ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),
        ),
        ExpansionTile(
          leading: const Icon(Icons.language),
          title: Text(AppLocalizations.of(context)!.language),
          subtitle: Text(AppLocalizations.of(context)!.languageName),
          children: [
            ListTile(
              title: const Text('Polski'),
              trailing: Localizations.localeOf(context).languageCode == 'pl'
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                MainApp.setLocale(context, const Locale('pl'));
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: Localizations.localeOf(context).languageCode == 'en'
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                MainApp.setLocale(context, const Locale('en'));
              },
            ),
          ],
        ),
        const Divider(height: 32),
        ListTile(
          leading: Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            AppLocalizations.of(context)!.logout,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.remove('email');
            try {
              await Supabase.instance.client.auth.signOut();
            } catch (e) {
              // Ignore
            }
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),
      ],
    );
  }
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}
