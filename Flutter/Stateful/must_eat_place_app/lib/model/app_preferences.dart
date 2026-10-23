/// 사용자가 선택할 수 있는 편안한 포인트 색상 목록이다.
enum AppThemeColor {
  coral('코랄', 0xFFE75B3A),
  sage('세이지', 0xFF4F8065),
  ocean('오션', 0xFF3975A6),
  lavender('라벤더', 0xFF7866A9);

  const AppThemeColor(this.label, this.colorValue);

  final String label;
  final int colorValue;

  /// 저장된 이름이 없거나 잘못된 경우 기본 코랄 테마를 반환한다.
  static AppThemeColor fromName(String? name) {
    return values.where((color) => color.name == name).firstOrNull ?? coral;
  }
}

/// SQLite에 저장하고 앱 테마에 반영할 사용자 화면 설정이다.
class AppPreferences {
  const AppPreferences({
    this.isDarkMode = false,
    this.themeColor = AppThemeColor.coral,
  });

  final bool isDarkMode;
  final AppThemeColor themeColor;
}
