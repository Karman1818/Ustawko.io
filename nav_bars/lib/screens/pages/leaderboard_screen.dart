import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabaseService = SupabaseService();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('TABELA LIDERÓW', style: theme.textTheme.displayMedium),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'RANKING NAJGROŹNIEJSZYCH KLUBÓW W POLSCE',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabaseService.getLeaderboardStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 80, color: theme.primaryColor),
                        const SizedBox(height: 20),
                        const Text('TABELA JEST PUSTA'),
                        const SizedBox(height: 10),
                        const Text('CZEKAMY NA PIERWSZĄ KREW', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                final leaderboard = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final row = leaderboard[index];
                    final club = row['club'] as String;
                    final wins = row['wins'] as int;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: index == 0 ? Colors.amber.shade900.withOpacity(0.3) : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: index == 0 ? Colors.amber : (index == 1 ? Colors.grey.shade300 : (index == 2 ? Colors.brown.shade300 : theme.colorScheme.surfaceContainerHighest)),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: index < 3 ? Colors.black : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          club,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: index == 0 ? 20 : 16,
                            color: index == 0 ? Colors.amber : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$wins', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(width: 5),
                            const Text('WYGRANYCH', style: TextStyle(fontSize: 10)),
                          ],
                        ),
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
}
