import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../helper/shared_prefe/shared_prefe.dart';
import '../utils/app_const/app_const.dart';
import 'api_url.dart';
import 'subscription_service.dart';

/// Socket Service for real-time messaging
/// - Connects to: https://loading-purposes-finger-plays.trycloudflare.com?id={userId}
/// - Send Event: single-chat-send-message
/// - Receive Event: single-chat-send-message
class SocketApi {
  // Singleton instance
  SocketApi._internal();
  static final SocketApi _instance = SocketApi._internal();
  factory SocketApi() => _instance;

  static io.Socket? _socket;
  static bool _isConnecting = false;
  static Completer<bool>? _connectionCompleter;
  static String?
  _currentSocketUserId; // Track which user is currently connected

  ///<------------------------- Socket Initialization ---------------->
  static Future<bool> init() async {
    String userId = await SharePrefsHelper.getString(AppConstants.userId);
    String token = await SharePrefsHelper.getString(AppConstants.bearerToken);

    // 1. Check if already connected AND it's the SAME user
    if (isConnected()) {
      if (_currentSocketUserId == userId) {
        debugPrint(
          '✅ Socket already connected for user $userId. Skipping init.',
        );
        return true;
      } else {
        debugPrint(
          '🔄 User changed ($userId != $_currentSocketUserId). Reconnecting socket...',
        );
        dispose(); // Force disconnect old user's socket
      }
    }

    // 2. Prevent multiple simultaneous connection attempts
    if (_isConnecting) {
      debugPrint('🔄 Socket connection already in progress...');
      return await _connectionCompleter?.future ?? false;
    }

    _isConnecting = true;
    _connectionCompleter = Completer<bool>();

    try {
      debugPrint('');
      debugPrint('╔═══════════════════════════════════════════════════════╗');
      debugPrint('║           🔧 SOCKET INITIALIZATION                    ║');
      debugPrint('╠═══════════════════════════════════════════════════════╣');
      debugPrint('║ User ID: $userId');
      debugPrint('║ Token exists: ${token.isNotEmpty}');
      debugPrint('╚═══════════════════════════════════════════════════════╝');

      if (userId.isEmpty || userId == "null") {
        debugPrint('❌ Socket init failed: Invalid User ID');
        _completeConnection(false);
        return false;
      }

      // Fetch and save subscription ID
      debugPrint('📡 Fetching subscription ID...');
      String? subscriptionId =
          await SubscriptionService.fetchAndSaveActiveSubscription();
      debugPrint('📡 Subscription ID: $subscriptionId');

      // Only disconnect if we have a stale/disconnected socket instance that isn't null
      if (_socket != null) {
        debugPrint('🧹 Cleaning up stale socket instance...');
        _socket!.dispose();
        _socket = null;
      }

      final socketUrl = ApiUrl.socketUrl(userId: userId);

      debugPrint('');
      debugPrint('╔═══════════════════════════════════════════════════════╗');
      debugPrint('║           🌐 CONNECTING TO SOCKET                     ║');
      debugPrint('╠═══════════════════════════════════════════════════════╣');
      debugPrint('║ URL: $socketUrl');
      debugPrint('╚═══════════════════════════════════════════════════════╝');

      // Create socket connection
      final newSocket = io.io(
        socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setReconnectionAttempts(10)
            .setReconnectionDelay(3000)
            .enableAutoConnect()
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );

      _socket = newSocket;

      // Setup event handlers
      newSocket.onConnect((_) {
        debugPrint('');
        debugPrint('╔═══════════════════════════════════════════════════════╗');
        debugPrint('║        ✅ SOCKET CONNECTED SUCCESSFULLY!              ║');
        debugPrint('╠═══════════════════════════════════════════════════════╣');
        debugPrint('║ Socket ID: ${newSocket.id}');
        debugPrint('╚═══════════════════════════════════════════════════════╝');
        debugPrint('');
      });

      newSocket.onDisconnect((data) {
        debugPrint('❌ SOCKET DISCONNECTED: $data');
      });

      newSocket.onConnectError((error) {
        debugPrint('⚠️ SOCKET CONNECT ERROR: $error');
      });

      newSocket.onError((error) {
        debugPrint('⚠️ SOCKET ERROR: $error');
      });

      newSocket.on('unauthorized', (data) {
        debugPrint('🚨 UNAUTHORIZED: $data');
      });

      // Wait for connection (max 5 seconds)
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (newSocket.connected) {
          debugPrint('✅ Socket connected in ${(i + 1) * 500}ms');
          _currentSocketUserId = userId; // Save current user ID
          _completeConnection(true);
          return true;
        }
        debugPrint('⏳ Waiting... ${(i + 1) * 500}ms');
      }

      debugPrint('⚠️ Socket connection timeout');
      _completeConnection(false);
      return false;
    } catch (e) {
      debugPrint('❌ Socket init error: $e');
      _completeConnection(false);
      return false;
    }
  }

  static void _completeConnection(bool success) {
    _isConnecting = false;
    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      _connectionCompleter!.complete(success);
    }
    _connectionCompleter = null;
  }

  ///<------------------------- Check Connection Status ---------------->
  static bool isConnected() {
    return _socket != null && _socket!.connected;
  }

  ///<------------------------- Send Message ---------------->
  /// Event: single-chat-send-message
  /// Payload: { text, receiverId, currentSubId, conversationId, chat: "singlechat" }
  static void sendMessage({
    required String text,
    required String receiverId,
    required String currentSubId,
    required String conversationId,
    String chatType = 'singlechat', // Added parameter with default
  }) {
    if (_socket == null) {
      debugPrint('❌ Cannot send message: Socket is null');
      return;
    }

    final Map<String, dynamic> data = {
      'text': text,
      'currentSubId': currentSubId,
      'conversationId': conversationId,
      'chat': chatType,
    };

    data['receiverId'] = receiverId;

    final String eventName = chatType == 'groupchat'
        ? 'group_send-message'
        : 'single-chat-send-message';

    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════╗');
    debugPrint('║           📤 SENDING MESSAGE                          ║');
    debugPrint('╠═══════════════════════════════════════════════════════╣');
    debugPrint('║ Event: $eventName');
    debugPrint('║ (Used for $chatType)');
    debugPrint('║ text: $text');
    debugPrint('║ receiverId: $receiverId');
    debugPrint('║ currentSubId: $currentSubId');
    debugPrint('║ conversationId: $conversationId');
    debugPrint('║ chat: $chatType');
    debugPrint('╚═══════════════════════════════════════════════════════╝');
    debugPrint('');

    _socket!.emit(eventName, data);
  }

  ///<------------------------- Generic Send Event ---------------->
  static void sendEvent(String eventName, dynamic data) {
    if (_socket == null) {
      debugPrint('❌ Cannot send event: Socket is null');
      return;
    }
    debugPrint('📤 EMIT: $eventName -> $data');
    _socket!.emit(eventName, data);
  }

  ///<------------------------- Listen for Events ---------------->
  static void listen(String eventName, Function(dynamic) callback) {
    if (_socket == null) {
      debugPrint('⚠️ Cannot listen: Socket is null');
      return;
    }

    // Remove previous listener to prevent duplicates
    _socket!.off(eventName);

    debugPrint('👂 LISTENING: $eventName');

    _socket!.on(eventName, (data) {
      debugPrint('');
      debugPrint('╔═══════════════════════════════════════════════════════╗');
      debugPrint('║           📥 MESSAGE RECEIVED                         ║');
      debugPrint('╠═══════════════════════════════════════════════════════╣');
      debugPrint('║ Event: $eventName');
      debugPrint('║ Data: $data');
      debugPrint('╚═══════════════════════════════════════════════════════╝');
      debugPrint('');
      callback(data);
    });
  }

  ///<------------------------- Stop Listening ---------------->
  static void stopListening(String eventName) {
    _socket?.off(eventName);
    debugPrint('🔇 Stopped listening: $eventName');
  }

  ///<------------------------- Disconnect & Cleanup ---------------->
  static void dispose() {
    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════╗');
    debugPrint('║           🛑 DISCONNECTING SOCKET                     ║');
    debugPrint('╚═══════════════════════════════════════════════════════╝');
    debugPrint('');

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnecting = false;
    _connectionCompleter = null;
  }
}
