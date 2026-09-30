import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:titan_tunes/domaine/entities/album_entity.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';
import 'package:titan_tunes/presentation/notifiers/duration_cache_notifier.dart';
import 'package:titan_tunes/presentation/notifiers/player_notifier.dart';
import 'package:titan_tunes/presentation/notifiers/profile_notifier.dart';
import 'package:titan_tunes/presentation/notifiers/whats_new_notifier.dart';
import 'package:titan_tunes/presentation/state/artist_state.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/like_button_with_count.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/mini_player_widget.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/vip_blur_wrapper.dart';
import 'package:titan_tunes/provider/auth_provider.dart';
import 'package:titan_tunes/provider/favorite_providers.dart';
import 'package:titan_tunes/provider/home_state.dart';
import 'package:titan_tunes/provider/music_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const Color primaryOrange = Color(0xFFFF8A00);
  static const Color backgroundGrey = Color(0xFFF8F9FA);

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initialized) return;
      _initialized = true;
      _loadAllSafe();
    });
  }

  Future<void> _loadAllSafe() async {
    final clientId = ref.read(authNotifierProvider).user?.id ?? '';
    final musicNotifier = ref.read(musicNotifierProvider.notifier);
    final favoriteNotifier = ref.read(favoriteNotifierProvider.notifier);
    final durationNotifier = ref.read(durationCacheProvider.notifier);
    final whatsNewNotifier = ref.read(whatsNewProvider.notifier);

    final albumsEmpty = ref.read(musicNotifierProvider).albums.isEmpty;
    final favoritesEmpty =
        ref.read(favoriteNotifierProvider).likedSongIds.isEmpty;

    if (albumsEmpty) {
      await musicNotifier.loadAll();
    }

    if (!mounted) return;
    final songs = ref.read(musicNotifierProvider).allSongs;

    if (songs.isNotEmpty) {
      durationNotifier.loadAll(songs);
    }

    if (clientId.isNotEmpty && favoritesEmpty) {
      await favoriteNotifier.loadFavorites(clientId);
    }

    whatsNewNotifier.start();
  }

  Future<void> _refresh() async {
    final clientId = ref.read(authNotifierProvider).user?.id ?? '';
    final musicNotifier = ref.read(musicNotifierProvider.notifier);
    final favoriteNotifier = ref.read(favoriteNotifierProvider.notifier);
    final durationNotifier = ref.read(durationCacheProvider.notifier);
    final whatsNewNotifier = ref.read(whatsNewProvider.notifier);

    await Future.wait([
      musicNotifier.loadAll(),
      if (clientId.isNotEmpty) favoriteNotifier.loadFavorites(clientId),
    ]);

    if (!mounted) return;
    final songs = ref.read(musicNotifierProvider).allSongs;
    if (songs.isNotEmpty) {
      durationNotifier.loadAll(songs);
    }

    whatsNewNotifier.refreshNow();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: primaryOrange,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(),
                    SizedBox(height: 10.h),
                    _buildFeaturedBanner(),
                    SizedBox(height: 24.h),
                    _buildCategoryTabs(ref, selectedTab),
                    SizedBox(height: 20.h),
                    _buildTabContent(context, ref, selectedTab),
                    SizedBox(height: 30.h),
                    if (selectedTab == HomeTab.news) ...[
                      _buildPlaylistSection(context, ref),
                      SizedBox(height: 20.h),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayerWidget(),
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.search, size: 28.sp, color: Colors.black87),
            onPressed: () {},
          ),
          Row(
            children: [
              Icon(Icons.music_note, color: primaryOrange, size: 28.sp),
              SizedBox(width: 4.w),
              Text(
                'Tunes',
                style: TextStyle(
                  color: primaryOrange,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.more_vert, size: 28.sp, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BANNIÈRE
  // ─────────────────────────────────────────────────────────
  Widget _buildFeaturedBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        height: 125.h,
        decoration: BoxDecoration(
          color: primaryOrange,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 20.w,
              top: 20.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Album',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12.sp)),
                  SizedBox(height: 4.h),
                  Text(
                    'Happier Than\nEver',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text('Billie Eilish',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12.sp)),
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20.r),
                  topLeft: Radius.circular(40.r),
                ),
                child: Image.asset(
                  'assets/images/homewoman.png',
                  width: 230.w,
                  height: 140.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.image, size: 80.sp, color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TABS
  // ─────────────────────────────────────────────────────────
  Widget _buildCategoryTabs(WidgetRef ref, HomeTab selectedTab) {
    final tabs = [
      {'type': HomeTab.news, 'label': 'News'},
      {'type': HomeTab.video, 'label': 'Video'},
      {'type': HomeTab.artists, 'label': 'Artists'},
      {'type': HomeTab.podcasts, 'label': 'Podcasts'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: tabs.map((tab) {
          final tabType = tab['type'] as HomeTab;
          final isSelected = tabType == selectedTab;

          return Padding(
            padding: EdgeInsets.only(right: 24.w),
            child: GestureDetector(
              onTap: () {
                ref.read(selectedTabProvider.notifier).selectTab(tabType);
              },
              child: Column(
                children: [
                  Text(
                    tab['label'] as String,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.black87 : Colors.grey.shade400,
                      fontSize: 18.sp,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      height: 3.h,
                      width: 30.w,
                      decoration: BoxDecoration(
                        color: primaryOrange,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, WidgetRef ref, HomeTab tab) {
    switch (tab) {
      case HomeTab.news:
        return _buildNewsSection(context, ref);
      case HomeTab.video:
        return _buildVideoSection(context);
      case HomeTab.artists:
        return _buildArtistsSection(context);
      case HomeTab.podcasts:
        return _buildPodcastsSection(context);
    }
  }

  // ─────────────────────────────────────────────────────────
  // NEWS
  // ─────────────────────────────────────────────────────────
  Widget _buildNewsSection(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicNotifierProvider);
    final albums = musicState.albums;
    final allSongs = musicState.allSongs;
    final playerState = ref.watch(playerProvider);
    final isPremium =
        ref.watch(profileNotifierProvider).user?.isPremium ?? false;

    if (musicState.isLoading && albums.isEmpty) {
      return SizedBox(
        height: 260.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (albums.isEmpty) {
      return SizedBox(
        height: 260.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.album_outlined,
                  size: 50.sp, color: Colors.grey.shade400),
              SizedBox(height: 12.h),
              Text('Aucun album disponible',
                  style: TextStyle(
                      fontSize: 14.sp, color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 260.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];

          // Filtre précis par albumTrackingId
          final songsOfAlbum = allSongs
              .where((s) => s.albumTrackingId == album.trackingId)
              .toList();

          final isAlbumCurrent = playerState.currentSong != null &&
              songsOfAlbum.any((s) =>
                  s.trackingId == playerState.currentSong!.trackingId);
          final isAlbumPlaying = isAlbumCurrent &&
              playerState.isPlaying &&
              !playerState.isPreviewOnly;

          final isLocked = album.isLocked && !isPremium;

          return _buildAlbumCard(
            context,
            ref,
            album: album,
            isPlaying: isAlbumPlaying,
            songsCount: songsOfAlbum.length,
            isLocked: isLocked,
            onPlayTap: () async {
              if (isLocked) return;
              if (songsOfAlbum.isEmpty) return;
              if (isAlbumCurrent && !playerState.isPreviewOnly) {
                ref.read(playerProvider.notifier).togglePlayPause();
              } else {
                await ref.read(playerProvider.notifier).playSongInPlaylist(
                      song: songsOfAlbum.first,
                      playlist: songsOfAlbum,
                      album: album,
                    );
                if (context.mounted) context.push('/music_page');
              }
            },
            onImageTap: () {
              if (isLocked) return;
              if (songsOfAlbum.isEmpty) return;
              ref.read(playerProvider.notifier).previewSong(
                    song: songsOfAlbum.first,
                    playlist: songsOfAlbum,
                    album: album,
                  );
              if (context.mounted) context.push('/music_page');
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CARTE D'ALBUM
  // ─────────────────────────────────────────────────────────
  Widget _buildAlbumCard(
    BuildContext context,
    WidgetRef ref, {
    required AlbumEntity album,
    required bool isPlaying,
    required int songsCount,
    required bool isLocked,
    required VoidCallback onPlayTap,
    required VoidCallback onImageTap,
  }) {
    return SizedBox(
      width: 150.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⭐ Image avec léger flou si verrouillé
          GestureDetector(
            onTap: isLocked ? null : onImageTap,
            child: VipBlurWrapper(
              isLocked: isLocked,
              borderRadius: 16,
              blurAmount: 1.5,
              showBigBadge: true,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.network(
                      album.imageAlbum,
                      width: 150.w,
                      height: 150.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        width: 150.w,
                        height: 150.h,
                        color: Colors.grey.shade300,
                        child: Icon(Icons.music_note,
                            size: 40.sp, color: Colors.white),
                      ),
                    ),
                  ),
                  // Bouton play (masqué si verrouillé)
                  if (!isLocked)
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: onPlayTap,
                        child: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: primaryOrange,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  // Badge "NOUVEAU"
                  if (album.isNew && !isLocked)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: primaryOrange,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text('NOUVEAU',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            album.titreAlbum,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.grey.shade600 : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            album.nomArtiste,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                '$songsCount chanson${songsCount > 1 ? "s" : ""}',
                style: TextStyle(
                    fontSize: 10.sp, color: Colors.grey.shade500),
              ),
              SizedBox(width: 6.w),
              if (!isLocked)
                GestureDetector(
                  onTap: () => _openArtistFromAlbum(context, ref, album),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Visiter',
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: primaryOrange,
                              fontWeight: FontWeight.w600)),
                      Icon(Icons.arrow_forward_ios,
                          size: 8.sp, color: primaryOrange),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Icon(Icons.lock,
                        size: 10.sp, color: primaryOrange),
                    SizedBox(width: 2.w),
                    Text('Verrouillé',
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: primaryOrange,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // VIDEO / ARTISTS / PODCASTS
  // ─────────────────────────────────────────────────────────
  Widget _buildVideoSection(BuildContext context) => SizedBox.shrink();
  Widget _buildArtistsSection(BuildContext context) => SizedBox.shrink();
  Widget _buildPodcastsSection(BuildContext context) => SizedBox.shrink();

  // ─────────────────────────────────────────────────────────
  // PLAYLIST — ⭐ FIX : verrouillage strict via albumTrackingId
  // ─────────────────────────────────────────────────────────
  Widget _buildPlaylistSection(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicNotifierProvider);
    final playerState = ref.watch(playerProvider);
    final durationState = ref.watch(durationCacheProvider);
    final isPremium =
        ref.watch(profileNotifierProvider).user?.isPremium ?? false;
    final songs = musicState.allSongs;

    if (songs.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Text(
          'Aucune chanson disponible',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Playlist',
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    _buildPlaylistSubtitle(
                        playerState, durationState, songs),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/music_page'),
                child: Text('Voir Plus',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final isCurrent = playerState.isCurrentSong(song);
              final isPlaying = isCurrent &&
                  playerState.isPlaying &&
                  !playerState.isPreviewOnly;

              final album = _findAlbumForSong(musicState.albums, song);

              // ⭐ FIX : verrouillage STRICT (pas de fallback artiste)
              final isLocked = _isSongLockedStrict(
                    song: song,
                    albums: musicState.albums,
                    isPremium: isPremium,
                  );

              final Duration? displayDuration =
                  isCurrent && playerState.duration > Duration.zero
                      ? playerState.duration
                      : durationState.getOf(song.trackingId);

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    // ⭐ Miniature avec petit cadenas seulement
                    GestureDetector(
                      onTap: () {
                        if (isLocked) {
                          _showPremiumDialog(context);
                          return;
                        }
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
                                album: album,
                              );
                        }
                      },
                      child: SmallLockOverlay(
                        isLocked: isLocked,
                        borderRadius: 10,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: album != null
                                  ? Image.network(
                                      album.imageAlbum,
                                      width: 50.w,
                                      height: 50.h,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _placeholder(50),
                                    )
                                  : _placeholder(50),
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
                                  size: 20.sp,
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
                          Text(
                            song.titre,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: isLocked
                                  ? Colors.grey.shade600
                                  : (isCurrent
                                      ? primaryOrange
                                      : Colors.black87),
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        _formatDuration(displayDuration),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: isCurrent
                              ? primaryOrange
                              : Colors.grey.shade500,
                        ),
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
                        child: Icon(
                          Icons.lock,
                          size: 20.sp,
                          color: primaryOrange,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // SOUS-TITRE PLAYLIST
  // ─────────────────────────────────────────────────────────
  Widget _buildPlaylistSubtitle(
    PlayerState playerState,
    DurationCacheState durationState,
    List<SongEntity> songs,
  ) {
    final total = durationState.totalOf(songs);
    final known = durationState.knownCountOf(songs);
    final totalSongs = songs.length;

    final isThisPlaylistPlaying =
        playerState.uiPlaylist.length == songs.length &&
            playerState.currentSong != null &&
            songs.any((s) =>
                s.trackingId == playerState.currentSong!.trackingId);

    if (isThisPlaylistPlaying && playerState.duration > Duration.zero) {
      return Text(
        '${_formatTotalDuration(playerState.position)} / '
        '${_formatTotalDuration(total)}',
        style: TextStyle(
          fontSize: 12.sp,
          color: primaryOrange,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (known == 0) {
      return Row(
        children: [
          SizedBox(
            width: 10.w,
            height: 10.h,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: primaryOrange,
            ),
          ),
          SizedBox(width: 6.w),
          Text('Calcul des durées...',
              style: TextStyle(
                  fontSize: 12.sp, color: Colors.grey.shade500)),
        ],
      );
    }

    if (durationState.isLoading) {
      return Row(
        children: [
          Text('$totalSongs chansons • ',
              style: TextStyle(
                  fontSize: 12.sp, color: Colors.grey.shade600)),
          Text(_formatTotalDuration(total),
              style: TextStyle(
                  fontSize: 12.sp,
                  color: primaryOrange,
                  fontWeight: FontWeight.w600)),
          SizedBox(width: 6.w),
          SizedBox(
            width: 10.w,
            height: 10.h,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: primaryOrange,
            ),
          ),
        ],
      );
    }

    return Text(
      '$totalSongs chanson${totalSongs > 1 ? "s" : ""} • '
      '${_formatTotalDuration(total)}',
      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Ouvrir ArtistAlbumPage
  // ─────────────────────────────────────────────────────────
  Future<void> _openArtistFromAlbum(
    BuildContext context,
    WidgetRef ref,
    AlbumEntity album,
  ) async {
    final musicState = ref.read(musicNotifierProvider);
    if (musicState.albums.isEmpty) return;

    await ref.read(artistProvider.notifier).loadFromAlbum(
          tappedAlbum: album,
          allAlbums: musicState.albums,
          allSongs: musicState.allSongs,
        );

    if (context.mounted) {
      context.push('/artist_album');
    }
  }

  void _showPremiumDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Padding(
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
            Text('Contenu Premium',
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: 8.h),
            Text(
              'Débloquez cette chanson en passant en Premium.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                  height: 1.5),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/settings');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Text('Passer en Premium',
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Plus tard',
                  style: TextStyle(
                      fontSize: 14.sp, color: Colors.grey.shade600)),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BOTTOM NAV
  // ─────────────────────────────────────────────────────────
  Widget _buildBottomNavBar(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: 60.h + (bottomPadding > 0 ? 8.h : 0),
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 4.h : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Accueil', true, () {}),
          _buildNavItem(Icons.explore_outlined, 'Explorer', false,
              () => context.go('/playlists_page')),
          _buildNavItem(Icons.favorite_border, 'Favoris', false,
              () => context.push('/favorites')),
          _buildNavItem(Icons.person_outline, 'Profile', false,
              () => context.push('/profile')),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isSelected ? primaryOrange : Colors.grey.shade400,
              size: 26.sp),
          SizedBox(height: 4.h),
          Text(label,
              style: TextStyle(
                color: isSelected ? primaryOrange : Colors.grey.shade400,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════════════════

Widget _placeholder(double size) {
  return Container(
    width: size.w,
    height: size.h,
    color: Colors.grey.shade200,
    child: Icon(Icons.music_note, color: Colors.grey.shade500, size: 20.sp),
  );
}

/// Résolution de l'album d'une chanson (pour afficher la miniature)
AlbumEntity? _findAlbumForSong(List<AlbumEntity> albums, SongEntity song) {
  if (song.albumTrackingId != null && song.albumTrackingId!.isNotEmpty) {
    for (final a in albums) {
      if (a.trackingId == song.albumTrackingId) return a;
    }
  }
  try {
    return albums.firstWhere(
      (a) =>
          a.nomArtiste.toLowerCase().trim() ==
          song.artiste.toLowerCase().trim(),
    );
  } catch (_) {
    return null;
  }
}

/// ⭐ FIX : Verrouillage STRICT
/// Une chanson est verrouillée si :
/// 1. song.isVip == true (VIP direct)
/// 2. OU son albumTrackingId correspond à un album verrouillé
/// 
/// ⚠️ On n'utilise PAS le fallback "artiste" pour déterminer le verrouillage
bool _isSongLockedStrict({
  required SongEntity song,
  required List<AlbumEntity> albums,
  required bool isPremium,
}) {
  if (isPremium) return false;
  if (song.isVip) return true;

  // Verrouillage uniquement si albumTrackingId est explicite
  if (song.albumTrackingId == null ||
      song.albumTrackingId!.isEmpty) {
    return false; // Pas d'album → pas verrouillé par défaut
  }

  try {
    final album = albums.firstWhere(
      (a) => a.trackingId == song.albumTrackingId,
    );
    return album.isLocked;
  } catch (_) {
    return false;
  }
}

String _formatDuration(Duration? duration) {
  if (duration == null || duration == Duration.zero) return '--:--';
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String _formatTotalDuration(Duration duration) {
  if (duration == Duration.zero) return '0:00';

  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  final seconds = duration.inSeconds % 60;

  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}