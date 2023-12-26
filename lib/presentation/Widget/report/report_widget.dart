import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/entities/report.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

Widget reportWidget(TabController tabController, BuildContext context, Report? report, int selectedIndex) {
  return report == null
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : Container(
          color: Colors.white,
          child: Stack(
            children: [
              IndexedStack(
                index: selectedIndex,
                children: <Widget>[
                  Visibility(
                    visible: selectedIndex == 0,
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            /* Durum Bilgileri */
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                            child: Text(AppLocalizations.of(context)!.planogram),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 15.0,
                                            animation: true,
                                            percent: report.periodicResults!.todaysPeriodicResults!
                                                    .planogramRealizationScore! /
                                                100,
                                            center: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  (report.periodicResults!.todaysPeriodicResults!
                                                          .planogramRealizationScore!)
                                                      .toString(),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                ),
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: (report.periodicResults!.todaysPeriodicResults!
                                                                  .planogramRealizationScoreComparedToYesterday! <
                                                              0
                                                          ? const Color.fromARGB(255, 173, 42, 33)
                                                          : Colors.green),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    "${report.periodicResults!.todaysPeriodicResults!.planogramRealizationScoreComparedToYesterday!}% ${report.periodicResults!.todaysPeriodicResults!.planogramRealizationScoreComparedToYesterday! < 0 ? "▼" : "▲"}",
                                                  ),
                                                )
                                              ],
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: anaRenk.withGreen(report
                                                .periodicResults!.todaysPeriodicResults!.planogramRealizationScore!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                            child: Text(AppLocalizations.of(context)!.bulunurluk),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 15.0,
                                            animation: true,
                                            percent: report.periodicResults!.todaysPeriodicResults!
                                                    .planogramAvailabilityScore! /
                                                100,
                                            center: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${report.periodicResults!.todaysPeriodicResults!.planogramAvailabilityScore!}",
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                ),
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: (report.periodicResults!.todaysPeriodicResults!
                                                                  .planogramAvailabilityScoreComparedToYesterday! <
                                                              0
                                                          ? const Color.fromARGB(255, 173, 42, 33)
                                                          : Colors.green),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    "${report.periodicResults!.todaysPeriodicResults!.planogramAvailabilityScoreComparedToYesterday!}% ${report.periodicResults!.todaysPeriodicResults!.planogramAvailabilityScoreComparedToYesterday! < 0 ? "▼" : "▲"}",
                                                  ),
                                                )
                                              ],
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: anaRenk.withGreen(report
                                                .periodicResults!.todaysPeriodicResults!.planogramAvailabilityScore!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                            child: Text(AppLocalizations.of(context)!.mustHave),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 15.0,
                                            animation: true,
                                            percent:
                                                report.periodicResults!.todaysPeriodicResults!.drinkMusthaveScore! /
                                                    100,
                                            center: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  report.periodicResults!.todaysPeriodicResults!
                                                      .planogramAvailabilityScore!
                                                      .toString(),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                ),
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: (report.periodicResults!.todaysPeriodicResults!
                                                                  .drinkMusthaveScoreComparedToYesterday! <
                                                              0
                                                          ? const Color.fromARGB(255, 173, 42, 33)
                                                          : Colors.green),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    "${report.periodicResults!.todaysPeriodicResults!.drinkMusthaveScoreComparedToYesterday!}% ${report.periodicResults!.todaysPeriodicResults!.drinkMusthaveScoreComparedToYesterday! < 0 ? "▼" : "▲"}",
                                                  ),
                                                )
                                              ],
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: anaRenk.withGreen(
                                                report.periodicResults!.todaysPeriodicResults!.drinkMusthaveScore!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                            child: Text(AppLocalizations.of(context)!.gelisim),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 15.0,
                                            animation: true,
                                            percent:
                                                report.periodicResults!.todaysPeriodicResults!.shelfShareScore! / 100,
                                            center: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${report.periodicResults!.todaysPeriodicResults!.shelfShareScore!}",
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                ),
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: (report.periodicResults!.todaysPeriodicResults!
                                                                  .shelfShareScoreComparedToYesterday! <
                                                              0
                                                          ? const Color.fromARGB(255, 173, 42, 33)
                                                          : Colors.green),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    "${report.periodicResults!.todaysPeriodicResults!.shelfShareScoreComparedToYesterday!}% ${report.periodicResults!.todaysPeriodicResults!.shelfShareScoreComparedToYesterday! < 0 ? "▼" : "▲"}",
                                                  ),
                                                )
                                              ],
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: anaRenk.withGreen(
                                                report.periodicResults!.todaysPeriodicResults!.shelfShareScore!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            /* Durum Bilgileri */
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 14, left: 14, top: 15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: anaRenk,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: Text(AppLocalizations.of(context)!.ziyaret,
                                                style: const TextStyle(
                                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                                          ),
                                          Container(
                                            width: 150,
                                            height: 70,
                                            margin: const EdgeInsets.only(bottom: 10),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 13, 87, 148),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "${report.periodicResults!.todaysPeriodicResults!.visitedCustomers}",
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsetsDirectional.only(top: 5),
                                                        decoration: BoxDecoration(
                                                            color: (report.periodicResults!.todaysPeriodicResults!
                                                                        .visitedCustomersComparedToYesterday! <
                                                                    0
                                                                ? const Color.fromARGB(255, 173, 42, 33)
                                                                : Colors.green),
                                                            borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                        padding: const EdgeInsets.all(3),
                                                        child: Text(
                                                          style: const TextStyle(fontSize: 10, color: Colors.white),
                                                          "${report.periodicResults!.todaysPeriodicResults!.visitedCustomersComparedToYesterday!}% ${report.periodicResults!.todaysPeriodicResults!.visitedCustomersComparedToYesterday! < 0 ? "▼" : "▲"}",
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 14, left: 14, top: 15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: anaRenk,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: Text(AppLocalizations.of(context)!.fotograf,
                                                style: const TextStyle(
                                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                                          ),
                                          Container(
                                            width: 150,
                                            height: 70,
                                            margin: const EdgeInsets.only(bottom: 10),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 13, 87, 148),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "${report.periodicResults!.todaysPeriodicResults!.numberOfPhotos!}",
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsetsDirectional.only(top: 5),
                                                        decoration: BoxDecoration(
                                                            color: (report.periodicResults!.todaysPeriodicResults!
                                                                        .numberOfPhotosComparedToYesterday! <
                                                                    0
                                                                ? const Color.fromARGB(255, 173, 42, 33)
                                                                : Colors.green),
                                                            borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                        padding: const EdgeInsets.all(3),
                                                        child: Text(
                                                          style: const TextStyle(fontSize: 10, color: Colors.white),
                                                          "${report.periodicResults!.todaysPeriodicResults!.numberOfPhotosComparedToYesterday!}% ${report.periodicResults!.todaysPeriodicResults!.numberOfPhotosComparedToYesterday! < 0 ? "▼" : "▲"}",
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 250,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: selectedIndex == 1,
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            /* Durum Bilgileri */
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                            child: Text(AppLocalizations.of(context)!.planogram),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 15.0,
                                            animation: true,
                                            percent: report.periodicResults!.thisWeeksPeriodicResults!
                                                    .planogramRealizationScore! /
                                                100,
                                            center: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  report.periodicResults!.thisWeeksPeriodicResults!
                                                      .planogramRealizationScore!
                                                      .toString(),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                ),
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: (report.periodicResults!.thisWeeksPeriodicResults!
                                                                  .planogramRealizationScoreComparedToLastWeek! <
                                                              0
                                                          ? const Color.fromARGB(255, 173, 42, 33)
                                                          : Colors.green),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    "${report.periodicResults!.thisWeeksPeriodicResults!.planogramRealizationScoreComparedToLastWeek!}% ${report.periodicResults!.thisWeeksPeriodicResults!.planogramRealizationScoreComparedToLastWeek! < 0 ? "▼" : "▲"}",
                                                  ),
                                                )
                                              ],
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: anaRenk.withGreen(report
                                                .periodicResults!.thisWeeksPeriodicResults!.planogramRealizationScore!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                            child: Text(AppLocalizations.of(context)!.bulunurluk),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 15.0,
                                            animation: true,
                                            percent: report.periodicResults!.thisWeeksPeriodicResults!
                                                    .planogramAvailabilityScore! /
                                                100,
                                            center: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  report.periodicResults!.thisWeeksPeriodicResults!
                                                      .planogramAvailabilityScore!
                                                      .toString(),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                ),
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: (report.periodicResults!.thisWeeksPeriodicResults!
                                                                  .planogramAvailabilityScoreComparedToLastWeek! <
                                                              0
                                                          ? const Color.fromARGB(255, 173, 42, 33)
                                                          : Colors.green),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    "${report.periodicResults!.thisWeeksPeriodicResults!.planogramAvailabilityScoreComparedToLastWeek!}% ${report.periodicResults!.thisWeeksPeriodicResults!.planogramAvailabilityScoreComparedToLastWeek! < 0 ? "▼" : "▲"}",
                                                  ),
                                                )
                                              ],
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: anaRenk.withGreen(report.periodicResults!
                                                .thisWeeksPeriodicResults!.planogramAvailabilityScore!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                            child: Text(AppLocalizations.of(context)!.mustHave),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 15.0,
                                            animation: true,
                                            percent:
                                                report.periodicResults!.thisWeeksPeriodicResults!.drinkMusthaveScore! /
                                                    100,
                                            center: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  report.periodicResults!.thisWeeksPeriodicResults!.drinkMusthaveScore!
                                                      .toString(),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                ),
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: (report.periodicResults!.thisWeeksPeriodicResults!
                                                                  .drinkMusthaveScoreComparedToLastWeek! <
                                                              0
                                                          ? const Color.fromARGB(255, 173, 42, 33)
                                                          : Colors.green),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    "${report.periodicResults!.thisWeeksPeriodicResults!.drinkMusthaveScoreComparedToLastWeek!}% ${report.periodicResults!.thisWeeksPeriodicResults!.drinkMusthaveScoreComparedToLastWeek! < 0 ? "▼" : "▲"}",
                                                  ),
                                                )
                                              ],
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: anaRenk.withGreen(
                                                report.periodicResults!.thisWeeksPeriodicResults!.drinkMusthaveScore!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                            child: Text(AppLocalizations.of(context)!.gelisim),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 15.0,
                                            animation: true,
                                            percent:
                                                report.periodicResults!.thisWeeksPeriodicResults!.shelfShareScore! /
                                                    100,
                                            center: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  report.periodicResults!.thisWeeksPeriodicResults!.shelfShareScore!
                                                      .toString(),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                ),
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: (report.periodicResults!.thisWeeksPeriodicResults!
                                                                  .shelfShareScoreComparedToLastWeek! <
                                                              0
                                                          ? const Color.fromARGB(255, 173, 42, 33)
                                                          : Colors.green),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    "${report.periodicResults!.thisWeeksPeriodicResults!.shelfShareScoreComparedToLastWeek!}% ${report.periodicResults!.thisWeeksPeriodicResults!.shelfShareScoreComparedToLastWeek! < 0 ? "▼" : "▲"}",
                                                  ),
                                                )
                                              ],
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: anaRenk.withGreen(
                                                report.periodicResults!.thisWeeksPeriodicResults!.shelfShareScore!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            /* Durum Bilgileri */
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 14, left: 14, top: 15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: anaRenk,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: Text(AppLocalizations.of(context)!.ziyaret,
                                                style: const TextStyle(
                                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                                          ),
                                          Container(
                                            width: 150,
                                            height: 70,
                                            margin: const EdgeInsets.only(bottom: 10),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 13, 87, 148),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "${report.periodicResults!.thisWeeksPeriodicResults!.visitedCustomers!}",
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsetsDirectional.only(top: 5),
                                                        decoration: BoxDecoration(
                                                            color: (report.periodicResults!.thisWeeksPeriodicResults!
                                                                        .visitedCustomersComparedToLastWeek! <
                                                                    0
                                                                ? const Color.fromARGB(255, 173, 42, 33)
                                                                : Colors.green),
                                                            borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                        padding: const EdgeInsets.all(3),
                                                        child: Text(
                                                          style: const TextStyle(fontSize: 10, color: Colors.white),
                                                          "${report.periodicResults!.thisWeeksPeriodicResults!.visitedCustomersComparedToLastWeek!}% ${report.periodicResults!.thisWeeksPeriodicResults!.visitedCustomersComparedToLastWeek! < 0 ? "▼" : "▲"}",
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 14, left: 14, top: 15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: anaRenk,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: Text(AppLocalizations.of(context)!.fotograf,
                                                style: const TextStyle(
                                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                                          ),
                                          Container(
                                            width: 150,
                                            height: 70,
                                            margin: const EdgeInsets.only(bottom: 10),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 13, 87, 148),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "${report.periodicResults!.thisWeeksPeriodicResults!.numberOfPhotos!}",
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsetsDirectional.only(top: 5),
                                                        decoration: BoxDecoration(
                                                            color: (report.periodicResults!.thisWeeksPeriodicResults!
                                                                        .numberOfPhotosComparedToLastWeek! <
                                                                    0
                                                                ? const Color.fromARGB(255, 173, 42, 33)
                                                                : Colors.green),
                                                            borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                        padding: const EdgeInsets.all(3),
                                                        child: Text(
                                                          style: const TextStyle(fontSize: 10, color: Colors.white),
                                                          "${report.periodicResults!.thisWeeksPeriodicResults!.numberOfPhotosComparedToLastWeek!}% ${report.periodicResults!.thisWeeksPeriodicResults!.numberOfPhotosComparedToLastWeek! < 0 ? "▼" : "▲"}",
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 250,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: selectedIndex == 2,
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            /* Durum Bilgileri */
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                            child: Text(AppLocalizations.of(context)!.planogram),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 15.0,
                                            animation: true,
                                            percent: report.periodicResults!.thisMonthsPeriodicResults!
                                                    .planogramRealizationScore! /
                                                100,
                                            center: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  report.periodicResults!.thisMonthsPeriodicResults!
                                                      .planogramRealizationScore!
                                                      .toString(),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                ),
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: (report.periodicResults!.thisMonthsPeriodicResults!
                                                                  .planogramRealizationScoreComparedToLastMonth! <
                                                              0
                                                          ? const Color.fromARGB(255, 173, 42, 33)
                                                          : Colors.green),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    "${report.periodicResults!.thisMonthsPeriodicResults!.planogramRealizationScoreComparedToLastMonth!}% ${report.periodicResults!.thisMonthsPeriodicResults!.planogramRealizationScoreComparedToLastMonth! < 0 ? "▼" : "▲"}",
                                                  ),
                                                )
                                              ],
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: anaRenk.withGreen(report.periodicResults!
                                                .thisMonthsPeriodicResults!.planogramRealizationScore!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                            child: Text(AppLocalizations.of(context)!.bulunurluk),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 15.0,
                                            animation: true,
                                            percent: report.periodicResults!.thisMonthsPeriodicResults!
                                                    .planogramAvailabilityScore! /
                                                100,
                                            center: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  report.periodicResults!.thisMonthsPeriodicResults!
                                                      .planogramAvailabilityScore!
                                                      .toString(),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                ),
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: (report.periodicResults!.thisMonthsPeriodicResults!
                                                                  .planogramAvailabilityScoreComparedToLastMonth! <
                                                              0
                                                          ? const Color.fromARGB(255, 173, 42, 33)
                                                          : Colors.green),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    "${report.periodicResults!.thisMonthsPeriodicResults!.planogramAvailabilityScoreComparedToLastMonth!}% ${report.periodicResults!.thisMonthsPeriodicResults!.planogramAvailabilityScoreComparedToLastMonth! < 0 ? "▼" : "▲"}",
                                                  ),
                                                )
                                              ],
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: anaRenk.withGreen(report.periodicResults!
                                                .thisMonthsPeriodicResults!.planogramAvailabilityScore!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                            child: Text(AppLocalizations.of(context)!.mustHave),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 15.0,
                                            animation: true,
                                            percent:
                                                report.periodicResults!.thisMonthsPeriodicResults!.drinkMusthaveScore! /
                                                    100,
                                            center: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  report.periodicResults!.thisMonthsPeriodicResults!.drinkMusthaveScore!
                                                      .toString(),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                ),
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: (report.periodicResults!.thisMonthsPeriodicResults!
                                                                  .drinkMusthaveScoreComparedToLastMonth! <
                                                              0
                                                          ? const Color.fromARGB(255, 173, 42, 33)
                                                          : Colors.green),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    "${report.periodicResults!.thisMonthsPeriodicResults!.drinkMusthaveScoreComparedToLastMonth!}% ${report.periodicResults!.thisMonthsPeriodicResults!.drinkMusthaveScoreComparedToLastMonth! < 0 ? "▼" : "▲"}",
                                                  ),
                                                )
                                              ],
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: anaRenk.withGreen(
                                                report.periodicResults!.thisMonthsPeriodicResults!.drinkMusthaveScore!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                            child: Text(AppLocalizations.of(context)!.gelisim),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 15.0,
                                            animation: true,
                                            percent:
                                                report.periodicResults!.thisMonthsPeriodicResults!.shelfShareScore! /
                                                    100,
                                            center: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  report.periodicResults!.thisMonthsPeriodicResults!.shelfShareScore!
                                                      .toString(),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                ),
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(top: 5),
                                                  decoration: BoxDecoration(
                                                      color: (report.periodicResults!.thisMonthsPeriodicResults!
                                                                  .shelfShareScoreComparedToLastMonth! <
                                                              0
                                                          ? const Color.fromARGB(255, 173, 42, 33)
                                                          : Colors.green),
                                                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                                    "${report.periodicResults!.thisMonthsPeriodicResults!.shelfShareScoreComparedToLastMonth!}% ${report.periodicResults!.thisMonthsPeriodicResults!.shelfShareScoreComparedToLastMonth! < 0 ? "▼" : "▲"}",
                                                  ),
                                                )
                                              ],
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: anaRenk.withGreen(
                                                report.periodicResults!.thisMonthsPeriodicResults!.shelfShareScore!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            /* Durum Bilgileri */
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 14, left: 14, top: 15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: anaRenk,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: Text(AppLocalizations.of(context)!.ziyaret,
                                                style: const TextStyle(
                                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                                          ),
                                          Container(
                                            width: 150,
                                            height: 70,
                                            margin: const EdgeInsets.only(bottom: 10),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 13, 87, 148),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "${report.periodicResults!.thisMonthsPeriodicResults!.visitedCustomers!}",
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsetsDirectional.only(top: 5),
                                                        decoration: BoxDecoration(
                                                            color: (report.periodicResults!.thisMonthsPeriodicResults!
                                                                        .visitedCustomersComparedToLastMonth! <
                                                                    0
                                                                ? const Color.fromARGB(255, 173, 42, 33)
                                                                : Colors.green),
                                                            borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                        padding: const EdgeInsets.all(3),
                                                        child: Text(
                                                          style: const TextStyle(fontSize: 10, color: Colors.white),
                                                          "${report.periodicResults!.thisMonthsPeriodicResults!.visitedCustomersComparedToLastMonth!}% ${report.periodicResults!.thisMonthsPeriodicResults!.visitedCustomersComparedToLastMonth! < 0 ? "▼" : "▲"}",
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 14, left: 14, top: 15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: anaRenk,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: Text(AppLocalizations.of(context)!.fotograf,
                                                style: const TextStyle(
                                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                                          ),
                                          Container(
                                            width: 150,
                                            height: 70,
                                            margin: const EdgeInsets.only(bottom: 10),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 13, 87, 148),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "${report.periodicResults!.thisMonthsPeriodicResults!.numberOfPhotos!}",
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsetsDirectional.only(top: 5),
                                                        decoration: BoxDecoration(
                                                            color: (report.periodicResults!.thisMonthsPeriodicResults!
                                                                        .numberOfPhotosComparedToLastMonth! <
                                                                    0
                                                                ? const Color.fromARGB(255, 173, 42, 33)
                                                                : Colors.green),
                                                            borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                        padding: const EdgeInsets.all(3),
                                                        child: Text(
                                                          style: const TextStyle(fontSize: 10, color: Colors.white),
                                                          "${report.periodicResults!.thisMonthsPeriodicResults!.numberOfPhotosComparedToLastMonth!}% ${report.periodicResults!.thisMonthsPeriodicResults!.numberOfPhotosComparedToLastMonth! < 0 ? "▼" : "▲"}",
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 250,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
}
