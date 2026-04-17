part of 'app_theme.dart';

class AppTypography {
  static const String fontFamilyMono = 'SpaceMono';
  static const String fontFamilySans = 'DMSans';

  // Specific text styles based on PRD tokens
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 36,
    height: 1.1,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  // Specific use case
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 15, // Not explicitly defined in table but used commonly for buttons
    fontWeight: FontWeight.w700,
  );

  // TextTheme sets for Material ThemeData
  static TextTheme get darkTextTheme {
    return const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
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
    return const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
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
