import '../../data/models/help_center_model.dart';

sealed class HelpCenterState {
  const HelpCenterState();
}

class HelpCenterLoading extends HelpCenterState {
  const HelpCenterLoading();
}

class HelpCenterLoaded extends HelpCenterState {
  const HelpCenterLoaded({
    required this.allFaqs,
    required this.filteredFaqs,
    required this.contactItems,
    required this.filteredContacts,
    required this.selectedCategory,
    required this.searchQuery,
  });

  final List<FAQItem> allFaqs;
  final List<FAQItem> filteredFaqs;
  final List<ContactItem> contactItems;
  final List<ContactItem> filteredContacts;
  final String selectedCategory;
  final String searchQuery;

  HelpCenterLoaded copyWith({
    List<FAQItem>? allFaqs,
    List<FAQItem>? filteredFaqs,
    List<ContactItem>? contactItems,
    List<ContactItem>? filteredContacts,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return HelpCenterLoaded(
      allFaqs: allFaqs ?? this.allFaqs,
      filteredFaqs: filteredFaqs ?? this.filteredFaqs,
      contactItems: contactItems ?? this.contactItems,
      filteredContacts: filteredContacts ?? this.filteredContacts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
