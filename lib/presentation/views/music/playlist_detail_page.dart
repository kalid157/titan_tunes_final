import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:titan_tunes/domaine/entities/playlist_entity.dart';
import 'package:titan_tunes/domaine/entities/song_entity.dart';
import 'package:titan_tunes/presentation/notifiers/player_notifier.dart';
import 'package:titan_tunes/presentation/notifiers/playlist_notifier.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/like_button_with_count.dart';
import 'package:titan_tunes/provider/auth_provider.dart';
import 'package:titan_tunes/provider/music_providers.dart';
import 'package:titan_tunes/provider/playlist_providers.dart';

class PlaylistDetailPage extends ConsumerStatefulWidget {
  final PlaylistEntity playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  ConsumerState<PlaylistDetailPage> createState() =>
      _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends ConsumerState<PlaylistDetailPage> {
  static const Color primaryOrange = Color(0xFFFF8A00);

  List<SongEntity> _playlistSongs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlaylistSongs();
  }

  Future<void> _loadPlaylistSongs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final songs = await ref
          .read(playlistRepositoryProvider)
          .getPlaylistSongs(widget.playlist.id);

      if (!mounted) return;
      setState(() {
        _playlistSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger les chansons';
        _isLoading = false;
      });
    }
  }

  // ⭐ Ouvre le sélecteur de songs
  Future<void> _openAddSongs() async {
    final musicState = ref.read(musicNotifierProvider);
    final allSongs = musicState.allSongs;

    // IDs des songs déjà dans la playlist
    final existingIds = _playlistSongs.map((s) => s.trackingId).toSet();

    final selected = await showModalBottomSheet<List<SongEntity>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SongPickerSheet(
        allSongs: allSongs,
        alreadyInPlaylist: existingIds,
      ),
    );

    if (selected == null || selected.isEmpty) return;

    // Ajoute les songs sélectionnées
    await _addSongs(selected);
  }

  Future<void> _addSongs(List<SongEntity> songs) async {
    final clientId = ref.read(authNotifierProvider).user?.id ?? '';
    if (clientId.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    int successCount = 0;

    for (final song in songs) {
      final ok = await ref.read(playlistNotifierProvider.notifier)
          .addSongToPlaylist(
            playlistId: widget.playlist.id,
            songId: song.trackingId,
          );
      if (ok) successCount++;
    }

    if (!mounted) return;
    Navigator.pop(context); // Ferme le loading

    if (successCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$successCount chanson${successCount > 1 ? "s" : ""} ajoutée${successCount > 1 ? "s" : ""} ✅'),
          backgroundColor: Colors.green,
        ),
      );
      _loadPlaylistSongs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur d\'ajout'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18.sp, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/playlists');
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert,
                size: 22.sp, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlaylistSongs,
        color: primaryOrange,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ─── HEADER ───
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),

            // ─── BOUTON AJOUTER ───
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: _openAddSongs,
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(
                      'Ajouter des chansons',
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 16.h)),

            // ─── LISTE DES SONGS ───
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_error != null)
              SliverToBoxAdapter(child: _buildError())
            else if (_playlistSongs.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildSongItem(_playlistSongs[index]),
                  childCount: _playlistSongs.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: widget.playlist.imageUrl != null &&
                      widget.playlist.imageUrl!.isNotEmpty
                  ? Image.network(
                      widget.playlist.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.playlist.title,
                  style: TextStyle(
                      fontSize: 20.sp, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Text(
                  '${_playlistSongs.length} chanson${_playlistSongs.length > 1 ? "s" : ""}',
                  style: TextStyle(
                      fontSize: 13.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.music_note,
          size: 40.sp, color: Colors.grey.shade500),
    );
  }

  Widget _buildSongItem(SongEntity song) {
    final playerState = ref.watch(playerProvider);
    final isCurrent = playerState.isCurrentSong(song);
    final isPlaying = isCurrent && playerState.isPlaying;

    return GestureDetector(
      onTap: () {
        ref.read(playerProvider.notifier).playSongInPlaylist(
              song: song,
              playlist: _playlistSongs,
            );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: isCurrent
              ? primaryOrange.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: isCurrent
                    ? primaryOrange
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: isCurrent ? Colors.white : Colors.grey.shade700,
                size: 22.sp,
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
                      color: isCurrent ? primaryOrange : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    song.artiste,
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            LikeButtonWithCount(
              songTrackingId: song.trackingId,
              iconSize: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: EdgeInsets.all(40.r),
      child: Column(
        children: [
          Icon(Icons.library_music_outlined,
              size: 60.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            'Aucune chanson dans cette playlist',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Appuyez sur "Ajouter des chansons"',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: EdgeInsets.all(40.r),
      child: Column(
        children: [
          Icon(Icons.error_outline,
              size: 50.sp, color: Colors.redAccent),
          SizedBox(height: 12.h),
          Text(
            _error!,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadPlaylistSongs,
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SÉLECTEUR DE SONGS (Modal)
// ═══════════════════════════════════════════════════════════
class _SongPickerSheet extends StatefulWidget {
  final List<SongEntity> allSongs;
  final Set<String> alreadyInPlaylist;

  const _SongPickerSheet({
    required this.allSongs,
    required this.alreadyInPlaylist,
  });

  @override
  State<_SongPickerSheet> createState() => _SongPickerSheetState();
}

class _SongPickerSheetState extends State<_SongPickerSheet> {
  static const Color primaryOrange = Color(0xFFFF8A00);

  final Set<String> _selected = {};
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filtre : exclut les songs déjà dans la playlist + recherche
    final available = widget.allSongs
        .where((s) => !widget.alreadyInPlaylist.contains(s.trackingId))
        .where((s) =>
            _query.isEmpty ||
            s.titre.toLowerCase().contains(_query.toLowerCase()) ||
            s.artiste.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Barre
              Container(
                margin: EdgeInsets.only(top: 10.h),
                width: 50.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ajouter des chansons',
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_selected.length} sélectionnée${_selected.length > 1 ? "s" : ""}',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: primaryOrange,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Recherche
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        prefixIcon:
                            Icon(Icons.search, color: primaryOrange),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Liste
              Expanded(
                child: available.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: available.length,
                        itemBuilder: (context, index) {
                          final song = available[index];
                          final selected =
                              _selected.contains(song.trackingId);

                          return ListTile(
                            leading: Checkbox(
                              value: selected,
                              activeColor: primaryOrange,
                              onChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    _selected.add(song.trackingId);
                                  } else {
                                    _selected.remove(song.trackingId);
                                  }
                                });
                              },
                            ),
                            title: Text(
                              song.titre,
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artiste,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600),
                            ),
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selected.remove(song.trackingId);
                                } else {
                                  _selected.add(song.trackingId);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),

              // Bouton valider
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _selected.isEmpty
                          ? null
                          : () {
                              final selected = available
                                  .where((s) =>
                                      _selected.contains(s.trackingId))
                                  .toList();
                              Navigator.pop(context, selected);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                      ),
                      child: Text(
                        _selected.isEmpty
                            ? 'Sélectionnez des chansons'
                            : 'Ajouter ${_selected.length} chanson${_selected.length > 1 ? "s" : ""}',
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off_outlined,
              size: 50.sp, color: Colors.grey.shade400),
          SizedBox(height: 12.h),
          Text(
            _query.isEmpty
                ? 'Toutes les chansons sont déjà dans cette playlist'
                : 'Aucun résultat',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}