import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.amount,
    required this.type,
    required this.postBalance,
  });

  final String id;
  final String title;
  final DateTime timestamp;
  final double amount;
  final String type;
  final double postBalance;

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      title: map['title'] as String? ?? '',
      timestamp: _parseTimestamp(map['timestamp']),
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      type: map['type'] as String? ?? 'expense',
      postBalance: (map['postBalance'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'timestamp': Timestamp.fromDate(timestamp),
      'amount': amount,
      'type': type,
      'postBalance': postBalance,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    DateTime? timestamp,
    double? amount,
    String? type,
    double? postBalance,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      postBalance: postBalance ?? this.postBalance,
    );
  }

  static DateTime _parseTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
