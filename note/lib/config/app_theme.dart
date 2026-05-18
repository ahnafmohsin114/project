import 'package:flutter/material.dart';
class AppColors {
  static const Color bgPrimary  = Color(0xFFF5F0FF);
  static const Color bgWhite    = Color(0xFFFFFFFF);
  static const Color bgSurface  = Color(0xFFFBF9FF);
  static const Color bgCard     = Color(0xFFFFFFFF);
  static const Color primary      = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color primaryDark  = Color(0xFF5A4BD1);
  static const Color secondary      = Color(0xFFFF6B9D);
  static const Color secondaryLight = Color(0xFFFFE4EF);
  static const Color success      = Color(0xFF00C896);
  static const Color successLight = Color(0xFFCCFBEF);
  static const Color warning      = Color(0xFFFFAB2E);
  static const Color warningLight = Color(0xFFFFF3CD);
  static const Color error      = Color(0xFFFF4757);
  static const Color errorLight = Color(0xFFFFE4E6);
  static const Color textPrimary   = Color(0xFF1A1040);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted     = Color(0xFFADB5BD);
  static const Color borderLight = Color(0xFFE8E2F8);
  static const Color borderMid   = Color(0xFFD4CCF5);
  static const List<String> noteHexColors = [
    '#FFF9C4',
    '#FCE4EC',
    '#E8F5E9',
    '#E3F2FD',
    '#EDE7F6',
    '#FBE9E7',
    '#E0F7FA',
    '#F3E5F5',
    '#E8EAF6',
    '#F9FBE7',
  ];

  static const List<Color> noteAccents = [
    Color(0xFFF59E0B),
    Color(0xFFE91E63),
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFFBF360C),
    Color(0xFF00695C),
    Color(0xFFAD1457),
    Color(0xFF283593),
    Color(0xFF558B2F),
  ];
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFF5F0FF), Color(0xFFFFEFF8), Color(0xFFF0F9FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF9B88F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
