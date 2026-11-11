import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 주요 아이콘에 공통으로 사용하는 배경 상자다.
class AppIconBox extends StatelessWidget {
  const AppIconBox({super.key, required this.icon, this.size = 42});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: AppColors.primary, size: size * 0.55),
    );
  }
}
