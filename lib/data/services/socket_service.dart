import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

import '../models/bid_model.dart';
import '../models/auction_model.dart';

/// Socket Service for real-time auction updates
class SocketService {
  static SocketService? _instance;
  io.Socket? _socket;
  String? _lastAuthToken; // Store last auth token for reconnection
  static const String _tokenKey = 'auth_token';

  // Stream controllers for real-time events
  final _bidStreamController = StreamController<BidModel>.broadcast();
  final _priceUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _timerExtendController = StreamController<Map<String, dynamic>>.broadcast();
  final _auctionEndController = StreamController<String>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _viewerCountController = StreamController<Map<String, dynamic>>.broadcast();
  final _bidSuccessController = StreamController<Map<String, dynamic>>.broadcast();
  final _bidErrorController = StreamController<String>.broadcast();
  final _outbidController = StreamController<Map<String, dynamic>>.broadcast();
  final _newAuctionController = StreamController<AuctionModel>.broadcast();
  final _auctionListUpdateController = StreamController<Map<String, dynamic>>.broadcast();

  // Getters for streams
  Stream<BidModel> get bidStream => _bidStreamController.stream;
  Stream<Map<String, dynamic>> get priceUpdateStream => _priceUpdateController.stream;
  Stream<Map<String, dynamic>> get timerExtendStream => _timerExtendController.stream;
  Stream<String> get auctionEndStream => _auctionEndController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<Map<String, dynamic>> get viewerCountStream => _viewerCountController.stream;
  Stream<Map<String, dynamic>> get bidSuccessStream => _bidSuccessController.stream;
  Stream<String> get bidErrorStream => _bidErrorController.stream;
  Stream<Map<String, dynamic>> get outbidStream => _outbidController.stream;
  Stream<AuctionModel> get newAuctionStream => _newAuctionController.stream;
  Stream<Map<String, dynamic>> get auctionListUpdateStream => _auctionListUpdateController.stream;

  bool get isConnected => _socket?.connected ?? false;

  SocketService._();

  static SocketService get instance {
    _instance ??= SocketService._();
    return _instance!;
  }

