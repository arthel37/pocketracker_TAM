import 'package:hive_ce/hive.dart';
import '../models/pokemon_model.dart';

class LocalDbService {
  static Box get _caughtBox => Hive.box('caught_pokemon');

  static List<CaughtPokemon> getCaughtPokemons() {
    return _caughtBox.values.map((item) {
      return CaughtPokemon.fromMap(item as Map<dynamic, dynamic>);
    }).toList();
  }

  static Future<void> catchPokemon(CaughtPokemon pokemon) async {
    await _caughtBox.put(pokemon.id, pokemon.toMap());
  }

  static Future<void> releasePokemon(int id) async {
    await _caughtBox.delete(id);
  }

  static bool isCaught(int id) {
    return _caughtBox.containsKey(id);
  }
}
