import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const GroupChatScreen({super.key, required this.bookingId});

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  // Mock messages for demo
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      sender: 'Adunni A.',
      avatar: 'A',
      text: 'Hey everyone! Excited for this trip 🎉',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isMine: false,
      avatarColor: AppColors.accent,
    ),
    _ChatMessage(
      sender: 'Tour Guide (Naija Roots)',
      avatar: 'N',
      text:
          'Welcome all! 👋 Here\'s the meeting point: Murtala Muhammed International Airport, Terminal 2, by the Air Peace counter. Time: 8:00 AM sharp.',
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      isMine: false,
      isOperator: true,
      avatarColor: AppColors.primary,
    ),
    _ChatMessage(
      sender: 'Tobi K.',
      avatar: 'T',
      text: 'Can\'t wait! What\'s the dress code for the welcome dinner?',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      isMine: false,
      avatarColor: AppColors.primaryLight,
    ),
    _ChatMessage(
      sender: 'You',
      avatar: 'Y',
      text: 'Smart casual is fine!',
      time: DateTime.now().subtract(const Duration(minutes: 45)),
      isMine: true,
      avatarColor: AppColors.primary,
    ),
  ];

  void _send() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(
        sender: 'You',
        avatar: 'Y',
        text: _messageController.text.trim(),
        time: DateTime.now(),
        isMine: true,
        avatarColor: AppColors.primary,
      ));
    });
    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.groups_2_rounded,
                      color: Colors.white, size: 20),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detty December Lagos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '22 travelers • Tour guide active',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Trip status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            color: AppColors.primary.withOpacity(0.05),
            child: Row(
              children: [
                const Icon(Icons.flight_takeoff_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'Trip starts in 23 days • Dec 18, 2026',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _MessageBubble(message: _messages[index]),
            ),
          ),
          // Message input
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.sm,
              AppSizes.md,
              AppSizes.sm + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border:
                  Border(top: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: AppColors.textSecondary,
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: AppSizes.sm),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String sender;
  final String avatar;
  final String text;
  final DateTime time;
  final bool isMine;
  final bool isOperator;
  final Color avatarColor;

  _ChatMessage({
    required this.sender,
    required this.avatar,
    required this.text,
    required this.time,
    required this.isMine,
    this.isOperator = false,
    required this.avatarColor,
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMine) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: message.avatarColor,
              child: Text(
                message.avatar,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isMine)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.sender,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: message.isOperator
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (message.isOperator) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              color: AppColors.primary, size: 12),
                        ],
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md, vertical: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: message.isMine
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppSizes.radiusMd),
                      topRight: const Radius.circular(AppSizes.radiusMd),
                      bottomLeft: Radius.circular(
                          message.isMine ? AppSizes.radiusMd : 4),
                      bottomRight: Radius.circular(
                          message.isMine ? 4 : AppSizes.radiusMd),
                    ),
                    border: message.isMine
                        ? null
                        : Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isMine
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                  child: Text(
                    timeFormat.format(message.time),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
