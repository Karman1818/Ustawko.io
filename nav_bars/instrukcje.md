# Instrukcje: Dodanie autentykacji do aplikacji nav_bars

## Stan obecny

Aplikacja używa `shared_preferences` jako tymczasowego "logowania":
- `login_screen.dart` — zapisuje email do SharedPreferences (bez weryfikacji hasła)
- `main.dart` — sprawdza czy `email` istnieje w prefs, by wybrać ekran startowy
- `settings_screen.dart` — wylogowanie = usunięcie `email` z prefs
- `profile_screen.dart` — czyta email z SharedPreferences, imię jest na stałe wpisane ("Jan Kowalski")

Po integracji z backendem wszystkie te miejsca wymagają modyfikacji.

---

## Opcja A: Firebase Authentication

### 1. Przygotowanie w Firebase Console

1. Wejdź na [console.firebase.google.com](https://console.firebase.google.com)
2. Kliknij **Add project** → podaj nazwę → utwórz projekt
3. W menu po lewej: **Authentication** → **Get started**
4. Zakładka **Sign-in method** → włącz **Email/Password**
5. W ustawieniach projektu dodaj aplikację Flutter:
   - Kliknij ikonę `</>` (Web) lub odpowiednio iOS/Android
   - Pobierz plik konfiguracyjny lub skopiuj dane SDK

### 2. Instalacja FlutterFire CLI i konfiguracja

```bash
# Zainstaluj FlutterFire CLI (jednorazowo)
dart pub global activate flutterfire_cli

# W katalogu projektu:
flutterfire configure
```

Polecenie `flutterfire configure` automatycznie:
- Pobierze dane z Firebase Console
- Wygeneruje plik `lib/firebase_options.dart`
- Skonfiguruje platformy (Android, iOS, Web)

### 3. Dodanie zależności do `pubspec.yaml`

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
```

Uruchom:
```bash
flutter pub get
```

### 4. Modyfikacja `lib/main.dart`

Zastąp logikę SharedPreferences sprawdzaniem sesji Firebase:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final user = FirebaseAuth.instance.currentUser;
  final String initialRoute = user != null ? '/home' : '/login';

  runApp(MainApp(initialRoute: initialRoute));
}
```

**Usuń** import `shared_preferences` z `main.dart` — nie jest już potrzebny.

### 5. Modyfikacja `lib/screens/login_screen.dart`

Dodaj kontroler hasła i prawdziwe logowanie. Zastąp metodę `_saveUserLogged`:

```dart
import 'package:firebase_auth/firebase_auth.dart';

// Dodaj kontroler hasła obok istniejącego _emailController:
final TextEditingController _passwordController = TextEditingController();

// Nowa metoda logowania (zastępuje _saveUserLogged):
Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Błąd logowania')),
    );
  }
}
```

W `TextFormField` dla hasła dodaj `controller: _passwordController`.

Przycisk Zaloguj wywołuje `_login()` zamiast `_saveUserLogged(...)`.

**Usuń** import `shared_preferences`.

### 6. Dodanie ekranu rejestracji `lib/screens/register_screen.dart`

Utwórz nowy plik z podobną strukturą do `login_screen.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Błąd rejestracji')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Skopiuj strukturę formularza z LoginScreen,
    // zmień przycisk na "Zarejestruj się" wywołujący _register()
    // Dodaj TextButton "Masz już konto? Zaloguj się" z powrotem do /login
  }
}
```

Zarejestruj route w `main.dart`:
```dart
'/register': (context) => const RegisterScreen(),
```

### 7. Modyfikacja `lib/screens/settings_screen.dart`

Zastąp wylogowanie przez prefs prawdziwym wylogowaniem:

```dart
import 'package:firebase_auth/firebase_auth.dart';

// W onTap wylogowania:
onTap: () async {
  await FirebaseAuth.instance.signOut();
  if (context.mounted) {
    Navigator.pushReplacementNamed(context, '/login');
  }
},
```

**Usuń** import `shared_preferences`.

### 8. Modyfikacja `lib/screens/profile_screen.dart`

Pobierz dane z Firebase zamiast SharedPreferences:

```dart
import 'package:firebase_auth/firebase_auth.dart';

// Usuń _loadEmail() i _email field.
// Pobierz bezpośrednio:
final user = FirebaseAuth.instance.currentUser;
// user.email — email użytkownika
// user.displayName — imię (jeśli ustawione przy rejestracji)
```

W `build()` użyj `user?.email ?? '...'` zamiast `_email`.

**Usuń** import `shared_preferences`.

---

## Opcja B: Supabase

### 1. Przygotowanie w Supabase Dashboard

1. Wejdź na [supabase.com](https://supabase.com) → **New project**
2. Podaj nazwę, hasło bazy danych, wybierz region
3. Po utworzeniu projektu wejdź w **Settings → API**
4. Skopiuj:
   - **Project URL** (np. `https://xxxx.supabase.co`)
   - **anon public key**
5. W **Authentication → Providers** — Email jest domyślnie włączony

### 2. Dodanie zależności do `pubspec.yaml`

```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

```bash
flutter pub get
```

### 3. Modyfikacja `lib/main.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'TWOJ_SUPABASE_URL',       // wklej z Settings → API
    anonKey: 'TWOJ_ANON_KEY',       // wklej z Settings → API
  );

  final session = Supabase.instance.client.auth.currentSession;
  final String initialRoute = session != null ? '/home' : '/login';

  runApp(MainApp(initialRoute: initialRoute));
}
```

**Usuń** import `shared_preferences`.

> **Uwaga dla uczniów:** Nie wklejaj kluczy bezpośrednio w kodzie w prawdziwych projektach — używaj zmiennych środowiskowych lub pliku `.env`. Na potrzeby nauki jest to akceptowalne.

### 4. Modyfikacja `lib/screens/login_screen.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

