import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 두 숫자의 사칙연산 결과를 보여주는 계산기 화면입니다.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

/// 입력값, 계산 결과, 각 결과의 표시 상태를 관리합니다.
class _HomeState extends State<Home> {
  /// 첫 번째 숫자 입력을 관리합니다.
  final num1controller = TextEditingController();

  /// 두 번째 숫자 입력을 관리합니다.
  final num2controller = TextEditingController();

  /// 덧셈 결과를 표시하는 읽기 전용 필드의 컨트롤러입니다.
  final _addController = TextEditingController();

  /// 뺄셈 결과를 표시하는 읽기 전용 필드의 컨트롤러입니다.
  final _subtractController = TextEditingController();

  /// 곱셈 결과를 표시하는 읽기 전용 필드의 컨트롤러입니다.
  final _multiplyController = TextEditingController();

  /// 나눗셈 결과를 표시하는 읽기 전용 필드의 컨트롤러입니다.
  final _divideController = TextEditingController();

  /// 각 사칙연산 결과를 화면에 노출할지 결정하는 스위치 상태입니다.
  bool _showAdd = false,
      _showSubtract = false,
      _showMultiply = true,
      _showDivide = true;

  /// 계산 후 저장되는 사칙연산 결과입니다.
  double? _add, _subtract, _multiply, _divide;

  /// 화면 종료 시 생성한 컨트롤러를 해제합니다.
  @override
  void dispose() {
    for (final controller in [
      num1controller,
      num2controller,
      _addController,
      _subtractController,
      _multiplyController,
      _divideController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 정수는 소수점 없이, 실수는 소수점을 유지하여 문자열로 변환합니다.
  String _format(double value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();

  /// 입력값을 검증하고 사칙연산 결과를 계산합니다.
  void _calculate() {
    final first = double.tryParse(num1controller.text);
    final second = double.tryParse(num2controller.text);
    if (first == null || second == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('두 개의 숫자를 올바르게 입력해주세요.')));
      return;
    }
    setState(() {
      _add = first + second;
      _subtract = first - second;
      _multiply = first * second;
      _divide = second == 0 ? null : first / second;
      _syncResults();
    });
  }

  /// 스위치가 켜진 연산 결과만 읽기 전용 필드에 표시합니다.
  void _syncResults() {
    _addController.text = _showAdd && _add != null ? _format(_add!) : '';
    _subtractController.text = _showSubtract && _subtract != null
        ? _format(_subtract!)
        : '';
    _multiplyController.text = _showMultiply && _multiply != null
        ? _format(_multiply!)
        : '';
    _divideController.text = _showDivide && _divide != null
        ? _format(_divide!)
        : '';
  }

  /// 두 입력값과 계산 결과를 모두 지웁니다.
  void _clear() => setState(() {
    num1controller.clear();
    num2controller.clear();
    _add = _subtract = _multiply = _divide = null;
    _syncResults();
  });

  /// 스위치 변경을 반영하고 결과 표시를 갱신합니다.
  void _changeSwitch(bool value, void Function(bool) update) => setState(() {
    update(value);
    _syncResults();
  });

  /// 입력, 버튼, 스위치 및 결과 필드로 계산기 화면을 구성합니다.
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      centerTitle: true,
      title: const Text('간단한 계산기'),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _numberField(num1controller, '첫번째 숫자를 입력하세요'),
            const SizedBox(height: 14),
            _numberField(num2controller, '두번째 숫자를 입력하세요'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _calculate,
                  child: const Text('계산하기'),
                ),
                const SizedBox(width: 28),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: _clear,
                  child: const Text('지우기'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              children: [
                _operationSwitch(
                  '덧셈:',
                  _showAdd,
                  (v) => _changeSwitch(v, (x) => _showAdd = x),
                ),
                _operationSwitch(
                  '뺄셈:',
                  _showSubtract,
                  (v) => _changeSwitch(v, (x) => _showSubtract = x),
                ),
                _operationSwitch(
                  '곱셈:',
                  _showMultiply,
                  (v) => _changeSwitch(v, (x) => _showMultiply = x),
                ),
                _operationSwitch(
                  '나눗셈:',
                  _showDivide,
                  (v) => _changeSwitch(v, (x) => _showDivide = x),
                ),
              ],
            ),
            const SizedBox(height: 36),
            _resultField('덧셈 결과', _addController),
            _resultField('뺄셈 결과', _subtractController),
            _resultField('곱셈 결과', _multiplyController),
            _resultField('나눗셈 결과', _divideController),
          ],
        ),
      ),
    ),
  );

  /// 숫자, 소수점, 음수 기호만 입력 가능한 숫자 입력 필드입니다.
  Widget _numberField(TextEditingController controller, String label) =>
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
        ],
        decoration: InputDecoration(labelText: label),
      );

  /// 특정 연산 결과의 표시 여부를 제어하는 스위치입니다.
  Widget _operationSwitch(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label),
      Switch(value: value, onChanged: onChanged),
    ],
  );

  /// 사용자가 수정할 수 없는 계산 결과 표시 필드입니다.
  Widget _resultField(String label, TextEditingController controller) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(labelText: label),
        ),
      );
}
