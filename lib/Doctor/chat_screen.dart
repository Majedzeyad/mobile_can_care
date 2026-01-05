import 'package:flutter/material.dart';
import '../services/firebase_services.dart';
import '../models/group_chat_model.dart';
import '../models/group_chat_message_model.dart';

/// Chat Screen - شاشة المحادثة
///
/// Real-time chat interface for group chats
/// Features:
/// - Real-time message updates
/// - Send messages
/// - View message history
/// - Show sender name, role, and timestamp
/// - Mark messages as read
class ChatScreen extends StatefulWidget {
  final String groupId;

  const ChatScreen({super.key, required this.groupId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseServices _firebaseServices = FirebaseServices.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  GroupChatModel? _group;
  Map<String, String> _members = {};
  bool _isLoading = true;
  bool _isSending = false;
  Stream<List<GroupChatMessageModel>>? _messagesStream;
  List<GroupChatMessageModel> _fallbackMessages = [];
  bool _useFallback = false;
  // Pending messages (optimistic updates) - messages sent but not yet confirmed from Firebase
  final Map<String, GroupChatMessageModel> _pendingMessages = {};

  @override
  void initState() {
    super.initState();
    _loadGroupData();
    _setupMessagesStream();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupData() async {
    try {
      setState(() => _isLoading = true);

      // Load group info
      final group = await _firebaseServices.getGroupChat(widget.groupId);
      if (group == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('المجموعة غير موجودة')));
          Navigator.pop(context);
        }
        return;
      }

      // Load members
      final members = await _firebaseServices.getGroupChatMembers(
        widget.groupId,
      );

      if (mounted) {
        setState(() {
          _group = group;
          _members = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Chat Screen] Error loading group data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل بيانات المجموعة: $e')),
        );
      }
    }
  }

  void _setupMessagesStream() async {
    try {
      _messagesStream = _firebaseServices.getGroupChatMessages(widget.groupId);
      setState(() {});

      // Try to load messages once as fallback
      _loadMessagesFallback();

      // Scroll to bottom after initial load to show latest messages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_scrollController.hasClients && mounted) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      });
    } catch (e) {
      print('[Chat Screen] Error setting up stream: $e');
      // Use fallback
      _loadMessagesFallback();
    }
  }

  Future<void> _loadMessagesFallback() async {
    try {
      print('[Chat Screen] Loading messages using fallback method...');
      final messages = await _firebaseServices.getGroupChatMessagesOnce(
        widget.groupId,
      );
      if (mounted) {
        setState(() {
          _fallbackMessages = messages;
          _useFallback = messages.isNotEmpty;
        });
        print('[Chat Screen] Fallback loaded ${messages.length} messages');
      }
    } catch (e) {
      print('[Chat Screen] Error loading fallback messages: $e');
    }
  }

