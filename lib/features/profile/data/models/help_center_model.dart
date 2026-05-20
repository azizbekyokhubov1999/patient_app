import 'package:flutter/material.dart';

class FAQItem {
  const FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });

  final String id;
  final String question;
  final String answer;
  final String category;
}

class ContactItem {
  const ContactItem({
    required this.id,
    required this.name,
    required this.value,
    required this.icon,
    required this.url,
  });

  final String id;
  final String name;
  final String value;
  final IconData icon;
  final String url;
}

/// FAQ filter chip labels.
abstract final class HelpCategories {
  static const String all = 'All';
  static const String services = 'Services';
  static const String general = 'General';
  static const String account = 'Account';

  static const List<String> chips = [
    all,
    services,
    general,
    account,
  ];
}
