import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:neocortexapp/entities/report.dart';
import 'package:neocortexapp/entities/transaction.dart';
import 'package:neocortexapp/presentation/Widget/appbar/appbar_widget.dart';
import 'package:neocortexapp/presentation/Widget/homepage/footer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/presentation/Widget/homepage/first_visit.dart';
import 'package:neocortexapp/presentation/pages/visit_detail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class DashboardPage extends StatefulWidget {
  final TabController tabController;
  final Report report;
  final List<Placemark> placemarks;
  final List<Transactions> transactions;
  final Customer customer;
  final List<Customer> customers;
  final StopWatchTimer stopWatchTimer;
  const DashboardPage(
      {super.key,
      required this.tabController,
      required this.report,
      required this.placemarks,
      required this.customer,
      required this.transactions,
      required this.customers,
      required this.stopWatchTimer});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

enum Strength {
  empty('', 0 / 4, Colors.transparent),
  weak('cake', 1 / 4, Colors.red),
  medium('easy', 2 / 4, Colors.yellow),
  strong('medium', 3 / 4, Colors.blue),
  veryStrong('hard', 4 / 4, Colors.green),
  ;

  final String text;
  final double value;
  final Color color;

  const Strength(this.text, this.value, this.color);
}

class _DashboardPageState extends State<DashboardPage>
    with AutomaticKeepAliveClientMixin<DashboardPage>, TickerProviderStateMixin {
  bool isScrolled = false;
  bool ziyaret = false;
  AnimationController? animation;
  Animation<double>? _fadeInFadeOut;
  AuthenticateManager? authenticateManager;

  var passwordTextEditingController = TextEditingController(text: "");
  var againPasswordTextEditingController = TextEditingController(text: "");
  var exPasswordTextEditingController = TextEditingController(text: "");
  var info = "";
  var pdfPath = "";
  Strength _strength = Strength.empty;

  Strength _calculatePasswordStrength(String value) {
    if (value.contains(RegExp(r'^\d{3}$'))) {
      return Strength.weak;
    } else if (value.contains(RegExp(r'^[a-zA-Z0-9]{4,}$'))) {
      return Strength.medium;
    } else if (value.contains(RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{7,}$'))) {
      return Strength.strong;
    } else if (value.contains(RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'))) {
      return Strength.veryStrong;
    } else {
      return Strength.empty;
    }
  }

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        ziyaret = value.getBool("ziyaret") ?? false;
      });
      if (ziyaret == true) {
        var endTime = DateTime.now();
        var startTime = DateTime.parse(value.getString("ziyaretBaslangic")!);
        widget.stopWatchTimer.setPresetTime(mSec: endTime.difference(startTime).inMilliseconds);
        widget.stopWatchTimer.onStartTimer();
      }
    });
    authenticateManager = AuthenticateManager();
    authenticateManager!.init().asStream();

    fromAsset('assets/pdf/uygulama_turu.pdf', 'uygulama_turu.pdf').then((f) {
      setState(() {
        pdfPath = f.path;
      });
    });
  }

  Future<void> callBackRefresh() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      ziyaret = prefs.getBool("ziyaret") ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    setAppbarAnimation();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: anaRenk,
        title: neoCortexTitleWidget(),
        actions: [
          TextButton(
              onPressed: () {
                openSettings(context);
              },
              child: const Icon(
                Icons.settings,
                color: Colors.white,
              ))
        ],
      ),
      body: NotificationListener<ScrollUpdateNotification>(
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              width: double.infinity,
              color: anaRenk,
              child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textAlign: TextAlign.left,
                        AppLocalizations.of(context)!.bilgi(
                            widget.report.periodicResults!.thisMonthsPeriodicResults!.numberOfPhotos!,
                            widget.report.periodicResults!.thisMonthsPeriodicResults!.visitedCustomers!),
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Image.asset('assets/images/vector.png'),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.kalanZiyaret(widget.report.numberOfCustomers! -
                                  widget.report.periodicResults!.thisMonthsPeriodicResults!.visitedCustomers!),
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ].expand((x) => [const SizedBox(height: 13), x]).skip(1).toList(),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: Container(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 208, 208, 208), borderRadius: BorderRadius.all(Radius.circular(10))),
                  width: 40,
                  height: 5,
                ),
              ),
            ),
            // ignore: void_checks
            widget.placemarks.isNotEmpty
                ? ziyaret == false
                    ? mapFirstPoint(
                        context,
                        "${widget.placemarks[0].street} ${widget.placemarks[0].thoroughfare} ${widget.placemarks[0].subThoroughfare}",
                        "${widget.placemarks[0].subAdministrativeArea} ${widget.placemarks[0].administrativeArea}",
                        widget.customer,
                        widget.tabController,
                        authenticateManager,
                        ziyaret,
                        callBackRefresh(),
                        widget.stopWatchTimer)
                    : visitInfoCard(context, authenticateManager, ziyaret, callBackRefresh(), widget.customers,
                        widget.stopWatchTimer)
                : const CircularProgressIndicator(),
            Container(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                width: double.infinity,
                child: Card(
                    elevation: 4,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
                    child: Column(
                      children: [
                        Container(
                          color: const Color.fromARGB(255, 244, 244, 244),
                          padding: const EdgeInsets.only(left: 15, right: 5),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(
                              AppLocalizations.of(context)!.durumBilgileri,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    widget.tabController.index = 3;
                                  });
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.tumu,
                                  style: const TextStyle(color: anaRenk, fontWeight: FontWeight.bold),
                                ))
                          ]),
                        ),
                        SingleChildScrollView(
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
                                              percent: widget.report.periodicResults!.thisMonthsPeriodicResults!
                                                      .planogramRealizationScore! /
                                                  100,
                                              center: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    widget.report.periodicResults!.thisMonthsPeriodicResults!
                                                        .planogramRealizationScore!
                                                        .toString(),
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsetsDirectional.only(top: 5),
                                                    decoration: BoxDecoration(
                                                        color: (widget
                                                                    .report
                                                                    .periodicResults!
                                                                    .thisMonthsPeriodicResults!
                                                                    .planogramRealizationScoreComparedToLastMonth! <
                                                                0
                                                            ? const Color.fromARGB(255, 173, 42, 33)
                                                            : Colors.green),
                                                        borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                    padding: const EdgeInsets.all(3),
                                                    child: Text(
                                                      style: const TextStyle(fontSize: 10, color: Colors.white),
                                                      "${widget.report.periodicResults!.thisMonthsPeriodicResults!.planogramRealizationScoreComparedToLastMonth!}% ${widget.report.periodicResults!.thisMonthsPeriodicResults!.planogramRealizationScoreComparedToLastMonth! < 0 ? "▼" : "▲"}",
                                                    ),
                                                  )
                                                ],
                                              ),
                                              circularStrokeCap: CircularStrokeCap.round,
                                              progressColor: anaRenk.withGreen(widget.report.periodicResults!
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
                                              percent: widget.report.periodicResults!.thisMonthsPeriodicResults!
                                                      .planogramAvailabilityScore! /
                                                  100,
                                              center: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    widget.report.periodicResults!.thisMonthsPeriodicResults!
                                                        .planogramAvailabilityScore!
                                                        .toString(),
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsetsDirectional.only(top: 5),
                                                    decoration: BoxDecoration(
                                                        color: (widget
                                                                    .report
                                                                    .periodicResults!
                                                                    .thisMonthsPeriodicResults!
                                                                    .planogramAvailabilityScoreComparedToLastMonth! <
                                                                0
                                                            ? const Color.fromARGB(255, 173, 42, 33)
                                                            : Colors.green),
                                                        borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                    padding: const EdgeInsets.all(3),
                                                    child: Text(
                                                      style: const TextStyle(fontSize: 10, color: Colors.white),
                                                      "${widget.report.periodicResults!.thisMonthsPeriodicResults!.planogramAvailabilityScoreComparedToLastMonth!}% ${widget.report.periodicResults!.thisMonthsPeriodicResults!.planogramAvailabilityScoreComparedToLastMonth! < 0 ? "▼" : "▲"}",
                                                    ),
                                                  )
                                                ],
                                              ),
                                              circularStrokeCap: CircularStrokeCap.round,
                                              progressColor: anaRenk.withGreen(widget.report.periodicResults!
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
                                              percent: widget.report.periodicResults!.thisMonthsPeriodicResults!
                                                      .drinkMusthaveScore! /
                                                  100,
                                              center: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    widget.report.periodicResults!.thisMonthsPeriodicResults!
                                                        .drinkMusthaveScore!
                                                        .toString(),
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsetsDirectional.only(top: 5),
                                                    decoration: BoxDecoration(
                                                        color: (widget
                                                                    .report
                                                                    .periodicResults!
                                                                    .thisMonthsPeriodicResults!
                                                                    .drinkMusthaveScoreComparedToLastMonth! <
                                                                0
                                                            ? const Color.fromARGB(255, 173, 42, 33)
                                                            : Colors.green),
                                                        borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                    padding: const EdgeInsets.all(3),
                                                    child: Text(
                                                      style: const TextStyle(fontSize: 10, color: Colors.white),
                                                      "${widget.report.periodicResults!.thisMonthsPeriodicResults!.drinkMusthaveScoreComparedToLastMonth!}% ${widget.report.periodicResults!.thisMonthsPeriodicResults!.drinkMusthaveScoreComparedToLastMonth! < 0 ? "▼" : "▲"}",
                                                    ),
                                                  )
                                                ],
                                              ),
                                              circularStrokeCap: CircularStrokeCap.round,
                                              progressColor: anaRenk.withGreen(widget.report.periodicResults!
                                                  .thisMonthsPeriodicResults!.drinkMusthaveScore!),
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
                                              percent: widget.report.periodicResults!.thisMonthsPeriodicResults!
                                                      .shelfShareScore! /
                                                  100,
                                              center: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    widget.report.periodicResults!.thisMonthsPeriodicResults!
                                                        .shelfShareScore!
                                                        .toString(),
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsetsDirectional.only(top: 5),
                                                    decoration: BoxDecoration(
                                                        color: (widget
                                                                    .report
                                                                    .periodicResults!
                                                                    .thisMonthsPeriodicResults!
                                                                    .shelfShareScoreComparedToLastMonth! <
                                                                0
                                                            ? const Color.fromARGB(255, 173, 42, 33)
                                                            : Colors.green),
                                                        borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                    padding: const EdgeInsets.all(3),
                                                    child: Text(
                                                      style: const TextStyle(fontSize: 10, color: Colors.white),
                                                      "${widget.report.periodicResults!.thisMonthsPeriodicResults!.shelfShareScoreComparedToLastMonth!}% ${widget.report.periodicResults!.thisMonthsPeriodicResults!.shelfShareScoreComparedToLastMonth! < 0 ? "▼" : "▲"}",
                                                    ),
                                                  )
                                                ],
                                              ),
                                              circularStrokeCap: CircularStrokeCap.round,
                                              progressColor: anaRenk.withGreen(widget
                                                  .report.periodicResults!.thisMonthsPeriodicResults!.shelfShareScore!),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              )
                            ],
                          ),
                        ),
                      ],
                    ))),
            Container(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                width: double.infinity,
                child: Card(
                    elevation: 4,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
                    child: Column(
                      children: [
                        Container(
                          color: const Color.fromARGB(255, 244, 244, 244),
                          padding: const EdgeInsets.only(left: 15, right: 5),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(
                              AppLocalizations.of(context)!.ziyaretEdilenNoktalar,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    openVisit(context);
                                  });
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.tumu,
                                  style: const TextStyle(color: anaRenk, fontWeight: FontWeight.bold),
                                ))
                          ]),
                        ),
                        /* Durum Bilgileri */
                        Padding(
                            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0),
                            child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: widget.transactions.take(5).length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    trailing: CircularPercentIndicator(
                                      radius: 20.0,
                                      lineWidth: 5.0,
                                      animation: true,
                                      percent: widget.transactions[index].shelfShareScore.values
                                              .map((e) => e.percentage as double)
                                              .reduce(max) /
                                          100,
                                      center: Text(
                                          "${widget.transactions[index].shelfShareScore.values.map((e) => e.percentage as double).reduce(max).toStringAsFixed(0)}%"),
                                      circularStrokeCap: CircularStrokeCap.round,
                                      progressColor: anaRenk.withGreen(widget
                                          .report.periodicResults!.thisMonthsPeriodicResults!.drinkMusthaveScore!),
                                    ),
                                    contentPadding: const EdgeInsets.all(0),
                                    titleAlignment: ListTileTitleAlignment.center,
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  VisitDetail(transactions: widget.transactions[index])));
                                    },
                                    title: Text(widget.transactions[index].unvan.toString()),
                                    subtitle: Text(
                                        "${DateFormat("dd.MM.yyyy HH:mm").format(widget.transactions[index].dateTime!)} - Sap Kodu:${widget.transactions[index].customerSapCode}"),
                                    leading: const Icon(
                                      Icons.circle,
                                      color: Color.fromARGB(255, 232, 232, 232),
                                    ),
                                  );
                                })),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    )))
          ]),
        ),
        onNotification: (notification) {
          if (notification.metrics.pixels >= 12 && isScrolled == false) {
            setState(() {
              isScrolled = true;
            });
          } else if (notification.metrics.pixels < 12 && isScrolled == true) {
            setState(() {
              isScrolled = false;
            });
          }
          return true;
        },
      ),
      bottomNavigationBar: FooterPageWidget(
        tabBarController: widget.tabController,
        isPopEnabled: false,
      ),
    );
  }

  Future<void> openSettings(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: const RoundedRectangleBorder(side: BorderSide.none),
            backgroundColor: const Color.fromARGB(255, 245, 245, 245),
            titlePadding: const EdgeInsets.all(0),
            insetPadding: const EdgeInsets.all(0),
            alignment: Alignment.bottomCenter,
            title: Container(
              padding: const EdgeInsets.only(left: 20),
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 253, 253, 253),
                  border: Border(bottom: BorderSide(color: Color.fromARGB(255, 224, 224, 224), width: 1))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.ayarlar,
                    style: const TextStyle(color: anaRenk, fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_downward,
                        color: anaRenk,
                      ))
                ],
              ),
            ),
            content: Container(
              padding: const EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.83,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Proje",
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text("${authenticateManager!.getProjectId()!} -  ${authenticateManager!.getProjectName()!}",
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.kullaniciAdi,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(authenticateManager!.getFullName()!,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.email,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(authenticateManager!.getEmail()!,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, right: 4, top: 14),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 5, backgroundColor: anaRenk, padding: const EdgeInsets.all(15)),
                            onPressed: () {
                              setState(() {
                                info = "";
                                passwordTextEditingController.text = "";
                                againPasswordTextEditingController.text = "";
                                exPasswordTextEditingController.text = "";
                              });

                              showDialog<void>(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        title: Text(AppLocalizations.of(context)!.sifremiUnuttum),
                                        actions: [
                                          SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                                  onPressed: () async {
                                                    if (passwordTextEditingController.text !=
                                                        againPasswordTextEditingController.text) {
                                                      setState(() {
                                                        info = AppLocalizations.of(context)!.sifrelerUyusmuyor;
                                                      });
                                                    } else {
                                                      if (_strength.text != "cake") {
                                                        setState(() {
                                                          info = AppLocalizations.of(context)!
                                                              .sifrelerSifrelemeAlgoritmasinaUygunDegil;
                                                        });
                                                      } else {
                                                        final response = await http.post(
                                                            Uri.parse("${AppConfig.baseApiUrl}/changepassword"),
                                                            headers: <String, String>{
                                                              "token": authenticateManager!.getToken()!,
                                                              "project_id": authenticateManager!.getProjectId()!
                                                            },
                                                            body: jsonEncode(<String, String>{
                                                              'current_password': exPasswordTextEditingController.text,
                                                              'new_password': passwordTextEditingController.text
                                                            }));
                                                        var j = jsonDecode(response.body);
                                                        if (j["Status"] == "Error") {
                                                          setState(() {
                                                            info = j["Content"];
                                                          });
                                                        } else {
                                                          setState(() {
                                                            info = "";

                                                            Fluttertoast.showToast(
                                                                msg: "İşlem Başarılı.",
                                                                toastLength: Toast.LENGTH_SHORT,
                                                                gravity: ToastGravity.BOTTOM,
                                                                timeInSecForIosWeb: 1,
                                                                backgroundColor: Colors.green,
                                                                textColor: Colors.white,
                                                                fontSize: 16.0);

                                                            Future.delayed(Duration(seconds: 2), () {
                                                              Navigator.of(context).pop();
                                                            });
                                                          });
                                                        }
                                                      }
                                                    }
                                                  },
                                                  child: Text(AppLocalizations.of(context)!.gonder)))
                                        ],
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              info,
                                              style: const TextStyle(color: Colors.red, fontSize: 10),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TextField(
                                              onChanged: (value) {},
                                              controller: exPasswordTextEditingController,
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                  fillColor: inputBackgroundColor,
                                                  filled: true,
                                                  prefixIconColor: const Color.fromARGB(255, 141, 141, 141),
                                                  prefixIcon: const Icon(Icons.lock_open),
                                                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                                                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                                  hintText: AppLocalizations.of(context)!.eskiSifre),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Visibility(
                                              visible: false,
                                              child: LinearProgressIndicator(
                                                minHeight: 20,
                                                value: _strength.value,
                                                backgroundColor: Colors.grey,
                                                color: _strength.color,
                                              ),
                                            ),
                                            Visibility(
                                              visible: false,
                                              child:
                                                  Text(_strength.text.isNotEmpty ? 'Şifreniz : ${_strength.text}' : ''),
                                            ),
                                            TextField(
                                              onChanged: (value) => {
                                                setState(() {
                                                  _strength = _calculatePasswordStrength(value);
                                                })
                                              },
                                              controller: passwordTextEditingController,
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                  fillColor: inputBackgroundColor,
                                                  filled: true,
                                                  prefixIconColor: const Color.fromARGB(255, 141, 141, 141),
                                                  prefixIcon: const Icon(Icons.lock_open),
                                                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                                                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                                  hintText: AppLocalizations.of(context)!.yeniSifre),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TextField(
                                              controller: againPasswordTextEditingController,
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                  fillColor: inputBackgroundColor,
                                                  filled: true,
                                                  prefixIconColor: const Color.fromARGB(255, 141, 141, 141),
                                                  prefixIcon: const Icon(Icons.lock_open),
                                                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                                                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                                  hintText: AppLocalizations.of(context)!.sifreYeniden),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)!.sifremiSifirla,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            )),
                      ),
                    )
                  ]),
                  Column(children: [
                    GestureDetector(
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Stack(
                                  children: [
                                    PDFView(
                                      filePath: pdfPath,
                                      enableSwipe: true,
                                      autoSpacing: false,
                                      preventLinkNavigation: true,
                                      pageFling: false,
                                      onError: (error) {
                                        print(error.toString());
                                      },
                                      onPageError: (page, error) {
                                        print('$page: ${error.toString()}');
                                      },
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () => Navigator.of(context).pop(),
                                        child: Container(
                                          color: Colors.white,
                                          child: const Icon(
                                            Icons.close,
                                            color: anaRenk,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.uygulamaTuru,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.versiyon,
                              style: const TextStyle(fontSize: 14),
                            ),
                            FutureBuilder(
                              future: PackageInfo.fromPlatform(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(snapshot.data!.version.toString());
                                }
                                return const CircularProgressIndicator();
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, right: 4, top: 14),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 5, backgroundColor: anaRenk, padding: const EdgeInsets.all(15)),
                            onPressed: () {
                              AuthenticateManager.logout(context);
                            },
                            child: Text(
                              AppLocalizations.of(context)!.cikisYap,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            )),
                      ),
                    )
                  ]),
                ],
              ),
            ));
      },
    );
  }

  Future<void> openVisit(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          backgroundColor: const Color.fromARGB(255, 245, 245, 245),
          titlePadding: const EdgeInsets.all(0),
          insetPadding: const EdgeInsets.all(0),
          alignment: Alignment.bottomCenter,
          title: Container(
            padding: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 253, 253, 253),
                border: Border(bottom: BorderSide(color: Color.fromARGB(255, 224, 224, 224), width: 1))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.ziyaretEdilenNoktalar,
                  style: const TextStyle(color: anaRenk, fontWeight: FontWeight.bold, fontSize: 17),
                ),
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_downward,
                      color: anaRenk,
                    ))
              ],
            ),
          ),
          content: Container(
            padding: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.83,
            child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.transactions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        trailing: CircularPercentIndicator(
                          radius: 20.0,
                          lineWidth: 5.0,
                          animation: true,
                          percent: widget.transactions[index].shelfShareScore.values
                                  .map((e) => e.percentage as double)
                                  .reduce(max) /
                              100,
                          center: Text(
                              "${widget.transactions[index].shelfShareScore.values.map((e) => e.percentage as double).reduce(max).toStringAsFixed(0)}%"),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: anaRenk
                              .withGreen(widget.report.periodicResults!.thisMonthsPeriodicResults!.drinkMusthaveScore!),
                        ),
                        contentPadding: const EdgeInsets.all(0),
                        titleAlignment: ListTileTitleAlignment.center,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VisitDetail(
                                        transactions: widget.transactions[index],
                                      )));
                        },
                        title: Text(widget.transactions[index].unvan.toString()),
                        subtitle: Text(
                            "${DateFormat("dd.MM.yyyy HH:mm").format(widget.transactions[index].dateTime!)} - Sap Kodu:${widget.transactions[index].customerSapCode}"),
                        leading: const Icon(
                          Icons.circle,
                          color: Color.fromARGB(255, 232, 232, 232),
                        ),
                      );
                    })),
          ),
        );
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await widget.stopWatchTimer.dispose(); // Need to call dispose function.
  }

  void setAppbarAnimation() {
    animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeInFadeOut = Tween<double>(begin: 0, end: 1).animate(animation!);

    animation?.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        animation?.forward();
      }
    });
    animation?.forward();
  }

  @override
  bool get wantKeepAlive => true;
}
