import 'dart:developer';
import 'dart:io' show Platform;
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
    if (!kIsWeb) {
      try {
        _fcm = FirebaseMessaging.instance;
      } catch (e) {
        log('FirebaseMessaging no disponible: $e');
      }
    }
  }

  /// Retorna el token FCM actual del dispositivo
  Future<String?> getToken() async {
    if (kIsWeb || _fcm == null) return null;
    try {
      return await _fcm!.getToken();
    } catch (e) {
      log('Error al obtener FCM token: $e');
      return null;
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

      final fcmToken = token ?? await getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        final platformName = kIsWeb
            ? 'web'
            : (Platform.isAndroid ? 'android' : 'ios');

        await apiClient.post(
          ApiEndpoints.updateToken,
          body: {
            'device_token': fcmToken,
            'platform': platformName,
          },
          requiresAuth: true,
        );
        log('FCM Token sincronizado con Laravel: $fcmToken ($platformName)');
      }
    } catch (e) {
      log('FCM sync error: $e');
    }
  }
}