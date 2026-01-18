import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/auth_provider.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String auctionId;
  final String otherUserName;
  final String auctionTitle;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.auctionId,
    required this.otherUserName,
    required this.auctionTitle,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().openConversationById(
        widget.conversationId,
        widget.auctionId,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    context.read<ChatProvider>().closeConversation();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final currentUserId = context.read<AuthProvider>().user?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(chatProvider),
      body: Column(
        children: [
          // Auction Details Card
          if (chatProvider.auctionDetails != null)
            _buildAuctionCard(chatProvider.auctionDetails!),
          
          // Messages List
          Expanded(
            child: chatProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      final isMe = message['senderId'] == currentUserId;
                      final isSystem = message['messageType'] == 'system';
                      
                      if (isSystem) {
                        return _buildSystemMessage(message);
                      }
                      
                      return _MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  ),
          ),

          // Message Input
          _buildMessageInput(chatProvider),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatProvider chatProvider) {
    return AppBar(
      backgroundColor: const Color(0xFF1a1a2e),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.otherUserName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.auctionTitle,
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(value, chatProvider),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 8),
                  Text('تفاصيل المزاد'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'shipped',
              child: Row(
                children: [
                  Icon(Icons.local_shipping, size: 20),
                  SizedBox(width: 8),
                  Text('تم الشحن'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delivered',
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 20),
                  SizedBox(width: 8),
                  Text('تم التوصيل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'completed',
              child: Row(
                children: [
                  Icon(Icons.done_all, size: 20, color: Colors.green),
                  SizedBox(width: 8),
                  Text('إتمام الصفقة'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuctionCard(Map<String, dynamic> details) {
    final images = details['images'] as List<dynamic>? ?? [];
    final finalPrice = details['finalPrice'] as num? ?? 0;
    final isSeller = details['isSeller'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: images.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(images.first as String),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.grey[200],
            ),
            child: images.isEmpty
                ? Icon(Icons.image, color: Colors.grey[400])
                : null,
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details['title'] as String? ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'السعر النهائي: ${finalPrice.toStringAsFixed(0)} د.ع',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSeller ? Colors.orange.shade100 : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isSeller ? 'بائع' : 'مشتري',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSeller ? Colors.orange.shade700 : Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Color(0xFF1E88E5), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message['body'] as String? ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatProvider chatProvider) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onPressed: () {
              // TODO: Implement attachment
            },
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالة...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(chatProvider),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1a1a2e),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: chatProvider.isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: chatProvider.isSending ? null : () => _sendMessage(chatProvider),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatProvider chatProvider) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final success = await chatProvider.sendMessage(text);
    
    if (success) {
      _scrollToBottom();
    }
  }

  void _handleMenuAction(String action, ChatProvider chatProvider) {
    switch (action) {
      case 'details':
        _showDetailsDialog();
        break;
      case 'shipped':
      case 'delivered':
      case 'completed':
        _confirmStatusChange(action, chatProvider);
        break;
    }
  }

  void _showDetailsDialog() {
    final details = context.read<ChatProvider>().auctionDetails;
    if (details == null) return;

    final seller = details['seller'] as Map<String, dynamic>?;
    final buyer = details['buyer'] as Map<String, dynamic>?;
    final isSeller = details['isSeller'] as bool? ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل الصفقة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('المنتج', details['title'] as String? ?? ''),
              _detailRow('السعر النهائي', '${details['finalPrice']} د.ع'),
              const Divider(),
              if (seller != null) ...[
                const Text('معلومات البائع:', style: TextStyle(fontWeight: FontWeight.bold)),
                _detailRow('الاسم', seller['name'] as String? ?? ''),
                if (!isSeller && seller['phone'] != null)
                  _detailRow('الهاتف', seller['phone'] as String),
              ],
              if (buyer != null) ...[
                const SizedBox(height: 8),
                const Text('معلومات المشتري:', style: TextStyle(fontWeight: FontWeight.bold)),
                _detailRow('الاسم', buyer['name'] as String? ?? ''),
                if (isSeller && buyer['phone'] != null)
                  _detailRow('الهاتف', buyer['phone'] as String),
              ],
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _confirmStatusChange(String status, ChatProvider chatProvider) {
    final statusText = {
      'shipped': 'تم الشحن',
      'delivered': 'تم التوصيل',
      'completed': 'تم إتمام الصفقة',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد'),
        content: Text('هل تريد تغيير الحالة إلى "${statusText[status]}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              chatProvider.updateStatus(status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1a1a2e),
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF1a1a2e) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message['body'] as String? ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message['createdAt'] as String?),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white60 : Colors.grey[500],
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message['isRead'] == true ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message['isRead'] == true ? Colors.blue[300] : Colors.white60,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
