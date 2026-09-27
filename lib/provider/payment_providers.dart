import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/data/datasources/fake_payement_datasource.dart';

import 'package:titan_tunes/data/datasources/payment_remote_datasource.dart';
import 'package:titan_tunes/data/repositories/fake_payment_repository_impl.dart';
import 'package:titan_tunes/data/repositories/payment_repository_impl.dart';
import 'package:titan_tunes/domaine/repositories/payment_repository.dart';

// ═══════════════════════════════════════════════════════════════
// MODE DE PAIEMENT — PUBLIC et CONST
// ═══════════════════════════════════════════════════════════════
enum PaymentMode { fake, stripe }

/// CHANGE ICI pour basculer entre Fake et Stripe
/// - `PaymentMode.fake`   → test sans backend (recommandé en dev)
/// - `PaymentMode.stripe` → production avec Stripe SDK
//const PaymentMode kPaymentMode = PaymentMode.fake;
//  MODE STRIPE (au lieu de fake)
const PaymentMode kPaymentMode = PaymentMode.stripe;

// ═══════════════════════════════════════════════════════════════
// Dio dédié au serveur Stripe (port 4242)
// ═══════════════════════════════════════════════════════════════
final paymentDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
  ));

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint('💳 $o'),
    ));
  }

  return dio;
});

// ═══════════════════════════════════════════════════════════════
// DataSources
// ═══════════════════════════════════════════════════════════════
final paymentRemoteDatasourceProvider =
    Provider<PaymentRemoteDatasource>((ref) {
  return PaymentRemoteDatasource(ref.watch(paymentDioProvider));
});

final fakePaymentDatasourceProvider =
    Provider<FakePaymentDatasource>((ref) {
  return FakePaymentDatasource();
});

// ═══════════════════════════════════════════════════════════════
// ⭐ Repository — sélectionne Fake ou Stripe selon le mode
// ═══════════════════════════════════════════════════════════════
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  switch (kPaymentMode) {
    case PaymentMode.fake:
      debugPrint('💳 Payment Repository : FAKE');
      return FakePaymentRepositoryImpl(
        datasource: ref.watch(fakePaymentDatasourceProvider),
      );

    case PaymentMode.stripe:
      debugPrint('💳 Payment Repository : STRIPE');
      return StripePaymentRepositoryImpl(
        datasource: ref.watch(paymentRemoteDatasourceProvider),
      );
  }
});