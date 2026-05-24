import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle display(BuildContext context) => GoogleFonts.playfairDisplay(
    fontSize: 32, fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.onSurface,
    letterSpacing: -0.5,
  );

  static TextStyle heading1(BuildContext context) => GoogleFonts.playfairDisplay(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle heading2(BuildContext context) => GoogleFonts.playfairDisplay(
    fontSize: 20, fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle body(BuildContext context) => GoogleFonts.lato(
    fontSize: 14, color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodyBold(BuildContext context) => GoogleFonts.lato(
    fontSize: 14, fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle caption(BuildContext context) => GoogleFonts.lato(
    fontSize: 12, color: AppColors.warmGray,
  );

  static TextStyle price(BuildContext context) => GoogleFonts.playfairDisplay(
    fontSize: 18, fontWeight: FontWeight.w700,
    color: AppColors.gold,
  );

  static TextStyle khmer(BuildContext context) => const TextStyle(
    fontFamily: 'Hanuman', fontSize: 16,
    color: AppColors.gold,
  );
}