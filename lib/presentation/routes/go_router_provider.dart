import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titan_tunes/presentation/views/auth/auth_options.dart';
import 'package:titan_tunes/presentation/views/auth/register.dart';
import 'package:titan_tunes/presentation/views/auth/sign_in.dart';
import 'package:titan_tunes/presentation/views/home/artist_album_page.dart';
import 'package:titan_tunes/presentation/views/home/choose_mode.dart';
import 'package:titan_tunes/presentation/views/home/get_started.dart';
import 'package:titan_tunes/presentation/views/home/home_page.dart';
import 'package:titan_tunes/presentation/views/home/lyrics_page.dart';
import 'package:titan_tunes/presentation/views/home/music_page.dart';
import 'package:titan_tunes/presentation/views/music/playlists_page.dart';
import 'package:titan_tunes/presentation/views/profile/favorites_page.dart';
import 'package:titan_tunes/presentation/views/profile/listening_history_page.dart';
import 'package:titan_tunes/presentation/views/profile/notifications_page.dart';
import 'package:titan_tunes/presentation/views/profile/profile_page.dart';
import 'package:titan_tunes/presentation/views/profile/settings_page.dart';
// import 'package:titan/presentation/views/auth/login.dart';

final goRouterProvider = Provider<GoRouter>((ref) {

  
  return GoRouter(
    initialLocation: '/', // Point de départ
    debugLogDiagnostics: true,
    routes: [
      // Route pour GetStarted
      GoRoute(
        path: '/',
        name: 'getStarted',
        builder: (context, state) => const GetStartedScreen(),
      ),
      
      // Route pour ChooseMode (celle qui manque)
      
      GoRoute(path: '/choose_mode', builder: (context, state) => const ChooseModeScreen()),
      GoRoute(
        path: '/sign_in',                                    
        name: 'signIn',
        builder: (context, state) => const SignIn(),
      ),
      GoRoute(
        path: '/register',                                  
        builder: (context, state) => const Register(),
      ),


      // Exemple pour la suite (Login)
       GoRoute(
        path: '/auth_options',
         name: 'auth_options',
         builder: (context, state) => const AuthOptionsScreen(),
       ),

       GoRoute(
        path: '/register',
         name: 'register',
         builder: (context, state) => const Register(),
       ),
       GoRoute(
        path: '/sing_in',
         name: 'signin',
         builder: (context, state) => const SignIn(),
       ),

       GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        ),

        GoRoute(
          path: '/music_page',
          name: 'musicPage',
          builder: (context, state) => const MusicPage(),
),


        GoRoute(
          path: '/lyrics_page',
          name: 'lyricsPage',
          builder: (context, state) => const LyricsPage(),
        ),

        GoRoute(
          path: '/artist_album_page',
          name: 'artistAlbumpage',
          builder: (context, state) => const ArtistAlbumPage(),
        ),
        
          GoRoute(
            path: '/artist_album',         // ancienne route
            name: 'artistAlbum',
            builder: (context, state) => const ArtistAlbumPage(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
              ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/listening_history',
          name: 'listeningHistory',
          builder: (context, state) => const ListeningHistoryPage(),
        ),
        GoRoute(path: '/music_page', builder: (_, __) => const MusicPage()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        GoRoute(
          path: '/favorites',
          name: 'favorites',
          builder: (context, state) => const FavoritesPage(),
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsPage(),
        ),

        GoRoute(
          path: '/playlists_page',
          name: 'playlistspage',
          builder: (context, state) => const PlaylistsPage(),
        ),

        GoRoute(path: '/listening_history', builder: (_, __) => const ListeningHistoryPage()),
        //GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
        
    ],
  );
}
);