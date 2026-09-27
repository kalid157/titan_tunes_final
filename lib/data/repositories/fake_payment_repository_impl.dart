import 'dart:async';
import 'package:titan_tunes/data/datasources/fake_payement_datasource.dart';
import 'package:titan_tunes/domaine/entities/payment_entity.dart';
import 'package:titan_tunes/domaine/repositories/payment_repository.dart';

class FakePaymentRepositoryImpl implements PaymentRepository {
  final FakePaymentDatasource _datasource;

  FakePaymentRepositoryImpl({required FakePaymentDatasource datasource})
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
      clientSecret: data['clientSecret'] as String,
      paymentIntentId: data['paymentIntentId'] as String,
      amount: amount,
      currency: currency,
      status: PaymentStatus.requiresAction,
    );
  }

  @override
  Future<PaymentResultEntity> confirmPayment({
    required String clientSecret,
    required String paymentMethodId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // 90 % de succès pour simuler des cas réels
    final success = DateTime.now().millisecond % 10 != 0;

    return PaymentResultEntity(
      success: success,
      transactionId: success
          ? 'txn_fake_${DateTime.now().millisecondsSinceEpoch}'
          : null,
      message: success ? 'Paiement simulé réussi' : 'Carte refusée (simulé)',
    );
  }
}