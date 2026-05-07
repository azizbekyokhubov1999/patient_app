import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/card_model.dart';

class CardPreview extends StatelessWidget {
  const CardPreview({
    required this.card,
    super.key,
  });

  final CardModel card;

  @override
  Widget build(BuildContext context) {
    final number = card.cardNumber.trim().isEmpty ? '4716 9627 1635 8047' : card.cardNumber;
    final holder = card.cardHolderName.trim().isEmpty ? 'Jennifer Aaker' : card.cardHolderName;
    final expiry = card.expiryDate.trim().isEmpty ? '02/30' : card.expiryDate;

    return Container(
      width: double.infinity,
      height: 190,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A7BFF), Color(0xFF1360FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.topRight,
            child: Text(
              'VISA',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 28,
              ),
            ),
          ),
          const Spacer(),
          Text(
            number,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 34 / 2,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MetaText(
                  label: 'Card holder name',
                  value: holder,
                ),
              ),
              Expanded(
                child: _MetaText(
                  label: 'Expiry date',
                  value: expiry,
                ),
              ),
              const SizedBox(width: 24),
              Container(
                width: 38,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.75)),
                ),
                child: const Icon(
                  LucideIcons.creditCard,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
