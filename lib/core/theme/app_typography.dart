part of 'app_theme.dart';

class AppTypography {
  // Use getters since GoogleFonts returns a runtime TextStyle

  static TextStyle get displayLarge => GoogleFonts.spaceMono(
        fontSize: 36,
        height: 1.1,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get displayMedium => GoogleFonts.spaceMono(
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get displaySmall => GoogleFonts.spaceMono(
        fontSize: 16,
        height: 1.2,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      );

  // TextTheme sets for Material ThemeData
  static TextTheme get darkTextTheme {
    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineMedium: headlineMedium,
      titleMedium: titleMedium,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelMedium: labelMedium,
    ).apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    );
  }

  static TextTheme get lightTextTheme {
    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineMedium: headlineMedium,
      titleMedium: titleMedium,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelMedium: labelMedium,
    ).apply(
      bodyColor: AppColors.textPrimaryLight,
      displayColor: AppColors.textPrimaryLight,
    );
  }
}
