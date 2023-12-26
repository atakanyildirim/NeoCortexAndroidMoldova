import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/dataaccess/visit_repository.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:neocortexapp/presentation/Widget/homepage/footer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/presentation/pages/camera_page.dart';
import 'package:neocortexapp/presentation/pages/survey_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;
  final TabController tabController;
  final StopWatchTimer stopWatchTimer;
  const CustomerDetailPage(
      {super.key, required this.customer, required this.tabController, required this.stopWatchTimer});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  AuthenticateManager? authenticateManager;
  var gruplar = [];
  String selectedValue = "1";
  bool isLoading = false;
  bool ziyaret = false;

  @override
  void initState() {
    super.initState();
    authenticateManager = AuthenticateManager();
    authenticateManager!.init().asStream();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        if(value.containsKey("ziyaret")){
          ziyaret = value.getBool("ziyaret")!;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    gruplar.add(AppLocalizations.of(context)!.digerleri);
    gruplar.add(AppLocalizations.of(context)!.acikKanal);
    gruplar.add(AppLocalizations.of(context)!.kapaliKanal);
    gruplar.add("Ekomini");
    gruplar.add("Carrefour");
    gruplar.add("Migros");
    gruplar.add("Macro Center");
    gruplar.add(AppLocalizations.of(context)!.digerleri);
    return Scaffold(
      appBar: AppBar(
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        elevation: 0,
        backgroundColor: anaRenk,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            widget.customer.customerName!,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: anaRenk,
            width: double.infinity,
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            AppLocalizations.of(context)!.durum,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            AppLocalizations.of(context)!.aktif,
                            style: const TextStyle(fontSize: 13),
                          )
                        ])
                      ]),
                    ),
                    if (widget.customer.musteriPozisyon != null)
                      const SizedBox(
                        width: 10,
                      ),
                    if (widget.customer.musteriPozisyon != null)
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(15),
                        child: Row(children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              AppLocalizations.of(context)!.musteriPozisyonu,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              widget.customer.musteriPozisyon!,
                              style: const TextStyle(fontSize: 13),
                            )
                          ])
                        ]),
                      )
                  ],
                )),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              const SizedBox(
                width: 11,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 146, 146, 146),
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  AuthenticateManager authenticateManager = AuthenticateManager();
                  await authenticateManager.init();
                  if (authenticateManager.getProjectId() == "5") {
                    // ignore: use_build_context_synchronously
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              actionsAlignment: MainAxisAlignment.spaceBetween,
                              title: Text(widget.customer.customerName!),
                              actions: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                    onPressed: ziyaret
                                        ? null
                                        : () async {
                                            final prefs = await SharedPreferences.getInstance();
                                            prefs.setBool("ziyaret", true);
                                            prefs.setString("ziyaretBaslangic", DateTime.now().toString());
                                            prefs.setString(
                                                "customerVisit", widget.customer.customerSapCode.toString());
                                            widget.stopWatchTimer.onResetTimer();
                                            widget.stopWatchTimer.onStartTimer();
                                            setState(() {
                                              ziyaret = true;
                                            });
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
                                                widget.customer.customerSapCode.toString()) {
                                              // ignore: use_build_context_synchronously
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => SurveyPage(
                                                            customerSurvey: widget.customer,
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
                                                widget.customer.customerSapCode.toString()) {
                                              await availableCameras().then((value) => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) => CameraPage(
                                                          cameras: value, customerDetail: widget.customer))));
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
                    await availableCameras().then((value) => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CameraPage(cameras: value, customerDetail: widget.customer))));
                  }
                },
                child: Column(
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                    Text(
                      AppLocalizations.of(context)!.islemeBasla,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 146, 146, 146),
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  try {
                    final coords = Coords(double.parse(widget.customer.customerLatitude.toString()),
                        double.parse(widget.customer.customerLongitude.toString()));
                    final title = widget.customer.customerName.toString();
                    final availableMaps = await MapLauncher.installedMaps;

                    // ignore: use_build_context_synchronously
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          child: Container(
                            color: Colors.white,
                            child: Wrap(
                              children: <Widget>[
                                for (var map in availableMaps)
                                  ListTile(
                                    onTap: () => map.showMarker(
                                      coords: coords,
                                      title: title,
                                    ),
                                    title: Text(map.mapName),
                                    leading: SvgPicture.asset(
                                      map.icon,
                                      height: 30.0,
                                      width: 30.0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                  }
                },
                child: Column(
                  children: [
                    const Icon(
                      Icons.near_me,
                      color: Colors.white,
                    ),
                    Text(
                      AppLocalizations.of(context)!.haritadanAc,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 233, 233, 233),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.efes,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            "${widget.customer.efesDoorCount ?? 0} ${AppLocalizations.of(context)!.kapi}",
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 233, 233, 233),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.diger,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            "${widget.customer.storeCoolerDoorCount ?? 0} ${AppLocalizations.of(context)!.kapi}",
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 233, 233, 233),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.rakip,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            "${widget.customer.competitorDoorCount ?? 0} ${AppLocalizations.of(context)!.kapi}",
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.musteriAdi,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(widget.customer.customerName!)
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.unvan,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Flexible(
                            child: Text(
                          widget.customer.unvan!,
                          textAlign: TextAlign.right,
                        ))
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.kanalTipi,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(AppLocalizations.of(context)!.digerleri) //gruplar[widget.customer.musteriKanaliGrubu!] Buraya hard kod diğerleri bastık.
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.sapKodu,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(widget.customer.customerSapCode!.toString())
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.uzaklik,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(widget.customer.mesafe!.toString())
                      ],
                    ),
                    if (widget.customer.yetkili != null)
                      const SizedBox(
                        height: 10,
                      ),
                    if (widget.customer.yetkili != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.yetkili,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(widget.customer.yetkili!.toString())
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.satisMuduruAdi,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(widget.customer.satisMudurluguAdi!)
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.bayiDistributorAdi,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(widget.customer.bayiiDistributorAdi!)
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.il,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(widget.customer.il!)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: FooterPageWidget(tabBarController: widget.tabController, isPopEnabled: true),
    );
  }

  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }
}
