import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'config.dart';

class StreamDetector {
  static Timer? _timer;
  static bool _wasLive = false;
  static bool _isChecking = false;
  static bool _hasShownInitialNotification = false;
  
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }
  
  static void startDetecting() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(seconds: RadioConfig.checkIntervalSeconds), 
      (timer) async {
        await _checkStreamStatus();
      }
    );
    _checkStreamStatus();
  }
  
  static void stopDetecting() {
    _timer?.cancel();
    _timer = null;
  }
  
  static Future<bool> isStreamAlive() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse(RadioConfig.streamUrl));
      final response = await request.close();
      client.close();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  static Future<void> _showLiveNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'live_channel', 'Conexión Celestial Radio',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      0,
      '🎙️ ¡Conexión Celestial está al aire!',
      'Toca para escuchar ahora mismo en vivo',
      details,
      payload: 'open_radio',
    );
  }
  
  static Future<void> _showOfflineNotification() async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'live_channel', 'Conexión Celestial Radio',
        importance: Importance.low,
      ),
      iOS: DarwinNotificationDetails(),
    );
    
    await _notifications.show(
      1,
      '📻 Transmisión finalizada',
      'Vuelve pronto a Conexión Celestial Radio',
      details,
    );
  }
  
  static Future<void> _checkStreamStatus() async {
    if (_isChecking) return;
    _isChecking = true;
    
    final bool isLive = await isStreamAlive();
    
    if (isLive && !_wasLive && _hasShownInitialNotification) {
      await _showLiveNotification();
    }
    
    if (!isLive && _wasLive) {
      await _showOfflineNotification();
    }
    
    _wasLive = isLive;
    _hasShownInitialNotification = true;
    _isChecking = false;
  }
}
