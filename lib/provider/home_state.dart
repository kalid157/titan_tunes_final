import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum des onglets disponibles sur l'écran d'accueil
enum HomeTab { news, video, artists, podcasts }

/// Provider qui gère l'onglet actuellement sélectionné
final selectedTabProvider = NotifierProvider<SelectedTabNotifier, HomeTab>(() {
  return SelectedTabNotifier();
});

class SelectedTabNotifier extends Notifier<HomeTab> {
  @override
  HomeTab build() => HomeTab.news; // Par défaut : News

  void selectTab(HomeTab tab) {
    state = tab;
  }
}