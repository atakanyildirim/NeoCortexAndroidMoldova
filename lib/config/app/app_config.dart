import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

bool isDebugModeBanner = false;

String appTitle = "NeoCortex";
String baseApiUrl = "https://efesmd.neocortexbe.com";
int projectId = 1; // Burası iptal tokenden ilk proje_id bilgisi alındı.

Locale appLocale = const Locale("tr");

var supportedLocales = const [Locale("en"), Locale("tr"), Locale("kk"), Locale("ka"), Locale("ru"), Locale("ro")];

var localizationsDelegates = const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
