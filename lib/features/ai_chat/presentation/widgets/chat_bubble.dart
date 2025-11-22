import 'package:flutter/material.dart';
import 'package:monie/core/themes/app_colors.dart'; 
import 'package:monie/features/ai_chat/domain/entities/chat_message.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; 

// Import các widget attachment (sẽ tạo ở bước sau nếu cần chart)

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Màu sắc theo phong cách Messenger
    final backgroundColor = isUser
        ? AppColors.primary // Màu chủ đạo của app
        : (isDarkMode ? Colors.grey[800] : Colors.grey[200]);
    
    final textColor = isUser
        ? Colors.white
        : (isDarkMode ? Colors.white : Colors.black87);

    // Bo góc tùy chỉnh (nhọn 1 góc tạo hiệu ứng đuôi)
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar AI (chỉ hiện bên trái)
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.secondary.withOpacity(0.2),
              child: const Icon(Icons.smart_toy_outlined, size: 16, color: AppColors.secondary),
            ),
            const SizedBox(width: 8),
          ],

          // Nội dung tin nhắn
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Text Message
                  MarkdownBody(
                    data: message.text,
                    styleSheet: MarkdownStyleSheet(
                      p: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        height: 1.4,
                      ),
                      strong: TextStyle( // Style cho chữ in đậm (**)
                        fontWeight: FontWeight.bold,
                        color: textColor, 
                      ),
                      // Các style khác nếu cần
                    ),
                  ),
                  // 2. Attachments (Charts/Cards)
                  if (message.attachments != null && message.attachments!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    // Render attachment đầu tiên (demo, thực tế có thể map list)
                    _buildAttachmentPreview(message.attachments!.first, context),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper đơn giản để placeholder cho attachment (sẽ implement chi tiết chart sau)
  Widget _buildAttachmentPreview(ChatAttachment attachment, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            attachment.type == 'chart' ? Icons.bar_chart : Icons.info_outline,
            color: Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'View ${attachment.type}', // Sẽ thay bằng Chart Widget thật
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
