import 'package:intl/intl.dart';

import '../../data/models/transaction_model.dart';

class WalletTransactionGroup {
  const WalletTransactionGroup({
    required this.header,
    required this.transactions,
  });

  final String header;
  final List<TransactionModel> transactions;
}

List<WalletTransactionGroup> groupWalletTransactions(
  List<TransactionModel> transactions,
) {
  if (transactions.isEmpty) return const [];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final buckets = <String, List<TransactionModel>>{};
  final order = <String>[];

  for (final tx in transactions) {
    final date = DateTime(
      tx.timestamp.year,
      tx.timestamp.month,
      tx.timestamp.day,
    );
    final header = _headerForDate(date, today, yesterday);
    if (!buckets.containsKey(header)) {
      buckets[header] = [];
      order.add(header);
    }
    buckets[header]!.add(tx);
  }

  return order
      .map(
        (header) => WalletTransactionGroup(
          header: header,
          transactions: buckets[header]!,
        ),
      )
      .toList();
}

String _headerForDate(DateTime date, DateTime today, DateTime yesterday) {
  if (date == today) return 'Today';
  if (date == yesterday) return 'Yesterday';
  return DateFormat('dd MMMM yyyy').format(date);
}
