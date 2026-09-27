import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:titan_tunes/presentation/views/auth/sign_in.dart';

/// Écran de choix d'authentification (Connexion / Inscription).
class AuthOptionsScreen extends StatelessWidget {
  const AuthOptionsScreen({super.key});

  // Couleur orange extraite de votre design
  static const Color primaryOrange = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fond légèrement gris clair
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Motif de fond (Optionnel - à remplacer par une image ou CustomPaint plus tard)
            // _buildBackgroundPattern(),

            // 2. Contenu principal
            Column(
              children: [
                // Bouton Retour
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          size: 16.sp,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          // Retour à l'écran précédent
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // Logo (Image PNG à remplacer)
                // TODO: Remplacez 'assets/images/logo.png' par le chemin de votre image
                Image.asset(
                  'assets/images/titan_orange_tunes_variante 1.png', 
                  height: 60.h,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback si l'image n'est pas encore ajoutée
                    return Icon(Icons.music_note, size: 60.sp, color: primaryOrange);
                  },
                ),

                SizedBox(height: 30.h),

                // Titre
                Text(
                  'Enjoy Listening To Music',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 16.h),

                // Sous-titre
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Text(
                    'Spotify is a proprietary Swedish audio streaming and media services provider',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // Boutons d'action (Connexion / Inscription)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      // Bouton "Se Connecter"
                      Expanded(
                        child: SizedBox(
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Naviguer vers l'écran de connexion
                              Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignIn(),
                        ),
                      );
                               //context.push('signin');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Se Connecter',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 16.w),
                      
                      // Bouton "S'enregistrer"
                      Expanded(
                        child: SizedBox(
                          height: 50.h,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Naviguer vers l'écran d'inscription
                               context.push('register');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "S'enregistrer",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Image du bas (Femme avec casque)
                // TODO: Remplacez par votre image PNG
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/images/woman.png', // À remplacer
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 210.h,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Text("Image de la femme ici", style: TextStyle(fontSize: 12.sp)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}