import 'package:flutter/material.dart';
import '../../models/ustawka.dart';
import '../../services/supabase_service.dart';

class BattleMarketScreen extends StatefulWidget {
  const BattleMarketScreen({super.key});

  @override
  State<BattleMarketScreen> createState() => _BattleMarketScreenState();
}

class _BattleMarketScreenState extends State<BattleMarketScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('RYNEK STARCIA', style: theme.textTheme.displayMedium),
          ),
          Expanded(
            child: StreamBuilder<List<Ustawka>>(
              stream: _supabaseService.getUstawkiStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState(theme);
                }

                final ustawki = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: ustawki.length,
                  itemBuilder: (context, index) {
                    return _BattleCard(ustawka: ustawki[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups, size: 80, color: theme.primaryColor),
          const SizedBox(height: 20),
          const Text('BRAK AKTYWNYCH USTAWIEK W TWOJEJ OKOLICY', textAlign: TextAlign.center),
          const SizedBox(height: 10),
          const Text('BĄDŹ PIERWSZYM AGRESOREM!', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BattleCard extends StatelessWidget {
  final Ustawka ustawka;
  const _BattleCard({required this.ustawka});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEquipment = ustawka.rulesJson['equipment'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${ustawka.initiatorClub} VS ${ustawka.targetClub}',
                    style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: isEquipment ? theme.primaryColor : Colors.green,
                  child: Text(
                    isEquipment ? 'SPRZĘT' : 'SOLÓWKA',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 20),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(ustawka.arenaName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ustawka.weatherInfo ?? 'Brak danych o pogodzie',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            
            // Balans Sił (Live Stream Placeholder)
            _BalanceBar(ustawkaId: ustawka.id!, clubA: ustawka.initiatorClub, clubB: ustawka.targetClub),

            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                final String? selectedClub = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('WYBIERZ EKIPĘ', style: TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.black,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(ustawka.initiatorClub, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onTap: () => Navigator.pop(ctx, ustawka.initiatorClub),
                        ),
                        const Divider(color: Colors.white24),
                        ListTile(
                          title: Text(ustawka.targetClub, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onTap: () => Navigator.pop(ctx, ustawka.targetClub),
                        ),
                      ],
                    ),
                  ),
                );

                if (selectedClub != null) {
                  try {
                    await SupabaseService().joinUstawka(ustawka.id!, selectedClub);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('DOŁĄCZONO DO EKIPY $selectedClub!'),
                          backgroundColor: Colors.green,
                        )
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('BŁĄD: ${e.toString()}'),
                          backgroundColor: theme.primaryColor,
                        )
                      );
                    }
                  }
                }
              },
              child: const Center(child: Text('WCHODZĘ W TO!')),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceBar extends StatelessWidget {
  final String ustawkaId;
  final String clubA;
  final String clubB;

  const _BalanceBar({required this.ustawkaId, required this.clubA, required this.clubB});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabase = SupabaseService();

    return StreamBuilder<Map<String, int>>(
      stream: supabase.getParticipantCounts(ustawkaId),
      builder: (context, snapshot) {
        final counts = snapshot.data ?? {};
        final countA = counts[clubA] ?? 0;
        final countB = counts[clubB] ?? 0;
        final total = countA + countB;
        
        double percentA = 0.5;
        if (total > 0) {
          percentA = countA / total;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$clubA: $countA', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                Text('$clubB: $countB', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: (percentA * 100).toInt().clamp(1, 99),
                    child: Container(color: theme.primaryColor),
                  ),
                  Expanded(
                    flex: ((1 - percentA) * 100).toInt().clamp(1, 99),
                    child: Container(color: Colors.white),
                  ),
                ],
              ),
            ),
            const Center(
              child: Text('BALANS SIŁ', style: TextStyle(fontSize: 8, letterSpacing: 2)),
            ),
          ],
        );
      },
    );
  }
}
