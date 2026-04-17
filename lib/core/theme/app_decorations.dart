part of 'app_theme.dart';

class AppDecorations {
  static BoxDecoration get cardBackground => BoxDecoration(
    color: AppColors.surfaceDark,
    borderRadius: BorderRadius.circular(12),
  );
  
  static BoxDecoration get cardHoverBorder => BoxDecoration(
    color: AppColors.surfaceDark,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.primary, width: 2),
  );

  static BoxDecoration get summaryCard => BoxDecoration(
    color: AppColors.surface2Dark,
    borderRadius: BorderRadius.circular(10),
  );

  static BoxDecoration get transactionCardExpanded => BoxDecoration(
    color: AppColors.surfaceDark,
    borderRadius: BorderRadius.circular(10),
    border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
  );
}
