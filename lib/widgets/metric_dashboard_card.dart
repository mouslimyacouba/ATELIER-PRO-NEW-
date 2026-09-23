import 'package:flutter/material.dart';
import '../core/theme.dart';

/// MetricDashboardCard - Carte de métrique et chiffre d'affaires
/// conforme aux spécifications Sahara Craft Tech.
class MetricDashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final bool isTrendPositive;
  final IconData icon;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final bool isFeatured;
  final VoidCallback? onTap;

  const MetricDashboardCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.isTrendPositive = true,
    required this.icon,
    this.iconBackgroundColor,
    this.iconColor,
    this.isFeatured = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isFeatured
        ? AtelierProColors.primaryContainer
        : AtelierProColors.surfaceContainerLowest;
    final textColor = isFeatured ? Colors.white : AtelierProColors.onSurface;
    final subtitleColor = isFeatured
        ? AtelierProColors.surfaceContainerHighest
        : AtelierProColors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: isFeatured
                ? null
                : Border.all(color: AtelierProColors.outlineVariant, width: 1),
            boxShadow: isFeatured
                ? [
                    BoxShadow(
                      color: AtelierProColors.primaryContainer.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor ??
                          (isFeatured
                              ? AtelierProColors.primary
                              : AtelierProColors.surfaceContainerLow),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: iconColor ??
                          (isFeatured
                              ? AtelierProColors.onPrimary
                              : AtelierProColors.primaryContainer),
                    ),
                  ),
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isTrendPositive
                            ? AtelierProColors.tertiaryContainer
                            : AtelierProColors.secondaryFixed,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isTrendPositive
                              ? AtelierProColors.onTertiaryContainer
                              : AtelierProColors.secondary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: isFeatured
                      ? AtelierProTheme.currencyDisplayStyle(
                          fontSize: 24, color: Colors.white)
                      : TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: subtitleColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: subtitleColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
