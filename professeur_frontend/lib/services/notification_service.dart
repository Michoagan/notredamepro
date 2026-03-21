import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications(Function(String) onTokenReceived) async {
    // 1. Demander la permission (surtout pour iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permission de notification accordée.');
      
      // 2. Récupérer le token FCM
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        onTokenReceived(token);
      }

      // 3. Écouter les changements de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        onTokenReceived(newToken);
      });

      // 4. Gérer les messages quand l'app est au premier plan
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Message reçu au premier plan: ${message.notification?.title}');
        // Optionnel : Afficher un dialogue ou un snackbar personnalisé
      });

    } else {
      debugPrint('Permission de notification refusée.');
    }
  }
}
