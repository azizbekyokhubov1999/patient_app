import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/help_center_model.dart';
import 'help_center_state.dart';

class HelpCenterCubit extends Cubit<HelpCenterState> {
  HelpCenterCubit() : super(const HelpCenterLoading()) {
    loadHelpCenter();
  }

  List<FAQItem> _allFaqs = const [];
  List<ContactItem> _contactItems = const [];

  Future<void> loadHelpCenter() async {
    emit(const HelpCenterLoading());
    await Future<void>.delayed(const Duration(milliseconds: 300));

    _allFaqs = _mockFaqs();
    _contactItems = _mockContacts();

    emit(
      HelpCenterLoaded(
        allFaqs: _allFaqs,
        filteredFaqs: List<FAQItem>.from(_allFaqs),
        contactItems: _contactItems,
        filteredContacts: List<ContactItem>.from(_contactItems),
        selectedCategory: HelpCategories.all,
        searchQuery: '',
      ),
    );
  }

  void filterByCategory(String category) {
    final current = state;
    if (current is! HelpCenterLoaded) return;
    _applyFilters(category: category, query: current.searchQuery);
  }

  void searchHelp(String query) {
    final current = state;
    if (current is! HelpCenterLoaded) return;
    _applyFilters(category: current.selectedCategory, query: query);
  }

  void _applyFilters({required String category, required String query}) {
    final current = state;
    if (current is! HelpCenterLoaded) return;

    final normalizedQuery = query.trim().toLowerCase();

    Iterable<FAQItem> faqs = _allFaqs;
    if (category != HelpCategories.all) {
      faqs = faqs.where((f) => f.category == category);
    }
    if (normalizedQuery.isNotEmpty) {
      faqs = faqs.where(
        (f) =>
            f.question.toLowerCase().contains(normalizedQuery) ||
            f.answer.toLowerCase().contains(normalizedQuery) ||
            f.category.toLowerCase().contains(normalizedQuery),
      );
    }

    Iterable<ContactItem> contacts = _contactItems;
    if (normalizedQuery.isNotEmpty) {
      contacts = contacts.where(
        (c) =>
            c.name.toLowerCase().contains(normalizedQuery) ||
            c.value.toLowerCase().contains(normalizedQuery),
      );
    }

    emit(
      current.copyWith(
        filteredFaqs: faqs.toList(),
        filteredContacts: contacts.toList(),
        selectedCategory: category,
        searchQuery: query,
      ),
    );
  }

  List<FAQItem> _mockFaqs() {
    const lorem =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.';

    return [
      FAQItem(
        id: 'faq-1',
        question: 'How do I book an appointment?',
        answer: lorem,
        category: HelpCategories.services,
      ),
      const FAQItem(
        id: 'faq-2',
        question: 'Can I cancel my appointment?',
        answer:
            'Yes. Go to Appointments, open the booking you want to change, and tap Cancel. Cancellation policies may apply depending on how close you are to the appointment time.',
        category: HelpCategories.services,
      ),
      const FAQItem(
        id: 'faq-3',
        question: 'Will I get a receipt after payment?',
        answer:
            'After a successful payment you can view and download your e-receipt from the booking details screen under My Appointments.',
        category: HelpCategories.general,
      ),
      const FAQItem(
        id: 'faq-4',
        question: 'What payment methods are accepted?',
        answer:
            'We accept credit and debit cards, PayPal, Apple Pay, and Google Pay. You can manage saved cards in Profile → Payment Methods.',
        category: HelpCategories.general,
      ),
      const FAQItem(
        id: 'faq-5',
        question: 'How do I contact customer support?',
        answer:
            'Switch to the Contact Us tab in Help Center or use the channels listed there including phone, WhatsApp, and social media.',
        category: HelpCategories.general,
      ),
      const FAQItem(
        id: 'faq-6',
        question: 'What if I forget my password?',
        answer:
            'On the sign-in screen tap Forgot Password, enter your email, and follow the verification steps to set a new password.',
        category: HelpCategories.account,
      ),
      const FAQItem(
        id: 'faq-7',
        question: 'Will I get appointment reminders?',
        answer:
            'Yes. Enable push notifications in Settings → Notification Settings to receive reminders before your scheduled visits.',
        category: HelpCategories.account,
      ),
    ];
  }

  List<ContactItem> _mockContacts() {
    return const [
      ContactItem(
        id: 'contact-1',
        name: 'Customer Service',
        value: '+1 (800) 555-0199',
        icon: Icons.headset_mic_outlined,
        url: 'tel:+18005550199',
      ),
      ContactItem(
        id: 'contact-2',
        name: 'WhatsApp',
        value: '+1 (480) 555-0103',
        icon: Icons.chat_outlined,
        url: 'https://wa.me/14805550103',
      ),
      ContactItem(
        id: 'contact-3',
        name: 'Website',
        value: 'www.healthcareapp.com',
        icon: Icons.language_outlined,
        url: 'https://www.healthcareapp.com',
      ),
      ContactItem(
        id: 'contact-4',
        name: 'Facebook',
        value: 'facebook.com/healthcareapp',
        icon: Icons.facebook_outlined,
        url: 'https://www.facebook.com/healthcareapp',
      ),
      ContactItem(
        id: 'contact-5',
        name: 'X',
        value: '@healthcareapp',
        icon: Icons.tag_outlined,
        url: 'https://x.com/healthcareapp',
      ),
      ContactItem(
        id: 'contact-6',
        name: 'Instagram',
        value: '@healthcareapp',
        icon: Icons.camera_alt_outlined,
        url: 'https://www.instagram.com/healthcareapp',
      ),
    ];
  }
}
