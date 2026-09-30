enum PaymentStatus {
  pending,
  processing,
  requiresAction, //  3DS / action Stripe
  success,
  failed,
  cancelled,
}

class PaymentIntentEntity {
  final String clientSecret;
  final String paymentIntentId;
  final double amount;
  final String currency;
  final PaymentStatus status;

  const PaymentIntentEntity({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.amount,
    this.currency = 'eur',
    this.status = PaymentStatus.pending,
  });
}

class PaymentResultEntity {
  final bool success;
  final String? transactionId;
  final String? message;

  const PaymentResultEntity({
    required this.success,
    this.transactionId,
    this.message,
  });
}