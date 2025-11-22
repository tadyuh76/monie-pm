import 'package:flutter/material.dart';
import 'package:monie/features/ai_chat/presentation/widgets/draggable_chat_bubble.dart';

class ChatBubbleManager {
  // Singleton pattern
  ChatBubbleManager._privateConstructor();
  static final ChatBubbleManager instance = ChatBubbleManager._privateConstructor();

  OverlayEntry? _overlayEntry;

  /// Hiển thị bong bóng chat
  void show(BuildContext context) {
    if (_overlayEntry != null) {
      return; // Đã hiển thị rồi
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => const DraggableChatBubble(),
    );

    // Thêm vào overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Ẩn bong bóng chat
  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
