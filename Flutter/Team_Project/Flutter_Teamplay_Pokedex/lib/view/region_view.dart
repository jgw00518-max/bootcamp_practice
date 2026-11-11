import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pokedex_app/model/pokemon.dart';
import 'package:pokedex_app/model/region.dart';

import 'pokemon_list_view.dart';

class RegionView extends StatefulWidget {
  const RegionView({super.key});

  @override
  State<RegionView> createState() => _RegionViewState();
}

class _RegionViewState extends State<RegionView> {
  late List<Region> regionList;
  late String loginId;

  final box = GetStorage();

  // ★ 잡은 포켓몬 번호 목록
  List<int> caughtPokemonNumbers = [];

  @override
  void initState() {
    super.initState();

    // LoginView에서 arguments로 넘긴 ID 받기
    loginId = Get.arguments ?? '사용자';

    regionList = [];
    addData();
    initStorage();
    loadCaughtData();
  }

  // ★ 저장된 포획 포켓몬 데이터 불러오기
  void loadCaughtData() {
    List<dynamic> savedCaught = box.read("caughtPokemonNumbers") ?? [];
    setState(() {
      caughtPokemonNumbers = savedCaught.cast<int>();
    });
  }

  // ★ 각 지방별 수집률(0.0 ~ 1.0) 계산 함수
  double getRegionProgress(Region region) {
    if (region.pokemonList.isEmpty) return 0.0;

    int caughtCount = region.pokemonList
        .where((pokemon) => caughtPokemonNumbers.contains(pokemon.number))
        .length;

    return caughtCount / region.pokemonList.length;
  }

  void addData() {
    regionList.add(Region(
      name: "관동", image: "images/gen1.png",
      pokemonList: [
        Pokemon(number: 1, name: "이상해씨", image: "images/gen1_1.png"),
        Pokemon(number: 4, name: "파이리", image: "images/gen1_2.png"),
        Pokemon(number: 7, name: "꼬부기", image: "images/gen1_3.png"),
        Pokemon(number: 144, name: "프리져", image: "images/gen1_4.png")
      ]
    ));

    regionList.add(Region(
      name: "성도", image: "images/gen2.png",
      pokemonList: [
        Pokemon(number: 152, name: "치코리타", image: "images/gen2_1.png"),
        Pokemon(number: 155, name: "브케인", image: "images/gen2_2.png"),
        Pokemon(number: 158, name: "리아코", image: "images/gen2_3.png"),
        Pokemon(number: 244, name: "앤테이", image: "images/gen2_4.png")
      ]
    ));

    regionList.add(Region(
      name: "호연", image: "images/gen3.png",
      pokemonList: [
        Pokemon(number: 252, name: "나무지기", image: "images/gen3_1.png"),
        Pokemon(number: 255, name: "아차모", image: "images/gen3_2.png"),
        Pokemon(number: 258, name: "물짱이", image: "images/gen3_3.png"),
        Pokemon(number: 384, name: "레쿠쟈", image: "images/gen3_4.png")
      ]
    ));

    regionList.add(Region(
      name: "신오", image: "images/gen4.png",
      pokemonList: [
        Pokemon(number: 387, name: "모부기", image: "images/gen4_1.png"),
        Pokemon(number: 390, name: "불꽃숭이", image: "images/gen4_2.png"),
        Pokemon(number: 393, name: "팽도리", image: "images/gen4_3.png"),
        Pokemon(number: 484, name: "펄기아", image: "images/gen4_4.png")
      ]
    ));

    regionList.add(Region(
      name: "하나", image: "images/gen5.png",
      pokemonList: [
        Pokemon(number: 495, name: "주리비얀", image: "images/gen5_1.png"),
        Pokemon(number: 498, name: "뚜꾸리", image: "images/gen5_2.png"),
        Pokemon(number: 501, name: "수댕이", image: "images/gen5_3.png"),
        Pokemon(number: 643, name: "레시라무", image: "images/gen5_4.png")
      ]
    ));

    regionList.add(Region(
      name: "칼로스", image: "images/gen6.png",
      pokemonList: [
        Pokemon(number: 650, name: "도치마론", image: "images/gen6_1.png"),
        Pokemon(number: 653, name: "푸호꼬", image: "images/gen6_2.png"),
        Pokemon(number: 656, name: "개구마르", image: "images/gen6_3.png"),
        Pokemon(number: 717, name: "이벨타르", image: "images/gen6_4.png")
      ]
    ));

    regionList.add(Region(
      name: "알로라", image: "images/gen7.png",
      pokemonList: [
        Pokemon(number: 722, name: "나몰빼미", image: "images/gen7_1.png"),
        Pokemon(number: 725, name: "냐오불", image: "images/gen7_2.png"),
        Pokemon(number: 728, name: "누리공", image: "images/gen7_3.png"),
        Pokemon(number: 791, name: "솔가레오", image: "images/gen7_4.png")
      ]
    ));

    regionList.add(Region(
      name: "가라르", image: "images/gen8.png",
      pokemonList: [
        Pokemon(number: 810, name: "흥나숭", image: "images/gen8_1.png"),
        Pokemon(number: 813, name: "염버니", image: "images/gen8_2.png"),
        Pokemon(number: 816, name: "울머기", image: "images/gen8_3.png"),
        Pokemon(number: 980, name: "무한다이노", image: "images/gen8_4.png")
      ]
    ));

    regionList.add(Region(
      name: "팔데아", image: "images/gen9.png",
      pokemonList: [
        Pokemon(number: 906, name: "나오하", image: "images/gen9_1.png"),
        Pokemon(number: 909, name: "뜨아거", image: "images/gen9_2.png"),
        Pokemon(number: 912, name: "꾸왁스", image: "images/gen9_3.png"),
        Pokemon(number: 1007, name: "코라이돈", image: "images/gen9_4.png")
      ]
    ));
  }

