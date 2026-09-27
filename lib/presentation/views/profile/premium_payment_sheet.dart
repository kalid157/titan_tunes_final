import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:titan_tunes/domaine/entities/payment_entity.dart';
import 'package:titan_tunes/presentation/notifiers/payment_notifier.dart';

class PremiumPaymentSheet extends ConsumerStatefulWidget {
  final String plan;
  final double amount;

  const PremiumPaymentSheet({
    super.key,
    this.plan = 'premium_individual',
    this.amount = 10.99,
  });

  static Future<bool> show(
    BuildContext context, {
    String plan = 'premium_individual',
    double amount = 10.99,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => PremiumPaymentSheet(plan: plan, amount: amount),
    );
    return result ?? false;
  }

  @override
  ConsumerState<PremiumPaymentSheet> createState() =>
      _PremiumPaymentSheetState();
}

class _PremiumPaymentSheetState extends ConsumerState<PremiumPaymentSheet> {
  static const Color primaryOrange = Color(0xFFFF8A00);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(paymentNotifierProvider.notifier).setPlan(
            widget.plan,
            widget.amount,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre décorative
            Container(
              width: 60.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
            SizedBox(height: 20.h),

            _buildStepIndicator(state.status),
            SizedBox(height: 24.h),

            if (state.status == PaymentStatus.pending ||
                state.status == PaymentStatus.failed)
              _buildStep1(state),

            if (state.status == PaymentStatus.requiresAction)
              _buildStep2(state),

            if (state.status == PaymentStatus.processing) _buildLoading(),

            if (state.status == PaymentStatus.success) _buildSuccess(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(PaymentStatus status) {
    int currentStep = 1;
    if (status == PaymentStatus.processing ||
        status == PaymentStatus.requiresAction) currentStep = 2;
    if (status == PaymentStatus.success) currentStep = 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(1, active: currentStep >= 1),
        _line(active: currentStep >= 2),
        _dot(2, active: currentStep >= 2),
        _line(active: currentStep >= 3),
        _dot(3, active: currentStep >= 3),
      ],
    );
  }

  Widget _dot(int i, {required bool active}) => Container(
        width: 28.w,
        height: 28.h,
        decoration: BoxDecoration(
          color: active ? primaryOrange : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text('$i',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold)),
        ),
      );

  Widget _line({required bool active}) => Container(
        width: 40.w,
        height: 2.h,
        color: active ? primaryOrange : Colors.grey.shade300,
      );

  // ══════════════════════════════════════════════════════════
  // ÉTAPE 1 : Résumé du plan
  // ══════════════════════════════════════════════════════════
  Widget _buildStep1(PaymentState state) {
    final isFamily = widget.plan == 'premium_family';

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: primaryOrange.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.workspace_premium,
              size: 40.sp, color: primaryOrange),
        ),
        SizedBox(height: 16.h),
        Text('Passer en Premium',
            style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: primaryOrange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            isFamily ? 'Premium Family' : 'Premium Individual',
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: primaryOrange),
          ),
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            children: [
              _buildBenefit('Accès à tous les albums'),
              _buildBenefit('Chansons VIP débloquées'),
              _buildBenefit('Sans publicité'),
              if (isFamily) _buildBenefit('Jusqu\'à 6 comptes'),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${widget.amount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            Padding(
              padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
              child: Text('/ mois',
                  style: TextStyle(
                      fontSize: 14.sp, color: Colors.grey.shade600)),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text('Annulable à tout moment',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
        SizedBox(height: 16.h),

        if (state.status == PaymentStatus.failed && state.message != null)
          Container(
            padding: EdgeInsets.all(12.r),
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline,
                    color: Colors.red.shade700, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(state.message!,
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.red.shade700)),
                ),
              ],
            ),
          ),

        // Bouton "Continuer vers le paiement"
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.credit_card, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  'Payer \$${widget.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8.h),
        TextButton(
          onPressed: () {
            ref.read(paymentNotifierProvider.notifier).reset();
            Navigator.pop(context, false);
          },
          child: Text('Annuler',
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 13.sp)),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 12.sp, color: Colors.grey.shade400),
            SizedBox(width: 4.w),
            Text('Paiement sécurisé par Stripe',
                style: TextStyle(
                    fontSize: 10.sp, color: Colors.grey.shade400)),
          ],
        ),
      ],
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16.sp, color: primaryOrange),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(text,
                style:
                    TextStyle(fontSize: 13.sp, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ÉTAPE 2 : Confirmation (PaymentSheet gère le reste)
  // ══════════════════════════════════════════════════════════
  Widget _buildStep2(PaymentState state) {
    return Column(
      children: [
        Icon(Icons.credit_card, size: 50.sp, color: primaryOrange),
        SizedBox(height: 16.h),
        Text('Confirmation',
            style: TextStyle(
                fontSize: 20.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Text(
          state.message ?? 'Confirmez le paiement',
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: () async {
              await ref
                  .read(paymentNotifierProvider.notifier)
                  .confirmPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.r)),
            ),
            child: Text('Confirmer',
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        CircularProgressIndicator(color: primaryOrange),
        SizedBox(height: 20.h),
        Text('Traitement en cours...',
            style:
                TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
        SizedBox(height: 8.h),
        Text('Ne fermez pas cette fenêtre',
            style:
                TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle,
              size: 60.sp, color: Colors.green),
        ),
        SizedBox(height: 20.h),
        Text('Paiement réussi',
            style: TextStyle(
                fontSize: 22.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Text('Bienvenue dans Premium 🎉',
            style: TextStyle(
                fontSize: 14.sp, color: Colors.grey.shade600)),
        SizedBox(height: 24.h),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // LOGIQUE DE PAIEMENT + REDIRECTION
  // ══════════════════════════════════════════════════════════
  Future<void> _processPayment() async {
    // 1. Créer le PaymentIntent
    final created = await ref
        .read(paymentNotifierProvider.notifier)
        .createPaymentIntent();

    if (!created || !mounted) return;

    // 2. Confirmer via Stripe PaymentSheet (ou Fake)
    final confirmed = await ref
        .read(paymentNotifierProvider.notifier)
        .confirmPayment();

    if (!mounted) return;

    if (confirmed) {
      //  Attendre un peu pour montrer l'écran de succès
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      ref.read(paymentNotifierProvider.notifier).reset();
      Navigator.pop(context, true);

      // REDIRECTION vers la PlaylistPage après 300 ms
      // (le temps que la modal se ferme complètement)
      /*await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        context.go('/playlists');
      } 
      */
    }
  }
}