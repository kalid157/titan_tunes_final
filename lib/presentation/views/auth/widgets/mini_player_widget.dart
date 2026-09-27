import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:titan_tunes/presentation/notifiers/player_notifier.dart';

///  Mini-player persistant : affiche la chanson en cours
/// et permet de la contrôler depuis n'importe quel écran.
class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  static const Color primaryOrange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final song = state.playingSong;

    //  Masquer si aucune chanson chargée
    if (song == null) return const SizedBox.shrink();

    final imageUrl = state.currentAlbum?.imageAlbum;
    final total = state.duration.inSeconds.toDouble();
    final current =
        state.position.inSeconds.toDouble().clamp(0, total).toDouble();

    // Pourcentage de progression
    final progress = total > 0 ? (current / total) : 0.0;

    return GestureDetector(
      onTap: () {
        //  Reset le focus sur ce qui joue, puis ouvre la page
        ref.read(playerProvider.notifier).focusOnPlayingSong();
        //  Ouvre la page musique complète
        context.push('/music_page');
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Barre de progression en fond
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3.h,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(primaryOrange),
                ),
              ),

              // Contenu
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 6.w, 8.h),
                child: Row(
                  children: [
                    // ─── MINIATURE ───
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 42.w,
                              height: 42.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                    SizedBox(width: 12.w),

                    // ─── TITRE + ARTISTE ───
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.titre,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            song.artiste,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // ─── BOUTON PLAY/PAUSE ───
                    IconButton(
                      icon: Icon(
                        state.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: primaryOrange,
                        size: 36.sp,
                      ),
                      onPressed: () {
                        ref.read(playerProvider.notifier).togglePlayPause();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 42.w,
      height: 42.h,
      color: Colors.grey.shade200,
      child: Icon(Icons.music_note,
          color: Colors.grey.shade500, size: 20.sp),
    );
  }
}