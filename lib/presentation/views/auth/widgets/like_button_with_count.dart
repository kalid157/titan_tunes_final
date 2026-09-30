import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//  Import du notifier (source unique pour favoriteNotifierProvider)
import 'package:titan_tunes/presentation/notifiers/favorite_notifier.dart';
import 'package:titan_tunes/presentation/notifiers/like_count_notifier.dart';
import 'package:titan_tunes/provider/auth_provider.dart';

// ❌ NE PAS importer favorite_providers.dart ici
// pour éviter l'ambiguïté (même si on a un export, ce n'est pas nécessaire).

class LikeButtonWithCount extends ConsumerWidget {
  final String songTrackingId;
  final double iconSize;
  final bool showCount;
  final EdgeInsets? padding;

  const LikeButtonWithCount({
    super.key,
    required this.songTrackingId,
    this.iconSize = 22,
    this.showCount = true,
    this.padding,
  });

  static const Color primaryOrange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked =
        ref.watch(favoriteNotifierProvider).isLiked(songTrackingId);
    final formattedCount =
        ref.watch(likeCountProvider).formattedCount(songTrackingId);
    final clientId = ref.watch(authNotifierProvider).user?.id ?? '';

    return GestureDetector(
      onTap: () {
        if (clientId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connectez-vous pour aimer une chanson'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        ref.read(favoriteNotifierProvider.notifier).toggleFavorite(
              clientTrackingId: clientId,
              songTrackingId: songTrackingId,
            );
      },
      child: Padding(
        padding: padding ?? EdgeInsets.all(8.r),
        child: showCount
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? primaryOrange : Colors.grey.shade400,
                    size: iconSize.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    formattedCount,
                    style: TextStyle(
                      fontSize: (iconSize * 0.55).sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isLiked ? primaryOrange : Colors.grey.shade500,
                    ),
                  ),
                ],
              )
            : Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? primaryOrange : Colors.grey.shade400,
                size: iconSize.sp,
              ),
      ),
    );
  }
}