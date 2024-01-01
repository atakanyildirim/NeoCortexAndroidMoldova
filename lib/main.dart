import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/firebase_options.dart';
import 'package:neocortexapp/presentation/pages/tutorial_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black.withOpacity(0.02),
    ),
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppConfig.getRemoteConfig();

  runApp(const NeoCortexApp());
}

class NeoCortexApp extends StatelessWidget {
  const NeoCortexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: AppConfig.isDebugModeBanner,
      theme: getThemeConfig(context),
      //locale: appLocale, // Default olarak dil set eden kod bu aktif olursa sürekli buradaki dil çıkar
      supportedLocales: AppConfig.supportedLocales,
      localizationsDelegates: AppConfig.localizationsDelegates,
      home: const TutorialPage(),
    );
  }
}
