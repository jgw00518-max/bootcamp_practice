// 지역 모델
import 'package:pokedex_app/model/pokemon.dart';

class Region {
  // Properties
  String name;
  String image;
  List<Pokemon> pokemonList;

  // Constructor
  Region(
    {
      required this.name,
      required this.image,
      required this.pokemonList
    }
  );
}