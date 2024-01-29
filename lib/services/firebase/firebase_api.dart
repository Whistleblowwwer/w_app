import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    final settings = await _firebaseMessaging.requestPermission();
    print(settings.authorizationStatus);
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((event) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${event.data}');

      if (event.notification != null) {
        print(
            'Message also contained a notification: ${event.notification?.title}');
      }
    });
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print(message);
  print(message.notification);
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}
