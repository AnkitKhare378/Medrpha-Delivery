import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../view/dashboard/dashboard_screen.dart';

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Get device FCM token and send to backend
  Future<void> updateTokenToBackend(int userId) async {
    String? token = await messaging.getToken();
    print("🔑 FCM Token: $token");

    if (token != null && token.isNotEmpty) {
      // TODO: Call your specific API here to save the token
      // Example:
      // await customerService.updateFcmToken(userId, token);

      // For now, let's just simulate the logic your backend developer wants:
      print("🚀 Sending Token to Backend for User $userId...");
    }
  }

  // Request notification permission
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
    } else {
      print('❌ Notification permission denied');
    }
  }

  // Get device FCM token
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    print("🔑 FCM Token: $token");
    return token ?? '';
  }

  // Firebase messaging initialization
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (kDebugMode) {
        print("📩 Notification title: ${notification?.title}");
        print("📩 Notification body: ${notification?.body}");
      }

      if (Platform.isIOS) {
        iosForegroundMessage();
      } else if (Platform.isAndroid) {
        initLocalNotification(context, message);
        showNotification(message);
      }
    });
  }

  // Local notification setup
  Future<void> initLocalNotification(BuildContext context, RemoteMessage message) async {
    // Change ic_notification to @mipmap/ic_launcher
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings("@mipmap/ic_launcher");

    const DarwinInitializationSettings iosInitSettings = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        handleMessage(context, message);
      },
    );
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "default_channel",
      "Default Channel",
      importance: Importance.max, // Set to max for heads-up notification
      priority: Priority.high,
      playSound: true,
      icon: "@mipmap/ic_launcher",
    );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      details,
    );
  }

  // Handle notification tap
  Future<void> setupInteractMessage(BuildContext context) async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(context, message);
    });

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.data.isNotEmpty) {
      handleMessage(context, initialMessage);
    }
  }

  Future<void> handleMessage(BuildContext context, RemoteMessage message) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen(initialIndex: 1)),
    );
  }

  // iOS foreground notifications
  Future<void> iosForegroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
