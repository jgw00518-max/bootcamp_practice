import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double? _bmi;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBmi() {
    final heightCm = double.tryParse(_heightController.text.trim());
    final weightKg = double.tryParse(_weightController.text.trim());
    if (heightCm == null ||
        weightKg == null ||
        heightCm <= 0 ||
        weightKg <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('신장과 몸무게를 올바르게 입력해주세요.')));
      return;
    }
    setState(() {
      final heightM = heightCm / 100;
      _bmi = weightKg / (heightM * heightM);
    });
  }

  int get _bmiIndex {
    final bmi = _bmi;
    if (bmi == null || bmi < 18.5) return 0;
    if (bmi < 23) return 1;
    if (bmi < 25) return 2;
    if (bmi < 30) return 3;
    return 4;
  }

  String get _bmiLabel => ['저체중', '정상체중', '과체중', '비만', '고도비만'][_bmiIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('BMI 계산기'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: '신장을 입력하세요 (단위 : cm)',
                  hintText: '예) 170',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: '몸무게를 입력하세요 (단위 : kg)',
                  hintText: '예) 60',
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _calculateBmi,
                  child: const Text('BMI 계산'),
                ),
              ),
              const SizedBox(height: 36),
              if (_bmi != null)
                Text(
                  '귀하의 BMI지수는 ${_bmi!.toStringAsFixed(1)}이고 $_bmiLabel 입니다.',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 24),
              _BmiIndicator(selectedIndex: _bmiIndex),
            ],
          ),
        ),
      ),
    );
  }
}

class _BmiIndicator extends StatelessWidget {
  const _BmiIndicator({required this.selectedIndex});
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면의 실제 가로 길이를 5등분하고, 선택 구간의 중심에 화살표를 놓습니다.
        final sectionWidth = constraints.maxWidth / 5;
        const arrowWidth = 40.0;
        final arrowLeft =
            sectionWidth * selectedIndex + (sectionWidth - arrowWidth) / 2;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 42),
              child: Image.asset(
                'images/bmi.png',
                width: constraints.maxWidth,
                fit: BoxFit.fitWidth,
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              left: arrowLeft,
              child: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
                size: arrowWidth,
              ),
            ),
          ],
        );
      },
    );
  }
}
