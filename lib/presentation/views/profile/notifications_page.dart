import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:titan_tunes/presentation/notifiers/whats_new_notifier.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  static const Color primaryOrange = Color(0xFFFF8A00);

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(whatsNewProvider.notifier).markAllRead());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whatsNewProvider);
    final songs = state.newSongs;
  
  if (!state.endpointAvailable && songs.isEmpty) {
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
        title: Text("What's new",
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off,
                size: 60.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text('Service bientôt disponible',
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
            SizedBox(height: 8.h),
            Text('Les nouveautés apparaîtront ici',
                style: TextStyle(
                    fontSize: 12.sp, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
  
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
        title: Text("What's new",
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ),
      body: songs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 60.sp, color: Colors.grey.shade400),
                  SizedBox(height: 16.h),
                  Text('Aucune nouveauté',
                      style: TextStyle(
                          fontSize: 14.sp, color: Colors.grey.shade600)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: primaryOrange.withOpacity(0.3), width: 1.w),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: primaryOrange.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.new_releases,
                            color: primaryOrange, size: 18.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nouvelle chanson',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: primaryOrange,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 4.h),
                            Text(song.titre,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            SizedBox(height: 2.h),
                            Text(song.artiste,
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      Icon(Icons.play_arrow,
                          color: primaryOrange, size: 24.sp),
                    ],
                  ),
                );
              },
            ),
    );
  }
}