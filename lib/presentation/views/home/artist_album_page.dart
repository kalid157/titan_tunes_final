import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:titan_tunes/domaine/entities/album_entity.dart';
import 'package:titan_tunes/presentation/notifiers/player_notifier.dart';
import 'package:titan_tunes/presentation/notifiers/profile_notifier.dart';
import 'package:titan_tunes/presentation/state/artist_state.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/mini_player_widget.dart';
import 'package:titan_tunes/provider/auth_provider.dart';
import 'package:titan_tunes/provider/favorite_providers.dart';

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

    //  CAS 1 : chargement en cours → spinner
    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: backgroundGrey,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    //  CAS 2 : aucun artiste chargé → message + bouton retour
    if (state.artistName == null) {
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
                Text(
                  'Aucun artiste sélectionné',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Retournez à l\'accueil et cliquez sur un album',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12.sp, color: Colors.grey.shade500),
                ),
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
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 12.h),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // CAS 3 : état normal → page complète
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
              child: _buildAlbumsRow(ref, state, isPremium: isPremium),
            ),
            SliverToBoxAdapter(
              child: _buildSongsHeader(ref, state),
            ),
            _buildSongsList(context, ref, state),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayerWidget(),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════
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
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 16.sp,
            color: Colors.black87,
          ),
          //  pop sécurisé
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
            icon: Icon(
              Icons.more_vert,
              size: 20.sp,
              color: Colors.black87,
            ),
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
                child: Icon(
                  Icons.person,
                  size: 100.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            )
          : Container(color: Colors.grey.shade300),
    ),
  );
}

  // ══════════════════════════════════════════════════════════
  // INFO ARTISTE
  // ══════════════════════════════════════════════════════════
  Widget _buildArtistInfo(ArtistState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          Text(
            state.artistName ?? '',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${state.albums.length} Album${state.albums.length > 1 ? "s" : ""}, '
            '${state.allSongs.length} Son${state.allSongs.length > 1 ? "s" : ""}',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (state.description != null) ...[
            SizedBox(height: 12.h),
            Text(
              state.description!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ALBUMS
  // ══════════════════════════════════════════════════════════
  Widget _buildAlbumsRow(
    WidgetRef ref,
    ArtistState state, {
    required bool isPremium,
  }) {
    final visibleAlbums =
        isPremium ? state.albums : state.albums.take(1).toList();

    final hiddenCount = state.albums.length - visibleAlbums.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            itemCount: visibleAlbums.length + (hiddenCount > 0 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == visibleAlbums.length && hiddenCount > 0) {
                return _buildSeeAllAlbumsCard(
                  context,
                  hiddenCount: hiddenCount,
                );
              }

              final album = visibleAlbums[index];
              final isSelected =
                  state.selectedAlbum?.trackingId == album.trackingId;

              return _buildAlbumItem(ref, album, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeeAllAlbumsCard(BuildContext context,
      {required int hiddenCount}) {
    return GestureDetector(
      onTap: () => _showPremiumDialog(context, hiddenCount),
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 140.w,
              height: 140.h,
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: primaryOrange,
                  width: 2.w,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline,
                        size: 36.sp, color: primaryOrange),
                    SizedBox(height: 8.h),
                    Text(
                      '+$hiddenCount',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Voir tout l\'album',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: primaryOrange,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumItem(WidgetRef ref, AlbumEntity album, bool isSelected) {
    return GestureDetector(
      onTap: () => ref.read(artistProvider.notifier).selectAlbum(album),
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: isSelected
                    ? Border.all(color: primaryOrange, width: 3.w)
                    : null,
              ),
              child: ClipRRect(
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

  // ══════════════════════════════════════════════════════════
  // HEADER SONGS
  // ══════════════════════════════════════════════════════════
  Widget _buildSongsHeader(WidgetRef ref, ArtistState state) {
    final filterLabel = state.selectedAlbum?.titreAlbum ?? 'Toutes les chansons';

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Songs',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (state.selectedAlbum != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        filterLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: () => ref
                            .read(artistProvider.notifier)
                            .clearAlbumSelection(),
                        child: Icon(Icons.close,
                            size: 14.sp, color: primaryOrange),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SONGS LIST
  // ══════════════════════════════════════════════════════════
  Widget _buildSongsList(
      BuildContext context, WidgetRef ref, ArtistState state) {
    final songs = state.displayedSongs;
    final playerState = ref.watch(playerProvider);
    final favoriteState = ref.watch(favoriteNotifierProvider);
    final clientId = ref.watch(authNotifierProvider).user?.id ?? '';

    if (songs.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Center(
            child: Text(
              'Aucune chanson pour cet artiste',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = songs[index];
          final isCurrent = playerState.isCurrentSong(song);
          final isPlaying = isCurrent && playerState.isPlaying;
          final isLiked = favoriteState.isLiked(song.trackingId);

          final thumbUrl = state.selectedAlbum?.imageAlbum ??
              (state.albums.isNotEmpty ? state.albums.first.imageAlbum : null);

          return GestureDetector(
            onTap: () {
              ref.read(playerProvider.notifier).playSongInPlaylist(
                    song: song,
                    playlist: songs,
                    album: state.selectedAlbum ??
                        (state.albums.isNotEmpty
                            ? state.albums.first
                            : null),
                  );
              context.push('/music_page');
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isCurrent
                    ? primaryOrange.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  // Miniature + play overlay
                  GestureDetector(
                    onTap: () {
                      if (isCurrent) {
                        ref.read(playerProvider.notifier).togglePlayPause();
                      } else {
                        ref.read(playerProvider.notifier).playSongInPlaylist(
                              song: song,
                              playlist: songs,
                              album: state.selectedAlbum ??
                                  (state.albums.isNotEmpty
                                      ? state.albums.first
                                      : null),
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
                        Container(
                          width: 50.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withOpacity(isPlaying ? 0.4 : 0.0),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
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
                        Text(
                          song.titre,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                isCurrent ? primaryOrange : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          song.artiste,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Like
                  GestureDetector(
                    onTap: () {
                      if (clientId.isEmpty) return;
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
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked
                            ? primaryOrange
                            : Colors.grey.shade400,
                        size: 22.sp,
                      ),
                    ),
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

  Widget _thumbnailPlaceholder() {
    return Container(
      width: 50.w,
      height: 50.h,
      color: Colors.grey.shade200,
      child: Icon(Icons.music_note,
          color: Colors.grey.shade500, size: 22.sp),
    );
  }

  // ══════════════════════════════════════════════════════════
  // DIALOG PREMIUM
  // ══════════════════════════════════════════════════════════
  void _showPremiumDialog(BuildContext context, int hiddenCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
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
                'Débloquez $hiddenCount album${hiddenCount > 1 ? "s" : ""}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Passez en Premium pour accéder à tous les albums de cet artiste et bien plus encore.',
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
                    Navigator.pop(context);
                    context.push('/settings');
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
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Plus tard',
                  style: TextStyle(
                      fontSize: 14.sp, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}