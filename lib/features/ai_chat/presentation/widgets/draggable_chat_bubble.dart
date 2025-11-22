import 'package:flutter/material.dart';
import 'package:monie/core/themes/app_colors.dart';
import 'package:monie/features/ai_chat/presentation/pages/ai_chat_page.dart';

class DraggableChatBubble extends StatefulWidget {
  const DraggableChatBubble({super.key});

  @override
  State<DraggableChatBubble> createState() => _DraggableChatBubbleState();
}

class _DraggableChatBubbleState extends State<DraggableChatBubble> with SingleTickerProviderStateMixin {
  Offset position = const Offset(20, 500); // Vị trí ban đầu
  late AnimationController _controller;
  late Animation<Offset> _animation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Thời gian "hút" về cạnh
    );
    _controller.addListener(() {
      setState(() {
        position = _animation.value;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Đặt vị trí mặc định ban đầu (góc dưới trái)
    final size = MediaQuery.of(context).size;
    if (position == const Offset(20, 500)) {
       position = Offset(20, size.height - 160); 
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Hàm tính toán vị trí "hút" về cạnh
  void _snapToEdge(Size screenSize) {
    final double endX;
    
    // Chia đôi màn hình, thả bên nào thì hút về bên đó
    if (position.dx + 30 < screenSize.width / 2) {
      endX = 16.0; // Cách lề trái 16px
    } else {
      endX = screenSize.width - 60 - 16.0; // Cách lề phải 16px (trừ width bong bóng)
    }

    // Giữ nguyên Y, nhưng đảm bảo không bị kéo ra khỏi màn hình trên/dưới
    double endY = position.dy;
    if (endY < 50) endY = 50; // Cách top tối thiểu
    if (endY > screenSize.height - 100) endY = screenSize.height - 100; // Cách bottom tối thiểu

    // Bắt đầu animation
    _animation = Tween<Offset>(
      begin: position,
      end: Offset(endX, endY),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        // Xử lý kéo thả thủ công bằng PanUpdate để kiểm soát tốt hơn Draggable
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
        },
        onPanEnd: (details) {
          setState(() => _isDragging = false);
          _snapToEdge(screenSize); // Thả tay ra -> Hút về cạnh
        },
        onTap: () {
          // Yêu cầu 2: Bấm vào mở trang Chat mới (Full Screen Page)
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AIChatPage()),
          );
        },
        child: _buildBubble(),
      ),
    );
  }

  Widget _buildBubble() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Gradient màu tím/xanh hiện đại
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B8AFE),
            Color(0xFF5D3FD3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          )
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome, // Icon AI lấp lánh
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
