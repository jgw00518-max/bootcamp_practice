import 'package:flutter/material.dart';

import '../vm/must_eat_place_view_model.dart';
import 'category_settings_page.dart';
import 'theme_settings_page.dart';
import 'data_management_page.dart';

/// 화면 테마와 카테고리 관리로 이동하는 사용자 설정 메뉴다.
class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({
    super.key,
    required this.viewModel,
    this.embedded = false,
  });

  final MustEatPlaceViewModel viewModel;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: embedded ? null : AppBar(title: const Text('사용자 설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '설정',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '원하는 항목을 선택해 앱을 나에게 맞게 설정해 보세요.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _SettingsMenuCard(
            buttonKey: const Key('theme_settings_button'),
            icon: Icons.palette_outlined,
            title: '화면 및 테마',
            description: '다크모드와 포인트 색상을 변경합니다.',
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => ThemeSettingsPage(viewModel: viewModel),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SettingsMenuCard(
            buttonKey: const Key('data_management_button'),
            icon: Icons.cloud_sync_outlined,
            title: '데이터 관리',
            description: '맛집 데이터를 JSON 파일로 백업하거나 복원합니다.',
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => DataManagementPage(viewModel: viewModel),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SettingsMenuCard(
            buttonKey: const Key('category_settings_button'),
            icon: Icons.category_outlined,
            title: '카테고리 관리',
            description: '맛집 분류를 추가하거나 삭제합니다.',
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => CategorySettingsPage(viewModel: viewModel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 설정 항목의 역할을 아이콘과 설명으로 보여주는 이동 카드다.
class _SettingsMenuCard extends StatelessWidget {
  const _SettingsMenuCard({
    required this.buttonKey,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final Key buttonKey;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: buttonKey,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
