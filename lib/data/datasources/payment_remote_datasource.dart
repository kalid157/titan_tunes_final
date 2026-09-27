import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:titan_tunes/config/api_config.dart';

class PaymentRemoteDatasource {
  final Dio _dio;

  PaymentRemoteDatasource(this._dio);

  /// Appelle ton serveur Stripe : POST /create-payment-intent
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    String currency = 'eur',
  }) async {
    final url = '${ApiConfig.paymentServerUrl}/create-payment-intent';
    debugPrint('💳 POST $url');

    try {
      final response = await _dio.post(
        url,
        data: {
          'items': [
            {'id': 'abonnement-premium'}
          ],
          'amount': (amount * 100).round(), // Stripe = centimes
          'currency': currency,
        },
      );

      debugPrint('💳 Status: ${response.statusCode}');
      debugPrint('💳 Response: ${response.data}');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('❌ Stripe error: ${e.response?.statusCode}');
      debugPrint('❌ Body: ${e.response?.data}');
      rethrow;
    }
  }
}