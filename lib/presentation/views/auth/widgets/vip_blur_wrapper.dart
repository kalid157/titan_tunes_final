import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:titan_tunes/presentation/notifiers/profile_notifier.dart';

class VipBlurWrapper extends ConsumerWidget {
  final bool isVip;
  final Widget child;

  const VipBlurWrapper({
    super.key,
    required this.isVip,
    required this.child,
  });

  static const Color primaryOrange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium =
        ref.watch(profileNotifierProvider).user?.isPremium ?? false;

    if (!isVip || isPremium) return child;

    return Stack(
      children: [
        // Flou + désactivation du tap
        AbsorbPointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Opacity(opacity: 0.5, child: child),
          ),
        ),
        // Lock overlay
        Positioned.fill(
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: primaryOrange,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, color: Colors.white, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text('Premium',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}