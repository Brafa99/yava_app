class ApiConfig {
  /// Dominio base sin el segmento /api (ApiEndpoints ya contiene el prefijo /api)
  static const String baseUrl = 'https://yavaapp.namnamapp.com';
  
  /// Directorio público de imágenes y documentos subidos
  static const String storageUrl = 'https://yavaapp.namnamapp.com/storage/';
  
  /// Servidor de WebSockets (Laravel Echo / Reverb)
  static const String socketUrl = 'https://yavaapp.namnamapp.com:6001';
}