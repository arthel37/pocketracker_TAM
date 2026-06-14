class PokemonListResult {
  final int id;
  final String name;
  final String url;
  final String imageUrl;

  PokemonListResult({
    required this.id,
    required this.name,
    required this.url,
    required this.imageUrl,
  });

  factory PokemonListResult.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final idString = url.split('/').reversed.elementAt(1);
    final id = int.parse(idString);

    return PokemonListResult(
      id: id,
      name: json['name'],
      url: url,
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
    );
  }
}

class PokemonDetail {
  final int id;
  final String name;
  final String imageUrl;
  final int weight;
  final int height;
  final List<String> types;
  final List<String> moves;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.weight,
    required this.height,
    required this.types,
    required this.moves,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    var typesList = (json['types'] as List)
        .map((t) => t['type']['name'].toString())
        .toList();
    var movesList = (json['moves'] as List)
        .map((t) => t['move']['name'].toString())
        .toList();

    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['front_default'] ?? '',
      weight: json['weight'],
      height: json['height'],
      types: typesList,
      moves: movesList,
    );
  }
}

class CaughtPokemon {
  final int id;
  final String name;
  final String imageUrl;
  final DateTime caughtDate;

  CaughtPokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.caughtDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'caughtDate': caughtDate.toIso8601String(),
    };
  }

  factory CaughtPokemon.fromMap(Map<dynamic, dynamic> map) {
    return CaughtPokemon(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      caughtDate: DateTime.parse(map['caughtDate']),
    );
  }
}
