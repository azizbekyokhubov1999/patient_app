import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/transaction_model.dart';

class WalletTransactionTile extends StatelessWidget {
  const WalletTransactionTile({required this.transaction, super.key});

  final TransactionModel transaction;

  static const Color _incomeGreen = Color(0xFF059669);
  static const Color _expenseRed = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat('dd MMMM | hh:mm a').format(transaction.timestamp);
    final amountPrefix = transaction.isIncome ? '+ ' : '- ';
    final amountColor = transaction.isIncome ? _incomeGreen : _expenseRed;
    final amountText =
        '$amountPrefix\$${transaction.amount.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke.withValues(alpha: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Balance \$${transaction.postBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
