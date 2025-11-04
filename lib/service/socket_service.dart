import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../helper/shared_prefe/shared_prefe.dart';
import '../utils/app_const/app_const.dart';
import 'api_url.dart';

class SocketApi {
  // Singleton instance
  SocketApi._internal();
  static final SocketApi _instance = SocketApi._internal();

  factory SocketApi() => _instance;

  static io.Socket? _socket;

  ///<------------------------- Socket Initialization ---------------->
  static Future<void> init() async {
    String userId = await SharePrefsHelper.getString(AppConstants.userId);
    String token = await SharePrefsHelper.getString(AppConstants.bearerToken);

    if (userId.isEmpty || userId == "null") {
      debugPrint('❌ Socket initialization failed: Invalid User ID');
      return;
    }

    // Disconnect previous socket if already connected
    if (_socket != null) {
      debugPrint('🔄 Disconnecting old socket instance...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    debugPrint('🌐 Connecting socket for User ID: $userId');

    final newSocket = io.io(
      ApiUrl.socketUrl(id: userId),
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setReconnectionAttempts(10) // More retries for better reconnection
          .setReconnectionDelay(3000) // 3-second delay before retrying
          .enableAutoConnect() // Automatically connect on init
          .setExtraHeaders({'Authorization': 'Bearer $token'}) // If needed
          .build(),
    );

    _socket = newSocket;

    debugPrint('🔄 Attempting socket connection...');

    newSocket.onConnect((_) {
      debugPrint('✅ SOCKET CONNECTED: ${newSocket.id}');
    });

    newSocket.onDisconnect((data) {
      debugPrint('❌ SOCKET DISCONNECTED: $data');
    });

    newSocket.onError((error) {
      debugPrint('⚠️ SOCKET ERROR: $error');
    });

    newSocket.on('unauthorized', (data) {
      debugPrint('🚨 UNAUTHORIZED ACCESS: $data');
    });

    // Removed onAny - not supported in socket_io_client package
    // If you need to debug specific events, listen to them individually:
    // newSocket.on('message', (data) => debugPrint('📥 MESSAGE: $data'));
    // newSocket.on('notification', (data) => debugPrint('📥 NOTIFICATION: $data'));

    // Ask backend if "joinRoom" or similar is needed
    debugPrint('🔹 Emitting "joinRoom" (Check if required by backend)');
    newSocket.emit('joinRoom', {'userId': userId});
  }

  ///<------------------------- Public Method to Check Connection ---------------->
  static bool isConnected() {
    bool status = _socket != null && _socket!.connected;
    debugPrint('🔍 Socket Connection Status: $status');
    return status;
  }

  ///<------------------------- Emit Events ---------------->
  static void sendEvent(String eventName, dynamic data) {
    if (isConnected()) {
      debugPrint('📤 EMITTING EVENT: $eventName -> Data: $data');
      _socket!.emit(eventName, data);
    } else {
      debugPrint('❌ Cannot send event. Socket is not connected: $eventName');
    }
  }

  ///<------------------------- Listen for Events ---------------->
  static void listen(String eventName, Function(dynamic) callback) {
    if (!isConnected()) {
      debugPrint('⚠️ Cannot listen for $eventName. Socket is not connected.');
      return;
    }

    debugPrint('👂 LISTENING FOR EVENT: $eventName');

    // Remove previous listener to prevent duplicates
    // _socket!.off(eventName);

    _socket!.on(eventName, (data) {
      debugPrint('🔔 EVENT RECEIVED: $eventName -> $data');
      callback(data);
    });
  }

  ///<------------------------- Disconnect & Cleanup ---------------->
  static void dispose() {
    debugPrint('🛑 CLOSING SOCKET CONNECTION...');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}