import 'package:flutter/material.dart';
import '../services/poke_api_service.dart';
import '../models/pokemon_model.dart';
import 'pokemon_detail_screen.dart';

class UncaughtListScreen extends StatefulWidget {
  const UncaughtListScreen({super.key});

  @override
  State<UncaughtListScreen> createState() => _UncaughtListScreenState();
}

class _UncaughtListScreenState extends State<UncaughtListScreen> {
  final List<PokemonListResult> _pokemons = [];

  final ScrollController _scrollController = ScrollController();

  int _offset = 0;
  final int _limit = 50;

  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore) {
        _loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingInitial = true;
      _hasError = false;
      _offset = 0;
      _pokemons.clear();
    });

    try {
      final data = await PokeApiService.fetchPokemonList(
        limit: _limit,
        offset: _offset,
      );
      setState(() {
        _pokemons.addAll(data);
        _offset += _limit;
        _isLoadingInitial = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoadingInitial = false;
      });
      _showErrorBanner('Błąd połączenia: $e');
    }
  }

  Future<void> _loadMoreData() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final data = await PokeApiService.fetchPokemonList(
        limit: _limit,
        offset: _offset,
      );
      setState(() {
        _pokemons.addAll(data);
        _offset += _limit;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorBanner('Błąd podczas pobierania kolejnych Pokemonów');
    }
  }

  Future<void> _refreshData() async {
    await _loadInitialData();
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
      body: RefreshIndicator(onRefresh: _refreshData, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError && _pokemons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Błąd połączenia",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text("Odśwież"),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _pokemons.length,
            itemBuilder: (context, index) {
              final poke = _pokemons[index];
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
                  ).then((_) => setState(() {}));
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
          ),
        ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
