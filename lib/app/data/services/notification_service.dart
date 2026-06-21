import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import 'storage_service.dart';

// Top-level handler required by firebase_messaging for background messages.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Background messages are shown automatically by FCM on Android.
  // No additional work needed here unless you want to update local state.
}

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'menu_posts',
    'Daily Menu Updates',
    description: 'Notifications when a restaurant posts today\'s menu',
    importance: Importance.high,
  );

  Future<NotificationService> init() async {
    await _requestPermission();
    await _createAndroidChannel();
    await _initLocalNotifications();
    _handleForegroundMessages();
    _handleNotificationTap();
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    await _subscribeToTopic();
    return this;
  }

  // ── Permission ──────────────────────────────────────────────────────────────
  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ── Android channel ─────────────────────────────────────────────────────────
  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  // ── Local notifications (foreground display) ────────────────────────────────
  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  void _handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['restaurant_id'],
      );
    });
  }

  // ── Navigation on tap ───────────────────────────────────────────────────────
  void _handleNotificationTap() {
    // App opened from terminated state via notification
    _messaging.getInitialMessage().then(_routeFromMessage);

    // App resumed from background via notification
    FirebaseMessaging.onMessageOpenedApp.listen(_routeFromMessage);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final restaurantId = response.payload;
    if (restaurantId != null) {
      Get.toNamed(Routes.RESTAURANT_DETAIL, arguments: {'restaurantId': restaurantId});
    }
  }

  void _routeFromMessage(RemoteMessage? message) {
    if (message == null) return;
    final restaurantId = message.data['restaurant_id'] as String?;
    if (restaurantId != null) {
      Get.toNamed(Routes.RESTAURANT_DETAIL, arguments: {'restaurantId': restaurantId});
    }
  }

  // ── Topic subscription ───────────────────────────────────────────────────────
  // Customers subscribe to 'all_customers' so the Edge Function can send
  // a single FCM v1 topic message that reaches everyone at once.
  Future<void> _subscribeToTopic() async {
    final role = StorageService.to.userRole;
    if (role == 'customer') {
      try {
        await _messaging.subscribeToTopic('all_customers');
      } catch (e) {
        debugPrint('NotificationService: topic subscribe failed: $e');
      }
    }
  }

  Future<void> unsubscribeFromTopic() async {
    try {
      await _messaging.unsubscribeFromTopic('all_customers');
    } catch (e) {
      debugPrint('NotificationService: topic unsubscribe failed: $e');
    }
  }
}
