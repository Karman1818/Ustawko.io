import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/arena_service.dart';
import '../../models/arena.dart';
import '../../models/ustawka.dart';
import '../../services/supabase_service.dart';

class ArenaRadarScreen extends StatefulWidget {
  const ArenaRadarScreen({super.key});

  @override
  State<ArenaRadarScreen> createState() => _ArenaRadarScreenState();
}

class _ArenaRadarScreenState extends State<ArenaRadarScreen> {
  final ArenaService _arenaService = ArenaService();
  final SupabaseService _supabaseService = SupabaseService();
  Arena? _currentArena;
  bool _isLoading = false;
  String? _selectedInitiator;
  String? _selectedTarget;
  bool _useEquipment = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _selectedInitiator = AppConstants.popularClubs[0];
    _selectedTarget = AppConstants.popularClubs[1];
    _drawArena();
  }

  Future<void> _drawArena() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final arena = await _arenaService.generateRandomArena();
      if (!mounted) return;
      setState(() => _currentArena = arena);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('KREATOR STARCIA', style: textTheme.displayMedium),
            const SizedBox(height: 20),
            
            // Wybór Klubów
            _buildClubSelector('TWÓJ KLUB', _selectedInitiator, (val) {
              setState(() => _selectedInitiator = val);
            }),
            const SizedBox(height: 10),
            Center(child: Text('VS', style: textTheme.headlineLarge)),
            const SizedBox(height: 10),
            _buildClubSelector('PRZECIWNIK', _selectedTarget, (val) {
              setState(() => _selectedTarget = val);
            }),
            
            const SizedBox(height: 30),
            
            // Zasady
            Text('ZASADY', style: textTheme.headlineLarge),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildToggleButton(
                    'CZYSTE RĘCE', 
                    !_useEquipment, 
                    () => setState(() => _useEquipment = false)
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildToggleButton(
                    'SPRZĘT', 
                    _useEquipment, 
                    () => setState(() => _useEquipment = true)
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Data i Godzina
            Text('TERMIN STARCIA', style: textTheme.headlineLarge),
            const SizedBox(height: 10),
            ListTile(
              tileColor: Colors.grey[900],
              title: Text(
                '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year} ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              trailing: const Icon(Icons.calendar_today, color: Colors.white),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date == null || !context.mounted) return;
                
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_selectedDate),
                );
                if (time == null || !context.mounted) return;
                
                setState(() {
                  _selectedDate = DateTime(
                    date.year, date.month, date.day,
                    time.hour, time.minute
                  );
                });
              },
            ),

            const SizedBox(height: 30),

            // Arena i Pogoda
            Text('RADAR AREN', style: textTheme.headlineLarge),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentArena?.name.toUpperCase() ?? 'SZUKANIE POLANY...',
                          style: textTheme.titleLarge?.copyWith(color: theme.primaryColor),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'RAPORT WARUNKÓW BITEWNYCH:',
                          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _currentArena?.weatherReport ?? 'Brak danych wywiadowczych.',
                          style: textTheme.bodyLarge,
                        ),
                      ],
                    ),
              ),
            ),
            
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _drawArena,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('LOSUJ INNĄ ARENĘ'),
            ),

            const SizedBox(height: 40),
            
            // Przycisk Główny
            ElevatedButton(
              onPressed: _isLoading || _currentArena == null ? null : () async {
                setState(() => _isLoading = true);
                try {
                  final newUstawka = Ustawka(
                    id: null, // Supabase wygeneruje UUID
                    initiatorClub: _selectedInitiator!,
                    targetClub: _selectedTarget!,
                    arenaName: _currentArena!.name,
                    arenaLat: _currentArena!.lat,
                    arenaLng: _currentArena!.lng,
                    weatherInfo: _currentArena!.weatherReport,
                    battleDate: _selectedDate,
                    rulesJson: {'equipment': _useEquipment},
                    status: 'pending',
                  );

                  await _supabaseService.createUstawka(newUstawka);
                  
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PROJEKT USTAWKI ZGŁOSZONY DO SYSTEMU!'),
                      backgroundColor: Colors.green,
                    )
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('BŁĄD SYSTEMU: $e'), backgroundColor: Colors.red)
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
              child: const Text('ZATWIERDŹ USTAWKĘ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubSelector(String label, String? current, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
        Container(
          margin: const EdgeInsets.only(top: 5),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: Colors.grey[900],
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: current,
              isExpanded: true,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              items: AppConstants.popularClubs.map((club) {
                return DropdownMenuItem(value: club, child: Text(club));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          border: Border.all(color: isSelected ? theme.primaryColor : Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            label, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: isSelected ? Colors.white : Colors.white
            )
          ),
        ),
      ),
    );
  }
}
