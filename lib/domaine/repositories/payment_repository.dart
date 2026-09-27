import 'package:titan_tunes/domaine/entities/payment_entity.dart';

/// Contrat du repository paiement (couche DOMAIN).
abstract class PaymentRepository {
  /// Crée un PaymentIntent côté serveur Stripe.
  /// Retourne un clientSecret à utiliser avec Stripe SDK.
  Future<PaymentIntentEntity> createPaymentIntent({
    required double amount,
    String currency,
    required String plan,
  });

  /// Confirme le paiement auprès de Stripe.
  Future<PaymentResultEntity> confirmPayment({
    required String clientSecret,
    required String paymentMethodId,
  });
}