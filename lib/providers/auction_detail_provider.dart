import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/models.dart';
import '../../data/services/services.dart';

/// Auction Detail Provider - Manages auction state and real-time updates
class AuctionDetailProvider extends ChangeNotifier {
  final ApiService _apiService;
  final SocketService _socketService;

  AuctionModel? _auction;
  List<BidModel> _bids = [];
  List<QuestionModel> _questions = [];
  AutoBidConfig? _autoBidConfig;
  Map<String, dynamic>? _completionDetails;
  bool _isCompletionLoading = false;
  
  bool _isLoading = false;
  bool _isBidding = false;
  String? _error;
  bool _isConnected = false;
  
  // Timer for countdown
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;
  
  // HTTP Polling fallback timer (when Socket.IO fails)
  Timer? _pollingTimer;
  int _socketFailCount = 0;
  static const int _maxSocketFailsBeforePolling = 3;
  
  // Stream subscriptions
  StreamSubscription? _bidSubscription;
  StreamSubscription? _priceSubscription;
  StreamSubscription? _timerSubscription;
  StreamSubscription? _auctionEndSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _bidSuccessSubscription;
  StreamSubscription? _bidErrorSubscription;
  StreamSubscription? _auctionListUpdateSubscription;

  // Getters
  AuctionModel? get auction => _auction;
  List<BidModel> get bids => _bids;
  List<QuestionModel> get questions => _questions;
  AutoBidConfig? get autoBidConfig => _autoBidConfig;
  Map<String, dynamic>? get completionDetails => _completionDetails;
  bool get isCompletionLoading => _isCompletionLoading;
  bool get isLoading => _isLoading;
  bool get isBidding => _isBidding;
  String? get error => _error;
  bool get isConnected => _isConnected;
  Duration get timeRemaining => _timeRemaining;
  
  bool get hasEnded => _timeRemaining <= Duration.zero;
  bool get isAboutToEnd => _timeRemaining.inMinutes <= AppConstants.antiSnipingThresholdMinutes && !hasEnded;
  double get nextMinBid => (_auction?.currentPrice ?? 0) + (_auction?.minBidIncrement ?? 0);

  AuctionDetailProvider({
    ApiService? apiService,
    SocketService? socketService,
  })  : _apiService = apiService ?? ApiService.instance,
        _socketService = socketService ?? SocketService.instance;

