import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:w_app/services/api/api_service.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      final settings = await _firebaseMessaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
        await _registerToken();
        _configureMessageListeners();
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _registerToken() async {
    try {
      final fCMToken = await _firebaseMessaging.getToken();
      print(fCMToken);
      if (fCMToken != null) {
        var apiService = ApiService();
        final responseUploadToken =
            await apiService.sendTokenToServer(fCMToken);
        print(responseUploadToken);
        if (responseUploadToken) {
          print('Token uploaded: $fCMToken');
        }
      }
    } catch (e) {
      print('Error registering token: $e');
    }
  }

  void _configureMessageListeners() {
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((event) {
      print(
          'Foreground message: Title: ${event.notification?.title}, Body: ${event.notification?.body}');
    });
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(
      'Background message: Title: ${message.notification?.title}, Body: ${message.notification?.body}');
}
