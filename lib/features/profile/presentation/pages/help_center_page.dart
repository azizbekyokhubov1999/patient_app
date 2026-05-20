import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../manager/help_center_cubit.dart';
import '../manager/help_center_state.dart';
import '../widgets/category_chips.dart';
import '../widgets/contact_item_card.dart';
import '../widgets/faq_expansion_tile.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Help Center',
          backgroundColor: AppColors.white,
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppPaths.profile);
            }
          },
        ),
        body: BlocBuilder<HelpCenterCubit, HelpCenterState>(
          builder: (context, state) {
            if (state is HelpCenterLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is! HelpCenterLoaded) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: context.read<HelpCenterCubit>().searchHelp,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(
                        color: AppColors.secondaryText,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.secondaryText,
                      ),
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.2,
                        ),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: AppColors.white,
                  child: TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.secondaryText,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'FAQ'),
                      Tab(text: 'Contact Us'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _FaqTabContent(state: state),
                      _ContactTabContent(state: state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FaqTabContent extends StatelessWidget {
  const _FaqTabContent({required this.state});

  final HelpCenterLoaded state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.md),
        CategoryChips(
          selectedCategory: state.selectedCategory,
          onCategorySelected:
              context.read<HelpCenterCubit>().filterByCategory,
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: state.filteredFaqs.isEmpty
              ? const _EmptyResults(message: 'No FAQs match your search')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                  ),
                  itemCount: state.filteredFaqs.length,
                  itemBuilder: (context, index) {
                    final item = state.filteredFaqs[index];
                    return FaqExpansionTile(
                      item: item,
                      initiallyExpanded: index == 0 && state.searchQuery.isEmpty,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ContactTabContent extends StatelessWidget {
  const _ContactTabContent({required this.state});

  final HelpCenterLoaded state;

  @override
  Widget build(BuildContext context) {
    if (state.filteredContacts.isEmpty) {
      return const _EmptyResults(
        message: 'No contact channels match your search',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      itemCount: state.filteredContacts.length,
      itemBuilder: (context, index) {
        return ContactItemCard(item: state.filteredContacts[index]);
      },
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
