import 'package:flutter/material.dart';
import '../services/local_db_service.dart';
import '../models/pokemon_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<CaughtPokemon> caught = LocalDbService.getCaughtPokemons();
    final now = DateTime.now();

    final caughtToday = caught
        .where(
          (p) =>
              p.caughtDate.year == now.year &&
              p.caughtDate.month == now.month &&
              p.caughtDate.day == now.day,
        )
        .length;
    final caughtThisWeek = caught
        .where((p) => now.difference(p.caughtDate).inDays <= 7)
        .length;
    final caughtThisMonth = caught
        .where((p) => now.difference(p.caughtDate).inDays <= 30)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Trenera")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png",
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Statystyki Łapania",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 30),
            _buildStatCard(
              context,
              "Złapane dzisiaj",
              caughtToday,
              Colors.orange,
            ),
            _buildStatCard(
              context,
              "Złapane w tym tygodniu",
              caughtThisWeek,
              Colors.green,
            ),
            _buildStatCard(
              context,
              "Złapane w tym miesiącu",
              caughtThisMonth,
              Colors.blue,
            ),
            _buildStatCard(
              context,
              "Suma wszystkich",
              caught.length,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.assessment, color: color, size: 30),
        title: Text(label),
        trailing: Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
