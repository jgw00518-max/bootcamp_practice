import 'package:flutter/material.dart';

/// 선택한 기본주소와 우편번호를 강조해 보여주는 읽기 전용 주소 카드다.
class AddressField extends StatelessWidget {
  const AddressField({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasAddress = trailing != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasAddress
            ? colors.primaryContainer.withValues(alpha: 0.42)
            : colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAddress
              ? colors.primary.withValues(alpha: 0.35)
              : colors.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on_outlined,
            color: hasAddress ? colors.primary : colors.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: hasAddress ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 8),
                  Text(trailing!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