  void initStorage() {
    box.write("_regionName", "");
    box.write("_pokemons", "");
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///// 화면구성 ////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        toolbarHeight: 70,
        title: Text(
          '$loginId님의 전국도감',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),

        child: Column(
          children: [

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/background.png'),
                    fit: BoxFit.contain,
                  ),
                ),

                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 0.75, // ★ 진행률 바 공간 확보를 위해 비율 살짝 조정
                  ),
                  itemCount: regionList.length,
                  itemBuilder: (context, index) {
                    return _buildGridItem(index);
                  },
                ),
              ),
            ),

            Image.asset(
              'images/logo.png',
              width: 100,
              height: 50,
              fit: BoxFit.contain,
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      )
    );
  }

  // ==================== [분리된 함수] ====================

  Widget _buildGridItem(int index) {
    return GestureDetector(
      onTap: () => _onRegionTap(index),
      child: _buildCard(index),
    );
  }

  Widget _buildCard(int index) {
    final region = regionList[index];
    final double progress = getRegionProgress(region);
    final int percentage = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                region.image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                region.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            
            // ★ 수집률 진행률 바 & 백분율 텍스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFFE53935),
                    minHeight: 4,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$percentage%",
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ★ 페이지 이동 후 뒤로 가기로 돌아왔을 때 수집률 자동 갱신 (async / await 추가)
  void _onRegionTap(int index) async {
    saveStorage(index);
    await Get.to(() => const PokemonListView());
    loadCaughtData(); // 목록 화면에서 돌아오면 데이터 다시 불러오기
  }

  void saveStorage(int index) {
    box.write("_regionName", regionList[index].name);

    final pokemonMapList = regionList[index].pokemonList.map(
      (pokemon) {
        return {
          "number": pokemon.number,
          "name": pokemon.name,
          "image": pokemon.image
        };
      },
    ).toList();

    box.write("_pokemons", pokemonMapList);
  }
}