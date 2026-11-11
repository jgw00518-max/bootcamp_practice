import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF5B5CF0);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF7B849C);
  static const surface = Color(0xFFF7F8FC);
  static const border = Color(0xFFE8EAF1);
  static const green = Color(0xFF37C978);
  static const orange = Color(0xFFFFA726);
  static const red = Color(0xFFFF5C65);
}

/// 화면 전반에서 반복되는 크기와 간격을 한 기준으로 제공합니다.
abstract final class AppDimensions {
  static const screenPadding = 20.0;
  static const cardPadding = 16.0;
  static const cardRadius = 16.0;
  static const inputRadius = 14.0;
  static const buttonHeight = 54.0;
  static const sectionSpacing = 24.0;
  static const supportingTextSize = 13.0;
}

/// 의미가 같은 다이얼로그 액션이 동일한 색과 강조 수준을 사용하도록 합니다.
abstract final class AppDialogStyles {
  static final destructiveAction = FilledButton.styleFrom(
    backgroundColor: AppColors.red,
    foregroundColor: Colors.white,
  );

  static final destructiveTextAction = TextButton.styleFrom(
    foregroundColor: AppColors.red,
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );

  static final cancelAction = TextButton.styleFrom(
    foregroundColor: AppColors.muted,
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );
}

/// 앱 전체에서 공유하는 밝은 테마를 제공합니다.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
      bodyMedium: TextStyle(color: AppColors.ink),
      bodySmall: TextStyle(
        color: AppColors.muted,
        fontSize: AppDimensions.supportingTextSize,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withValues(alpha: .12),
      checkmarkColor: AppColors.primary,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.disabled)
              ? Colors.black.withValues(alpha: .45)
              : Colors.black,
          fontSize: 13,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w700,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.muted,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 4,
      backgroundColor: Colors.white,
      shadowColor: AppColors.ink.withValues(alpha: .08),
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primary.withValues(alpha: .1),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.muted.withValues(alpha: .78),
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w600,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.muted.withValues(alpha: .78),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      focusElevation: 4,
      hoverElevation: 4,
      highlightElevation: 6,
      shape: const CircleBorder(),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      modalBackgroundColor: Colors.white,
      elevation: 8,
      modalElevation: 8,
      shadowColor: Color(0x1A111827),
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: AppColors.border,
      dragHandleSize: Size(40, 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: AppColors.ink.withValues(alpha: .1),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.muted,
        fontSize: AppDimensions.supportingTextSize,
        height: 1.45,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
