# Ustawka.io 🥊

**Ustawka.io** to satyryczna aplikacja mobilna stworzona dla prawdziwych fanatyków, którzy cenią honorowe konfrontacje w malowniczych okolicznościach przyrody. Zapomnij o nudnych komunikatorach – tutaj umawiasz się na starcie z klasą, sprawdzasz pogodę i dbasz o swoje barwy klubowe.

## 🚀 Główne Funkcjonalności

Aplikacja oferuje kompletny ekosystem do zarządzania "honorowymi spotkaniami":

1. **Autoryzacja i Barwy Klubowe**: 
   - Rejestracja z obowiązkowym wyborem Twojego klubu (Supabase Auth).
   - Profil użytkownika zintegrowany z bazą danych, przechowujący Twoją tożsamość.

2. **Generator Aren (Overpass API)**:
   - Dynamiczne wyszukiwanie prawdziwych lokalizacji (lasy, polany, nieużytki) na terenie całej Polski prosto z map OpenStreetMap.
   - Każda ustawka odbywa się w unikalnym miejscu.

3. **Raporty Warunków Bitewnych (Open-Meteo)**:
   - Pobieranie aktualnej pogody dla wybranej areny w czasie rzeczywistym.
   - Satyryczne raporty o przyczepności butów, błocie i widoczności.

4. **Rynek Starcia (Market)**:
   - Przeglądanie dostępnych ustawek w Twojej okolicy.
   - System "Wchodzę w to!" z podglądem balansu sił między klubami w czasie rzeczywistym (Realtime).

5. **Głosowanie i Leaderboard**:
   - Po odbyciu starcia uczestnicy głosują na zwycięzcę poprzez system "Głosowania Świadków".
   - Globalny ranking klubów (SQL View) pokazujący na żywo, kto dominuje w tabeli.

6. **Status Kontuzji (L4)**:
   - Odniosłeś rany w walce? Zgłoś L4 w profilu.
   - System zablokuje Ci możliwość zapisywania się na kolejne walki do momentu zakończenia rekonwalescencji (timer 24h).

## 🎨 Design System: BRUTALISM

Aplikacja charakteryzuje się surowym, brutalistycznym stylem:
- **Kontrastowe kolory**: Głęboka czerń, krwista czerwień i jaskrawy żółty.
- **Grube obramowania**: Wszystkie elementy UI są solidne i kanciaste.
- **Typografia**: Duże, pogrubione fonty, które podkreślają klimat aplikacji.

## 🛠️ Stack Technologiczny

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (Auth, Realtime, Database, RPC Functions)
- **Mapy**: Overpass API (OpenStreetMap)
- **Pogoda**: Open-Meteo API
- **Nawigacja**: Animated Bottom Navigation Bar

## 📦 Instalacja

1. Sklonuj repozytorium:
   ```bash
   git clone https://github.com/Karman1818/Ustawko.io.git
   ```
2. Zainstaluj zależności:
   ```bash
   cd nav_bars
   flutter pub get
   ```
3. Skonfiguruj bazę Supabase używając pliku `nav_bars/supabase/schema.sql`. Pamiętaj o uruchomieniu triggerów i funkcji RPC!
4. Odpal aplikację:
   ```bash
   flutter run
   ```

---
*Aplikacja ma charakter wyłącznie satyryczny i humorystyczny.*
