 import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildBottomNavBar(context);
  }

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
    var primaryOrange;
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