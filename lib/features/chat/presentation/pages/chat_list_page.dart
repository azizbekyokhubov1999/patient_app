import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/chat_model.dart';
import '../manager/chat_cubit.dart';
import '../manager/chat_state.dart';
import '../widgets/active_doctor_avatar.dart';
import '../widgets/chat_tile.dart';

/// Chat inbox — Figma dual-tone header + white sheet list.
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool _searchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) {
        _searchController.clear();
        context.read<ChatCubit>().searchChats('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return Column(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ChatHeader(
                      onBack: context.canPop() ? () => context.pop() : null,
                      onSearch: _toggleSearch,
                    ),
                    if (_searchVisible) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(color: AppColors.white),
                          cursorColor: AppColors.white,
                          decoration: InputDecoration(
                            hintText: 'Search doctors...',
                            hintStyle: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.7),
                            ),
                            filled: true,
                            fillColor: AppColors.white.withValues(alpha: 0.15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          onChanged: context.read<ChatCubit>().searchChats,
                        ),
                      ),
                    ],
                    SizedBox(
                      height: 115,
                      child: state.activeDoctors.isEmpty
                          ? const SizedBox.shrink()
                          : ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: state.activeDoctors.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final doctor = state.activeDoctors[index];
                                return ActiveDoctorAvatar(
                                  doctor: doctor,
                                  onTap: () => _openChat(context, doctor),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _ChatTabRow(
                        selectedTab: state.selectedTab,
                        allCount: state.allCount,
                        onTabSelected: context.read<ChatCubit>().switchTab,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _ChatListBody(state: state),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openChat(BuildContext context, ChatModel chat) {
    context.push(AppPaths.chatDetail, extra: chat);
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    this.onBack,
    required this.onSearch,
  });

  final VoidCallback? onBack;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          if (onBack != null)
            _HeaderIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack!,
            )
          else
            const SizedBox(width: 48),
          const Expanded(
            child: Text(
              'Chat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
          _HeaderIconButton(
            icon: Icons.search,
            onTap: onSearch,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryText),
        ),
      ),
    );
  }
}

class _ChatTabRow extends StatelessWidget {
  const _ChatTabRow({
    required this.selectedTab,
    required this.allCount,
    required this.onTabSelected,
  });

  final String selectedTab;
  final int allCount;
  final ValueChanged<String> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _ChatTab(
            label: 'All',
            badgeCount: allCount,
            isSelected: selectedTab == ChatState.tabAll,
            onTap: () => onTabSelected(ChatState.tabAll),
          ),
          const SizedBox(width: 28),
          _ChatTab(
            label: 'Unread',
            isSelected: selectedTab == ChatState.tabUnread,
            onTap: () => onTabSelected(ChatState.tabUnread),
          ),
        ],
      ),
    );
  }
}

class _ChatTab extends StatelessWidget {
  const _ChatTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryText
                      : AppColors.secondaryText,
                ),
              ),
              if (badgeCount != null && badgeCount! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 72,
            height: 20,
            child: isSelected
                ? CustomPaint(
                    painter: _TabIndicatorPainter(),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _TabIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lineY = 0.0;
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY), paint);

    final trianglePath = Path();
    final cx = size.width / 2;
    trianglePath.moveTo(cx - 5, lineY + 2);
    trianglePath.lineTo(cx + 5, lineY + 2);
    trianglePath.lineTo(cx, lineY + 9);
    trianglePath.close();
    canvas.drawPath(
      trianglePath,
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChatListBody extends StatelessWidget {
  const _ChatListBody({required this.state});

  final ChatState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: AppTextStyles.doctorMeta,
          ),
        ),
      );
    }

    if (state.filteredChats.isEmpty) {
      return Center(
        child: Text(
          state.selectedTab == ChatState.tabUnread
              ? 'No unread messages'
              : 'No conversations yet',
          style: AppTextStyles.doctorMeta,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: state.filteredChats.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final chat = state.filteredChats[index];
        return ChatTile(
          chat: chat,
          onTap: () => context.push(AppPaths.chatDetail, extra: chat),
        );
      },
    );
  }
}
