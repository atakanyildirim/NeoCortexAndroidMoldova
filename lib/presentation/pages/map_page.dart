import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/dataaccess/visit_repository.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:neocortexapp/presentation/Widget/homepage/footer.dart';
import 'package:neocortexapp/presentation/pages/camera_page.dart';
import 'package:neocortexapp/presentation/pages/survey_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:turkish/turkish.dart';

import '../Widget/appbar/appbar_map_widget.dart';

class MapPage extends StatefulWidget {
  final TabController tabController;
  final Position? position;
  final List<Customer> customers;
  final StopWatchTimer stopWatchtimer;
  const MapPage(
      {super.key, required this.tabController, required this.customers, this.position, required this.stopWatchtimer});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin<MapPage> {
  final Completer<google.GoogleMapController> mapController = Completer<google.GoogleMapController>();
  TextEditingController searchController = TextEditingController();
  bool showSearchBox = false;
  google.BitmapDescriptor currentMarkerIcon = google.BitmapDescriptor.defaultMarker;
  List<Customer> filteredCustomers = List.empty();
  AuthenticateManager? authenticateManager;
  String selectedValue = "1";
  bool isLoading = false;
  bool ziyaret = false;
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      if(value.containsKey("ziyaret")){
        ziyaret = value.getBool("ziyaret")!;
      }
    });
    authenticateManager = AuthenticateManager();
    authenticateManager!.init().asStream();
    setCurrentMarker();

    searchController.addListener(() {
      setState(() {
        showSearchBox = true;
        filteredCustomers = widget.customers;
        if (widget.customers.isNotEmpty) {
          filteredCustomers = widget.customers
              .where((element) =>
                  (element.customerName!).toLowerCaseTr().contains(searchController.text.toLowerCaseTr()) ||
                  (element.customerSapCode.toString()).toLowerCaseTr().contains(searchController.text.toLowerCaseTr()))
              .toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        bottomNavigationBar: FooterPageWidget(tabBarController: widget.tabController, isPopEnabled: false),
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: getMapPageAppbarWidget(
            filteredCustomers,
            searchController,
            showSearchBox,
            context,
            mapController,
            widget.position,
            clearSearchBox,
            setStateCallback,
            setStateSearchBoxClicked,
            authenticateManager!.getProjectId().toString(),
            widget.stopWatchtimer),
        body: widget.position != null
            ? google.GoogleMap(
                myLocationButtonEnabled: false,
                mapType: google.MapType.normal,
                compassEnabled: false,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                markers: getMarkers(),
                initialCameraPosition: google.CameraPosition(
                    zoom: 15, target: google.LatLng(widget.position!.latitude, widget.position!.longitude)),
                onMapCreated: (google.GoogleMapController controller) {
                  mapController.complete(controller);
                },
              )
            : Center(
                child: Shimmer.fromColors(
                    baseColor: const Color.fromARGB(255, 168, 168, 168),
                    highlightColor: Colors.grey.shade100,
                    enabled: true,
                    child: Text(
                      AppLocalizations.of(context)!.haritaYukleniyor,
                      style: const TextStyle(fontSize: 20),
                    )),
              ));
  }

  Set<google.Marker> getMarkers() {
    Set<google.Marker> markes = {};
    markes.add(google.Marker(
      position: google.LatLng(widget.position!.latitude, widget.position!.longitude),
      infoWindow: google.InfoWindow(
        title: "NeoCortex",
        snippet: AppLocalizations.of(context)!.suankiKonumum,
      ),
      markerId: const google.MarkerId("home"),
      icon: currentMarkerIcon,
    ));
    // ignore: avoid_function_literals_in_foreach_calls
    widget.customers.forEach((customer) async {
      String img = "";
      customer.musteriKanaliGrubu = 7; //  Burası hard kod kaldırlacak 
      switch (customer.musteriKanaliGrubu) {
        case 1:
          img = customer.lastVisitDateTime != null &&
                  DateTime.parse(customer.lastVisitDateTime!).month == DateTime.now().month
              ? "assets/images/map2ok.png"
              : "assets/images/map2mavi.png";
          break;
        case 2:
          img = customer.lastVisitDateTime != null &&
                  DateTime.parse(customer.lastVisitDateTime!).month == DateTime.now().month
              ? "assets/images/map1ok.png"
              : "assets/images/map1mor.png";
          break;
        case 3:
          img = customer.lastVisitDateTime != null &&
                  DateTime.parse(customer.lastVisitDateTime!).month == DateTime.now().month
              ? "assets/images/eco_miniok.png"
              : "assets/images/eco_mini.png";
          break;
        case 4:
          img = customer.lastVisitDateTime != null &&
                  DateTime.parse(customer.lastVisitDateTime!).month == DateTime.now().month
              ? "assets/images/map4ok.png"
              : "assets/images/carrefour.png";
          break;
        case 5:
          img = customer.lastVisitDateTime != null &&
                  DateTime.parse(customer.lastVisitDateTime!).month == DateTime.now().month
              ? "assets/images/map5ok.png"
              : "assets/images/migros.png";
          break;
        case 6:
          img = customer.lastVisitDateTime != null &&
                  DateTime.parse(customer.lastVisitDateTime!).month == DateTime.now().month
              ? "assets/images/map6ok.png"
              : "assets/images/macrocenter.png";
          break;
        case 7:
          img = customer.lastVisitDateTime != null &&
                  DateTime.parse(customer.lastVisitDateTime!).month == DateTime.now().month
              ? "assets/images/map7ok.png"
              : "assets/images/diger.png";
          break;
        default:
      }

      markes.add(google.Marker(
          onTap: () => showDialog(
                barrierColor: Colors.transparent,
                context: context,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.all(15),
                        insetPadding: const EdgeInsets.all(20),
                        alignment: Alignment.bottomCenter,
                        backgroundColor: const Color.fromARGB(223, 255, 255, 255),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    customer.customerName!,
                                    style: const TextStyle(fontSize: 16, color: anaRenk, fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: anaRenk,
                                  ),
                                  padding: const EdgeInsets.all(3),
                                  child: Text(
                                    customer.mesafe!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3, bottom: 4),
                              child: Text(
                                customer.sevkAdresi ?? "",
                                style: const TextStyle(fontSize: 14, color: anaRenk, fontWeight: FontWeight.w400),
                              ),
                            ),
                            (customer.lastVisitDateTime != null &&
                                    DateTime.parse(customer.lastVisitDateTime!).month == DateTime.now().month)
                                ? Container(
                                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: anaAcikRenk,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Son Ziyaret",
                                            style: TextStyle(color: Color.fromARGB(255, 0, 77, 140), fontSize: 13),
                                          ),
                                          Text(
                                            customer.lastVisitDateTime != null
                                                ? DateFormat("dd-MM-yyyy HH:MM")
                                                    .format(DateTime.parse(customer.lastVisitDateTime!))
                                                : "-",
                                            style:
                                                const TextStyle(color: Color.fromARGB(255, 0, 77, 140), fontSize: 13),
                                          )
                                        ],
                                      ),
                                    ))
                                : const Text(""),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(0),
                                      foregroundColor: Colors.white,
                                      backgroundColor: anaRenk,
                                      shadowColor: Colors.greenAccent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                      minimumSize: const Size(300, 40),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.near_me, size: 20),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.yolTarifiAl,
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                        )
                                      ],
                                    ),
                                    onPressed: () async {
                                      try {
                                        final coords = Coords(double.parse(customer.customerLatitude.toString()),
                                            double.parse(customer.customerLongitude.toString()));
                                        final title = customer.customerName.toString();
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
                                  ),
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: anaRenk,
                                      shadowColor: Colors.greenAccent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                      minimumSize: const Size(300, 40),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.camera_alt_sharp,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.islemeBasla,
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    onPressed: () async {
                                      var prefs = await SharedPreferences.getInstance();

                                      setState(() {
                                        ziyaret = prefs.getBool("ziyaret")!;
                                      });
                                      Navigator.of(context).pop();
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
                                                  title: Text(customer.customerName!),
                                                  actions: [
                                                    ElevatedButton(
                                                        style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                                        onPressed: ziyaret
                                                            ? null
                                                            : () async {
                                                                final prefs = await SharedPreferences.getInstance();
                                                                prefs.setBool("ziyaret", true);
                                                                prefs.setString(
                                                                    "ziyaretBaslangic", DateTime.now().toString());
                                                                prefs.setString("customerVisit",
                                                                    customer.customerSapCode.toString());
                                                                widget.stopWatchtimer.onResetTimer();
                                                                widget.stopWatchtimer.onStartTimer();
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
                                                                    customer.customerSapCode.toString()) {
                                                                  // ignore: use_build_context_synchronously
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => SurveyPage(
                                                                                customerSurvey: customer,
                                                                              )));
                                                                } else {
                                                                  // ignore: use_build_context_synchronously
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (context) {
                                                                      return AlertDialog(
                                                                        title:
                                                                            Text(AppLocalizations.of(context)!.uyari),
                                                                        actions: [
                                                                          ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: anaRenk),
                                                                              onPressed: () =>
                                                                                  Navigator.of(context).pop(),
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
                                                                    customer.customerSapCode.toString()) {
                                                                  await availableCameras().then((value) =>
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (_) => CameraPage(
                                                                                  cameras: value,
                                                                                  customerDetail: customer))));
                                                                } else {
                                                                  // ignore: use_build_context_synchronously
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (context) {
                                                                      return AlertDialog(
                                                                        title:
                                                                            Text(AppLocalizations.of(context)!.uyari),
                                                                        actions: [
                                                                          ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: anaRenk),
                                                                              onPressed: () =>
                                                                                  Navigator.of(context).pop(),
                                                                              child: Text("Ok"))
                                                                        ],
                                                                        content: const Text(
                                                                            "Lütfen önce ziyareti bitiriniz"),
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
                                                                          for (var i = 0;
                                                                              i < data["content"].length;
                                                                              i++) {
                                                                            list.add(DropdownMenuItem(
                                                                              value:
                                                                                  data["content"][i]["id"].toString(),
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
                                                                          style: ElevatedButton.styleFrom(
                                                                              backgroundColor: anaRenk),
                                                                          onPressed: isLoading
                                                                              ? null
                                                                              : () async {
                                                                                  SharedPreferences prefs =
                                                                                      await SharedPreferences
                                                                                          .getInstance();
                                                                                  setState(
                                                                                    () {
                                                                                      isLoading = true;
                                                                                    },
                                                                                  );
                                                                                  bool isSuccess = await VisitRepository
                                                                                      .sendVisitReason(
                                                                                          prefs.getString(
                                                                                              "customerVisit")!,
                                                                                          selectedValue.toString());
                                                                                  if (isSuccess) {
                                                                                    // ignore: use_build_context_synchronously
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (context) {
                                                                                        return AlertDialog(
                                                                                          actions: [
                                                                                            ElevatedButton(
                                                                                                style: ElevatedButton
                                                                                                    .styleFrom(
                                                                                                        backgroundColor:
                                                                                                            anaRenk),
                                                                                                onPressed: () {
                                                                                                  Navigator.of(context)
                                                                                                      .pop();
                                                                                                  Navigator.of(context)
                                                                                                      .pop();
                                                                                                },
                                                                                                child: const Text("OK"))
                                                                                          ],
                                                                                          title: const Text("Durum"),
                                                                                          content: const Text(
                                                                                              "Başarıyla Gönderildi"),
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                    setState(() {
                                                                                      isLoading = false;
                                                                                    });
                                                                                  }
                                                                                },
                                                                          child: Text(
                                                                              AppLocalizations.of(context)!.gonder))
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
                                                                  AuthenticateManager authenticateManager =
                                                                      AuthenticateManager();
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
                                                                          title:
                                                                              Text(AppLocalizations.of(context)!.durum),
                                                                          content: const Text(
                                                                              "Başarıyla Ziyaret Tamamlandı"),
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
                                                                style:
                                                                    const TextStyle(color: Colors.white, fontSize: 12),
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
                                                builder: (_) => CameraPage(cameras: value, customerDetail: customer))));
                                      }
                                    },
                                  ),
                                ),
                              ].expand((x) => [const SizedBox(width: 5), x]).skip(1).toList(),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          markerId: google.MarkerId(customer.customerSapCode.toString()),
          position: google.LatLng(double.parse(customer.customerLatitude!), double.parse(customer.customerLongitude!)),
          icon: await google.BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, img)));
    });
    return markes;
  }

  void clearSearchBox() {
    searchController.clear();
    setState(() {});
  }

  Future<void> setStateSearchBoxClicked(String? customerLatitude, String? customerLongitude) async {
    mapController.future.then((controller) {
      controller.animateCamera(google.CameraUpdate.newLatLngZoom(
          google.LatLng(double.parse(customerLatitude!), double.parse(customerLongitude!)), 15));
      setState(() {
        showSearchBox = false;
      });
    });
  }

  void setStateCallback() {
    setState(() {
      showSearchBox = false;
    });
  }

  void setCurrentMarker() {
    google.BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(32, 32), devicePixelRatio: 1), "assets/images/logoSmall.png")
        .then(
      (icon) {
        setState(() {
          currentMarkerIcon = icon;
        });
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
