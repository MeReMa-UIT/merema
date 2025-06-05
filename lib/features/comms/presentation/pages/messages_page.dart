// TODO: Group 2 pages together like messenger

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/services/message_notification_service.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/auth/domain/usecases/get_acc_id.dart';
import 'package:merema/features/comms/domain/entities/messages.dart';
import 'package:merema/features/comms/presentation/bloc/messages_state_cubit.dart';
import 'package:merema/features/comms/presentation/bloc/messages_state.dart';

class MessagesPage extends StatefulWidget {
  final int contactId;
  final String contactName;

  const MessagesPage({
    super.key,
    required this.contactId,
    required this.contactName,
  });

  static Route route({required int contactId, required String contactName}) =>
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => MessagesCubit()..getMessages(contactId),
          child: MessagesPage(
            contactId: contactId,
            contactName: contactName,
          ),
        ),
      );

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late MessageNotificationService _notificationService;
  int? _currentUserAccId;

  @override
  void initState() {
    super.initState();
    _notificationService = sl<MessageNotificationService>();
    _notificationService.addListener(_onNewMessage);
    _getCurrentUserAccId();
  }

  Future<void> _getCurrentUserAccId() async {
    final accId = await sl<GetAccIdUseCase>().call(null);
    setState(() {
      _currentUserAccId = accId;
    });
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNewMessage);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onNewMessage(Message message) {
    context.read<MessagesCubit>().getMessages(widget.contactId);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<MessagesCubit>().sendMessage(
            _messageController.text.trim(),
            widget.contactId,
          );
      _messageController.clear();
    }
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (messageDate == today) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactName),
        backgroundColor: AppPallete.backgroundColor,
        foregroundColor: AppPallete.textColor,
      ),
      backgroundColor: AppPallete.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MessagesCubit, MessagesState>(
              builder: (context, state) {
                if (state is MessagesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppPallete.primaryColor,
                    ),
                  );
                } else if (state is MessagesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppPallete.errorColor,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(
                            color: AppPallete.errorColor,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: AppButton(
                            text: 'Retry',
                            onPressed: () => context
                                .read<MessagesCubit>()
                                .getMessages(widget.contactId),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is MessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: AppPallete.lightGrayColor,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No messages found',
                            style: TextStyle(
                              color: AppPallete.darkGrayColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = state.messages.length - 1 - index;
                      final message = state.messages[reversedIndex];
                      final isMyMessage = _currentUserAccId != null &&
                          message.senderId == _currentUserAccId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: isMyMessage
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isMyMessage) ...[
                              CircleAvatar(
                                backgroundColor: AppPallete.primaryColor,
                                radius: 16,
                                child: Text(
                                  widget.contactName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppPallete.backgroundColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isMyMessage
                                      ? AppPallete.primaryColor
                                      : AppPallete.backgroundColor,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        color: isMyMessage
                                            ? AppPallete.backgroundColor
                                            : AppPallete.textColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(message.sentAt),
                                      style: TextStyle(
                                        color: isMyMessage
                                            ? AppPallete.backgroundColor
                                                .withOpacity(0.8)
                                            : AppPallete.darkGrayColor,
                                        fontSize: 12,
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
                return const SizedBox.shrink();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppPallete.backgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: AppField(
                    labelText: 'Type a message...',
                    controller: _messageController,
                    required: false,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(
                    Icons.send,
                    color: AppPallete.primaryColor,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
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
