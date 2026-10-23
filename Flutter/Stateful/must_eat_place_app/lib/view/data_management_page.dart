import 'package:flutter/material.dart';

import '../vm/backup_file_service.dart';
import '../vm/must_eat_place_view_model.dart';

/// 맛집 데이터를 JSON 파일로 백업하고 선택한 파일로 복원하는 화면이다.
class DataManagementPage extends StatefulWidget {
  const DataManagementPage({
    super.key,
    required this.viewModel,
    this.fileService = const BackupFileService(),
  });

  final MustEatPlaceViewModel viewModel;
  final BackupFileService fileService;

  @override
  State<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends State<DataManagementPage> {
  bool _working = false;

  /// 현재 SQLite 스냅샷을 만들고 사용자가 선택한 위치에 JSON으로 저장한다.
  Future<void> _exportBackup() async {
    if (_working) return;
    setState(() => _working = true);
    try {
      final backup = await widget.viewModel.createBackup();
      final saved = await widget.fileService.save(backup);
      if (saved) _showMessage('백업 파일을 저장했습니다.');
    } catch (error) {
      _showMessage('백업하지 못했습니다: ${_readableError(error)}');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  /// 파일을 먼저 검증하고 사용자 확인 후 기존 SQLite 데이터를 교체한다.
  Future<void> _restoreBackup() async {
    if (_working) return;
    setState(() => _working = true);
    try {
      final backup = await widget.fileService.pick();
      if (backup == null || !mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('백업 데이터 복원'),
          content: Text(
            '현재 데이터를 지우고 맛집 ${backup.places.length}개와 '
            '카테고리 ${backup.categories.length}개를 복원할까요?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              key: const Key('confirm_restore_button'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('복원'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      await widget.viewModel.restoreBackup(backup);
      _showMessage('백업 데이터를 복원했습니다.');
    } catch (error) {
      _showMessage('복원하지 못했습니다: ${_readableError(error)}');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _readableError(Object error) {
    return error
        .toString()
        .replaceFirst('Bad state: ', '')
        .replaceFirst('FormatException: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('데이터 관리')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_done_outlined,
                  size: 38,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '현재 저장된 맛집 ${widget.viewModel.totalCount}개를 '
                    'JSON 파일로 안전하게 보관할 수 있습니다.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _DataActionCard(
            buttonKey: const Key('export_backup_button'),
            icon: Icons.file_upload_outlined,
            title: '백업 파일 내보내기',
            description: '맛집, 카테고리, 화면 설정을 JSON 파일로 저장합니다.',
            onTap: _working ? null : _exportBackup,
          ),
          const SizedBox(height: 12),
          _DataActionCard(
            buttonKey: const Key('restore_backup_button'),
            icon: Icons.settings_backup_restore_rounded,
            title: '백업 파일 복원',
            description: '선택한 JSON 파일의 데이터로 현재 목록을 교체합니다.',
            onTap: _working ? null : _restoreBackup,
            destructive: true,
          ),
          if (_working) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '복원하면 현재 데이터가 삭제됩니다. 복원 전 최신 백업을 '
                      '먼저 내보내는 것을 권장합니다.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 백업과 복원 동작의 차이를 설명과 색상으로 구분하는 카드다.
class _DataActionCard extends StatelessWidget {
  const _DataActionCard({
    required this.buttonKey,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.destructive = false,
  });

  final Key buttonKey;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: buttonKey,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(description),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
