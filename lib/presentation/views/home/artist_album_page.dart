import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:titan_tunes/domaine/entities/album_entity.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';
import 'package:titan_tunes/presentation/notifiers/player_notifier.dart';
import 'package:titan_tunes/presentation/notifiers/profile_notifier.dart';
import 'package:titan_tunes/presentation/state/artist_state.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/like_button_with_count.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/mini_player_widget.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/vip_blur_wrapper.dart';

void _safePop(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/home');
  }
}

class ArtistAlbumPage extends ConsumerWidget {
  const ArtistAlbumPage({super.key});

  static const Color primaryOrange = Color(0xFFFF8A00);
  static const Color backgroundGrey = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(artistProvider);
    final isPremium =
        ref.watch(profileNotifierProvider).user?.isPremium ?? false;

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: backgroundGrey,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.artistName == null) {
      return Scaffold(
        backgroundColor: backgroundGrey,
        appBar: AppBar(
          backgroundColor: backgroundGrey,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                size: 18.sp, color: Colors.black87),
            onPressed: () => _safePop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search,
                    size: 60.sp, color: Colors.grey.shade400),
                SizedBox(height: 16.h),
                Text('Aucun artiste sélectionné',
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
                SizedBox(height: 20.h),
                ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home_outlined, size: 18),
                  label: const Text('Retour à l\'accueil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            _buildHeader(context, state),
            SliverToBoxAdapter(child: _buildArtistInfo(state)),
            SliverToBoxAdapter(child: _sectionTitle('Albums')),
            SliverToBoxAdapter(
              child: _buildAlbumsRow(
                  ref, state, isPremium: isPremium),
            ),
            SliverToBoxAdapter(child: _buildSongsHeader(ref, state)),
            _buildSongsList(context, ref, state, isPremium: isPremium),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayerWidget(),
    );
  }

  Widget _buildHeader(BuildContext context, ArtistState state) {
    return SliverAppBar(
      expandedHeight: 260.h,
      pinned: true,
      backgroundColor: backgroundGrey,
      leading: Padding(
        padding: EdgeInsets.all(8.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                size: 16.sp, color: Colors.black87),
            onPressed: () => _safePop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.all(8.r),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.more_vert,
                  size: 20.sp, color: Colors.black87),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: state.artistImageUrl != null
            ? Image.network(
                state.artistImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: Icon(Icons.person,
                      size: 100.sp, color: Colors.grey.shade500),
                ),
              )
            : Container(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildArtistInfo(ArtistState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          Text(state.artistName ?? '',
              style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          SizedBox(height: 8.h),
          Text(
            '${state.albums.length} Album${state.albums.length > 1 ? "s" : ""}, '
            '${state.allSongs.length} Son${state.allSongs.length > 1 ? "s" : ""}',
            style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500),
          ),
          if (state.description != null) ...[
            SizedBox(height: 12.h),
            Text(state.description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                    height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 12.h),
      child: Text(title,
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
    );
  }

  // ─────────────────────────────────────────────────────────
  // ALBUMS — avec verrouillage
  // ─────────────────────────────────────────────────────────
  Widget _buildAlbumsRow(
    WidgetRef ref,
    ArtistState state, {
    required bool isPremium,
  }) {
    return SizedBox(
      height: 210.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: state.albums.length,
        itemBuilder: (context, index) {
          final album = state.albums[index];
          final isSelected =
              state.selectedAlbum?.trackingId == album.trackingId;
          final isLocked = album.isLocked && !isPremium;

          return _buildAlbumItem(
            ref,
            state,
            album,
            isSelected,
            isLocked: isLocked,
          );
        },
      ),
    );
  }

  Widget _buildAlbumItem(
    WidgetRef ref,
    ArtistState state,
    AlbumEntity album,
    bool isSelected, {
    required bool isLocked,
  }) {
    return GestureDetector(
      onTap: () {
        if (isLocked) return;
        ref.read(artistProvider.notifier).selectAlbum(album);
      },
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            VipBlurWrapper(
              isLocked: isLocked,
              borderRadius: 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: isSelected
                      ? Border.all(color: primaryOrange, width: 3.w)
                      : null,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.network(
                        album.imageAlbum,
                        width: 140.w,
                        height: 140.h,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 140.w,
                          height: 140.h,
                          color: Colors.grey.shade300,
                          child: Icon(Icons.album,
                              size: 40.sp, color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                    if (album.isNew)
                      Positioned(
                        top: 6.h,
                        left: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: primaryOrange,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text('NEW',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              album.titreAlbum,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryOrange : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HEADER SONGS
  // ─────────────────────────────────────────────────────────
  Widget _buildSongsHeader(WidgetRef ref, ArtistState state) {
    final hasAlbumSelected = state.selectedAlbum != null;
    final songsCount = state.displayedSongs.length;
    final isLoading = state.isLoadingAlbumSongs;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasAlbumSelected ? 'Songs de l\'album' : 'Songs',
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 2.h),
                  if (isLoading)
                    Row(
                      children: [
                        SizedBox(
                          width: 10.w,
                          height: 10.h,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: primaryOrange),
                        ),
                        SizedBox(width: 6.w),
                        Text('Chargement...',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600)),
                      ],
                    )
                  else
                    Text(
                      '$songsCount chanson${songsCount > 1 ? "s" : ""}',
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey.shade600),
                    ),
                ],
              ),
              if (hasAlbumSelected)
                GestureDetector(
                  onTap: () => ref
                      .read(artistProvider.notifier)
                      .clearAlbumSelection(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Text('Tout voir',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: primaryOrange,
                                fontWeight: FontWeight.w600)),
                        SizedBox(width: 4.w),
                        Icon(Icons.close,
                            size: 12.sp, color: primaryOrange),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (hasAlbumSelected) ...[
            SizedBox(height: 8.h),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8.r),
                border:
                    Border.all(color: primaryOrange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.album, size: 14.sp, color: primaryOrange),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      state.selectedAlbum!.titreAlbum,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: primaryOrange,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // SONGS LIST — avec verrouillage
  // ─────────────────────────────────────────────────────────
  Widget _buildSongsList(
    BuildContext context,
    WidgetRef ref,
    ArtistState state, {
    required bool isPremium,
  }) {
    if (state.isLoadingAlbumSongs) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final songs = state.displayedSongs;
    final playerState = ref.watch(playerProvider);

    if (songs.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40.r),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.music_off_outlined,
                    size: 50.sp, color: Colors.grey.shade400),
                SizedBox(height: 12.h),
                Text(
                  state.selectedAlbum != null
                      ? 'Aucune chanson dans cet album'
                      : 'Aucune chanson pour cet artiste',
                  style: TextStyle(
                      fontSize: 14.sp, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final defaultAlbum = state.selectedAlbum ??
        (state.albums.isNotEmpty ? state.albums.first : null);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = songs[index];
          final isCurrent = playerState.isCurrentSong(song);
          final isPlaying = isCurrent &&
              playerState.isPlaying &&
              !playerState.isPreviewOnly;

          final songAlbum = _findAlbumForSong(state, song) ?? defaultAlbum;
          final thumbUrl = songAlbum?.imageAlbum;

          // ⭐ Song verrouillée ?
          final isLocked = (song.isVip ||
                  (songAlbum?.isLocked ?? false)) &&
              !isPremium;

          return GestureDetector(
            onTap: () {
              if (isLocked) return;
              ref.read(playerProvider.notifier).playSongInPlaylist(
                    song: song,
                    playlist: songs,
                    album: songAlbum,
                  );
              context.push('/music_page');
            },
            child: Container(
              margin:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isCurrent
                    ? primaryOrange.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  VipBlurWrapper(
                    isLocked: isLocked,
                    borderRadius: 10,
                    child: GestureDetector(
                      onTap: () {
                        if (isLocked) return;
                        if (isCurrent && !playerState.isPreviewOnly) {
                          ref
                              .read(playerProvider.notifier)
                              .togglePlayPause();
                        } else {
                          ref
                              .read(playerProvider.notifier)
                              .playSongInPlaylist(
                                song: song,
                                playlist: songs,
                                album: songAlbum,
                              );
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: thumbUrl != null
                                ? Image.network(
                                    thumbUrl,
                                    width: 50.w,
                                    height: 50.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _thumbnailPlaceholder(),
                                  )
                                : _thumbnailPlaceholder(),
                          ),
                          if (!isLocked)
                            Container(
                              width: 50.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(
                                    isPlaying ? 0.4 : 0.0),
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
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.titre,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: isCurrent
                                    ? primaryOrange
                                    : Colors.black87),
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
                  if (!isLocked)
                    LikeButtonWithCount(
                      songTrackingId: song.trackingId,
                      iconSize: 22,
                    )
                  else
                    Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Icon(Icons.lock,
                          size: 18.sp, color: Colors.grey.shade400),
                    ),
                ],
              ),
            ),
          );
        },
        childCount: songs.length,
      ),
    );
  }

  AlbumEntity? _findAlbumForSong(ArtistState state, SongEntity song) {
    if (song.albumTrackingId != null &&
        song.albumTrackingId!.isNotEmpty) {
      for (final a in state.albums) {
        if (a.trackingId == song.albumTrackingId) return a;
      }
    }
    return null;
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      width: 50.w,
      height: 50.h,
      color: Colors.grey.shade200,
      child: Icon(Icons.music_note,
          color: Colors.grey.shade500, size: 22.sp),
    );
  }
}