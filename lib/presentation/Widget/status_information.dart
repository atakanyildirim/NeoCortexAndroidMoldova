import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/presentation/Widget/v1widget.dart';

durumBilgileriBaslik(context) {
  return baslikGetir(baslik: AppLocalizations.of(context)!.durumBilgileri);
}

Widget durumBilgileriListe(context, reports) {
  if (reports != null && reports != "") {
    reports = jsonDecode(reports);
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: GridView.count(
        childAspectRatio: ((MediaQuery.of(context).size.width - 16) / 2) / 200,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        children: [
          durumBilgileriDondur(
              baslik: AppLocalizations.of(context)!.bulunurluk,
              text: reports != null
                  ? reports["Content"]["1"]["periodic_results"]["this_months_periodic_results"]
                              ["planogram_availability_score"]
                          .toString() +
                      "%"
                  : "",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              color: anaRenk.withGreen(reports != null
                  ? reports["Content"]["1"]["periodic_results"]["this_months_periodic_results"]
                      ["planogram_availability_score"]
                  : 0),
              percent: reports != null
                  ? reports["Content"]["1"]["periodic_results"]["this_months_periodic_results"]
                          ["planogram_availability_score"] /
                      100
                  : 0.00,
              lineWidth: 15.0,
              radius: 60.0),
          durumBilgileriDondur(
              baslik: AppLocalizations.of(context)!.planogram,
              text: reports != null
                  ? reports["Content"]["1"]["periodic_results"]["this_months_periodic_results"]
                              ["planogram_realization_score"]
                          .toString() +
                      "%"
                  : "",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              color: anaRenk.withGreen(reports != null
                  ? reports["Content"]["1"]["periodic_results"]["this_months_periodic_results"]
                      ["planogram_realization_score"]
                  : 0),
              percent: reports != null
                  ? reports["Content"]["1"]["periodic_results"]["this_months_periodic_results"]
                          ["planogram_realization_score"] /
                      100
                  : 0.00,
              lineWidth: 15.0,
              radius: 60.0),
          durumBilgileriDondur(
              baslik: AppLocalizations.of(context)!.mustHave,
              text: reports != null
                  ? reports["Content"]["1"]["periodic_results"]["this_months_periodic_results"]["drink_musthave_score"]
                          .toString() +
                      "%"
                  : "",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              color: anaRenk.withGreen(reports != null
                  ? reports["Content"]["1"]["periodic_results"]["this_months_periodic_results"]["drink_musthave_score"]
                  : 0),
              percent: reports != null
                  ? reports["Content"]["1"]["periodic_results"]["this_months_periodic_results"]
                          ["drink_musthave_score"] /
                      100
                  : 0.00,
              lineWidth: 15.0,
              radius: 60.0),
          durumBilgileriDondur(
              baslik: AppLocalizations.of(context)!.gelisim,
              text: reports != null
                  ? reports["Content"]["1"]["periodic_results"]["this_months_periodic_results"]["shelf_share_score"]
                          .toString() +
                      "%"
                  : "",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              color: anaRenk.withGreen(reports != null
                  ? reports["Content"]["1"]["periodic_results"]["this_months_periodic_results"]["shelf_share_score"]
                  : 0),
              percent: reports != null
                  ? reports["Content"]["1"]["periodic_results"]["this_months_periodic_results"]["shelf_share_score"] /
                      100
                  : 0.00,
              lineWidth: 15.0,
              radius: 60.0),
        ],
      ),
    );
  } else {
    return const CircularProgressIndicator();
  }
}

Widget durumBilgileriDondur({
  String baslik = "",
  String text = "",
  TextStyle style = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
  Color color = Colors.red,
  double percent = 0,
  double radius = 0,
  double lineWidth = 0,
}) {
  return defaultBox(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Text(baslik),
        ),
        circularIndicator(
            text: text, style: style, color: color, percent: percent, lineWidth: lineWidth, radius: radius),
      ],
    ),
  );
}
