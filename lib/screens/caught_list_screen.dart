import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/local_db_service.dart';
import 'pokemon_detail_screen.dart';

class CaughtListScreen extends StatefulWidget {
  const CaughtListScreen({super.key});

  @override
  State<CaughtListScreen> createState() => _CaughtListScreenState();
}

class _CaughtListScreenState extends State<CaughtListScreen> {
  List<CaughtPokemon> caughtPokemons = [];

  @override
  void initState() {
    super.initState();
    _loadCaught();
  }

  void _loadCaught() {
    setState(() {
      caughtPokemons = LocalDbService.getCaughtPokemons();
      caughtPokemons.sort((a, b) => b.caughtDate.compareTo(a.caughtDate));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mój Pokedex")),
      body: caughtPokemons.isEmpty
          ? const Center(child: Text("Nie złapałeś jeszcze żadnego Pokemona!"))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: caughtPokemons.length,
              itemBuilder: (context, index) {
                final poke = caughtPokemons[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      poke.imageUrl,
                      errorBuilder: (c, e, s) => const Icon(Icons.pets),
                    ),
                    title: Text(poke.name.toUpperCase()),
                    subtitle: Text(
                      "Złapany: ${poke.caughtDate.toLocal().toString().split('.')[0]}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await LocalDbService.releasePokemon(poke.id);
                        _loadCaught();
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PokemonDetailScreen(
                            pokemonName: poke.name,
                            pokemonId: poke.id,
                          ),
                        ),
                      ).then((_) => _loadCaught());
                    },
                  ),
                );
              },
            ),
    );
  }
}