  Widget _buildMessagesList(
    List<GroupChatMessageModel> messages,
    ThemeData theme,
  ) {
    final currentUserId = _firebaseServices.currentUserId;

    // Mark messages as read when viewing
    if (currentUserId != null) {
      for (final message in messages) {
        if (!message.isReadBy(currentUserId) &&
            message.senderId != currentUserId) {
          _firebaseServices.markMessageAsRead(message.id);
        }
      }
    }

    // Auto-scroll to bottom when new messages arrive (real-time updates)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Always scroll to bottom for real-time updates (millisecond precision)
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;

        // Scroll if not already at bottom (with small threshold)
        if ((maxScroll - currentScroll).abs() > 50) {
          _scrollController.animateTo(
            maxScroll,
            duration: const Duration(
              milliseconds: 200,
            ), // Faster for real-time feel
            curve: Curves.easeOut,
          );
        } else {
          // If already near bottom, just jump to ensure we're at the exact bottom
          _scrollController.jumpTo(maxScroll);
        }
      }
    });

    print(
      '[Chat Screen] Displaying ${messages.length} messages (all past and future)',
    );

    if (messages.isEmpty) {
      print('[Chat Screen] Messages list is empty!');
      return const Center(child: Text('لا توجد رسائل'));
    }

    // Debug: Print first message details
    if (messages.isNotEmpty) {
      final firstMsg = messages.first;
      print(
        '[Chat Screen] First message: id=${firstMsg.id}, senderId=${firstMsg.senderId}, message="${firstMsg.message}", groupChatId=${firstMsg.groupChatId}',
      );
    }

    // Debug: Print all messages
    print('[Chat Screen] Total messages to display: ${messages.length}');
    print('[Chat Screen] Current user ID: $currentUserId');

    int myMessagesCount = 0;
    int otherMessagesCount = 0;

    for (var i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final isMyMessage = msg.senderId == currentUserId;
      if (isMyMessage) {
        myMessagesCount++;
      } else {
        otherMessagesCount++;
      }
      print(
        '[Chat Screen] Message $i: senderId=${msg.senderId}, senderName=${msg.senderName}, senderRole=${msg.senderRole}, message="${msg.message}", isMe=$isMyMessage',
      );
    }

    print(
      '[Chat Screen] Summary: My messages=$myMessagesCount, Other users messages=$otherMessagesCount',
    );

    // Get currentUserId fresh for each build to ensure accuracy
    final currentUserIdFresh = _firebaseServices.currentUserId;

    if (currentUserIdFresh == null) {
      print(
        '[Chat Screen] WARNING: currentUserId is null! Cannot determine message alignment.',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      itemCount: messages.length,
      reverse: false, // Show oldest first, scroll to bottom
      itemBuilder: (context, index) {
        final message = messages[index];

        // Get fresh currentUserId for each message to ensure accuracy
        final currentUserIdForMessage = _firebaseServices.currentUserId;

        // IMPORTANT: Compare senderId with currentUserId
        // If senderId matches currentUserId, it's MY message
        // If senderId is different, it's from ANOTHER user
        final senderIdTrimmed = message.senderId.trim();
        final currentUserIdTrimmed = currentUserIdForMessage?.trim() ?? '';

        final isMe =
            currentUserIdTrimmed.isNotEmpty &&
            senderIdTrimmed.isNotEmpty &&
            senderIdTrimmed == currentUserIdTrimmed;

        // Debug: Print detailed comparison
        print('[Chat Screen] ===== Message $index =====');
        print(
          '[Chat Screen] senderId (from message): "$senderIdTrimmed" (length: ${senderIdTrimmed.length})',
        );
        print(
          '[Chat Screen] currentUserId (logged in): "$currentUserIdTrimmed" (length: ${currentUserIdTrimmed.length})',
        );
        print('[Chat Screen] senderName: "${message.senderName}"');
        print('[Chat Screen] senderRole: "${message.senderRole}"');
        print('[Chat Screen] message: "${message.message}"');
        print('[Chat Screen] isMe: $isMe');
        print('[Chat Screen] ========================');

        // Additional debugging: character-by-character comparison if lengths match but not equal
        if (senderIdTrimmed.length == currentUserIdTrimmed.length &&
            senderIdTrimmed != currentUserIdTrimmed) {
          print('[Chat Screen] WARNING: Same length but different IDs!');
          for (int i = 0; i < senderIdTrimmed.length; i++) {
            if (senderIdTrimmed[i] != currentUserIdTrimmed[i]) {
              print(
                '[Chat Screen] First difference at index $i: "${senderIdTrimmed[i]}" (${senderIdTrimmed.codeUnitAt(i)}) vs "${currentUserIdTrimmed[i]}" (${currentUserIdTrimmed.codeUnitAt(i)})',
              );
              break;
            }
          }
        }

        return _buildMessageBubble(context, theme, message, isMe);
      },
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final messageText = _messageController.text.trim();
    final currentUserId = _firebaseServices.currentUserId;
    if (currentUserId == null) return;

    // Get sender info (simplified - FirebaseServices will handle this)
    String senderName = 'مستخدم';
    String senderRole = 'patient';
    try {
      final doctorProfile = await _firebaseServices.getDoctorProfile();
      if (doctorProfile != null) {
        senderName = doctorProfile.name ?? 'طبيب';
        senderRole = 'doctor';
      } else {
        final userRole = await _firebaseServices.getUserRole(currentUserId);
        if (userRole == 'nurse') {
          senderRole = 'nurse';
          senderName = 'ممرض';
        } else {
          senderRole = 'patient';
          senderName = 'مستخدم';
        }
      }
    } catch (e) {
      print('[Chat Screen] Error getting sender info: $e');
    }

    // Create pending message (optimistic update) - show immediately
    final pendingId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    final pendingMessage = GroupChatMessageModel(
      id: pendingId,
      groupChatId: widget.groupId,
      senderId: currentUserId,
      senderName: senderName,
      senderRole: senderRole,
      message: messageText,
      createdAt: DateTime.now(),
      readBy: {currentUserId: true},
    );

    // Add to pending messages immediately (optimistic update)
    setState(() {
      _pendingMessages[pendingId] = pendingMessage;
      _messageController.clear();
      _isSending = true;
    });

    // Scroll to bottom immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      // Send message to Firebase
      final messageId = await _firebaseServices.sendGroupChatMessage(
        groupId: widget.groupId,
        message: messageText,
      );

      print('[Chat Screen] Message sent with ID: $messageId');
      
      // Remove pending message - it will be replaced by the real message from stream
      // The stream will automatically update with the real message
      setState(() {
        _pendingMessages.remove(pendingId);
      });
    } catch (e) {
      print('[Chat Screen] Error sending message: $e');
      if (mounted) {
        // Remove pending message on error
        setState(() {
          _pendingMessages.remove(pendingId);
        });
        // Restore message text on error
        _messageController.text = messageText;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في إرسال الرسالة: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    final diff = now.difference(date);

    // WhatsApp-like time formatting
    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}د';
    } else if (diff.inHours < 24 && messageDate == today) {
      final hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = hour < 12 ? 'ص' : 'م';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (diff.inDays < 7) {
      final days = [
        'الاثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
        'الأحد',
      ];
      return days[date.weekday - 1];
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month';
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return const Color(0xFF5B9AA0);
      case 'nurse':
        return const Color(0xFF9575CD);
      case 'patient':
        return const Color(0xFF81C784);
      default:
        return Colors.grey;
    }
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return 'طبيب';
      case 'nurse':
        return 'ممرض';
      case 'patient':
        return 'مريض';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _group?.name ?? 'المحادثة',
              style: const TextStyle(fontSize: 16),
            ),
            if (_group != null)
              Text(
                '${_group!.memberIds.length} عضو',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.info_outline),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('معلومات المجموعة'),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    _showGroupInfo(context, theme);
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                // WhatsApp-like background
                color: Color(0xFFECE5DD),
              ),
              child: Column(
                children: [
                  // Messages list
                  Expanded(
                    child: _useFallback
                        ? _buildMessagesList(_fallbackMessages, theme)
                        : _messagesStream == null
                        ? const Center(child: CircularProgressIndicator())
                        : StreamBuilder<List<GroupChatMessageModel>>(
                            stream: _messagesStream,
                            builder: (context, snapshot) {
                              print(
                                '[Chat Screen] StreamBuilder state: ${snapshot.connectionState}',
                              );
                              print(
                                '[Chat Screen] Has error: ${snapshot.hasError}',
                              );
                              print(
                                '[Chat Screen] Has data: ${snapshot.hasData}',
                              );

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                print('[Chat Screen] Waiting for data...');
                                // Show fallback messages if available while waiting
                                if (_fallbackMessages.isNotEmpty) {
                                  return _buildMessagesList(
                                    _fallbackMessages,
                                    theme,
                                  );
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError) {
                                print(
                                  '[Chat Screen] Stream error: ${snapshot.error}',
                                );
                                // Try to show fallback messages
                                if (_fallbackMessages.isNotEmpty) {
                                  return _buildMessagesList(
                                    _fallbackMessages,
                                    theme,
                                  );
                                }
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 64,
                                        color: Colors.red[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'خطأ في تحميل الرسائل',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(color: Colors.red[600]),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${snapshot.error}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.grey[500]),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadMessagesFallback,
                                        child: const Text('إعادة المحاولة'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final messages = snapshot.data ?? [];
                              print(
                                '[Chat Screen] Messages count: ${messages.length}',
                              );

                              // Merge pending messages (optimistic updates) with stream messages
                              final allMessages = <GroupChatMessageModel>[];
                              
                              // Add stream messages
                              allMessages.addAll(messages);
                              
                              // Add pending messages that haven't been confirmed yet
                              for (final pending in _pendingMessages.values) {
                                // Only add if not already in stream (check by content and sender)
                                final existsInStream = messages.any((msg) =>
                                    msg.message == pending.message &&
                                    msg.senderId == pending.senderId &&
                                    msg.createdAt != null &&
                                    pending.createdAt != null &&
                                    (msg.createdAt!.difference(pending.createdAt!).inSeconds.abs() < 5));
                                
                                if (!existsInStream) {
                                  allMessages.add(pending);
                                } else {
                                  // Remove from pending if confirmed
                                  _pendingMessages.remove(pending.id);
                                }
                              }
                              
                              // Sort all messages by createdAt
                              allMessages.sort((a, b) {
                                if (a.createdAt == null && b.createdAt == null) return 0;
                                if (a.createdAt == null) return 1;
                                if (b.createdAt == null) return -1;
                                return a.createdAt!.compareTo(b.createdAt!);
                              });

                              if (allMessages.isEmpty && _fallbackMessages.isEmpty) {
                                print(
                                  '[Chat Screen] No messages found for group ${widget.groupId}',
                                );
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'لا توجد رسائل بعد',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'ابدأ المحادثة بإرسال رسالة',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.grey[500]),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Group ID: ${widget.groupId}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[400],
                                              fontSize: 10,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // Use merged messages (stream + pending)
                              final displayMessages = allMessages.isNotEmpty
                                  ? allMessages
                                  : _fallbackMessages;

                              print(
                                '[Chat Screen] Displaying ${displayMessages.length} messages (${messages.length} from stream + ${_pendingMessages.length} pending)',
                              );

                              return _buildMessagesList(displayMessages, theme);
                            },
                          ),
                  ),

                  // Message input - WhatsApp style
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'اكتب رسالة...',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 15,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 15),
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _isSending
                              ? Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              theme.colorScheme.primary,
                                            ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: _sendMessage,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ThemeData theme,
    GroupChatMessageModel message,
    bool isMe,
  ) {
    final currentUserIdDebug = _firebaseServices.currentUserId;
    print(
      '[Chat Screen] _buildMessageBubble: isMe=$isMe, senderId="${message.senderId}", currentUserId="$currentUserIdDebug", senderName=${message.senderName}, senderRole=${message.senderRole}, message="${message.message}"',
    );

    // Force alignment based on isMe flag - ensure messages are on correct side
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    print('[Chat Screen] Message alignment: $alignment (isMe: $isMe)');

    return Align(
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 4,
          top: 4,
          left: isMe ? 50 : 8,
          right: isMe ? 8 : 50,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // IMPORTANT: Sender info (only if not me) - Always show sender name for other users
            // This ensures we can identify who sent each message
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sender name - always visible for other users
                    Text(
                      message.senderName.isNotEmpty
                          ? message.senderName
                          : 'مستخدم',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF4f7cff),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(
                          message.senderRole,
                        ).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getRoleLabel(message.senderRole),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getRoleColor(message.senderRole),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Message bubble - WhatsApp style
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFFDCF8C6) // WhatsApp green for own messages
                    : Colors.white, // White for other messages
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  topRight: const Radius.circular(8),
                  bottomLeft: Radius.circular(isMe ? 8 : 2),
                  bottomRight: Radius.circular(isMe ? 2 : 8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Only show message if not empty
                  if (message.message.isNotEmpty)
                    Text(
                      message.message,
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe ? Colors.black87 : Colors.black87,
                        height: 1.4,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '(رسالة فارغة)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 2),
                  // Time and read status - WhatsApp style
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.readBy != null && message.readBy!.length > 1
                              ? Icons.done_all
                              : Icons.done,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupInfo(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_group?.name ?? 'معلومات المجموعة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_group?.description != null &&
                  _group!.description!.isNotEmpty) ...[
                Text(
                  'الوصف:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_group!.description!),
                const SizedBox(height: 16),
              ],
              Text(
                'الأعضاء (${_group?.memberIds.length ?? 0}):',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...(_group?.memberIds.map((memberId) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(_members[memberId] ?? 'مستخدم'),
                        ],
                      ),
                    );
                  }) ??
                  []),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
