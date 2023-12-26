import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyRepository {
  static Future<String> getSurveys() async {
    AuthenticateManager authenticateManager = AuthenticateManager();
    await authenticateManager.init();
    
    final response = await http.post(Uri.parse("https://labelmd.neocortexs.com/servis"),
        body: <String, String>{"username": "ozan.kocer.rest_user","project_id" : authenticateManager.getProjectId()!, "password": "#Z825!/8;Sz4g*r(", "servis": "anket"});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('error');
    }
  }

  static Future postSurvey(String sonuc, String musteriKodu, List<dynamic> images, context) async {
    AuthenticateManager authenticateManager = AuthenticateManager();
    await authenticateManager.init();

    var request = http.MultipartRequest("POST", Uri.parse("https://nosimia.com.tr/efes/anketsonucugonder"));
    request.fields['username'] = 'ozan.kocer.rest_user';
    request.fields['password'] = '#Z825!/8;Sz4g*r(';
    request.fields['project_id'] = authenticateManager.getProjectId()!;
    request.fields['sonuc'] = sonuc;
    request.fields['musteri_kodu'] = musteriKodu;

    for (var i = 0; i < images.length; i++) {
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath('resimler[]', images[i]);
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    var baslik = "";
    var msg = "";
    var icon;

    if (jsonDecode(response.body)["status"] == 200) {
      baslik = AppLocalizations.of(context)!.basarili;
      msg = AppLocalizations.of(context)!.anketBasariliGonderildi;
      icon = const Icon(
        Icons.check,
        color: Colors.green,
      );
    } else {
      baslik = AppLocalizations.of(context)!.hata;
      msg = jsonDecode(response.body)["message"];
      icon = const Icon(
        Icons.close,
        color: Colors.red,
      );
    }

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(baslik),
            titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
            actionsOverflowButtonSpacing: 20,
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.devamEt)),
            ],
            content: Row(
              children: [
                icon,
                const SizedBox(
                  width: 5,
                ),
                Text(msg),
              ],
            ),
          );
        });
  }
}
