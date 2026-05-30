import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isCredit,
    required this.date,
    this.postBalance = 0,
  });

  final String id;
  final String title;
  final double amount;
  final bool isCredit;
  final DateTime date;
  final double postBalance;

  DateTime get timestamp => date;

  bool get isIncome => isCredit;

  bool get isExpense => !isCredit;

  String get type => isCredit ? 'income' : 'expense';

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TransactionModel._fromMap(data, doc.id);
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) =>
      TransactionModel._fromMap(map, id);

  factory TransactionModel._fromMap(Map<String, dynamic> map, String id) {
    final isCredit = map['isCredit'] as bool? ?? (map['type'] == 'income');

    return TransactionModel(
      id: id,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      isCredit: isCredit,
      date: _parseTimestamp(map['date'] ?? map['timestamp']),
      postBalance: (map['postBalance'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'isCredit': isCredit,
      'date': Timestamp.fromDate(date),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    bool? isCredit,
    DateTime? date,
    double? postBalance,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isCredit: isCredit ?? this.isCredit,
      date: date ?? this.date,
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
