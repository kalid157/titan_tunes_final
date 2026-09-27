import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:titan_tunes/domaine/entities/album_entity.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';
import 'package:titan_tunes/presentation/notifiers/player_notifier.dart';
import 'package:titan_tunes/provider/auth_provider.dart';
import 'package:titan_tunes/provider/favorite_providers.dart';
import 'package:titan_tunes/provider/music_providers.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  static const Color primaryOrange = Color(0xFFFF8A00);
  static const Color backgroundGrey = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteState = ref.watch(favoriteNotifierProvider);
    final musicState = ref.watch(musicNotifierProvider);
    final playerState = ref.watch(playerProvider);
    final clientId = ref.watch(authNotifierProvider).user?.id ?? '';

    // ⭐ Filtrer les songs aimées depuis la liste complète
    final likedSongs = musicState.allSongs
        .where((s) => favoriteState.isLiked(s.trackingId))
        .toList();

    // Album pour chaque song (pour la miniature)
    AlbumEntity? albumFor(SongEntity song) {
      try {
        return musicState.albums.firstWhere(
          (a) => a.nomArtiste.toLowerCase() == song.artiste.toLowerCase(),
        );
      } catch (_) {
        return null;
      }
    }

    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: backgroundGrey,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18.sp, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mes favoris',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${likedSongs.length}',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: primaryOrange,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: clientId.isEmpty
          ? _buildEmpty('Connectez-vous pour voir vos favoris')
          : likedSongs.isEmpty
              ? _buildEmpty('Aucune chanson aimée pour le moment')
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  itemCount: likedSongs.length,
                  itemBuilder: (context, index) {
                    final song = likedSongs[index];
                    final album = albumFor(song);
                    final isCurrent = playerState.isCurrentSong(song);
                    final isPlaying = isCurrent && playerState.isPlaying;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        children: [
                          // Miniature
                          GestureDetector(
                            onTap: () {
                              if (isCurrent) {
                                ref
                                    .read(playerProvider.notifier)
                                    .togglePlayPause();
                              } else {
                                ref
                                    .read(playerProvider.notifier)
                                    .playSongInPlaylist(
                                      song: song,
                                      playlist: likedSongs,
                                      album: album,
                                    );
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: album != null
                                      ? Image.network(
                                          album.imageAlbum,
                                          width: 55.w,
                                          height: 55.h,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _ph(55),
                                        )
                                      : _ph(55),
                                ),
                                Container(
                                  width: 55.w,
                                  height: 55.h,
                                  decoration: BoxDecoration(
                                    color: Colors.black
                                        .withOpacity(isPlaying ? 0.4 : 0.0),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 22.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 14.w),

                          // Titre + artiste
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(song.titre,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isCurrent
                                          ? primaryOrange
                                          : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                SizedBox(height: 4.h),
                                Text(song.artiste,
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),

                          // Bouton unlike (remplit)
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(favoriteNotifierProvider.notifier)
                                  .toggleFavorite(
                                    clientTrackingId: clientId,
                                    songTrackingId: song.trackingId,
                                  );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Icon(
                                Icons.favorite,
                                color: primaryOrange,
                                size: 24.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 60.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _ph(double size) {
    return Container(
      width: size.w,
      height: size.h,
      color: Colors.grey.shade200,
      child: Icon(Icons.music_note, color: Colors.grey.shade500, size: 22.sp),
    );
  }
}