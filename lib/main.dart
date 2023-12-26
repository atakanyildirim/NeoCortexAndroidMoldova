import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/presentation/pages/tutorial_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black.withOpacity(0.02),
    ),
  );
  runApp(const NeoCortexApp());
}

class NeoCortexApp extends StatelessWidget {
  const NeoCortexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: isDebugModeBanner,
      theme: getThemeConfig(context),
      //locale: appLocale, // Default olarak dil set eden kod bu aktif olursa sürekli buradaki dil çıkar
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationsDelegates,
      home: const TutorialPage(),
    );
  }
}
