import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/ustawka.dart';

class MyBattlesScreen extends StatefulWidget {
  const MyBattlesScreen({super.key});

  @override
  State<MyBattlesScreen> createState() => _MyBattlesScreenState();
}

class _MyBattlesScreenState extends State<MyBattlesScreen> {
  final supabaseService = SupabaseService();

  Future<void> _showVoteDialog(BuildContext context, Ustawka ustawka) async {
    // Check if user already voted
    final hasVoted = await supabaseService.hasVoted(ustawka.id!);
    if (hasVoted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Już oddałeś głos w tym starciu!')),
      );
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('KTO WYGRAŁ?'),
        content: const Text('Bądź honorowy. Wskaż ekipę, która ostatecznie utrzymała się na nogach.'),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
            onPressed: () async {
              Navigator.pop(context);
              await _submitVote(context, ustawka.id!, ustawka.initiatorClub);
            },
            child: Text(ustawka.initiatorClub, style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
            onPressed: () async {
              Navigator.pop(context);
              await _submitVote(context, ustawka.id!, ustawka.targetClub);
            },
            child: Text(ustawka.targetClub, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitVote(BuildContext context, String ustawkaId, String club) async {
    try {
      await supabaseService.submitVote(ustawkaId, club);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Głos oddany! Czekamy na weryfikację.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('MOJE BITWY', style: theme.textTheme.displayMedium),
          ),
          Expanded(
            child: StreamBuilder<List<Ustawka>>(
              stream: supabaseService.getMyBattlesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_mma, size: 80, color: theme.primaryColor),
                        const SizedBox(height: 20),
                        const Text('NIE BIERZESZ UDZIAŁU W ŻADNYM STARCIU'),
                        const SizedBox(height: 10),
                        const Text('TRENUJ CIĘŻKO ALBO WRACAJ DO DOMU', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                final myBattles = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: myBattles.length,
                  itemBuilder: (context, index) {
                    final ustawka = myBattles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ListTile(
                        title: Text(
                          '${ustawka.initiatorClub} VS ${ustawka.targetClub}',
                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${ustawka.arenaName} • ${ustawka.battleDate.day.toString().padLeft(2,'0')}.${ustawka.battleDate.month.toString().padLeft(2,'0')} ${ustawka.battleDate.hour.toString().padLeft(2,'0')}:${ustawka.battleDate.minute.toString().padLeft(2,'0')}'),
                        trailing: _buildTrailing(context, ustawka),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, Ustawka ustawka) {
    if (ustawka.status == 'completed') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber),
          Text(ustawka.winner ?? 'REMIS', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      );
    } else if (ustawka.battleDate.isBefore(DateTime.now())) {
      // Walka się odbyła, czas na głosowanie
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
        onPressed: () => _showVoteDialog(context, ustawka),
        child: const Text('GŁOSUJ', style: TextStyle(color: Colors.white, fontSize: 12)),
      );
    } else {
      // Walka w przyszłości
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time),
          Text('OCZEKUJE', style: TextStyle(fontSize: 10)),
        ],
      );
    }
  }
}
