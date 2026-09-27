import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:titan_tunes/domaine/entities/playlist_entity.dart';
import 'package:titan_tunes/presentation/notifiers/playlist_notifier.dart';
import 'package:titan_tunes/presentation/state/artist_state.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/mini_player_widget.dart';
import 'package:titan_tunes/provider/music_providers.dart';

class PlaylistsPage extends ConsumerStatefulWidget {
  const PlaylistsPage({super.key});

  @override
  ConsumerState<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends ConsumerState<PlaylistsPage> {
  static const Color primaryOrange = Color(0xFFFF8A00);
  static const Color backgroundGrey = Color(0xFFF8F9FA);

  @override
void initState() {
  super.initState();
  Future.microtask(() {
    ref.read(playlistNotifierProvider.notifier).loadAll();
  });
}

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistNotifierProvider);

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopTabs(state),
            _buildSubTabs(state),
            SizedBox(height: 8.h),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? _buildError(state.error!)
                      : _buildPlaylistList(state),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerWidget(),
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ONGLETS PRINCIPAUX (Musica / Podcasts)
  // ══════════════════════════════════════════════════════════
  Widget _buildTopTabs(PlaylistState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Música',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: state.mainTab == MusicTab.music
                    ? primaryOrange
                    : Colors.grey.shade300,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => ref
                  .read(playlistNotifierProvider.notifier)
                  .setMainTab(MusicTab.podcasts),
              child: Text(
                'Podcasts',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: state.mainTab == MusicTab.podcasts
                      ? Colors.black87
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert,
                size: 22.sp, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SOUS-ONGLETS (Playlists / Artistes / Álbumes)
  // ══════════════════════════════════════════════════════════
  Widget _buildSubTabs(PlaylistState state) {
    final tabs = [
      {'type': MusicSubTab.playlists, 'label': 'Playlists'},
      {'type': MusicSubTab.artists, 'label': 'Artistes'},
      {'type': MusicSubTab.albums, 'label': 'Álbumes'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: tabs.map((tab) {
          final tabType = tab['type'] as MusicSubTab;
          final isSelected = tabType == state.subTab;

          return Padding(
            padding: EdgeInsets.only(right: 24.w),
            child: GestureDetector(
              onTap: () => ref
                  .read(playlistNotifierProvider.notifier)
                  .setSubTab(tabType),
              child: Column(
                children: [
                  Text(
                    tab['label'] as String,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? primaryOrange
                          : Colors.grey.shade400,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      height: 2.h,
                      width: 30.w,
                      color: primaryOrange,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // LISTE DES PLAYLISTS
  // ══════════════════════════════════════════════════════════
 Widget _buildPlaylistList(PlaylistState state) {
  final items = state.displayedItems;

  if (items.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_play,
              size: 60.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            state.subTab == MusicSubTab.playlists
                ? 'Aucune playlist disponible'
                : state.subTab == MusicSubTab.albums
                    ? 'Aucun album disponible'
                    : 'Aucun artiste disponible',
            style: TextStyle(
                fontSize: 14.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () async {
      await ref.read(playlistNotifierProvider.notifier).loadAll();
    },
    color: primaryOrange,
    child: ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildPlaylistItem(item);
      },
    ),
  );
}

  Widget _buildPlaylistItem(PlaylistEntity item) {
  return GestureDetector(
    onTap: () {
      // ⭐ Navigation selon le type
      switch (item.type) {
        case PlaylistType.liked:
          context.push('/favorites');
          break;

        case PlaylistType.album:
          // Ouvre la page artiste/album
          final musicState = ref.read(musicNotifierProvider);
          final album = musicState.albums.firstWhere(
            (a) => a.trackingId == item.id,
            orElse: () => throw StateError('Album introuvable'),
          );
          ref.read(artistProvider.notifier).loadFromAlbum(
                tappedAlbum: album,
                allAlbums: musicState.albums,
                allSongs: musicState.allSongs,
              );
          context.push('/artist_album');
          break;

        case PlaylistType.artist:
          // Ouvre la page artiste (premier album de cet artiste)
          final musicState = ref.read(musicNotifierProvider);
          final album = musicState.albums.firstWhere(
            (a) => a.nomArtiste == item.title,
            orElse: () => musicState.albums.first,
          );
          ref.read(artistProvider.notifier).loadFromAlbum(
                tappedAlbum: album,
                allAlbums: musicState.albums,
                allSongs: musicState.allSongs,
              );
          context.push('/artist_album');
          break;

        case PlaylistType.custom:
        default:
          // ⭐ Playlist utilisateur → ouvrir ses détails
          if (item.id == 'create_playlist') {
            debugPrint('Créer une playlist');
            // context.push('/create_playlist');
          } else {
            debugPrint('Ouvrir playlist: ${item.title}');
            // context.push('/playlist_detail', extra: item.id);
          }
      }
    },
    child: Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          // Miniature
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: item.type == PlaylistType.custom
                  ? Colors.black
                  : (item.type == PlaylistType.liked
                      ? const Color(0xFF1E1E1E)
                      : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: _buildCoverOrIcon(item),
          ),
          SizedBox(width: 14.w),

          // Titre + sous-titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    item.type == PlaylistType.album ||
                            item.type == PlaylistType.artist
                        ? 'de ${item.subtitle}'
                        : item.subtitle!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else if (item.songCount != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '${item.songCount} canciones',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  /// Image pour les albums, icône pour create/liked
  Widget _buildCoverOrIcon(PlaylistEntity item) {
    // Cas 1 : icône spéciale
    if (item.type == PlaylistType.custom && item.id == 'create_playlist') {
      return Center(
        child: Icon(Icons.add, color: Colors.white, size: 28.sp),
      );
    }
    if (item.type == PlaylistType.liked) {
      return Center(
        child: Icon(Icons.favorite,
            color: primaryOrange, size: 28.sp),
      );
    }

    // Cas 2 : image d'album
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: Image.network(
          item.imageUrl!,
          width: 56.w,
          height: 56.h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.album,
            color: Colors.white70,
            size: 28.sp,
          ),
        ),
      );
    }

    // Fallback
    return Icon(Icons.music_note, color: Colors.white70, size: 28.sp);
  }

  // ══════════════════════════════════════════════════════════
  // ERREUR
  // ══════════════════════════════════════════════════════════
  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 50.sp, color: Colors.redAccent),
            SizedBox(height: 12.h),
            Text(error,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13.sp, color: Colors.grey.shade700)),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                      ref.read(playlistNotifierProvider.notifier).loadAll();
                            },
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BOTTOM NAV
  // ══════════════════════════════════════════════════════════
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 70.h,
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
          _buildNavItem(Icons.home_outlined, 'Accueil', false,
              () => context.go('/home')),
          _buildNavItem(Icons.explore, 'Explorer', true, () {}),
          _buildNavItem(Icons.favorite_border, 'Favoris', false,
              () => context.push('/favorites')),
          _buildNavItem(Icons.person_outline, 'Profil', false,
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
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}