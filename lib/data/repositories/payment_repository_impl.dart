import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:titan_tunes/data/datasources/payment_remote_datasource.dart';
import 'package:titan_tunes/domaine/entities/payment_entity.dart';
import 'package:titan_tunes/domaine/repositories/payment_repository.dart';

class StripePaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDatasource _datasource;

  StripePaymentRepositoryImpl({required PaymentRemoteDatasource datasource})
      : _datasource = datasource;

  @override
  Future<PaymentIntentEntity> createPaymentIntent({
    required double amount,
    String currency = 'eur',
    required String plan,
  }) async {
    final data = await _datasource.createPaymentIntent(
      amount: amount,
      currency: currency,
    );

    return PaymentIntentEntity(
      clientSecret: data['clientSecret'] as String? ?? '',
      paymentIntentId: data['paymentIntentId'] as String? ?? '',
      amount: amount,
      currency: currency,
      status: PaymentStatus.pending,
    );
  }

  /// ⭐ Utilise PaymentSheet — la méthode recommandée par Stripe
  /// pour une UX native (carte + 3DS automatique).
  @override
  Future<PaymentResultEntity> confirmPayment({
    required String clientSecret,
    required String paymentMethodId,
  }) async {
    try {
      // 1. Initialiser PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Tunes',
          style: ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFFFF8A00),
              background: Colors.white,
              componentBackground: const Color(0xFFF8F9FA),
              primaryText: Colors.black87,
              secondaryText: Colors.grey,
            ),
            shapes: PaymentSheetShape(
              borderRadius: 12,
            ),
          ),
        ),
      );

      // 2. Afficher la sheet native Stripe
      await Stripe.instance.presentPaymentSheet();

      // 3. L'utilisateur a validé
      return const PaymentResultEntity(
        success: true,
        message: 'Paiement réussi',
      );
    } on StripeException catch (e) {
      // L'utilisateur a annulé ou la carte a échoué
      if (e.error.code == FailureCode.Canceled) {
        return const PaymentResultEntity(
          success: false,
          message: 'Paiement annulé',
        );
      }
      return PaymentResultEntity(
        success: false,
        message: e.error.localizedMessage ?? 'Paiement échoué',
      );
    } catch (e) {
      return PaymentResultEntity(
        success: false,
        message: 'Erreur: $e',
      );
    }
  }
}