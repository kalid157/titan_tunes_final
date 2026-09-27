import 'package:connectivity_plus/connectivity_plus.dart';

/// Service qui vérifie l'état de la connexion internet.
/// Utilisé par les DataSources pour éviter de lancer une requête inutile.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Retourne `true` si une connexion est disponible (wifi, mobile, ethernet...)
  Future<bool> hasConnection() async {
    final List<ConnectivityResult> results =
        await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  /// Écoute en temps réel les changements de connectivité
  Stream<bool> onConnectivityChanged() {
    return _connectivity.onConnectivityChanged.map(
      (results) => !results.contains(ConnectivityResult.none),
    );
  }
}