import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get paymentServerUrl {
    const overrideUrl = String.fromEnvironment('PAYMENT_SERVER_URL');
    if (overrideUrl.isNotEmpty) return overrideUrl;

    if (kIsWeb) return 'http://localhost:4242';
    if (Platform.isAndroid) return 'http://10.0.2.2:4242';
    return 'http://localhost:4242';
  }
}