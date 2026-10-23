import 'package:flutter/material.dart';

import '../models/address_result.dart';
import '../models/saved_address.dart';
import '../repositories/saved_address_repository.dart';
import '../widgets/address_field.dart';
import '../widgets/address_label_dialog.dart';
import 'address_search_page.dart';

/// 주소 검색, 상세주소 입력, 로컬 저장 주소 목록을 한 화면에서 관리한다.
class AddressHomePage extends StatefulWidget {
  const AddressHomePage({super.key, this.repository});

  final SavedAddressRepository? repository;

  @override
  State<AddressHomePage> createState() => _AddressHomePageState();
}

class _AddressHomePageState extends State<AddressHomePage> {
  final _detailAddressController = TextEditingController();
  late final SavedAddressRepository _repository;
  List<SavedAddress> _savedAddresses = [];
  String _address = '';
  String _zoneCode = '';
  String? _editingId;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPrinted = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SavedAddressRepository();
    _loadSavedAddresses();
  }

  @override
  void dispose() {
    _detailAddressController.dispose();
    super.dispose();
  }

  /// 앱 재시작 뒤에도 남아 있는 주소 목록을 불러온다.
  Future<void> _loadSavedAddresses() async {
    try {
      final addresses = await _repository.load();
      if (mounted) setState(() => _savedAddresses = addresses);
    } catch (_) {
      if (mounted) _showMessage('저장된 주소를 불러오지 못했습니다.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 카카오 검색 결과를 입력 상태에 반영하고 새 저장 모드로 전환한다.
  Future<void> _searchAddress() async {
    final result = await Navigator.of(context).push<AddressResult>(
      MaterialPageRoute(builder: (_) => const AddressSearchPage()),
    );
    if (result == null || !mounted) return;
    setState(() {
      _address = result.address;
      _zoneCode = result.zoneCode;
      _editingId = null;
      _detailAddressController.clear();
      _isPrinted = false;
    });
  }

  /// 별칭 다이얼로그에서 값을 받은 뒤 주소 저장 작업을 시작한다.
  Future<void> _showSaveDialog() async {
    if (_address.isEmpty) {
      _showMessage('먼저 주소를 검색해 선택해 주세요.');
      return;
    }
    final currentItem = _savedAddresses
        .where((item) => item.id == _editingId)
        .firstOrNull;
    final label = await showDialog<String>(
      context: context,
      builder: (_) => AddressLabelDialog(
        initialLabel: currentItem?.label ?? '',
        isEditing: _editingId != null,
      ),
    );
    if (!mounted || label == null) return;
    if (label.isEmpty) {
      _showMessage('주소 별칭을 입력해 주세요. 예: 집, 회사');
      return;
    }
    await _saveAddress(label);
  }

  /// 저장 중에는 중복 실행을 막고, 저장 실패를 사용자에게 안내한다.
  Future<void> _saveAddress(String label) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final item = SavedAddress(
      id: _editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      label: label,
      address: _address,
      zoneCode: _zoneCode,
      detailAddress: _detailAddressController.text.trim(),
    );
    final index = _savedAddresses.indexWhere(
      (address) => address.id == item.id,
    );
    final updated = [..._savedAddresses];
    if (index == -1) {
      updated.add(item);
    } else {
      updated[index] = item;
    }
    try {
      await _repository.saveAll(updated);
      if (!mounted) return;
      setState(() {
        _savedAddresses = updated;
        _editingId = item.id;
      });
      _showMessage(index == -1 ? '주소를 저장했습니다.' : '저장 주소를 수정했습니다.');
    } catch (_) {
      if (mounted) _showMessage('주소 저장에 실패했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// 목록에서 누른 주소를 불러와 상세주소와 별칭을 수정할 수 있게 한다.
  void _selectAddress(SavedAddress item) {
    setState(() {
      _editingId = item.id;
      _address = item.address;
      _zoneCode = item.zoneCode;
      _detailAddressController.text = item.detailAddress;
      _isPrinted = false;
    });
  }

  /// 사용자가 확인한 뒤 선택 주소를 로컬 저장소와 목록에서 제거한다.
  Future<void> _deleteAddress(SavedAddress item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장 주소 삭제'),
        content: Text('${item.label} 주소를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final updated = _savedAddresses
        .where((address) => address.id != item.id)
        .toList();
    try {
      await _repository.saveAll(updated);
      if (!mounted) return;
      setState(() {
        _savedAddresses = updated;
        if (_editingId == item.id) _clearEditor();
      });
      _showMessage('저장 주소를 삭제했습니다.');
    } catch (_) {
      if (mounted) _showMessage('주소 삭제에 실패했습니다. 다시 시도해 주세요.');
    }
  }

  void _clearEditor() {
    _editingId = null;
    _address = '';
    _zoneCode = '';
    _detailAddressController.clear();
    _isPrinted = false;
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final hasAddress = _address.isNotEmpty;
    final detailAddress = _detailAddressController.text.trim();
    return Scaffold(
      appBar: AppBar(
        title: const Text('KaKao 주소 API 연동'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '내 주소 관리',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '주소를 검색하고 자주 쓰는 장소를 저장해 보세요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('address_search_button'),
              onPressed: _searchAddress,
              style: _buttonStyle,
              child: const Text('주소 검색'),
            ),
            const SizedBox(height: 18),
            AddressField(
              label: '선택한 주소(기본주소)',
              value: hasAddress ? _address : '주소 검색 버튼을 눌러 선택해 주세요.',
              trailing: hasAddress ? '우편번호: $_zoneCode' : null,
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('detail_address_field'),
              controller: _detailAddressController,
              enabled: hasAddress,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: '나머지 주소(상세주소)',
                hintText: '동, 호수 등 상세주소를 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('save_address_button'),
              onPressed: _isSaving ? null : _showSaveDialog,
              icon: const Icon(Icons.save_outlined),
              label: Text(
                _isSaving
                    ? '저장 중...'
                    : _editingId == null
                    ? '주소 저장'
                    : '주소 수정 저장',
              ),
            ),
            const SizedBox(height: 20),
            const Text('저장된 주소', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_savedAddresses.isEmpty)
              const Text('저장된 주소가 없습니다.')
            else
              ..._savedAddresses.map(
                (item) => Card(
                  color: _editingId == item.id
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: _editingId == item.id
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => _selectAddress(item),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.location_on_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(item.label),
                    subtitle: Text(
                      '(${item.zoneCode}) ${item.address}${item.detailAddress.isEmpty ? '' : ' ${item.detailAddress}'}',
                    ),
                    trailing: IconButton(
                      tooltip: '삭제',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteAddress(item),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: hasAddress
                  ? () => setState(() => _isPrinted = true)
                  : () => _showMessage('먼저 주소를 검색해 선택해 주세요.'),
              style: _buttonStyle,
              child: const Text('전체 주소 보기'),
            ),
            const SizedBox(height: 18),
            const Text('구분 출력', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: !_isPrinted
                    ? const Text('아직 출력할 내용이 없습니다. 주소를 선택한 뒤 버튼을 눌러 주세요.')
                    : Text(
                        '1) 기본주소: $_address\n2) 상세주소: ${detailAddress.isEmpty ? '-' : detailAddress}\n3) 전체주소: ($_zoneCode) $_address${detailAddress.isEmpty ? '' : ' $detailAddress'}',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _buttonStyle = FilledButton.styleFrom(
  minimumSize: const Size.fromHeight(52),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
);
