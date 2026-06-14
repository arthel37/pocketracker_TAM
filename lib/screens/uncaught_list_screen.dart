import 'package:flutter/material.dart';
import '../services/poke_api_service.dart';
import '../models/pokemon_model.dart';
import 'pokemon_detail_screen.dart';

class UncaughtListScreen extends StatefulWidget {
  const UncaughtListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _UncaughtListScreenState();
}

class _UncaughtListScreenState extends State<UncaughtListScreen> {
  late Future<List<PokemonListResult>> pokemonFuture;

  @override
  void initState() {
    super.initState();
    pokemonFuture = PokeApiService.fetchPokemonList();
  }

  Future<void> _refreshData() async {
    setState(() {
      pokemonFuture = PokeApiService.fetchPokemonList();
    });

    try {
      await pokemonFuture;
    } catch (e) {
      _showErrorBanner('Błąd pobierania danych');
    }
  }

  void _showErrorBanner(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 4), () => overlayEntry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dzikie Pokemony")),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<PokemonListResult>>(
          future: pokemonFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        "Błąd: ${snapshot.error}",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshData,
                        child: const Text("Odśwież"),
                      ),
                    ],
                  ),
                ),
              );
            }

            final pokemons = snapshot.data ?? [];
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: pokemons.length,
              itemBuilder: (context, index) {
                final poke = pokemons[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PokemonDetailScreen(
                          pokemonName: poke.name,
                          pokemonId: poke.id,
                        ),
                      ),
                    ).then((_) => setState(() {})); // Odśwież po powrocie
                  },
                  child: Card(
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          poke.imageUrl,
                          height: 80,
                          errorBuilder: (c, e, s) => const Icon(Icons.error),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          poke.name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
