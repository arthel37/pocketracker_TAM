import 'package:flutter/material.dart';
import '../services/poke_api_service.dart';
import '../services/local_db_service.dart';
import '../models/pokemon_model.dart';
import 'pokemon_moves_screen.dart';

class PokemonDetailScreen extends StatefulWidget {
  final String pokemonName;
  final int pokemonId;

  const PokemonDetailScreen({
    super.key,
    required this.pokemonName,
    required this.pokemonId,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late Future<PokemonDetail> detailFuture;
  bool isCaught = false;

  @override
  void initState() {
    super.initState();
    detailFuture = PokeApiService.fetchPokemonDetails(widget.pokemonName);
    isCaught = LocalDbService.isCaught(widget.pokemonId);
  }

  void _toggleCatch(PokemonDetail detail) async {
    if (isCaught) {
      await LocalDbService.releasePokemon(detail.id);
    } else {
      final newCatch = CaughtPokemon(
        id: detail.id,
        name: detail.name,
        imageUrl: detail.imageUrl,
        caughtDate: DateTime.now(),
      );
      await LocalDbService.catchPokemon(newCatch);
    }
    setState(() {
      isCaught = !isCaught;
    });
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.amber;
      case 'ice':
        return Colors.cyan;
      case 'fighting':
        return Colors.orange.shade900;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.indigo.shade300;
      case 'psychic':
        return Colors.pink;
      case 'bug':
        return Colors.lightGreen;
      case 'rock':
        return Colors.grey.shade700;
      case 'ghost':
        return Colors.deepPurple;
      case 'dragon':
        return Colors.indigo.shade800;
      case 'dark':
        return Colors.black87;
      case 'steel':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pinkAccent.shade100;
      case 'normal':
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pokemonName.toUpperCase())),
      body: FutureBuilder<PokemonDetail>(
        future: detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Błąd ładowania szczegółów:\n${snapshot.error}"),
            );
          }

          final detail = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    detail.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.broken_image, size: 80),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Waga: ${detail.weight / 10} kg | Wzrost: ${detail.height / 10} m",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: detail.types.map((t) {
                    final typeColor = _getTypeColor(t);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Chip(
                        label: Text(
                          t.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: typeColor,
                        side: BorderSide.none, // Usuwa domyślną obwolutę
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: Icon(
                    isCaught ? Icons.directions_run : Icons.catching_pokemon,
                  ),
                  label: Text(isCaught ? "Wypuść na wolność" : "Złap Pokemona"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCaught ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () => _toggleCatch(detail),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PokemonMovesScreen(
                          moves: detail.moves,
                          pokemonName: detail.name,
                        ),
                      ),
                    );
                  },
                  child: const Text("Zobacz listę ruchów"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
