// ⭐ hide RepeatMode — résout le conflit avec Flutter
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:titan_tunes/presentation/notifiers/player_notifier.dart';
import 'package:titan_tunes/presentation/state/artist_state.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/like_button_with_count.dart';
import 'package:titan_tunes/provider/music_providers.dart';

class LyricsPage extends ConsumerWidget {
  const LyricsPage({super.key});

  static const Color primaryOrange = Color(0xFFFF8A00);

  // TODO: brancher sur un endpoint /lyrics/{songId} plus tard
  static const String _mockLyrics = '''
[Verse 1]
Sleepin', you're on your tippy toes
Creepin' around like no one knows
Think you're so criminal
Bruises on both my knees for you
Don't say thank you or please
I do what I want when I'm wanting to
My soul? So cynical

[Verse 2]
Sleepin', you're on your tippy toes
Creepin' around like no one knows
Think you're so criminal
Bruises on both my knees for you
Don't say thank you or please

[Verse 3]
Sleepin', you're on your tippy toes
Creepin' around like no one knows
Think you're so criminal
''';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final song = state.currentSong;

    if (song == null) {
      return const Scaffold(body: Center(child: Text('Aucune chanson')));
    }

    final imageUrl = state.currentAlbum?.imageAlbum;

    return Scaffold(
      body: Stack(
        children: [
          // Fond flouté
          Positioned.fill(
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.black),
                  )
                : Container(color: Colors.black),
          ),
          Container(color: Colors.black.withOpacity(0.5)),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, song.titre),
                SizedBox(height: 10.h),
                if (state.isPreviewOnly) _buildPreviewBanner(),
                Expanded(child: _buildLyrics()),
                _buildMiniPlayer(context, ref, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18.sp),
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
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white, size: 22.sp),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BANDEAU APERÇU
  // ─────────────────────────────────────────────────────────
  Widget _buildPreviewBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.headphones, color: Colors.white70, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Aperçu — appuyez sur ▶ pour écouter',
              style: TextStyle(fontSize: 11.sp, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // PAROLES
  // ─────────────────────────────────────────────────────────
  Widget _buildLyrics() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: Text(
        _mockLyrics,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 16.sp,
          height: 1.8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  /// ─────────────────────────────────────────────────────────
  /// 
  Future<void> _openArtist(
  BuildContext context,
  WidgetRef ref,
  PlayerState state,
) async {
  final musicState = ref.read(musicNotifierProvider);
  final currentSong = state.currentSong;
  if (currentSong == null) return;

  if (musicState.albums.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aucun album disponible'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  // Trouve l'album en cours ou le premier album de l'artiste
  final artistLower = currentSong.artiste.toLowerCase();
  final album = state.currentAlbum ??
      musicState.albums.firstWhere(
        (a) => a.nomArtiste.toLowerCase() == artistLower,
        orElse: () => musicState.albums.first,
      );

  await ref.read(artistProvider.notifier).loadFromAlbum(
        tappedAlbum: album,
        allAlbums: musicState.albums,
        allSongs: musicState.allSongs,
      );

  if (context.mounted) {
    context.push('/artist_album');
  }
}
  // ─────────────────────────────────────────────────────────
  // MINI PLAYER avec modes de lecture
  // ─────────────────────────────────────────────────────────
  Widget _buildMiniPlayer(
      BuildContext context, WidgetRef ref, PlayerState state) {
    final song = state.currentSong!;
    final imageUrl = state.currentAlbum?.imageAlbum;
    final total = state.duration.inSeconds.toDouble();
    final current =
        state.position.inSeconds.toDouble().clamp(0, total).toDouble();
    final isPreview = state.isPreviewOnly;

    return Container(
      margin: EdgeInsets.all(12.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── LIGNE HAUTE : miniature + titre + like ───
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.music_note,
                            size: 24.sp,
                            color: Colors.grey,
                          ),
                        )
                      : Icon(Icons.music_note,
                          size: 24.sp, color: Colors.grey),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
  child: InkWell(
    borderRadius: BorderRadius.circular(8.r),
    onTap: () => _openArtist(context, ref, state),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            song.titre,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Flexible(
                child: Text(
                  song.artiste,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: primaryOrange,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right,
                size: 14.sp,
                color: primaryOrange,
              ),
            ],
          ),
        ],
      ),
    ),
  ),
),
              LikeButtonWithCount(
                songTrackingId: song.trackingId,
                iconSize: 24,
                padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // ─── SLIDER ───
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
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

          // ─── DURÉES ───
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(state.position),
                    style: TextStyle(
                        fontSize: 11.sp, color: Colors.grey.shade600)),
                Text(_fmt(state.duration),
                    style: TextStyle(
                        fontSize: 11.sp, color: Colors.grey.shade600)),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // ─── CONTRÔLES avec modes ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRepeatButton(ref, state),
              IconButton(
                icon: Icon(Icons.skip_previous,
                    size: 26.sp, color: Colors.black87),
                onPressed: isPreview
                    ? null
                    : () => ref.read(playerProvider.notifier).previous(),
              ),
              GestureDetector(
                onTap: () =>
                    ref.read(playerProvider.notifier).togglePlayPause(),
                child: Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: primaryOrange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryOrange.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isPlaying && !isPreview
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 26.sp,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.skip_next,
                    size: 26.sp, color: Colors.black87),
                onPressed: isPreview
                    ? null
                    : () => ref.read(playerProvider.notifier).next(),
              ),
              _buildShuffleButton(ref, state),
            ],
          ),
        ],
      ),
    );
  }

  //  Bouton de répétition : off → all → one → off
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
      icon: Icon(icon, size: 20.sp, color: color),
      onPressed: () => ref.read(playerProvider.notifier).cycleRepeatMode(),
      tooltip: switch (state.repeatMode) {
        RepeatMode.off => 'Lecture une fois',
        RepeatMode.all => 'Boucle',
        RepeatMode.one => 'Répéter une chanson',
      },
    );
  }

  // ⭐ Bouton aléatoire
  Widget _buildShuffleButton(WidgetRef ref, PlayerState state) {
    return IconButton(
      icon: Icon(
        Icons.shuffle,
        size: 20.sp,
        color: state.shuffleEnabled ? primaryOrange : Colors.grey.shade600,
      ),
      onPressed: () => ref.read(playerProvider.notifier).toggleShuffle(),
      tooltip:
          state.shuffleEnabled ? 'Aléatoire activé' : 'Aléatoire désactivé',
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}