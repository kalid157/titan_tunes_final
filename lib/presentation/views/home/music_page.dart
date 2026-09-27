// ⭐ hide RepeatMode — résout le conflit avec Flutter
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:titan_tunes/domaine/entities/song_entity.dart';
import 'package:titan_tunes/presentation/notifiers/player_notifier.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/like_button_with_count.dart';

class MusicPage extends ConsumerWidget {
  const MusicPage({super.key});

  static const Color primaryOrange = Color(0xFFFF8A00);
  static const Color backgroundGrey = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final song = state.currentSong;

    if (song == null) {
      return const Scaffold(
        body: Center(child: Text('Aucune chanson en lecture')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        // ⭐ SingleChildScrollView pour éviter l'overflow
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                _buildAppBar(context, state.currentAlbum?.titreAlbum),
                SizedBox(height: 16.h),

                // Bannière aperçu
                if (state.isPreviewOnly) ...[
                  _buildPreviewBanner(),
                  SizedBox(height: 12.h),
                ],

                _buildAlbumCover(state),
                SizedBox(height: 20.h),
                _buildSongInfo(song, ref),
                SizedBox(height: 16.h),
                _buildProgressBar(ref, state),
                SizedBox(height: 16.h),
                _buildControls(ref, state),
                SizedBox(height: 24.h),
                _buildLyricsButton(context),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, String? albumTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 16.sp, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        Expanded(
          child: Text(
            albumTitle ?? 'Lecture',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert, size: 22.sp, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // BANNIÈRE APERÇU
  // ─────────────────────────────────────────────────────────
  Widget _buildPreviewBanner() {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: primaryOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: primaryOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.headphones, color: primaryOrange, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Aperçu — appuyez sur ▶ pour écouter cet album',
              style: TextStyle(
                fontSize: 11.sp,
                color: primaryOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // POCHETTE
  // ─────────────────────────────────────────────────────────
  Widget _buildAlbumCover(PlayerState state) {
    final imageUrl = state.currentAlbum?.imageAlbum;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey(state.currentSong?.trackingId ?? 'empty'),
        width: double.infinity,
        height: 320.h,  // ⭐ Réduit de 340.h à 320.h pour la marge
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          color: Colors.grey.shade200,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Icon(Icons.music_note, size: 100.sp, color: Colors.grey.shade500),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TITRE + ARTISTE + LIKE
  // ─────────────────────────────────────────────────────────
  Widget _buildSongInfo(SongEntity song, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(song.titre,
                  style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              SizedBox(height: 6.h),
              Text(song.artiste,
                  style: TextStyle(
                      fontSize: 16.sp, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        LikeButtonWithCount(
          songTrackingId: song.trackingId,
          iconSize: 28,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // PROGRESSION
  // ─────────────────────────────────────────────────────────
  Widget _buildProgressBar(WidgetRef ref, PlayerState state) {
    final total = state.duration.inSeconds.toDouble();
    final current =
        state.position.inSeconds.toDouble().clamp(0, total).toDouble();

    final isPreview = state.isPreviewOnly;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3.h,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.r),
            activeTrackColor: primaryOrange,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: primaryOrange,
          ),
          child: Slider(
            value: isPreview ? 0 : current,
            max: total > 0 ? total : 1,
            onChanged: isPreview
                ? null
                : (v) => ref
                    .read(playerProvider.notifier)
                    .seek(Duration(seconds: v.toInt())),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(isPreview ? Duration.zero : state.position),
                  style: TextStyle(
                      fontSize: 12.sp, color: Colors.grey.shade600)),
              Text(_fmt(state.duration),
                  style: TextStyle(
                      fontSize: 12.sp, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // CONTRÔLES
  // ─────────────────────────────────────────────────────────
  Widget _buildControls(WidgetRef ref, PlayerState state) {
    final isPreview = state.isPreviewOnly;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // ⭐ Bouton répétition
        _buildRepeatButton(ref, state),

        // Previous
        IconButton(
          icon: Icon(Icons.skip_previous,
              color: isPreview ? Colors.grey.shade400 : Colors.black87,
              size: 32.sp),  // ⭐ Réduit de 36.sp à 32.sp
          onPressed: isPreview
              ? null
              : () => ref.read(playerProvider.notifier).previous(),
        ),

        // ⭐ Play/Pause — la logique clé
        // En preview : PLAY (pour lancer cette chanson)
        // Sinon : PAUSE si en lecture, PLAY sinon
        GestureDetector(
          onTap: () => ref.read(playerProvider.notifier).togglePlayPause(),
          child: Container(
            width: 68.w,  // ⭐ Réduit de 72.w à 68.w
            height: 68.w,
            decoration: BoxDecoration(
              color: primaryOrange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryOrange.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              // ⭐ Si preview → toujours "play"
              // Sinon → pause si playing, play sinon
              isPreview
                  ? Icons.play_arrow
                  : (state.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow),
              color: Colors.white,
              size: 34.sp,
            ),
          ),
        ),

        // Next
        IconButton(
          icon: Icon(Icons.skip_next,
              color: isPreview ? Colors.grey.shade400 : Colors.black87,
              size: 32.sp),  // ⭐ Réduit
          onPressed: isPreview
              ? null
              : () => ref.read(playerProvider.notifier).next(),
        ),

        // ⭐ Bouton aléatoire
        _buildShuffleButton(ref, state),
      ],
    );
  }

  // ⭐ Bouton répétition
  Widget _buildRepeatButton(WidgetRef ref, PlayerState state) {
    final IconData icon;
    final Color color;

    switch (state.repeatMode) {
      case RepeatMode.off:
        icon = Icons.repeat;
        color = Colors.grey.shade600;
        break;
      case RepeatMode.all:
        icon = Icons.repeat_on;
        color = primaryOrange;
        break;
      case RepeatMode.one:
        icon = Icons.repeat_one_on;
        color = primaryOrange;
        break;
    }

    return IconButton(
      icon: Icon(icon, size: 22.sp, color: color),  // ⭐ Réduit
      onPressed: () =>
          ref.read(playerProvider.notifier).cycleRepeatMode(),
      tooltip: switch (state.repeatMode) {
        RepeatMode.off => 'Lecture une fois',
        RepeatMode.all => 'Boucle sur la playlist',
        RepeatMode.one => 'Répéter cette chanson',
      },
    );
  }

  // ⭐ Bouton aléatoire
  Widget _buildShuffleButton(WidgetRef ref, PlayerState state) {
    return IconButton(
      icon: Icon(
        Icons.shuffle,
        size: 22.sp,  // ⭐ Réduit
        color: state.shuffleEnabled
            ? primaryOrange
            : Colors.grey.shade600,
      ),
      onPressed: () =>
          ref.read(playerProvider.notifier).toggleShuffle(),
      tooltip: state.shuffleEnabled
          ? 'Aléatoire activé'
          : 'Aléatoire désactivé',
    );
  }

  // ─────────────────────────────────────────────────────────
  // BOUTON LYRICS
  // ─────────────────────────────────────────────────────────
  Widget _buildLyricsButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/lyrics_page'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.keyboard_arrow_up, size: 22.sp, color: Colors.black87),
          SizedBox(height: 4.h),
          Text('Lyrics',
              style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}