import 'dart:async';

/// Simule le serveur Stripe pour tester sans backend.
class FakePaymentDatasource {
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    String currency = 'eur',
  }) async {
    // Simule 1,5s de latence réseau
    await Future.delayed(const Duration(milliseconds: 1500));

    return {
      'clientSecret':
          'pi_fake_${DateTime.now().millisecondsSinceEpoch}_secret_xyz',
      'paymentIntentId': 'pi_fake_${DateTime.now().millisecondsSinceEpoch}',
      'amount': (amount * 100).round(),
      'currency': currency,
    };
  }
}