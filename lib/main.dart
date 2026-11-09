import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/auth/presentation/controllers/auth_session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final container = ProviderContainer();
  // Restore the session before the first frame, so a relaunch opens Home
  // (signed in) or Onboarding (signed out) without a flash.
  await container.read(authSessionProvider.notifier).restore();
  runApp(UncontrolledProviderScope(container: container, child: const JDonutsApp()));
}