  /// Load auction details
  Future<void> loadAuction(String auctionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📦 Loading auction: $auctionId');
      _auction = await _apiService.getAuctionById(auctionId);
      print('✅ Auction loaded: ${_auction?.title}');
      _bids = _auction!.recentBids;
      _questions = _auction!.questions;
      
      _updateTimeRemaining();
      _startCountdownTimer();
      _subscribeToRealTimeUpdates(auctionId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e, stack) {
      print('❌ Load auction error: $e');
      print('Stack: $stack');
      _error = 'فشل في تحميل بيانات المزاد: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force refresh auction data from server (used after bid to avoid stale state)
  Future<void> _refreshAuction() async {
    if (_auction == null) return;
    try {
      final fresh = await _apiService.getAuctionById(_auction!.id);
      _auction = fresh;
      _bids = fresh.recentBids;
      _questions = fresh.questions;
      _updateTimeRemaining();
      notifyListeners();
    } catch (e) {
      // If refresh fails, keep existing state; no crash
      print('⚠️ Failed to refresh auction after bid: $e');
    }
  }

  /// Load completion details (winner/seller contact) when auction is finished
  Future<void> loadCompletionDetails() async {
    if (_auction == null) return;
    if (_completionDetails != null) return;
    if (_isCompletionLoading) return;

    _isCompletionLoading = true;
    notifyListeners();
    try {
      final data = await _apiService.getAuctionCompletionDetails(_auction!.id);
      _completionDetails = data;
    } catch (e) {
      print('⚠️ Failed to load completion details: $e');
    } finally {
      _isCompletionLoading = false;
      notifyListeners();
    }
  }

  /// Subscribe to real-time updates
  void _subscribeToRealTimeUpdates(String auctionId) {
    print('🔌 Subscribing to real-time updates for: $auctionId');
    print('🔌 Socket connected: ${_socketService.isConnected}');
    
    // Ensure socket is connected before joining
    if (!_socketService.isConnected) {
      print('🔌 Socket not connected, connecting as guest...');
      _socketService.connectAsGuest();
    }
    
    // Listen for connection status and join when connected
    _connectionSubscription = _socketService.connectionStatusStream.listen((connected) {
      print('🔌 Connection status changed: $connected');
      _isConnected = connected;
      if (connected) {
        print('🔌 Socket now connected! Joining auction room: $auctionId');
        _socketService.joinAuction(auctionId);
        // Socket connected - stop polling if active
        _stopPolling();
        _socketFailCount = 0;
      } else {
        // Socket disconnected - start polling immediately as fallback
        print('⚠️ Socket disconnected, starting HTTP polling fallback...');
        _startPolling(auctionId);
      }
      notifyListeners();
    });
    
    // Also try to join immediately if already connected
    if (_socketService.isConnected) {
      _socketService.joinAuction(auctionId);
    } else {
      // Start polling immediately as fallback since socket isn't connected
      print('⚠️ Socket not connected, starting HTTP polling fallback...');
      _startPolling(auctionId);
    }

    _bidSubscription = _socketService.bidStream.listen((bid) {
      if (bid.auctionId == auctionId) {
        _handleNewBid(bid);
      }
    });

    _priceSubscription = _socketService.priceUpdateStream.listen((data) {
      if (data['auctionId'] == auctionId) {
        _handlePriceUpdate(data);
      }
    });

    _timerSubscription = _socketService.timerExtendStream.listen((data) {
      if (data['auctionId'] == auctionId) {
        _handleTimerExtension(data);
      }
    });

    _auctionEndSubscription = _socketService.auctionEndStream.listen((endedAuctionId) {
      if (endedAuctionId == auctionId) {
        _handleAuctionEnd();
      }
    });

    // Listen for global auction list updates (fallback if room broadcast fails)
    _auctionListUpdateSubscription = _socketService.auctionListUpdateStream.listen((data) {
      if (data['auctionId'] == auctionId) {
        print('📢 Received auction_list_update for current auction');
        _handlePriceUpdate(data);
      }
    });

    // Listen for bid success
    _bidSuccessSubscription = _socketService.bidSuccessStream.listen((data) {
      print('✅ Bid success received: $data');
      
      // Update local auction price immediately
      final amount = data['amount'];
      if (_auction != null && amount != null) {
        _auction = _auction!.copyWith(
          currentPrice: (amount as num).toDouble(),
          bidCount: _auction!.bidCount + 1,
        );
      }
      
      if (_bidCompleter != null && !_bidCompleter!.isCompleted) {
        _bidCompleter!.complete(true);
      }
      _isBidding = false;
      notifyListeners();
    });

    // Listen for bid errors
    _bidErrorSubscription = _socketService.bidErrorStream.listen((errorMessage) {
      print('❌ Bid error received: $errorMessage');
      _error = errorMessage;
      if (_bidCompleter != null && !_bidCompleter!.isCompleted) {
        _bidCompleter!.complete(false);
      }
      _isBidding = false;
      notifyListeners();
    });
  }

  /// Handle new bid from socket
  void _handleNewBid(BidModel bid) {
    // Add to bids list
    _bids = [bid, ..._bids];
    
    // Update auction price, bid count, and highest bidder
    if (_auction != null) {
      _auction = _auction!.copyWith(
        currentPrice: bid.amount,
        bidCount: _auction!.bidCount + 1,
        highestBidderId: bid.bidderId,
      );
    }
    
    notifyListeners();
  }

  /// Handle price update from socket
  void _handlePriceUpdate(Map<String, dynamic> data) {
    if (_auction != null) {
      final newPrice = data['newPrice'] ?? data['currentPrice'];
      final bidderId = data['bidderId'] as String?;
      _auction = _auction!.copyWith(
        currentPrice: (newPrice as num).toDouble(),
        bidCount: data['bidCount'] as int? ?? _auction!.bidCount,
        highestBidderId: bidderId ?? _auction!.highestBidderId,
      );
      notifyListeners();
    }
  }

  /// Handle timer extension (anti-sniping)
  void _handleTimerExtension(Map<String, dynamic> data) {
    if (_auction != null) {
      final newEndTime = DateTime.parse(data['newEndTime'] as String);
      _auction = _auction!.copyWith(endTime: newEndTime);
      _updateTimeRemaining();
      notifyListeners();
    }
  }

  /// Handle auction end
  void _handleAuctionEnd() {
    if (_auction != null) {
      _auction = _auction!.copyWith(status: AuctionStatus.ended);
      _timeRemaining = Duration.zero;
      _countdownTimer?.cancel();
      notifyListeners();
    }
  }

  /// Start countdown timer
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
      notifyListeners();
    });
  }

  /// Update time remaining
  void _updateTimeRemaining() {
    if (_auction == null) {
      _timeRemaining = Duration.zero;
      return;
    }

    final now = DateTime.now();
    if (now.isAfter(_auction!.endTime)) {
      _timeRemaining = Duration.zero;
      _countdownTimer?.cancel();
    } else {
      _timeRemaining = _auction!.endTime.difference(now);
    }
  }

  /// Place a quick bid (minimum increment)
  Future<bool> placeQuickBid() async {
    if (_auction == null || hasEnded) return false;
    return await placeBid(nextMinBid);
  }

  // Completer for waiting bid response
  Completer<bool>? _bidCompleter;

  /// Place a custom bid
  Future<bool> placeBid(double amount) async {
    if (_auction == null || hasEnded) {
      print('❌ Cannot bid: auction=$_auction, hasEnded=$hasEnded');
      return false;
    }
    if (amount < nextMinBid) {
      print('❌ Amount $amount < nextMinBid $nextMinBid');
      return false;
    }

    _isBidding = true;
    _error = null;
    notifyListeners();

    try {
      print('💰 Placing bid: auctionId=${_auction!.id}, amount=$amount');
      
      // Check if socket is connected
      if (_socketService.isConnected) {
        print('🔌 Using Socket for bid');
        
        // Create completer to wait for response
        _bidCompleter = Completer<bool>();
        
        _socketService.placeBid(
          auctionId: _auction!.id,
          amount: amount,
        );
        
        // Wait for bid_success or bid_error with timeout
        final success = await _bidCompleter!.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('⏱️ Bid timeout - using REST API fallback');
            return false;
          },
        );
        
        _bidCompleter = null;
        _isBidding = false;
        notifyListeners();

        if (success) {
          await _refreshAuction();
        }
        return success;
      } else {
        // Fallback to REST API
        print('🌐 Socket not connected, using REST API');
        final bid = await _apiService.placeBid(
          auctionId: _auction!.id,
          amount: amount,
        );
        print('✅ Bid placed via REST API: ${bid.id}');
        
        // Update local state with my bid
        _bids = [bid, ..._bids];
        _auction = _auction!.copyWith(
          currentPrice: bid.amount,
          bidCount: _auction!.bidCount + 1,
          highestBidderId: bid.bidderId,
        );
        
        _isBidding = false;
        notifyListeners();

        await _refreshAuction();
        return true;
      }
    } catch (e) {
      print('❌ Bid error: $e');
      
      // Try to extract error message from DioException
      String errorMessage = 'فشل في تقديم المزايدة';
      if (e.toString().contains('أنت صاحب أعلى مزايدة')) {
        errorMessage = 'أنت صاحب أعلى مزايدة حالياً';
        // Update local state to reflect this
        if (_auction != null) {
          _auction = _auction!.copyWith(highestBidderId: 'current_user');
        }
      } else if (e.toString().contains('message')) {
        // Try to parse the error message
        final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(e.toString());
        if (match != null) {
          errorMessage = match.group(1) ?? errorMessage;
        }
      }
      
      _error = errorMessage;
      _isBidding = false;
      _bidCompleter = null;
      notifyListeners();
      return false;
    }
  }

  /// Setup auto-bid
  Future<bool> setupAutoBid(double maxAmount) async {
    if (_auction == null || hasEnded) return false;
    if (maxAmount < nextMinBid) return false;

    try {
      _socketService.setupAutoBid(
        auctionId: _auction!.id,
        maxAmount: maxAmount,
      );
      
      _autoBidConfig = AutoBidConfig(
        auctionId: _auction!.id,
        maxAmount: maxAmount,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل في إعداد المزايدة التلقائية';
      notifyListeners();
      return false;
    }
  }

  /// Cancel auto-bid
  void cancelAutoBid() {
    if (_auction == null) return;
    
    _socketService.cancelAutoBid(_auction!.id);
    _autoBidConfig = null;
    notifyListeners();
  }

  /// Ask a question
  Future<bool> askQuestion(String question) async {
    if (_auction == null) return false;

    try {
      final newQuestion = await _apiService.askQuestion(
        auctionId: _auction!.id,
        question: question,
      );
      
      _questions = [..._questions, newQuestion];
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل في إرسال السؤال';
      notifyListeners();
      return false;
    }
  }

  /// Check how many questions current user has asked
  int getUserQuestionCount(String userId) {
    return _questions.where((q) => q.askerId == userId).length;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Start HTTP polling as fallback when Socket.IO fails
  void _startPolling(String auctionId) {
    _stopPolling(); // Clear any existing timer
    print('🔄 Starting HTTP polling for auction: $auctionId (every 3 seconds)');
    
    // Poll immediately first
    _pollAuction(auctionId);
    
    // Then poll every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _pollAuction(auctionId);
    });
  }

  /// Poll auction data from API
  Future<void> _pollAuction(String auctionId) async {
    if (_auction == null) return;
    
    try {
      final fresh = await _apiService.getAuctionById(auctionId);
      
      // Check if price or bid count changed
      if (fresh.currentPrice != _auction!.currentPrice ||
          fresh.bidCount != _auction!.bidCount ||
          fresh.questions.length != _questions.length) {
        print('📊 Polling detected update: price ${_auction!.currentPrice} -> ${fresh.currentPrice}');
        _auction = fresh;
        _bids = fresh.recentBids;
        _questions = fresh.questions;
        _updateTimeRemaining();
        notifyListeners();
      }
    } catch (e) {
      print('⚠️ Polling failed: $e');
    }
  }

  /// Stop HTTP polling
  void _stopPolling() {
    if (_pollingTimer != null) {
      print('🛑 Stopping HTTP polling');
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  /// Clean up resources
  @override
  void dispose() {
    if (_auction != null) {
      _socketService.leaveAuction(_auction!.id);
    }
    
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();
    _bidSubscription?.cancel();
    _priceSubscription?.cancel();
    _timerSubscription?.cancel();
    _auctionEndSubscription?.cancel();
    _connectionSubscription?.cancel();
    _bidSuccessSubscription?.cancel();
    _bidErrorSubscription?.cancel();
    _auctionListUpdateSubscription?.cancel();
    
    super.dispose();
  }
}
