import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:titan_tunes/themes/theme_provider.dart';

// Importez votre provider de thème ici
// import 'package:ton_app/presentation/provider/theme_provider.dart';

/// Écran de sélection du thème (Mode Sombre / Mode Clair).
/// 
/// Cet écran utilise Riverpod pour modifier l'état global du thème de l'application.
class ChooseModeScreen extends ConsumerWidget {
  const ChooseModeScreen({super.key});

  static const Color primaryOrange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute le thème actuel pour savoir quel bouton est sélectionné
    // Remplacez ceci par votre provider réel : ref.watch(themeModeProvider)
    final currentThemeMode = ref.watch(themeModeProvider); 

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Image de fond
          _buildBackgroundImage(),

          // 2. Dégradé sombre
          _buildDarkGradientOverlay(),

          // 3. Contenu principal
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  // Logo
                  _buildLogo(),
                  
                  const Spacer(),

                  // Titre
                  Text(
                    'Choose Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  SizedBox(height: 40.h),

                  // Boutons de sélection de thème
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeSelector(
                        context: context,
                        title: 'Dark Mode',
                        icon: Icons.dark_mode_rounded,
                        isSelected: currentThemeMode == ThemeMode.dark,
                        onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark),
                      ),
                      SizedBox(width: 40.w),
                      _buildModeSelector(
                        context: context,
                        title: 'Light Mode',
                        icon: Icons.light_mode_rounded,
                        isSelected: currentThemeMode == ThemeMode.light,
                        onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bouton Continuez
                  _buildContinueButton(context),
                  
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit l'image de fond
  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/titanWoman2.png', // Même image que le GetStarted
        fit: BoxFit.cover,
      ),
    );
  }

  /// Construit l'overlay dégradé
  Widget _buildDarkGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.95),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  /// Logo Tunes
  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: const BoxDecoration(
            color: primaryOrange,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.music_note_rounded,
            color: Colors.black,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 8.w),
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
    );
  }

  /// Bouton de sélection de mode (Dark/Light)
  Widget _buildModeSelector({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Couleurs basées sur la sélection
    final Color iconColor = isSelected ? Colors.white : Colors.white54;
    final Color circleColor = isSelected 
        ? primaryOrange.withOpacity(0.2) 
        : Colors.white.withOpacity(0.05);
    final Color borderColor = isSelected ? primaryOrange : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 2.w,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton "Continuez"
  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Naviguer vers l'écran suivant (ex: Login ou Home)
         context.push('/auth_options');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: Text(
          'Continuez',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}