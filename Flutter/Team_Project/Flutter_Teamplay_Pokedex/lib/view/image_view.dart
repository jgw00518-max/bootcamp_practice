// 포켓몬 이미지
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pokedex_app/model/pokemon.dart';

class ImageView extends StatefulWidget {
  final Pokemon pokemon;

  const ImageView({super.key, required this.pokemon});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  // Properties
  late String pokemonImage;

  final box = GetStorage();

  double _angleX = 0.0;
  double _angleY = 0.0;
  // 최대 기울기 각도 제한
  final double _maxTiltAngle = 0.5;
  // 드래그 중에는 0초(즉시 반영), 손을 떼면 애니메이션 시간 부여
  Duration _animationDuration = Duration.zero; 

  @override
  void initState() {
    super.initState();
    loadStorage();
  }

  void loadStorage() {
    pokemonImage = box.read("_image") ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _animationDuration = Duration.zero; // 드래그 중엔 즉각 반응
              // 기존 값에 드래그 변화량을 더한 후, clamp로 최소/최대 범위 제한
              _angleY = (_angleY + details.delta.dx * 0.01).clamp(-_maxTiltAngle, _maxTiltAngle);
              _angleX = (_angleX - details.delta.dy * 0.01).clamp(-_maxTiltAngle, _maxTiltAngle);
            });
          },
          onPanEnd: (details) {
            setState(() {
              _animationDuration = const Duration(milliseconds: 300); // 0.5초 동안 복귀
              // 손을 떼면 원위치
              _angleX = 0.0;
              _angleY = 0.0;
            });
          },
          child: TweenAnimationBuilder(
            tween: Tween<Offset>(
              begin: Offset(_angleX, _angleY),
              end: Offset(_angleX, _angleY)
            ),
            duration: _animationDuration,
            builder: (context, offset, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(offset.dx)
                  ..rotateY(offset.dy),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: Card(
              color: Color.fromARGB(255, 226, 255, 228),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Image.asset(
                  widget.pokemon.image,
                  height: 230,
                  width: 230,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}