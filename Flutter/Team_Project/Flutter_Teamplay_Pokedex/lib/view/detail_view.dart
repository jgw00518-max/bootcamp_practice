// 포켓몬 정보
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pokedex_app/model/pokemon.dart';

class DetailView extends StatefulWidget {
  final Pokemon pokemon;

  const DetailView({super.key, required this.pokemon});

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  // Properties
  late String pokemonName;
  late int pokemonNumber;

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    loadStorage();
  }
  
  void loadStorage() {
    pokemonName = box.read("_name") ?? '';
    pokemonNumber = box.read("_number") ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "선택 포켓몬 : ${widget.pokemon.name}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 30),
            Text(
              "도감번호 : ${widget.pokemon.number.toString().padLeft(3, '0')}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              )
            ),
          ],
        ),
      ),
    );
  }
}