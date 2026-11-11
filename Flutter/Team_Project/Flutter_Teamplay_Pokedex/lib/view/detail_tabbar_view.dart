// 포켓몬 상세 정보 TabBar
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pokedex_app/model/pokemon.dart';
import 'package:pokedex_app/view/detail_view.dart';
import 'package:pokedex_app/view/image_view.dart';

class DetailTabbarView extends StatefulWidget {
  final Pokemon selectedPokemon;
  final List<Pokemon> pokemonList;

  const DetailTabbarView({
    super.key,
    required this.selectedPokemon,
    required this.pokemonList
  });

  @override
  State<DetailTabbarView> createState() => _DetailTabbarViewState();
}

class _DetailTabbarViewState extends State<DetailTabbarView> with SingleTickerProviderStateMixin {
  // Properties
  late TabController tabController;
  late Pokemon selectedPokemon;

  final box = GetStorage();

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
    selectedPokemon = widget.selectedPokemon;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: DropdownButton(
          value: selectedPokemon,
          icon: Icon(Icons.keyboard_arrow_down),
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold
          ),
          dropdownColor: Colors.redAccent,
          items: widget.pokemonList.map((pokemon) {
            return DropdownMenuItem(
              value: pokemon,
              child: Text(pokemon.name)
            );
          },).toList(),
          onChanged: onPokemonChanged
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.black,
          tabs: [
            Tab(
              icon: Icon(Icons.crop_original),
            ),
            Tab(
              icon: Icon(Icons.info_outline),
            )
          ]
        ),
      ),

      body: TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ImageView(pokemon: selectedPokemon),
          DetailView(pokemon: selectedPokemon)
        ]
      ),
    );
  }

  // Function
  void onPokemonChanged(Pokemon? pokemon) {
    if(pokemon == null) {
      return;
    }

    selectedPokemon = pokemon;
    setState(() {});

    box.write("_number", pokemon.number);
    box.write("_name", pokemon.name);
    box.write("_image", pokemon.image);
  }
}