  /// Initialize socket connection with auth token
  void connect(String authToken) {
    print('🔌 Socket connect called with token: ${authToken.substring(0, 20)}...');
    
    // Store token for reconnection
    _lastAuthToken = authToken;
    
    // Disconnect existing socket (might be guest connection)
    if (_socket != null) {
      print('🔌 Disconnecting existing socket to reconnect with auth');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    final socketUrl = AppConstants.socketUrl;
    print('🔌 Connecting to: $socketUrl with auth');
    
    // Create socket with explicit options map for better control
    _socket = io.io(
      socketUrl,
      <String, dynamic>{
        'transports': ['websocket', 'polling'], // Try websocket first with Cloudflare
        'path': '/socket.io/',
        'autoConnect': false,
        'forceNew': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 3000,
        'timeout': 20000,
        'auth': {'token': authToken},
      },
    );
    
    print('🔌 Socket created with auth, setting up listeners...');
    _setupListeners();
    
    // Explicitly connect
    print('🔌 Calling socket.connect() with auth...');
    _socket?.connect();
  }

  /// Connect as guest (without auth token) for receiving new auction updates
  void connectAsGuest() {
    print('🔌 Socket connect as guest');
    
    if (_socket != null && _socket!.connected) {
      print('🔌 Socket already connected');
      return;
    }
    
    // Dispose old socket if exists but not connected
    if (_socket != null) {
      print('🔌 Disposing old socket...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    final socketUrl = AppConstants.socketUrl;
    print('🔌 Connecting to: $socketUrl (Guest mode)');
    
    // Create socket with explicit options map for better control
    _socket = io.io(
      socketUrl,
      <String, dynamic>{
        'transports': ['websocket', 'polling'], // Try websocket first with Cloudflare
        'path': '/socket.io/',
        'autoConnect': false,
        'forceNew': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 3000,
        'timeout': 20000,
      },
    );
    
    print('🔌 Socket created, setting up listeners...');
    _setupListeners();
    print('🔌 Listeners set up, socket.connected = ${_socket?.connected}');
    
    // Explicitly connect
    print('🔌 Calling socket.connect()...');
    _socket?.connect();
  }

  // Track if we already logged errors (to avoid spam)
  bool _errorLogged = false;
  int _reconnectAttempts = 0;

  void _setupListeners() {
    _socket?.onConnect((_) {
      print('✅ Socket connected successfully! Socket ID: ${_socket?.id}');
      _errorLogged = false; // Reset error flag on successful connection
      _reconnectAttempts = 0;
      _connectionStatusController.add(true);
    });

    _socket?.onDisconnect((reason) {
      if (!_errorLogged) {
        print('⚠️ Socket disconnected. Using HTTP polling fallback.');
        _errorLogged = true;
      }
      _connectionStatusController.add(false);
    });

    _socket?.onConnectError((error) {
      if (!_errorLogged) {
        print('⚠️ Socket unavailable. Using HTTP polling fallback.');
        _errorLogged = true;
      }
      _connectionStatusController.add(false);
    });

    _socket?.onError((error) {
      // Suppress repeated error logs
    });
    
    _socket?.onConnecting((_) {
      // Suppress connecting logs
    });
    
    _socket?.onReconnect((_) {
      print('✅ Socket reconnected!');
      _errorLogged = false;
    });
    
    _socket?.onReconnectAttempt((_) {
      _reconnectAttempts++;
      if (_reconnectAttempts <= 1) {
        print('🔄 Socket reconnecting...');
      }
    });
    
    _socket?.onReconnectFailed((_) {
      if (!_errorLogged) {
        print('⚠️ Socket unavailable. HTTP polling active.');
        _errorLogged = true;
      }
    });

    // Listen for new bids
    _socket?.on('new_bid', (data) {
      try {
        // Backend sends: { auctionId, bid: {...}, newPrice, bidCount }
        final bidData = data['bid'];
        if (bidData != null) {
          final bid = BidModel.fromJson({
            ...Map<String, dynamic>.from(bidData),
            'auctionId': data['auctionId'],
          });
          _bidStreamController.add(bid);
        }
        // Also emit price update
        _priceUpdateController.add({
          'auctionId': data['auctionId'],
          'newPrice': data['newPrice'],
          'bidCount': data['bidCount'],
        });
      } catch (e) {
        print('Error parsing bid: $e');
      }
    });

    // Listen for viewer count updates
    _socket?.on('viewer_count', (data) {
      _viewerCountController.add(Map<String, dynamic>.from(data));
    });

    // Listen for bid success confirmation
    _socket?.on('bid_success', (data) {
      _bidSuccessController.add(Map<String, dynamic>.from(data));
    });

    // Listen for bid errors
    _socket?.on('bid_error', (data) {
      _bidErrorController.add(data['message'] as String? ?? 'خطأ في المزايدة');
    });

    // Listen for outbid notifications
    _socket?.on('outbid', (data) {
      _outbidController.add(Map<String, dynamic>.from(data));
    });

    // Listen for price updates
    _socket?.on('price_update', (data) {
      _priceUpdateController.add(Map<String, dynamic>.from(data));
    });

    // Listen for timer extensions (anti-sniping)
    _socket?.on('timer_extended', (data) {
      _timerExtendController.add(Map<String, dynamic>.from(data));
    });

    // Listen for auction end
    _socket?.on('auction_ended', (data) {
      _auctionEndController.add(data['auctionId'] as String);
    });

    // Listen for new auctions
    _socket?.on('new_auction', (data) {
      try {
        print('New auction received: $data');
        final auction = AuctionModel.fromJson(Map<String, dynamic>.from(data));
        _newAuctionController.add(auction);
      } catch (e) {
        print('Error parsing new auction: $e');
      }
    });

    // Listen for global auction list updates
    _socket?.on('auction_list_update', (data) {
      _auctionListUpdateController.add(Map<String, dynamic>.from(data));
    });
  }

  /// Join an auction room for real-time updates
  void joinAuction(String auctionId) {
    print('🔌 joinAuction called: auctionId=$auctionId, connected=${_socket?.connected}');
    if (_socket == null || !_socket!.connected) {
      print('❌ Cannot join auction room - socket not connected!');
      return;
    }
    _socket?.emit('join_auction', auctionId);
    print('✅ Emitted join_auction for: $auctionId');
  }

  /// Leave an auction room
  void leaveAuction(String auctionId) {
    print('🔌 leaveAuction called: auctionId=$auctionId');
    _socket?.emit('leave_auction', auctionId);
  }

  /// Ensure socket is connected with auth, auto-restore token if needed
  Future<bool> ensureConnectedWithAuth() async {
    if (_socket != null && _socket!.connected && _lastAuthToken != null) {
      return true;
    }
    
    // Try to restore token from storage
    if (_lastAuthToken == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedToken = prefs.getString(_tokenKey);
        if (savedToken != null) {
          print('🔌 Restoring socket connection with saved token');
          connect(savedToken);
          // Wait a bit for connection
          await Future.delayed(const Duration(milliseconds: 500));
          return _socket?.connected ?? false;
        }
      } catch (e) {
        print('⚠️ Failed to restore socket token: $e');
      }
      return false;
    }
    
    // Reconnect with existing token
    connect(_lastAuthToken!);
    await Future.delayed(const Duration(milliseconds: 500));
    return _socket?.connected ?? false;
  }

  /// Place a bid
  void placeBid({
    required String auctionId,
    required double amount,
    bool isAutoBid = false,
  }) async {
    print('🔌 Socket placeBid: connected=${_socket?.connected}, auctionId=$auctionId, amount=$amount');
    
    // Try to reconnect if not connected
    if (_socket == null || !_socket!.connected) {
      print('⚠️ Socket not connected, attempting to reconnect...');
      final reconnected = await ensureConnectedWithAuth();
      if (!reconnected) {
        print('❌ Failed to reconnect socket!');
        _bidErrorController.add('فشل الاتصال - حاول مرة أخرى');
        return;
      }
    }
    
    _socket?.emit('place_bid', {
      'auctionId': auctionId,
      'amount': amount,
      'isAutoBid': isAutoBid,
    });
    print('✅ place_bid event emitted');
  }

  /// Set up auto-bid
  void setupAutoBid({
    required String auctionId,
    required double maxAmount,
  }) {
    _socket?.emit('setup_auto_bid', {
      'auctionId': auctionId,
      'maxAmount': maxAmount,
    });
  }

  /// Cancel auto-bid
  void cancelAutoBid(String auctionId) {
    _socket?.emit('cancel_auto_bid', {'auctionId': auctionId});
  }

  /// Disconnect socket
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _bidStreamController.close();
    _priceUpdateController.close();
    _timerExtendController.close();
    _auctionEndController.close();
    _connectionStatusController.close();
    _auctionListUpdateController.close();
    _viewerCountController.close();
    _bidSuccessController.close();
    _bidErrorController.close();
    _outbidController.close();
    _newAuctionController.close();
  }
}
