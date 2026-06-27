import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/promotion.dart';
import '../theme/app_colors.dart';
import '../l10n/generated/app_localizations.dart';

class CouponCard extends StatelessWidget {
  final Promotion promo;
  const CouponCard({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? AppColors.darkCard : Colors.white,
            isDark ? AppColors.darkCard : AppColors.cream,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(80)
                : Colors.black.withAlpha(14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Row(
              children: [
                // Left accent
                Container(
                  width: 6,
                  height: 110,
                  color: _colorFromHex(promo.colorHex),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promo.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            letterSpacing: -0.2,
                            color:
                                isDark ? AppColors.cream : AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promo.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.cream.withAlpha(180)
                                : AppColors.warmGray,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Code pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _colorFromHex(promo.colorHex)
                                      .withAlpha(180),
                                  strokeAlign:
                                      BorderSide.strokeAlignInside,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                promo.code,
                                style: TextStyle(
                                  color: _colorFromHex(promo.colorHex),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: promo.code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.codeCopied),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    duration:
                                        const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: _colorFromHex(promo.colorHex)
                                      .withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.copy,
                                  size: 16,
                                  color: _colorFromHex(promo.colorHex),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Discount badge
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _colorFromHex(promo.colorHex).withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              promo.discount,
                              style: TextStyle(
                                color: _colorFromHex(promo.colorHex),
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              l10n.off,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.cream.withAlpha(180)
                                    : AppColors.warmGray,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFromHex(String hex) {
    hex = hex.replaceFirst('0x', '').replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
