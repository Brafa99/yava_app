import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'storage_service.dart';

class MessagingService {
  final ApiClient apiClient;
  final StorageService storageService;
  FirebaseMessaging? _fcm;

  MessagingService({
    required this.apiClient,
    required this.storageService,
  }) {
    // En Web evitamos llamar a instance si no está configurado el service worker
    if (!kIsWeb) {
      try {
        _fcm = FirebaseMessaging.instance;
      } catch (e) {
        log('FirebaseMessaging no disponible: $e');
      }
    }
  }

  Future<void> initialize() async {
    if (kIsWeb || _fcm == null) {
      log('FCM ignorado en entorno Web');
      return;
    }

    try {
      NotificationSettings settings = await _fcm!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('FCM: Permisos concedidos');
      }

      _fcm!.onTokenRefresh.listen((newToken) {
        syncTokenWithBackend(newToken);
      });
    } catch (e) {
      log('FCM init error: $e');
    }
  }

  Future<void> syncTokenWithBackend([String? token]) async {
    if (kIsWeb || _fcm == null) return;

    try {
      final userToken = await storageService.getToken();
      if (userToken == null || userToken.isEmpty) return;

      final fcmToken = token ?? await _fcm?.getToken();
      if (fcmToken != null) {
        await apiClient.post(
          ApiEndpoints.updateToken,
          body: {'device_token': fcmToken},
          requiresAuth: true,
        );
        log('FCM Token sincronizado con Laravel: $fcmToken');
      }
    } catch (e) {
      log('FCM sync error: $e');
    }
  }
}