import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:titan_tunes/domaine/entities/user_profile_entity.dart';
import 'package:titan_tunes/presentation/notifiers/profile_notifier.dart';
import 'package:titan_tunes/presentation/views/profile/premium_payment_sheet.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const Color primaryOrange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileNotifierProvider);
    final user = state.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18.sp, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings and privacy',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(20.r),
              children: [
                _sectionTitle('Apparence'),
                _settingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Couleur du thème',
                  subtitle: 'Personnalisez la couleur principale',
                  onTap: () {},
                ),

                _sectionTitle('Sécurité'),
                _settingsTile(
                  icon: Icons.lock_outline,
                  title: 'Confidentialité',
                  subtitle: 'Gérez vos préférences de confidentialité',
                  onTap: () {},
                ),
                _settingsTile(
                  icon: Icons.password_outlined,
                  title: 'Mot de passe',
                  subtitle: 'Changez votre mot de passe',
                  onTap: () {},
                ),

                _sectionTitle('Abonnement'),
                _buildCurrentPlanTile(context, ref, user),

                _sectionTitle('Notifications'),
                _settingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Alertes lorsqu\'une chanson est uploadée',
                  trailing: Switch(
                    value: true,
                    activeColor: primaryOrange,
                    onChanged: (value) {},
                  ),
                  onTap: () {},
                ),
              ],
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: primaryOrange, size: 22.sp),
        title: Text(
          title,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        trailing: trailing ??
            Icon(Icons.arrow_forward_ios,
                size: 14.sp, color: Colors.grey.shade400),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // CARTE PLAN ACTUEL
  // ══════════════════════════════════════════════════════════
  Widget _buildCurrentPlanTile(
    BuildContext context,
    WidgetRef ref,
    UserProfileEntity user,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_membership, color: primaryOrange, size: 22.sp),
              SizedBox(width: 12.w),
              Text(
                'Current plan',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _planOption(
            context,
            ref,
            plan: SubscriptionPlan.free,
            title: 'Free',
            price: '\$0.00 / month',
            amount: 0.0,
            isSelected: user.plan == SubscriptionPlan.free,
          ),
          SizedBox(height: 8.h),
          _planOption(
            context,
            ref,
            plan: SubscriptionPlan.premiumIndividual,
            title: 'Premium - Individual',
            price: '\$10.99 / month',
            amount: 10.99,
            isSelected: user.plan == SubscriptionPlan.premiumIndividual,
          ),
          SizedBox(height: 8.h),
          _planOption(
            context,
            ref,
            plan: SubscriptionPlan.premiumFamily,
            title: 'Premium - Family',
            price: '\$15.99 / month',
            amount: 15.99,
            isSelected: user.plan == SubscriptionPlan.premiumFamily,
          ),
        ],
      ),
    );
  }

  Widget _planOption(
    BuildContext context,
    WidgetRef ref, {
    required SubscriptionPlan plan,
    required String title,
    required String price,
    required double amount,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        // Plan gratuit : changement direct
        if (plan == SubscriptionPlan.free) {
          ref.read(profileNotifierProvider.notifier).setPremium(plan, price: 0);
          return;
        }

        // Plan premium : passer par le flow de paiement Mobile Money
        final ok = await PremiumPaymentSheet.show(
          context,
          plan: plan == SubscriptionPlan.premiumFamily
              ? 'premium_family'
              : 'premium_individual',
          amount: amount,
        );

        /*if (ok && context.mounted) {
          ref
              .read(profileNotifierProvider.notifier)
              .setPremium(plan, price: amount);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abonnement Premium activé 🎉'),
              backgroundColor: Colors.green,
            ),
          );
        } */
       if (ok && context.mounted) {
  // 1. Mettre à jour le plan
  ref.read(profileNotifierProvider.notifier).setPremium(plan, price: amount);

  // 2. Feedback utilisateur
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Abonnement Premium activé '),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );

  // 3.  REDIRECTION vers Playlists
  await Future.delayed(const Duration(milliseconds: 500));
  if (context.mounted) {
    context.go('/artist_album_page');
  }
}
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? primaryOrange : Colors.grey.shade300,
            width: isSelected ? 2.w : 1.w,
          ),
          color: isSelected ? primaryOrange.withOpacity(0.08) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? primaryOrange : Colors.grey.shade400,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? primaryOrange : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    price,
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}