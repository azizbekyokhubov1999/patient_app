import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    required this.controller,
    required this.onSend,
    this.onMicTap,
    this.onAttachTap,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final VoidCallback? onMicTap;
  final VoidCallback? onAttachTap;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onActionTap() {
    if (_hasText) {
      widget.onSend(widget.controller.text);
      widget.controller.clear();
    } else {
      widget.onMicTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.neutral200),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: AppColors.secondaryText.withValues(alpha: 0.8),
                    size: 22,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 96),
                    child: TextField(
                      controller: widget.controller,
                      minLines: 1,
                      maxLines: 1,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      scrollPhysics: const BouncingScrollPhysics(),
                      decoration: const InputDecoration(
                        hintText: 'Type a message here... ',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onAttachTap,
                  icon: Icon(
                    Icons.attach_file_rounded,
                    color: AppColors.secondaryText.withValues(alpha: 0.8),
                    size: 22,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: AppColors.primary,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _onActionTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                _hasText ? Icons.send_rounded : Icons.mic_rounded,
                color: AppColors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
