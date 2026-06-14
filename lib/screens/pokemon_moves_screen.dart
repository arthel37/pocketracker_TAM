import 'package:flutter/material.dart';

class PokemonMovesScreen extends StatelessWidget {
  final List<String> moves;
  final String pokemonName;

  const PokemonMovesScreen({
    super.key,
    required this.moves,
    required this.pokemonName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ruchy: ${pokemonName.toUpperCase()}")),
      body: ListView.builder(
        itemCount: moves.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.flash_on, color: Colors.amber),
            title: Text(
              moves[index].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
