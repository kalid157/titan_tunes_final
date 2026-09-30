/// Toutes les URLs de l'API Titan Tunes.
/// Un seul endroit à modifier si le backend change d'adresse.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';

class AppEndpoint {
  AppEndpoint._(); // Empêche l'instanciation

  // ═══════════════════════════════════════════════════════════
  //  SWITCH DE TEST — Change UNE SEULE ligne selon le besoin
  // ═══════════════════════════════════════════════════════════

  // Émulateur Android  → 'emulator'
  // Téléphone physique → 'physical'
  // Web / iOS simulator → 'local'

  static const String _testMode = 'emulator'; // ⬅ CHANGE ICI

  //  Ton IP locale (pour téléphone physique)
  // Trouve-la avec : hostname -I
  static const String _localIp = '192.168.10.103'; // ⬅ CHANGE PAR TA VRAIE IP

  ///  URL de base — détectée automatiquement
  /*
  static String get baseUrl {
    // Override par ligne de commande : --dart-define=API_URL=http://...
    const override = String.fromEnvironment('API_URL');
    if (override.isNotEmpty) return override;

    // Mode forcé manuellement
    switch (_testMode) {
      case 'physical':
        return 'http://$_localIp:8081';
      case 'local':
        return 'http://localhost:8081';
      case 'emulator':
      default:
        if (kIsWeb) return 'http://localhost:8081';
        if (Platform.isAndroid) return 'http://10.0.2.2:8081';
        return 'http://localhost:8081';
    }
  }
  */

  /// URL de base (à remplacer par votre URL Swagger)
   //static const String baseUrl = 'http://192.168.10.103:8081';
  //static const String baseUrl = 'http://10.0.2.2:8081';

  static const String baseUrl = 'https://titan-tune-reset.onrender.com';

  // --- AUTH ---
  static const String login = '/user/login';
  static const String register = '/user/registerClient';
  
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // --- USER ---
  static String profile(String clientId) => '/user/profile/$clientId';
  //static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';

  
  // --- MUSIC ---
  static const String allAlbums = '/albums/all';
  static const String allSongs = '/song/getAll';
  static const String newSongs = '/song/new';
  static String songById(String id) => '/song/$id';

  // --- HISTORY ---
  static String listeningHistory(String clientId) => '/song/history/$clientId';
  static const String saveListening = '/song/history';  // POST

  // --- MUSIC ---
  static const String albums = '/albums';
  static const String songs = '/songs';
  static const String artists = '/artists';

  // ⭐ Songs d'un artiste
  static String songsByArtist(String artistId) =>
      '/song/getAllForOne/$artistId';

  /// ⭐ Songs d'un album (NOUVEAU — celui que tu m'as montré)
  static String songsByAlbum(String albumId) =>
      '/song/getByAlbum/$albumId';

  // --- PAYMENT ---
  static const String initPayment = '/payment/mobile-money/initiate';
  static const String confirmPayment = '/payment/mobile-money/confirm';
  static const String subscribePremium = '/subscription/premium';

// --- PLAYLISTS ---
static const String allPlaylists = '/playlist/all';


//  Quand disponible :
// static String songsByAlbum(String albumId) => '/song/getAllForAlbum/$albumId';

// --- PLAYLIST ---
//static const String allPlaylists = '/playlist/all';
static const String addPlaylist = '/playlist/add';
static const String addSongToPlaylist = '/playlist/addSong';
static const String addMultipleSongsToPlaylist = '/playlist/addSongs';

/// Détails d'une playlist
static String playlistDetails(String id) => '/playlist/$id';

/// Songs d'une playlist
static String playlistSongs(String id) => '/playlist/$id/songs';

/// Supprimer une playlist
static String deletePlaylist(String id) => '/playlist/$id';



// --- FAVORIS ---
static const String favoris = '/favoris';
  /// Timeout pour les requêtes HTTP
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}