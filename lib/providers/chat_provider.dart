import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/services/services.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;
  final SocketService _socketService;

  List<Map<String, dynamic>> _conversations = [];
  Map<String, dynamic>? _currentConversation;
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _auctionDetails;
  
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  StreamSubscription? _messageSubscription;

  // Getters
  List<Map<String, dynamic>> get conversations => _conversations;
  Map<String, dynamic>? get currentConversation => _currentConversation;
  List<Map<String, dynamic>> get messages => _messages;
  Map<String, dynamic>? get auctionDetails => _auctionDetails;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  int get totalUnreadCount => _conversations.fold(0, (sum, c) => sum + ((c['unreadCount'] as int?) ?? 0));

  ChatProvider({
    ApiService? apiService,
    SocketService? socketService,
  })  : _apiService = apiService ?? ApiService.instance,
        _socketService = socketService ?? SocketService.instance;

  /// Load all conversations
  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _apiService.getConversations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في تحميل المحادثات: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Open conversation for auction
  Future<void> openConversation(String auctionId) async {
    _isLoading = true;
    _error = null;
    _messages = [];
    notifyListeners();

    try {
      // Get or create conversation
      _currentConversation = await _apiService.getOrCreateConversation(auctionId);
      
      // Load messages
      final conversationId = _currentConversation!['id'] as String;
      _messages = await _apiService.getMessages(conversationId);
      
      // Load auction details
      _auctionDetails = await _apiService.getAuctionCompletionDetails(auctionId);

      // Subscribe to real-time updates
      _subscribeToMessages(conversationId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في فتح المحادثة: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Open existing conversation by ID
  Future<void> openConversationById(String conversationId, String auctionId) async {
    _isLoading = true;
    _error = null;
    _messages = [];
    notifyListeners();

    try {
      _currentConversation = {'id': conversationId, 'auctionId': auctionId};
      
      // Load messages
      _messages = await _apiService.getMessages(conversationId);
      
      // Load auction details
      _auctionDetails = await _apiService.getAuctionCompletionDetails(auctionId);

      // Subscribe to real-time updates
      _subscribeToMessages(conversationId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في فتح المحادثة: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToMessages(String conversationId) {
    _messageSubscription?.cancel();
    // Listen for new messages through socket
    // The socket emits 'new_message' events
  }

  /// Send a message
  Future<bool> sendMessage(String body, {String messageType = 'text', String? attachmentUrl}) async {
    if (_currentConversation == null) return false;

    _isSending = true;
    notifyListeners();

    try {
      final message = await _apiService.sendMessage(
        conversationId: _currentConversation!['id'] as String,
        body: body,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
      );

      _messages = [..._messages, message];
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل في إرسال الرسالة: $e';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  /// Update delivery status
  Future<void> updateStatus(String status) async {
    if (_currentConversation == null) return;

    try {
      await _apiService.updateConversationStatus(
        _currentConversation!['id'] as String,
        status,
      );
      
      _currentConversation = {
        ..._currentConversation!,
        'status': status,
      };
      notifyListeners();
    } catch (e) {
      _error = 'فشل في تحديث الحالة';
      notifyListeners();
    }
  }

  /// Handle incoming message from socket
  void handleNewMessage(Map<String, dynamic> message) {
    if (_currentConversation != null && 
        message['conversationId'] == _currentConversation!['id']) {
      _messages = [..._messages, message];
      notifyListeners();
    }
    
    // Update conversations list
    final index = _conversations.indexWhere((c) => c['id'] == message['conversationId']);
    if (index != -1) {
      _conversations[index] = {
        ..._conversations[index],
        'lastMessage': message['body'],
        'lastMessageTime': message['createdAt'],
        'unreadCount': (_conversations[index]['unreadCount'] as int? ?? 0) + 1,
      };
      notifyListeners();
    }
  }

  /// Close current conversation
  void closeConversation() {
    _messageSubscription?.cancel();
    _currentConversation = null;
    _messages = [];
    _auctionDetails = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
