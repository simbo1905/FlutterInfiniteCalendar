import 'package:flutter/material.dart';

class LoadingWeekPlaceholder extends StatelessWidget {
  const LoadingWeekPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlaceholderBox(theme, height: 20, width: 160),
          const SizedBox(height: 16),
          ...List.generate(7, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _buildPlaceholderCircle(theme, diameter: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _buildPlaceholderBox(theme, height: 18),
                        const SizedBox(height: 8),
                        _buildPlaceholderBox(theme, height: 18, width: 120),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlaceholderBox(
    ThemeData theme, {
    required double height,
    double? width,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: theme.dividerColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildPlaceholderCircle(ThemeData theme, {required double diameter}) {
    return Container(
      height: diameter,
      width: diameter,
      decoration: BoxDecoration(
        color: theme.dividerColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
    );
  }
}
