import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppConfig {
  static bool isDebugModeBanner = false;

  // Firebaseden okunan alanlar
  static String appTitle = "NeoCortex";
  static String baseApiUrl = "https://efesmd.neocortexbe.com";
  static bool isInterrupt = true;
  static int dolap = 12;
  static int tabela = 5;
  static int teshir = 12;
  static int sicakRaf = 12;
  static String version = "1.0.0";
  static String apkUrl = "";

  // Buradaki değeri main methodunda aktif edersek cihazın kendi dili yerine aşağıdaki tanımlanan dil aktif eder
  static Locale appLocale = const Locale("tr");

  static var supportedLocales = const [
    Locale("en"),
    Locale("tr"),
    Locale("kk"),
    Locale("ka"),
    Locale("ru"),
    Locale("ro")
  ];

  static var localizationsDelegates = const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  static Future<FirebaseRemoteConfig> getRemoteConfig() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(seconds: 2),
    ));
    await remoteConfig.fetchAndActivate();
    setRemoteValues();
    return remoteConfig;
  }

  static void setRemoteValues() {
    appTitle = remoteConfig.getString("appTitle");
    baseApiUrl = remoteConfig.getString("baseApiUrlForEfes");
    isInterrupt = remoteConfig.getBool("InterruptProcess");
    dolap = remoteConfig.getInt("dolap");
    teshir = remoteConfig.getInt("teshir");
    tabela = remoteConfig.getInt("tabela");
    sicakRaf = remoteConfig.getInt("sicakRaf");
    version = remoteConfig.getString("appVersion");
    apkUrl = remoteConfig.getString("apkUrl");
  }
}
