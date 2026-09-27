import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:titan_tunes/domaine/entities/user_profile_entity.dart';
import 'package:titan_tunes/presentation/notifiers/profile_notifier.dart';
import 'package:titan_tunes/presentation/notifiers/whats_new_notifier.dart';
import 'package:titan_tunes/provider/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  static const Color primaryOrange = Color(0xFFFF8A00);
  static const Color backgroundGrey = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    // ⭐ Charge le profil au démarrage avec le clientId réel
    Future.microtask(() {
      final clientId = ref.read(authNotifierProvider).user?.id ?? '';
      if (clientId.isNotEmpty) {
        ref.read(profileNotifierProvider.notifier).loadProfile(clientId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);
    final user = state.user;

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: user == null
            ? _buildLoading(state)
            : RefreshIndicator(
                onRefresh: () async {
                  final clientId =
                      ref.read(authNotifierProvider).user?.id ?? '';
                  await ref
                      .read(profileNotifierProvider.notifier)
                      .loadProfile(clientId);
                },
                color: primaryOrange,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildAppBar(),
                      // Bandeau de fallback (affiché uniquement si usingFallback)
                    if (state.usingFallback) _buildFallbackBanner(),
                    
                      _buildAvatarSection(user),
                      _buildStats(user),
                      SizedBox(height: 20.h),
                      _buildPlanCard(user),
                      SizedBox(height: 20.h),
                      _buildMenuItems(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // ─── LOADING / ERROR ─────────────────────────────────────
  Widget _buildLoading(ProfileState state) {
  // ⭐ Si l'utilisateur n'est pas encore chargé ET qu'il y a une erreur
  if (state.user == null && state.error != null) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50.sp, color: Colors.redAccent),
            SizedBox(height: 12.h),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () {
                final clientId =
                    ref.read(authNotifierProvider).user?.id ?? '';
                ref
                    .read(profileNotifierProvider.notifier)
                    .loadProfile(clientId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
  return const Center(child: CircularProgressIndicator());
}

  // ─── APP BAR ─────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  size: 16.sp, color: Colors.black87),
              onPressed: () => context.pop(),
            ),
          ),
          Text('Profile',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
          IconButton(
            icon: Icon(Icons.more_vert, size: 22.sp, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

    /// Bandeau affiché quand le profil vient des données du login (fallback)
Widget _buildFallbackBanner() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
    padding: EdgeInsets.all(10.r),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: Colors.orange.shade200),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline,
            size: 16.sp, color: Colors.orange.shade700),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'Profil affiché en mode hors-ligne (données du login)',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.orange.shade800,
            ),
          ),
        ),
      ],
    ),
  );
}

  // ─── AVATAR + EMAIL + NOM ────────────────────────────────
  Widget _buildAvatarSection(UserProfileEntity user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Cercles décoratifs
            ...List.generate(8, (i) {
              final angle = (i * 45) * 3.14159 / 180;
              return Positioned(
                left: 70.w + 50.w * _cos(angle),
                top: 50.h + 50.h * _sin(angle),
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6BCB77),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
            // Avatar
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
                border: Border.all(color: Colors.white, width: 4.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: ClipOval(
                child: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                    ? Image.network(
                        user.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.person,
                            size: 50.sp, color: Colors.grey),
                      )
                    : Icon(Icons.person, size: 50.sp, color: Colors.grey),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // ⭐ Email
        Text(
          user.email,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        SizedBox(height: 8.h),
        // ⭐ Nom complet (au lieu de username)
        Text(
          user.fullName,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ─── STATS ──────────────────────────────────────────────
  Widget _buildStats(UserProfileEntity user) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${user.publicPlaylists} public playlists',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            width: 1,
            height: 12.h,
            color: Colors.grey.shade400,
          ),
          Text('${user.following} following',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  // ─── CARTE PLAN ─────────────────────────────────────────
  Widget _buildPlanCard(UserProfileEntity user) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: () => context.push('/settings'),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: user.isPremium
                  ? [const Color(0xFFE89B00), const Color(0xFF8B5A00)]
                  : [const Color(0xFFE8A23F), const Color(0xFF3D2A0F)],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Current Plan',
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.9))),
                  Icon(
                    user.isPremium
                        ? Icons.workspace_premium
                        : Icons.star_border,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(user.planLabel,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
              SizedBox(height: 4.h),
              Text('\$${user.monthlyPrice.toStringAsFixed(2)} / month',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.9))),
              if (!user.isPremium) ...[
                SizedBox(height: 12.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_upward,
                          size: 14.sp, color: primaryOrange),
                      SizedBox(width: 4.w),
                      Text('Passer en Premium',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: primaryOrange,
                          )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── MENU ────────────────────────────────────────────────
  Widget _buildMenuItems() {
    // ⭐ Compte les nouveautés non lues depuis whatsNewProvider
    final unreadCount = ref.watch(whatsNewProvider).unreadCount;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.history,
            label: 'Historique d\'écoute',
            onTap: () => context.push('/listening_history'),
          ),
          _buildMenuItem(
            icon: Icons.favorite_outline,
            label: 'Mes favoris',
            onTap: () => context.push('/favorites'),
          ),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            label: 'Settings and privacy',
            onTap: () => context.push('/settings'),
          ),
          _buildMenuItem(
            icon: Icons.notifications_none,
            label: "What's new",
            onTap: () => context.push('/notifications'),
            badge: unreadCount,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22.sp, color: Colors.black87),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
            ),
            if (badge > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: primaryOrange,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text('$badge',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_ios,
                size: 14.sp, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM NAV ─────────────────────────────────────────
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
          _buildNavItem(Icons.explore_outlined, 'Explorer', false,
              () => context.push('/music_page')),
          _buildNavItem(Icons.favorite_border, 'Favoris', false,
              () => context.push('/favorites')),
          _buildNavItem(Icons.person, 'Profil', true, () {}),
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

  // ─── UTILITAIRES ────────────────────────────────────────
  double _sin(double x) => (x - x * x * x / 6 + x * x * x * x * x / 120);
  double _cos(double x) => (1 - x * x / 2 + x * x * x * x / 24);
}