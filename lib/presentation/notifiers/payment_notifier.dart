import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/domaine/entities/payment_entity.dart';
import 'package:titan_tunes/presentation/notifiers/profile_notifier.dart';
import 'package:titan_tunes/domaine/entities/user_profile_entity.dart';
import 'package:titan_tunes/provider/payment_providers.dart';

class PaymentState {
  final PaymentStatus status;
  final String? clientSecret;
  final String? transactionId;
  final String? message;
  final double amount;
  final String plan;

  const PaymentState({
    this.status = PaymentStatus.pending,
    this.clientSecret,
    this.transactionId,
    this.message,
    this.amount = 10.99,
    this.plan = 'premium_individual',
  });

  PaymentState copyWith({
    PaymentStatus? status,
    String? clientSecret,
    String? transactionId,
    String? message,
    double? amount,
    String? plan,
  }) =>
      PaymentState(
        status: status ?? this.status,
        clientSecret: clientSecret ?? this.clientSecret,
        transactionId: transactionId ?? this.transactionId,
        message: message ?? this.message,
        amount: amount ?? this.amount,
        plan: plan ?? this.plan,
      );
}

class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() => const PaymentState();

  void setPlan(String plan, double amount) {
    state = state.copyWith(plan: plan, amount: amount);
  }

  /// Étape 1 : Créer le PaymentIntent côté serveur
  Future<bool> createPaymentIntent() async {
    state = state.copyWith(
      status: PaymentStatus.processing,
      message: 'Création du paiement...',
    );

    try {
      final intent = await ref.read(paymentRepositoryProvider).createPaymentIntent(
            amount: state.amount,
            plan: state.plan,
          );

      state = state.copyWith(
        clientSecret: intent.clientSecret,
        transactionId: intent.paymentIntentId,
        status: PaymentStatus.requiresAction,
        message: 'En attente de confirmation...',
      );
      return true;
    } catch (e) {
      debugPrint('❌ createPaymentIntent: $e');
      state = state.copyWith(
        status: PaymentStatus.failed,
        message: 'Impossible de créer le paiement',
      );
      return false;
    }
  }

  /// Étape 2 : Confirmer le paiement (Stripe SDK ou Fake)
  Future<bool> confirmPayment() async {
    if (state.clientSecret == null) {
      state = state.copyWith(
        status: PaymentStatus.failed,
        message: 'Aucun paiement en cours',
      );
      return false;
    }

    state = state.copyWith(
      status: PaymentStatus.processing,
      message: 'Confirmation en cours...',
    );

    try {
      final result = await ref.read(paymentRepositoryProvider).confirmPayment(
            clientSecret: state.clientSecret!,
            paymentMethodId: '', // Stripe le remplit tout seul
          );

      if (result.success) {
        //  Met à jour le profil en Premium
        final plan = state.plan == 'premium_family'
            ? SubscriptionPlan.premiumFamily
            : SubscriptionPlan.premiumIndividual;

        ref
            .read(profileNotifierProvider.notifier)
            .setPremium(plan, price: state.amount);

        state = state.copyWith(
          status: PaymentStatus.success,
          message: result.message ?? 'Paiement réussi',
        );
        return true;
      } else {
        state = state.copyWith(
          status: PaymentStatus.failed,
          message: result.message ?? 'Paiement refusé',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ confirmPayment: $e');
      state = state.copyWith(
        status: PaymentStatus.failed,
        message: 'Erreur lors de la confirmation',
      );
      return false;
    }
  }

  void reset() => state = const PaymentState();
}

final paymentNotifierProvider =
    NotifierProvider<PaymentNotifier, PaymentState>(() => PaymentNotifier());