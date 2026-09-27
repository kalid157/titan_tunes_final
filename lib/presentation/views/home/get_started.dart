import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
/// Écran d'accueil (Get Started) de l'application Tunes.
/// 
/// Cet écran respecte l'architecture propre en séparant la logique UI 
/// en sous-widgets privés pour une meilleure lisibilité et maintenabilité.
class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  // TODO: Remplacer par la couleur exacte de votre AppTheme (app_theme.dart)
  static const Color primaryOrange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Image de fond
          _buildBackgroundImage(),

          // 2. Dégradé sombre pour la lisibilité du texte
          _buildDarkGradientOverlay(),

          // 3. Contenu principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Logo en haut
                  _buildLogo(),
                  
                  const Spacer(),
                  
                  // Textes principaux
                  _buildTitle(),
                  const SizedBox(height: 16),
                  _buildSubtitle(),
                  
                  const SizedBox(height: 40),
                  
                  // Bouton d'action
                  _buildGetStartedButton(context),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit l'image de fond couvrant tout l'écran.
  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/titanWoman1.png', // À ajouter dans pubspec.yaml
        fit: BoxFit.cover,
      ),
    );
  }

  /// Construit l'overlay dégradé (transparent vers noir).
  Widget _buildDarkGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.95),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  /// Construit le logo "Tunes".
  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: primaryOrange,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.music_note_rounded,
            color: Colors.black,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Tunes',
          style: TextStyle(
            color: primaryOrange,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  /// Construit le titre principal.
  Widget _buildTitle() {
    return const Text(
      'Enjoy Listening To Music',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
    );
  }

  /// Construit le sous-titre.
  Widget _buildSubtitle() {
    return Text(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sagittis enim purus sed phasellus. Cursus ornare id scelerisque aliquam.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  /// Construit le bouton "Commencez".
  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Naviguer vers l'écran de login (ex: via GoRouter ou Navigator)
          // Exemple: context.go('/login');
           //Navigator.pushNamed(context, '/choose_mode'); // Remplacez par la route appropriée
            context.push('/choose_mode');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Commencez',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}