import 'package:flutter/material.dart';

const anaRenk = Color.fromARGB(255, 29, 73, 134);
const anaRenkLight = Color.fromARGB(255, 72, 108, 158);
const anaAcikRenk = Color.fromARGB(255, 208, 218, 233);
const inputBackgroundColor = Color.fromARGB(255, 234, 234, 234);
const anasayfaKonumBoxBorder = Color(0xffFDD37C);

ThemeData getThemeConfig(BuildContext context) {
  return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: false,
      textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 0.8, fontFamily: 'Montserrat'));
}
