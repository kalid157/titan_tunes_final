import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:titan_tunes/presentation/notifiers/listening_history_notifier.dart';

class ListeningHistoryPage extends ConsumerWidget {
  const ListeningHistoryPage({super.key});

  static const Color primaryOrange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⭐ Nouveau provider dédié à l'historique
    final state = ref.watch(listeningHistoryProvider);
    final items = state.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18.sp, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Historique d\'écoute',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 22.sp, color: Colors.redAccent),
              onPressed: () => _confirmClear(context, ref),
            ),
        ],
      ),
      body: items.isEmpty ? _buildEmpty() : _buildList(items),
    );
  }

  // ══════════════════════════════════════════════════════════
  // LISTE
  // ══════════════════════════════════════════════════════════
  Widget _buildList(List<ListeningHistoryEntity> items) {
    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Miniature
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: item.albumImageUrl != null &&
                          item.albumImageUrl!.isNotEmpty
                      ? Image.network(
                          item.albumImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.music_note,
                            size: 22.sp,
                            color: Colors.grey,
                          ),
                        )
                      : Icon(Icons.music_note,
                          size: 22.sp, color: Colors.grey),
                ),
              ),
              SizedBox(width: 12.w),

              // Titre + artiste + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.songTitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.artist,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _fmtDate(item.listenedAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Bouton play
              Icon(Icons.play_arrow, color: primaryOrange, size: 24.sp),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════
  // ÉTAT VIDE
  // ══════════════════════════════════════════════════════════
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 60.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            'Aucun historique pour le moment',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // CONFIRMATION SUPPRESSION
  // ══════════════════════════════════════════════════════════
  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer l\'historique ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(listeningHistoryProvider.notifier).clear();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Effacer',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FORMAT DATE
  // ══════════════════════════════════════════════════════════
  String _fmtDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return '${d.day}/${d.month}/${d.year}';
  }
}