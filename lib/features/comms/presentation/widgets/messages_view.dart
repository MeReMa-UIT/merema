import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/auth/domain/usecases/get_acc_id.dart';
import 'package:merema/features/comms/domain/entities/send_message_params.dart';
import 'package:merema/features/comms/presentation/bloc/messages_state_cubit.dart';
import 'package:merema/features/comms/presentation/bloc/messages_state.dart';
import 'package:merema/features/comms/presentation/notifiers/comms_notifier.dart';

class MessagesView extends StatefulWidget {
  final int contactId;
  final String contactName;
  final int conversationId;

  const MessagesView({
    super.key,
    required this.contactId,
    required this.contactName,
    required this.conversationId,
  });

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _currentUserAccId;
  String? _selectedMessageId;
  bool _hasMarkedAsSeen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCurrentUser();
    context.read<MessagesCubit>().getMessages(widget.conversationId);
    
    sl<CommsNotifier>().setActiveConversation(widget.conversationId);
  }

  Future<void> _initializeCurrentUser() async {
    try {
      _currentUserAccId = await sl<GetAccIdUseCase>().call(null);
      setState(() {});
    } catch (e) {
      debugPrint('Error getting current user ID: $e');
    }
  }

  @override
  void didUpdateWidget(MessagesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contactId != widget.contactId ||
        oldWidget.conversationId != widget.conversationId) {
      _hasMarkedAsSeen = false;
      // Update active conversation when switching to a different contact
      sl<CommsNotifier>().setActiveConversation(widget.conversationId);
      context.read<MessagesCubit>().getMessages(widget.conversationId);
    }
  }

  Future<void> _markMessagesAsSeen() async {
    final commsNotifier = sl<CommsNotifier>();
    await commsNotifier.markMessagesAsSeen(
      partnerAccId: widget.contactId,
      conversationId: widget.conversationId,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    
    sl<CommsNotifier>().clearActiveConversation();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _hasMarkedAsSeen = false;
      _markMessagesAsSeen();
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<MessagesCubit>().sendMessage(
            SendMessageParams(
              partnerAccId: widget.contactId,
              text: _messageController.text,
              conversationId: widget.conversationId,
            ),
          );
      _messageController.clear();
    }
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
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

  Widget _buildReadStatusWidget(String messageSentAt) {
    return FutureBuilder<String>(
      future: context.read<MessagesCubit>().getSeenStatus(messageSentAt),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Text(
            snapshot.data!,
            style: TextStyle(
              color: AppPallete.darkGrayColor.withOpacity(0.7),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _onMessageTap(String messageId, String messageSentAt) {
    setState(() {
      _selectedMessageId = _selectedMessageId == messageId ? null : messageId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppPallete.lightGrayColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppPallete.primaryColor,
                radius: 20,
                child: Text(
                  widget.contactName.isNotEmpty
                      ? widget.contactName[0].toUpperCase()
                      : '',
                  style: const TextStyle(
                    color: AppPallete.backgroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.contactName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocListener<MessagesCubit, MessagesState>(
            listener: (context, state) {
              if (state is MessagesLoaded &&
                  state.messages.isNotEmpty &&
                  !_hasMarkedAsSeen) {
                _hasMarkedAsSeen = true;
                final commsNotifier = sl<CommsNotifier>();
                final messagesData = state.messages
                    .map((msg) => {
                          'sender_acc_id': msg.senderAccId,
                          'is_seen': msg.isSeen,
                        })
                    .toList();

                commsNotifier.checkAndMarkMessagesAsSeen(
                  messages: messagesData,
                  partnerAccId: widget.contactId,
                  conversationId: widget.conversationId,
                );
              }
            },
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
                                .getMessages(widget.conversationId),
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
                    cacheExtent: 500.0,
                    itemBuilder: (context, index) {
                      final reversedIndex = state.messages.length - 1 - index;
                      final message = state.messages[reversedIndex];
                      final isMyMessage = _currentUserAccId != null &&
                          message.senderAccId == _currentUserAccId;
                      final isLastMessage =
                          reversedIndex == state.messages.length - 1;
                      final shouldShowStatus = isLastMessage ||
                          _selectedMessageId == message.messageId.toString();

                      return GestureDetector(
                        onTap: () => _onMessageTap(
                            message.messageId.toString(), message.sentAt),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: isMyMessage
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: isMyMessage
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (!isMyMessage) ...[
                                    CircleAvatar(
                                      backgroundColor: AppPallete.primaryColor,
                                      radius: 16,
                                      child: Text(
                                        widget.contactName.isNotEmpty
                                            ? widget.contactName[0]
                                                .toUpperCase()
                                            : '',
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
                                            MediaQuery.of(context).size.width *
                                                0.7,
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
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                              if (shouldShowStatus && isMyMessage)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 16,
                                    top: 4,
                                  ),
                                  child: _buildReadStatusWidget(message.sentAt),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppPallete.lightGrayColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
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
    );
  }
}
