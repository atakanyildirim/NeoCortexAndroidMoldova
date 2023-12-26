import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/dataaccess/visit_repository.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:neocortexapp/presentation/pages/camera_page.dart';
import 'package:neocortexapp/presentation/pages/survey_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

String selectedValue = "1";
bool isLoading = false;

Widget mapFirstPoint(
    BuildContext context,
    String konum,
    String konum2,
    Customer closedCustomer,
    TabController? tabController,
    AuthenticateManager? authenticateManager,
    bool ziyaret,
    Future<void> callBack,
    StopWatchTimer stopWatchTimer) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 15, left: 12, right: 12),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: anasayfaKonumBoxBorder,
          width: 4,
        ),
        color: anaRenk,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: anaRenkLight, borderRadius: BorderRadius.circular(5)),
                child: GestureDetector(
                  onTap: () {
                    // homepage.HomePageState().determinePosition();
                  },
                  child: const Icon(
                    CupertinoIcons.location_fill,
                    color: Colors.white,
                  ),
                ),
              ),
              title: Text(
                konum,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                konum2,
                style: const TextStyle(color: anaAcikRenk),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: anaRenkLight, borderRadius: BorderRadius.circular(5)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        tabController!.animateTo(4, curve: Curves.bounceIn, duration: const Duration(seconds: 0));
                      },
                      child: Text(
                        AppLocalizations.of(context)!.haritadanSec,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        tabController!.animateTo(4, curve: Curves.bounceIn, duration: const Duration(seconds: 0));
                      },
                      child: const Icon(
                        CupertinoIcons.right_chevron,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
            child: Row(
              children: [
                Text(AppLocalizations.of(context)!.yakindakiMusteriler,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration:
                      const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: Colors.white),
                  child: Text(
                    closedCustomer.mesafe!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: Text(
                          closedCustomer.customerName!,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: Text(
                          closedCustomer.sevkAdresi == null ? "" : closedCustomer.sevkAdresi!,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // homepage.HomePageState().determinePosition();
                        },
                        child: const Icon(
                          CupertinoIcons.refresh_circled,
                          color: anaRenk,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 20),
            child: GestureDetector(
              onTap: () async {
                await callBack;
                if (authenticateManager!.getProjectId() == "5") {
                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            actionsAlignment: MainAxisAlignment.spaceBetween,
                            title: Text(closedCustomer.customerName!),
                            actions: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                  onPressed: ziyaret
                                      ? null
                                      : () async {
                                          final prefs = await SharedPreferences.getInstance();
                                          prefs.setBool("ziyaret", true);
                                          prefs.setString("ziyaretBaslangic", DateTime.now().toString());
                                          prefs.setString("customerVisit", closedCustomer.customerSapCode.toString());
                                          setState(() {
                                            ziyaret = true;
                                          });
                                          stopWatchTimer.onResetTimer();
                                          stopWatchTimer.clearPresetTime();
                                          stopWatchTimer.onStartTimer();
                                        },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.play_circle_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.islemeBasla,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  )),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                  onPressed: !ziyaret
                                      ? null
                                      : () async {
                                          var prefs = await SharedPreferences.getInstance();
                                          if (prefs.getString("customerVisit") ==
                                              closedCustomer.customerSapCode.toString()) {
                                            // ignore: use_build_context_synchronously
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => SurveyPage(
                                                          customerSurvey: closedCustomer,
                                                        )));
                                          } else {
                                            // ignore: use_build_context_synchronously
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(AppLocalizations.of(context)!.uyari),
                                                  actions: [
                                                    ElevatedButton(
                                                        style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: Text("Ok"))
                                                  ],
                                                  content: Text("Lütfen önce ziyareti bitiriniz"),
                                                );
                                              },
                                            );
                                          }
                                        },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.list_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.anketeBasla,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  )),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                  onPressed: !ziyaret
                                      ? null
                                      : () async {
                                          var prefs = await SharedPreferences.getInstance();
                                          if (prefs.getString("customerVisit") ==
                                              closedCustomer.customerSapCode.toString()) {
                                            await availableCameras().then((value) => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        CameraPage(cameras: value, customerDetail: closedCustomer))));
                                          } else {
                                            // ignore: use_build_context_synchronously
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(AppLocalizations.of(context)!.uyari),
                                                  actions: [
                                                    ElevatedButton(
                                                        style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: Text("Ok"))
                                                  ],
                                                  content: const Text("Lütfen önce ziyareti bitiriniz"),
                                                );
                                              },
                                            );
                                          }
                                        },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.fotografCek,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  )),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              title: const Text("İptal Nedeni Seç"),
                                              content: FutureBuilder(
                                                future: VisitRepository.getVisitReasons(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    List<DropdownMenuItem<String>> list = [];
                                                    var data = jsonDecode(snapshot.data!);
                                                    for (var i = 0; i < data["content"].length; i++) {
                                                      list.add(DropdownMenuItem(
                                                        value: data["content"][i]["id"].toString(),
                                                        child: Text(data["content"][i]["value"]),
                                                      ));
                                                    }
                                                    return DropdownButton(
                                                      hint: Text(
                                                        AppLocalizations.of(context)!.seciniz,
                                                        softWrap: false,
                                                        overflow: TextOverflow.clip,
                                                      ),
                                                      items: list,
                                                      value: selectedValue,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedValue = value!;
                                                        });
                                                      },
                                                    );
                                                  }
                                                  return const Text("Lütfen Bekleyiniz...");
                                                },
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                                    onPressed: isLoading
                                                        ? null
                                                        : () async {
                                                            SharedPreferences prefs =
                                                                await SharedPreferences.getInstance();
                                                            setState(
                                                              () {
                                                                isLoading = true;
                                                              },
                                                            );
                                                            bool isSuccess = await VisitRepository.sendVisitReason(
                                                                prefs.getString("customerVisit")!,
                                                                selectedValue.toString());
                                                            if (isSuccess) {
                                                              // ignore: use_build_context_synchronously
                                                              showDialog(
                                                                context: context,
                                                                builder: (context) {
                                                                  return AlertDialog(
                                                                    actions: [
                                                                      ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                              backgroundColor: anaRenk),
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop();
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child: const Text("OK"))
                                                                    ],
                                                                    title: const Text("Durum"),
                                                                    content: const Text("Başarıyla Gönderildi"),
                                                                  );
                                                                },
                                                              );
                                                              setState(() {
                                                                isLoading = false;
                                                              });
                                                            }
                                                          },
                                                    child: Text(AppLocalizations.of(context)!.gonder))
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.ziyaretEdememeNedeni,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  )),
                              Visibility(
                                visible: ziyaret,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 173, 42, 32)),
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            setState(
                                              () {
                                                isLoading = true;
                                              },
                                            );
                                            final prefs = await SharedPreferences.getInstance();
                                            AuthenticateManager authenticateManager = AuthenticateManager();
                                            await authenticateManager.init();
                                            bool isSuccess = await VisitRepository.finishVisit(
                                                prefs.getString("customerVisit")!,
                                                authenticateManager.getEmail()!,
                                                prefs.getString("ziyaretBaslangic")!);
                                            if (isSuccess) {
                                              // ignore: use_build_context_synchronously
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    actions: [
                                                      ElevatedButton(
                                                          style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: const Text("OK"))
                                                    ],
                                                    title: Text(AppLocalizations.of(context)!.durum),
                                                    content: const Text("Başarıyla Ziyaret Tamamlandı"),
                                                  );
                                                },
                                              );
                                              setState(() {
                                                isLoading = false;
                                              });
                                            }
                                            await prefs.setBool("ziyaret", false);
                                            setState(() {
                                              ziyaret = false;
                                            });
                                          },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.stop_circle_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.ziyaretiBitir,
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                } else {
                  await availableCameras().then((value) => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CameraPage(cameras: value, customerDetail: closedCustomer))));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        AppLocalizations.of(context)!.islemeBasla,
                        style: const TextStyle(
                          color: anaRenk,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Icons.camera_alt_sharp,
                        color: anaRenk,
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Widget visitInfoCard(BuildContext context, AuthenticateManager? authenticateManager, bool ziyaret,
    Future<void> callBack, List<Customer> customers, StopWatchTimer stopWatchTimer) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 15, left: 12, right: 12),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: anasayfaKonumBoxBorder,
          width: 4,
        ),
        color: anaRenk,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: anaRenkLight, borderRadius: BorderRadius.circular(5)),
                child: GestureDetector(
                  onTap: () {
                    // homepage.HomePageState().determinePosition();
                  },
                  child: const Icon(
                    CupertinoIcons.stopwatch,
                    color: Colors.white,
                  ),
                ),
              ),
              title: Text(
                AppLocalizations.of(context)!.durum,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "Sağdaki buton ile anket veya analiz yapabilirsiniz.",
                style: const TextStyle(color: anaAcikRenk),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(color: anaRenkLight, borderRadius: BorderRadius.circular(5)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(
                          Icons.camera_alt_outlined,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    actionsAlignment: MainAxisAlignment.spaceBetween,
                                    actions: [
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                          onPressed: !ziyaret
                                              ? null
                                              : () async {
                                                  var prefs = await SharedPreferences.getInstance();
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => SurveyPage(
                                                                customerSurvey: customers
                                                                    .where((element) =>
                                                                        element.customerSapCode.toString() ==
                                                                        prefs.getString("customerVisit"))
                                                                    .first,
                                                              )));
                                                },
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.list_alt,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!.anketeBasla,
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ],
                                          )),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                          onPressed: !ziyaret
                                              ? null
                                              : () async {
                                                  var prefs = await SharedPreferences.getInstance();
                                                  await availableCameras().then((value) => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) => CameraPage(
                                                              cameras: value,
                                                              customerDetail: customers
                                                                  .where((element) =>
                                                                      element.customerSapCode.toString() ==
                                                                      prefs.getString("customerVisit"))
                                                                  .first))));
                                                },
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.camera_alt_outlined,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!.fotografCek,
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ],
                                          )),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return AlertDialog(
                                                      title: const Text("İptal Nedeni Seç"),
                                                      content: FutureBuilder(
                                                        future: VisitRepository.getVisitReasons(),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.hasData) {
                                                            List<DropdownMenuItem<String>> list = [];
                                                            var data = jsonDecode(snapshot.data!);
                                                            for (var i = 0; i < data["content"].length; i++) {
                                                              list.add(DropdownMenuItem(
                                                                value: data["content"][i]["id"].toString(),
                                                                child: Text(data["content"][i]["value"]),
                                                              ));
                                                            }
                                                            return DropdownButton(
                                                              hint: Text(
                                                                AppLocalizations.of(context)!.seciniz,
                                                                softWrap: false,
                                                                overflow: TextOverflow.clip,
                                                              ),
                                                              items: list,
                                                              value: selectedValue,
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  selectedValue = value!;
                                                                });
                                                              },
                                                            );
                                                          }
                                                          return const Text("Lütfen Bekleyiniz...");
                                                        },
                                                      ),
                                                      actions: [
                                                        ElevatedButton(
                                                            style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                                            onPressed: isLoading
                                                                ? null
                                                                : () async {
                                                                    var prefs = await SharedPreferences.getInstance();

                                                                    setState(
                                                                      () {
                                                                        isLoading = true;
                                                                      },
                                                                    );
                                                                    bool isSuccess =
                                                                        await VisitRepository.sendVisitReason(
                                                                            prefs.getString("customerVisit")!,
                                                                            selectedValue.toString());
                                                                    if (isSuccess) {
                                                                      // ignore: use_build_context_synchronously
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context) {
                                                                          return AlertDialog(
                                                                            actions: [
                                                                              ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                      backgroundColor: anaRenk),
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop();
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                  child: const Text("OK"))
                                                                            ],
                                                                            title: const Text("Durum"),
                                                                            content: const Text("Başarıyla Gönderildi"),
                                                                          );
                                                                        },
                                                                      );
                                                                      setState(() {
                                                                        isLoading = false;
                                                                      });
                                                                    }
                                                                  },
                                                            child: Text(AppLocalizations.of(context)!.gonder))
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.info_outline,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!.ziyaretEdememeNedeni,
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ],
                                          )),
                                      Visibility(
                                        visible: ziyaret,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color.fromARGB(255, 173, 42, 32)),
                                            onPressed: isLoading
                                                ? null
                                                : () async {
                                                    setState(
                                                      () {
                                                        isLoading = true;
                                                      },
                                                    );
                                                    final prefs = await SharedPreferences.getInstance();
                                                    AuthenticateManager authenticateManager = AuthenticateManager();
                                                    await authenticateManager.init();
                                                    bool isSuccess = await VisitRepository.finishVisit(
                                                        prefs.getString("customerVisit")!,
                                                        authenticateManager.getEmail()!,
                                                        prefs.getString("ziyaretBaslangic")!);
                                                    if (isSuccess) {
                                                      // ignore: use_build_context_synchronously
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            actions: [
                                                              ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor: anaRenk),
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: const Text("OK"))
                                                            ],
                                                            title: Text(AppLocalizations.of(context)!.durum),
                                                            content: const Text("Başarıyla Ziyaret Tamamlandı"),
                                                          );
                                                        },
                                                      );
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    }
                                                    await prefs.setBool("ziyaret", false);
                                                    setState(() {
                                                      ziyaret = false;
                                                    });
                                                  },
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.stop_circle_outlined,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  AppLocalizations.of(context)!.ziyaretiBitir,
                                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
            child: Row(
              children: [
                FutureBuilder(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox(
                        width: 200,
                        child: Text(
                          customers
                              .where((element) =>
                                  element.customerSapCode.toString() == snapshot.data!.getString("customerVisit"))
                              .first
                              .customerName!,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                        ),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)), color: Color.fromARGB(255, 3, 165, 3)),
                  child: Text(
                    AppLocalizations.of(context)!.aktif,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  StreamBuilder<int>(
                    stream: stopWatchTimer.rawTime,
                    initialData: 0,
                    builder: (context, snap) {
                      final value = snap.data;
                      final displayTime = StopWatchTimer.getDisplayTime(value!);
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              displayTime,
                              style:
                                  const TextStyle(fontSize: 40, fontFamily: 'Helvetica', fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // homepage.HomePageState().determinePosition();
                        },
                        child: const Icon(
                          CupertinoIcons.refresh_circled,
                          color: anaRenk,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 20),
            child: StatefulBuilder(
              builder: (context, setState) {
                return GestureDetector(
                  onTap: isLoading
                      ? null
                      : () async {
                          await callBack;
                          if (authenticateManager!.getProjectId() == "5") {
                            setState(
                              () {
                                isLoading = true;
                              },
                            );
                            final prefs = await SharedPreferences.getInstance();
                            AuthenticateManager authenticateManager = AuthenticateManager();
                            await authenticateManager.init();
                            bool isSuccess = await VisitRepository.finishVisit(prefs.getString("customerVisit")!,
                                authenticateManager.getEmail()!, prefs.getString("ziyaretBaslangic")!);
                            if (isSuccess) {
                              // ignore: use_build_context_synchronously
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    actions: [
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("OK"))
                                    ],
                                    title: Text(AppLocalizations.of(context)!.durum),
                                    content: const Text("Başarıyla Ziyaret Tamamlandı"),
                                  );
                                },
                              );
                              setState(() {
                                isLoading = false;
                              });
                            }
                            await prefs.setBool("ziyaret", false);
                            setState(() {
                              ziyaret = false;
                            });
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 247, 234, 234), borderRadius: BorderRadius.circular(7)),
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            textAlign: TextAlign.center,
                            AppLocalizations.of(context)!.ziyaretiBitir,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 162, 37, 28),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(
                            Icons.stop_circle,
                            color: Color.fromARGB(255, 162, 37, 28),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    ),
  );
}
