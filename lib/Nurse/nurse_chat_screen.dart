import 'package:flutter/material.dart';
import '../Doctor/chat_screen.dart';

/// Nurse Chat Screen - شاشة المحادثة للممرض/ة
///
/// Wrapper around the main ChatScreen that handles nurse-specific logic
/// This reuses the existing ChatScreen implementation from Doctor folder
class NurseChatScreen extends StatelessWidget {
  final String groupId;

  const NurseChatScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    // Reuse the existing ChatScreen implementation
    // It already handles all roles (doctor, nurse, patient)
    return ChatScreen(groupId: groupId);
  }
}

