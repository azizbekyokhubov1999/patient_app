import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../manager/chat_detail_cubit.dart';
import '../manager/chat_detail_state.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/message_bubble.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({required this.chat, super.key});

  final ChatModel chat;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageSearchController = TextEditingController();

  bool _messageSearchVisible = false;
  bool _notificationsMuted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _messageSearchController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    final cubit = context.read<ChatDetailCubit>();
    cubit.sendText(widget.chat.chatId, text);
    _inputController.clear();
  }

  void _toggleMessageSearch() {
    setState(() {
      _messageSearchVisible = !_messageSearchVisible;
      if (!_messageSearchVisible) {
        _messageSearchController.clear();
      }
    });
  }

  void _toggleSilentNotifications() {
    setState(() => _notificationsMuted = !_notificationsMuted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _notificationsMuted
              ? 'Notifications silenced for this chat'
              : 'Notifications restored for this chat',
        ),
      ),
    );
  }

  Future<void> _confirmDeleteChat(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text(
          'This will remove all messages in this conversation. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    context.read<ChatDetailCubit>().clearMessages();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat deleted')),
      );
      context.pop();
    }
  }

  List<MessageModel> _filterMessages(List<MessageModel> messages) {
    final query = _messageSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return messages;
    return messages
        .where((m) => m.content.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatDetailCubit, ChatDetailState>(
      listenWhen: (previous, current) =>
          previous.messages.length != current.messages.length,
      listener: (_, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
      builder: (context, state) {
        final filteredMessages = _filterMessages(state.messages);

        return Scaffold(
          backgroundColor: AppColors.primary,
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              SafeArea(
                bottom: false,
                child: _ChatDetailHeader(
                  chat: widget.chat,
                  onBack: () => context.pop(),
                  onVoiceCall: () => context.push(
                    AppPaths.voiceCall,
                    extra: widget.chat,
                  ),
                  onVideoCall: () => context.push(
                    AppPaths.videoCall,
                    extra: widget.chat,
                  ),
                  onToggleSilent: _toggleSilentNotifications,
                  onSearch: _toggleMessageSearch,
                  onDeleteChat: () => _confirmDeleteChat(context),
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
                      if (_messageSearchVisible)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: TextField(
                            controller: _messageSearchController,
                            autofocus: true,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search messages...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              filled: true,
                              fillColor: AppColors.neutral100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: _MessageList(
                          state: state,
                          messages: filteredMessages,
                          scrollController: _scrollController,
                          chat: widget.chat,
                          currentUserId:
                              context.read<ChatDetailCubit>().currentUserId,
                          patientAvatar: widget.chat.patientImage,
                        ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ChatInputField(
                            controller: _inputController,
                            onSend: (_) => _sendMessage(context),
                            onAttachTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Image sharing coming soon'),
                                ),
                              );
                            },
                            onMicTap: () => context
                                .read<ChatDetailCubit>()
                                .sendVoiceMessage(
                                  widget.chat.chatId,
                                  '',
                                  '0:00',
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatDetailHeader extends StatelessWidget {
  const _ChatDetailHeader({
    required this.chat,
    required this.onBack,
    required this.onVoiceCall,
    required this.onVideoCall,
    required this.onToggleSilent,
    required this.onSearch,
    required this.onDeleteChat,
  });

  final ChatModel chat;
  final VoidCallback onBack;
  final VoidCallback onVoiceCall;
  final VoidCallback onVideoCall;
  final VoidCallback onToggleSilent;
  final VoidCallback onSearch;
  final VoidCallback onDeleteChat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.white,
            backgroundImage: chat.doctorAvatar.isNotEmpty
                ? NetworkImage(chat.doctorAvatar)
                : null,
            child: chat.doctorAvatar.isEmpty
                ? const Icon(Icons.person_rounded, color: AppColors.primaryText)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.doctorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  chat.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            icon: Icons.phone_outlined,
            onTap: onVoiceCall,
            iconColor: AppColors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            borderColor: Colors.transparent,
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            offset: const Offset(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case 'video':
                  onVideoCall();
                case 'silent':
                  onToggleSilent();
                case 'search':
                  onSearch();
                case 'delete':
                  onDeleteChat();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'video',
                child: _PopupMenuRow(
                  icon: Icons.videocam_outlined,
                  label: 'Video Call',
                ),
              ),
              const PopupMenuItem(
                value: 'silent',
                child: _PopupMenuRow(
                  icon: Icons.volume_off_outlined,
                  label: 'To be silent',
                ),
              ),
              const PopupMenuItem(
                value: 'search',
                child: _PopupMenuRow(
                  icon: Icons.search,
                  label: 'Search',
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: _PopupMenuRow(
                  icon: Icons.delete_outline,
                  label: 'Delete Chat',
                  labelColor: AppColors.error,
                  iconColor: AppColors.error,
                ),
              ),
            ],
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.more_vert,
                size: 20,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopupMenuRow extends StatelessWidget {
  const _PopupMenuRow({
    required this.icon,
    required this.label,
    this.labelColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color? labelColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? AppColors.primaryText),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: labelColor ?? AppColors.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.primaryText,
    this.backgroundColor = AppColors.white,
    this.borderColor = AppColors.stroke,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: borderColor == Colors.transparent
              ? null
              : Border.all(color: borderColor),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.state,
    required this.messages,
    required this.scrollController,
    required this.chat,
    required this.currentUserId,
    required this.patientAvatar,
  });

  final ChatDetailState state;
  final List<MessageModel> messages;
  final ScrollController scrollController;
  final ChatModel chat;
  final String currentUserId;
  final String patientAvatar;

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
            style: const TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages',
          style: TextStyle(color: AppColors.secondaryText),
        ),
      );
    }

    final itemCount = messages.length + 1;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: _DateSeparator(label: 'TODAY'),
          );
        }

        final message = messages[index - 1];
        final isMe = message.senderId == currentUserId;

        return MessageBubble(
          message: message,
          isMe: isMe,
          peerAvatarUrl: chat.doctorAvatar,
          myAvatarUrl: patientAvatar,
        );
      },
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }
}
