import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String _storageKey = 'saved_notifications';

  /// Initialize notification service
  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    // Ask notification permission
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('Notification permission: ${settings.authorizationStatus}');

    // Get FCM token
    final token = await messaging.getToken();

    print('====================================');
    print('FCM TOKEN:');
    print(token);
    print('====================================');

    // Token can change
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('NEW FCM TOKEN: $newToken');

      // TODO:
      // Send this token to your backend here.
    });

    // App is open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('========== FOREGROUND MESSAGE ==========');

      await saveNotification(message);

      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      print('========================================');
    });

    // App was in background and user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('========== NOTIFICATION CLICKED ==========');

      await saveNotification(message);

      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      print('==========================================');
    });

    // App was completely terminated
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print('========== APP OPENED FROM TERMINATED ==========');

      await saveNotification(initialMessage);

      print('Title: ${initialMessage.notification?.title}');
      print('Body: ${initialMessage.notification?.body}');
      print('Data: ${initialMessage.data}');

      print('===============================================');
    }
  }

  /// Save notification to local storage
  static Future<void> saveNotification(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();

    final notificationTitle =
        message.notification?.title ?? message.data['title'] ?? 'Notification';

    final notificationBody =
        message.notification?.body ?? message.data['body'] ?? '';

    final notification = {
      'id':
          message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),

      'title': notificationTitle,

      'body': notificationBody,

      'time': DateTime.now().toIso8601String(),

      'data': message.data,
    };

    final oldNotifications = prefs.getStringList(_storageKey) ?? [];

    // Prevent duplicate notifications
    final alreadyExists = oldNotifications.any((item) {
      try {
        final decoded = jsonDecode(item);

        return decoded['id'] == notification['id'];
      } catch (_) {
        return false;
      }
    });

    if (alreadyExists) {
      return;
    }

    // Add newest notification at beginning
    oldNotifications.insert(0, jsonEncode(notification));

    await prefs.setStringList(_storageKey, oldNotifications);

    print('Notification saved locally.');
  }

  /// Get all saved notifications
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    final savedNotifications = prefs.getStringList(_storageKey) ?? [];

    final List<Map<String, dynamic>> notifications = [];

    for (final item in savedNotifications) {
      try {
        final decoded = jsonDecode(item);

        if (decoded is Map<String, dynamic>) {
          notifications.add(decoded);
        }
      } catch (e) {
        print('Error reading notification: $e');
      }
    }

    return notifications;
  }

  /// Delete all notifications
  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_storageKey);
  }

  /// Delete one notification
  static Future<void> deleteNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final savedNotifications = prefs.getStringList(_storageKey) ?? [];

    savedNotifications.removeWhere((item) {
      try {
        final decoded = jsonDecode(item);

        return decoded['id'] == id;
      } catch (_) {
        return false;
      }
    });

    await prefs.setStringList(_storageKey, savedNotifications);
  }
}

/// IMPORTANT:
/// This function handles background data messages.
///
/// It must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase must be initialized in the background isolate.
  await Firebase.initializeApp();

  print('========== BACKGROUND MESSAGE ==========');

  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');

  // Save notification locally.
  await NotificationService.saveNotification(message);

  print('=========================================');
}
