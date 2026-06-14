import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class PokeApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  static Future<List<PokemonListResult>> fetchPokemonList({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((json) => PokemonListResult.fromJson(json)).toList();
    } else {
      throw Exception('Brak dostępu do serwera');
    }
  }

  static Future<PokemonDetail> fetchPokemonDetails(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon/$name'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PokemonDetail.fromJson(data);
    } else {
      throw Exception('Nie udało się pobrać szczegółów');
    }
  }
}
