import 'dart:convert';

import 'package:file_picker/file_picker.dart';

import '../model/app_backup.dart';

/// JSON 백업 파일을 저장하고 사용자가 고른 파일을 읽는다.
class BackupFileService {
  const BackupFileService();

  /// 운영체제의 저장 위치 선택 창을 열어 JSON 바이트를 내보낸다.
  Future<bool> save(AppBackup backup) async {
    final date = backup.createdAt;
    final fileName =
        'must_eat_place_${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}.json';
    final uri = await FilePicker.saveFile(
      dialogTitle: '맛집 백업 파일 저장',
      fileName: fileName,
      bytes: utf8.encode(backup.toJsonString()),
      mimeType: 'application/json',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    return uri != null;
  }

  /// JSON 파일 하나를 선택하게 하고 내용을 검증된 백업 모델로 변환한다.
  Future<AppBackup?> pick() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return AppBackup.fromJsonString(utf8.decode(bytes));
  }
}
