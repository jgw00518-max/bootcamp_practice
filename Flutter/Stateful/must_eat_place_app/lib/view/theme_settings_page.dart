import 'package:flutter/material.dart';

import '../model/app_preferences.dart';
import '../vm/must_eat_place_view_model.dart';

/// 다크모드와 앱의 포인트 색상을 한 화면에서 관리한다.
class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key, required this.viewModel});

  final MustEatPlaceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('화면 및 테마')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(
              icon: Icons.brightness_6_outlined,
              title: '화면 모드',
              description: '사용 환경에 편안한 화면 밝기를 선택해 주세요.',
            ),
            const SizedBox(height: 14),
            Card(
              child: SwitchListTile(
                key: const Key('dark_mode_switch'),
                value: viewModel.isDarkMode,
                onChanged: viewModel.setDarkMode,
                secondary: Icon(
                  viewModel.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                ),
                title: const Text(
                  '다크모드',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  viewModel.isDarkMode ? '어두운 화면 사용 중' : '밝은 화면 사용 중',
                ),
              ),
            ),
            const SizedBox(height: 28),
            _SectionHeader(
              icon: Icons.palette_outlined,
              title: '색상 테마',
              description: '버튼과 탭에 사용할 포인트 색상을 선택해 주세요.',
            ),
            const SizedBox(height: 14),
            ...AppThemeColor.values.map(
              (color) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ThemeColorTile(
                  color: color,
                  selected: viewModel.themeColor == color,
                  onTap: () => viewModel.setThemeColor(color),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 설정 종류의 제목과 설명을 같은 형식으로 표시한다.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(icon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 하나의 테마 색상과 현재 선택 상태를 터치 가능한 카드로 표시한다.
class _ThemeColorTile extends StatelessWidget {
  const _ThemeColorTile({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final AppThemeColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        key: Key('theme_color_${color.name}'),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(backgroundColor: Color(color.colorValue)),
        title: Text(
          color.label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        trailing: selected
            ? Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
              )
            : const Icon(Icons.circle_outlined),
      ),
    );
  }
}