// Dodaj kontroler hasła:
final TextEditingController _passwordController = TextEditingController();

// Nowa metoda logowania:
Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;
  try {
    await _supabase.auth.signInWithPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  } on AuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );
  }
}
```

W `TextFormField` dla hasła dodaj `controller: _passwordController`.

Przycisk Zaloguj wywołuje `_login()`.

**Usuń** import `shared_preferences`.

### 5. Dodanie ekranu rejestracji `lib/screens/register_screen.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sprawdź email — wyślemy link weryfikacyjny')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Skopiuj strukturę formularza z LoginScreen,
    // zmień przycisk na "Zarejestruj się" wywołujący _register()
  }
}
```

Zarejestruj route w `main.dart`:
```dart
'/register': (context) => const RegisterScreen(),
```

> **Uwaga:** Supabase domyślnie wysyła email weryfikacyjny. W Dashboard → Authentication → Settings możesz wyłączyć "Enable email confirmations" na czas nauki/testów.

### 6. Modyfikacja `lib/screens/settings_screen.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// W onTap wylogowania:
onTap: () async {
  await Supabase.instance.client.auth.signOut();
  if (context.mounted) {
    Navigator.pushReplacementNamed(context, '/login');
  }
},
```

**Usuń** import `shared_preferences`.

### 7. Modyfikacja `lib/screens/profile_screen.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Usuń _loadEmail(), _email, initState i import shared_preferences.
// W build() pobierz dane bezpośrednio:
final user = Supabase.instance.client.auth.currentUser;
// user?.email — email użytkownika
// user?.userMetadata?['full_name'] — imię (jeśli zapisane przy rejestracji)
```

---

## Porównanie: Firebase vs Supabase

| Cecha | Firebase | Supabase |
|---|---|---|
| Konfiguracja | FlutterFire CLI (automatyczna) | Ręczne wklejenie URL + klucza |
| Pakiet | `firebase_auth` | `supabase_flutter` |
| Obsługa błędów | `FirebaseAuthException` | `AuthException` |
| Weryfikacja email | Opcjonalna | Domyślnie włączona |
| Baza danych | Firestore / Realtime DB | PostgreSQL (wbudowana) |
| Darmowy tier | Tak (Spark plan) | Tak |
| Open source | Nie | Tak |


---

## Wspólne kroki końcowe (oba scenariusze)

### Dodanie przycisku "Zarejestruj się" w LoginScreen

W `login_screen.dart`, po przycisku Zaloguj dodaj:

```dart
TextButton(
  onPressed: () => Navigator.pushNamed(context, '/register'),
  child: const Text('Nie masz konta? Zarejestruj się'),
),
```

### Usunięcie `shared_preferences` z projektu (opcjonalnie)

Jeśli `shared_preferences` nie jest już używany w żadnym pliku, usuń go z `pubspec.yaml`:

```yaml
# Usuń tę linię:
shared_preferences: ^2.5.5
```

```bash
flutter pub get
```

### Sprawdź wszystkie pliki po migracji

Szukaj pozostałości `SharedPreferences` w kodzie:
```bash
grep -r "shared_preferences\|SharedPreferences" lib/
```

Wynik powinien być pusty.
