import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:titan_tunes/presentation/notifiers/profile_notifier.dart';

/// ⭐ Wrapper qui verrouille un contenu pour les non-premium.
/// Le flou est léger pour garder l'image visible.
class VipBlurWrapper extends ConsumerWidget {
  final bool isLocked;
  final Widget child;
  final double blurAmount;
  final double borderRadius;
  final bool showBigBadge;

  const VipBlurWrapper({
    super.key,
    required this.isLocked,
    required this.child,
    this.blurAmount = 1.5,       // ⭐ Réduit à 1.5 (au lieu de 4)
    this.borderRadius = 12,
    this.showBigBadge = true,    // Badge central "Premium"
  });

  static const Color primaryOrange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isLocked) return child;

    final isPremium =
        ref.watch(profileNotifierProvider).user?.isPremium ?? false;
    if (isPremium) return child;

    return Stack(
      children: [
        // Image légèrement floutée + désactivée
        AbsorbPointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurAmount,
              sigmaY: blurAmount,
            ),
            // ⭐ Opacity plus haute pour mieux voir
            child: Opacity(opacity: 0.75, child: child),
          ),
        ),

        // Overlay sombre + cadenas
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius.r),
            child: Material(
              color: Colors.black.withOpacity(0.25),
              child: InkWell(
                onTap: () => _showPremiumSheet(context),
                child: showBigBadge
                    ? Center(child: _buildLockBadge())
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLockBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: primaryOrange,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, color: Colors.white, size: 11.sp),
          SizedBox(width: 4.w),
          Text(
            'Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => _buildPremiumSheet(ctx),
    );
  }

  Widget _buildPremiumSheet(BuildContext ctx) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(height: 20.h),
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
          Text(
            'Contenu Premium',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Débloquez cet album et toutes les nouveautés en passant en Premium.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ctx.push('/settings');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Text(
                'Passer en Premium',
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Plus tard',
              style: TextStyle(
                  fontSize: 14.sp, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

/// ⭐ Overlay léger pour les petits éléments (miniatures de playlist).
/// Affiche juste un cadenas en coin, sans flou complet.
class SmallLockOverlay extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final double borderRadius;

  const SmallLockOverlay({
    super.key,
    required this.child,
    required this.isLocked,
    this.borderRadius = 10,
  });

  static const Color primaryOrange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return child;

    return Stack(
      children: [
        child,
        // Overlay sombre
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius.r),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ),
        // Cadenas en bas à droite
        Positioned(
          bottom: 3.h,
          right: 3.w,
          child: Container(
            padding: EdgeInsets.all(3.r),
            decoration: const BoxDecoration(
              color: primaryOrange,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock,
                size: 10.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }
}