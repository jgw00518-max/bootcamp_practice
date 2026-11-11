// 지역 별 포켓몬 목록
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pokedex_app/model/pokemon.dart';
import 'package:pokedex_app/view/detail_tabbar_view.dart';

class PokemonListView extends StatefulWidget {
  const PokemonListView({super.key});

  @override
  State<PokemonListView> createState() => _PokemonListViewState();
}

class _PokemonListViewState extends State<PokemonListView> {
  // Properties
  late String regionName;
  late List<Pokemon> pokemonList;

  final box = GetStorage();

  // ★ 잡은 포켓몬 도감 번호 저장 리스트
  List<int> caughtPokemonNumbers = [];

  @override
  void initState() {
    super.initState();

    loadStorage();
  }

  void loadStorage() {
    regionName = box.read("_regionName") ?? '';
    final data = box.read("_pokemons") ?? [];

    pokemonList = (data as List).map(
      (item) => Pokemon(
        number: item["number"] ?? 0,
        name: item["name"] ?? '',
        image: item["image"] ?? ''
      ),
    ).toList();

    // ★ 저장되어 있던 포획 포켓몬 번호 목록 불러오기
    List<dynamic> savedCaught = box.read("caughtPokemonNumbers") ?? [];
    caughtPokemonNumbers = savedCaught.cast<int>();
  }

  // ★ 포켓볼 클릭 시 포획 상태 변경 함수
  void toggleCatch(int pokemonNumber) {
    setState(() {
      if (caughtPokemonNumbers.contains(pokemonNumber)) {
        caughtPokemonNumbers.remove(pokemonNumber);
      } else {
        caughtPokemonNumbers.add(pokemonNumber);
      }
    });

    // ★ 변경된 포획 상태를 GetStorage에 즉시 업데이트
    box.write("caughtPokemonNumbers", caughtPokemonNumbers);
  }

  @override
  void dispose() {
    box.remove("_regionName");
    box.remove("_pokemons");
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "$regionName지방",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        toolbarHeight: 70,
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: pokemonList.length,
          itemBuilder: (context, index) {
            final pokemon = pokemonList[index];
            // ★ 해당 포켓몬이 잡은 상태인지 확인
            final bool isCaught = caughtPokemonNumbers.contains(pokemon.number);
        
            return GestureDetector(
              onTap: () {
                final selectedPokemon = pokemonList[index];
                saveStorage(selectedPokemon);
                Get.to(DetailTabbarView(
                  selectedPokemon: selectedPokemon,
                  pokemonList: pokemonList,
                ));
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                child: SizedBox(
                  height: 120,
                  child: Card(
                    elevation: 3,
                    color: index % 2 == 0
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Image.asset(pokemonList[index].image)
                          ),
                          Text(
                            "     ${pokemonList[index].name}",
                            style: TextStyle(
                              fontSize: 15
                            ),
                          ),
                          const Spacer(), // ★ 오른쪽 끝으로 아이콘 배치
                          
                          // ★ 포획 등록/해제 포켓볼 버튼
                          IconButton(
                            icon: Image.asset(
                              'images/background.png',
                              width: 32,
                              height: 32,
                              color: isCaught ? null : Colors.grey.withValues(alpha: 0.4),
                              colorBlendMode: isCaught ? BlendMode.dst : BlendMode.modulate,
                            ),
                            onPressed: () {
                              toggleCatch(pokemon.number);
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Functions
  void saveStorage(Pokemon selectedPokemon) {
    box.write("_number", selectedPokemon.number);
    box.write("_name", selectedPokemon.name);
    box.write("_image", selectedPokemon.image);
  }
}