import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:titan_tunes/presentation/routes/go_router_provider.dart';
import 'package:titan_tunes/provider/payment_providers.dart';
import 'package:titan_tunes/themes/theme_provider.dart';

/// Clé publique Stripe TEST
const String kStripePublishableKey =
    'pk_test_51UIjo0GlT3iffOYGACUvxesd6ffwBTwW4Wy5Q1M0nhsCBSjHJd6eKG9djJrgCdjhpZMksT6jEofyNWnh7kIP1tGb00RSKUB2qD';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ═══════════════════════════════════════════════════════════
  // Init Stripe — UNIQUEMENT en mode stripe
  // ═══════════════════════════════════════════════════════════
  if (kPaymentMode == PaymentMode.stripe) {
    Stripe.publishableKey = kStripePublishableKey;
    await Stripe.instance.applySettings();
    debugPrint('💳 Stripe initialisé en mode production');
  } else {
    debugPrint('🧪 Payment mode: FAKE — Stripe désactivé');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Tunes',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          themeMode: themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF8A00),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF8A00),
              brightness: Brightness.dark,
            ),
          ),
        );
      },
    );
  }
}