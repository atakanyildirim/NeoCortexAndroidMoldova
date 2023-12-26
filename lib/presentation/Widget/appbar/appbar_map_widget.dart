import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/dataaccess/visit_repository.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:neocortexapp/presentation/pages/camera_page.dart';
import 'package:neocortexapp/presentation/pages/survey_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

String selectedValue = "1";
bool isLoading = false;
bool ziyaret = false;
AppBar getMapPageAppbarWidget(
    List<Customer> filteredCustomers,
    TextEditingController searchController,
    bool showSearchBox,
    BuildContext context,
    Completer<GoogleMapController> mapController,
    Position? currentPosition,
    void Function() clearSearchBox,
    void Function() setStateCallback,
    Future<void> Function(String? customerLatitude, String? customerLongitude) setStateSearchBoxClicked,
    String? project_id,
    StopWatchTimer stopWatchTimer) {
  SharedPreferences.getInstance().then((value) {
    if(value.containsKey("ziyaret")){
      ziyaret = value.getBool("ziyaret")!;
    }
  });
  return AppBar(
      elevation: 0,
      toolbarHeight: searchController.text.isNotEmpty && showSearchBox ? MediaQuery.of(context).size.height * 0.65 : 80,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      title: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Material(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    elevation: 5,
                    child: TextField(
                      showCursor: true,
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      controller: searchController,
                      cursorColor: const Color.fromARGB(255, 214, 214, 214),
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          fillColor: const Color.fromARGB(30, 243, 243, 243),
                          filled: true,
                          border: const OutlineInputBorder(borderSide: BorderSide.none),
                          labelText: AppLocalizations.of(context)!.arama,
                          labelStyle: const TextStyle(color: Colors.grey),
                          suffixIcon: IconButton(
                            onPressed: () {
                              clearSearchBox();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                          prefixIcon: const Icon(Icons.search)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: GestureDetector(
                      onTap: () {
                        if (currentPosition != null) {
                          mapController.future.then((controller) => controller.animateCamera(
                              CameraUpdate.newCameraPosition(CameraPosition(
                                  zoom: 15, target: LatLng(currentPosition.latitude, currentPosition.longitude)))));
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(110, 0, 0, 0),
                              blurRadius: 10,
                              offset: Offset(1, 1), // Shadow position
                            ),
                          ],
                          color: const Color.fromARGB(255, 243, 243, 243),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(10),
                        height: 56,
                        width: 58,
                        child: const Icon(
                          Icons.near_me,
                          color: anaRenkLight,
                        ),
                      )),
                ),
              ],
            ),
            Visibility(
              visible: searchController.text.isNotEmpty && showSearchBox,
              child: Card(
                margin: const EdgeInsets.only(top: 10),
                child: TapRegion(
                  onTapOutside: (event) {
                    setStateCallback();
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: SingleChildScrollView(
                      child: ListView.builder(
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: filteredCustomers.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                                onTap: () async {
                                  await setStateSearchBoxClicked(filteredCustomers[index].customerLatitude,
                                          filteredCustomers[index].customerLongitude)
                                      .whenComplete(() {
                                    showDialog(
                                      barrierColor: Colors.transparent,
                                      context: context,
                                      builder: (context) => Padding(
                                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1),
                                        child: AlertDialog(
                                          contentPadding: const EdgeInsets.all(15),
                                          insetPadding: const EdgeInsets.all(20),
                                          alignment: Alignment.bottomCenter,
                                          backgroundColor: const Color.fromARGB(223, 255, 255, 255),
                                          content: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    filteredCustomers[index].customerName!,
                                                    style: const TextStyle(
                                                        fontSize: 16, color: anaRenk, fontWeight: FontWeight.w400),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      color: anaRenk,
                                                    ),
                                                    padding: const EdgeInsets.all(3),
                                                    child: Text(
                                                      filteredCustomers[index].mesafe!,
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 3, bottom: 4),
                                                child: Text(
                                                  textAlign: TextAlign.left,
                                                  filteredCustomers[index].sevkAdresi ?? "",
                                                  style: const TextStyle(
                                                      fontSize: 14, color: anaRenk, fontWeight: FontWeight.w400),
                                                ),
                                              ),
                                              (filteredCustomers[index].lastVisitDateTime != null &&
                                                      DateTime.parse(filteredCustomers[index].lastVisitDateTime!)
                                                              .month ==
                                                          DateTime.now().month)
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
                                                              style: TextStyle(
                                                                  color: Color.fromARGB(255, 0, 77, 140), fontSize: 11),
                                                            ),
                                                            Text(
                                                              filteredCustomers[index].lastVisitDateTime != null
                                                                  ? DateFormat("dd-MM-yyyy HH:MM").format(
                                                                      DateTime.parse(
                                                                          filteredCustomers[index].lastVisitDateTime!))
                                                                  : "-",
                                                              style: const TextStyle(
                                                                  color: Color.fromARGB(255, 0, 77, 140), fontSize: 11),
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
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10.0)),
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
                                                          final coords = Coords(
                                                              double.parse(
                                                                  filteredCustomers[index].customerLatitude.toString()),
                                                              double.parse(filteredCustomers[index]
                                                                  .customerLongitude
                                                                  .toString()));
                                                          final title =
                                                              filteredCustomers[index].customerName.toString();
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
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10.0)),
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
                                                          AuthenticateManager authenticateManager =
                                                              AuthenticateManager();
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
                                                                      title:
                                                                          Text(filteredCustomers[index].customerName!),
                                                                      actions: [
                                                                        ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                                backgroundColor: anaRenk),
                                                                            onPressed: ziyaret
                                                                                ? null
                                                                                : () async {
                                                                                    final prefs =
                                                                                        await SharedPreferences
                                                                                            .getInstance();
                                                                                    prefs.setBool("ziyaret", true);
                                                                                    prefs.setString("ziyaretBaslangic",
                                                                                        DateTime.now().toString());
                                                                                    prefs.setString(
                                                                                        "customerVisit",
                                                                                        filteredCustomers[index]
                                                                                            .customerSapCode
                                                                                            .toString());
                                                                                    stopWatchTimer.onResetTimer();
                                                                                    stopWatchTimer.onStartTimer();
                                                                                    setState(() {
                                                                                      ziyaret = true;
                                                                                    });
                                                                                  },
                                                                            child: Row(
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment.center,
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.center,
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
                                                                                  AppLocalizations.of(context)!
                                                                                      .islemeBasla,
                                                                                  style: const TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            )),
                                                                        ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                                backgroundColor: anaRenk),
                                                                            onPressed: !ziyaret
                                                                                ? null
                                                                                : () async {
                                                                                    var prefs = await SharedPreferences
                                                                                        .getInstance();
                                                                                    if (prefs.getString(
                                                                                            "customerVisit") ==
                                                                                        filteredCustomers[index]
                                                                                            .customerSapCode
                                                                                            .toString()) {
                                                                                      // ignore: use_build_context_synchronously
                                                                                      Navigator.push(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                              builder: (context) =>
                                                                                                  SurveyPage(
                                                                                                    customerSurvey:
                                                                                                        filteredCustomers[
                                                                                                            index],
                                                                                                  )));
                                                                                    } else {
                                                                                      // ignore: use_build_context_synchronously
                                                                                      showDialog(
                                                                                        context: context,
                                                                                        builder: (context) {
                                                                                          return AlertDialog(
                                                                                            title: Text(
                                                                                                AppLocalizations.of(
                                                                                                        context)!
                                                                                                    .uyari),
                                                                                            actions: [
                                                                                              ElevatedButton(
                                                                                                  style: ElevatedButton
                                                                                                      .styleFrom(
                                                                                                          backgroundColor:
                                                                                                              anaRenk),
                                                                                                  onPressed: () =>
                                                                                                      Navigator.of(
                                                                                                              context)
                                                                                                          .pop(),
                                                                                                  child: Text("Ok"))
                                                                                            ],
                                                                                            content: Text(
                                                                                                "Lütfen önce ziyareti bitiriniz"),
                                                                                          );
                                                                                        },
                                                                                      );
                                                                                    }
                                                                                  },
                                                                            child: Row(
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment.center,
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.center,
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
                                                                                  AppLocalizations.of(context)!
                                                                                      .anketeBasla,
                                                                                  style: const TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            )),
                                                                        ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                                backgroundColor: anaRenk),
                                                                            onPressed: !ziyaret
                                                                                ? null
                                                                                : () async {
                                                                                    var prefs = await SharedPreferences
                                                                                        .getInstance();
                                                                                    if (prefs.getString(
                                                                                            "customerVisit") ==
                                                                                        filteredCustomers[index]
                                                                                            .customerSapCode
                                                                                            .toString()) {
                                                                                      await availableCameras().then(
                                                                                          (value) => Navigator.push(
                                                                                              context,
                                                                                              MaterialPageRoute(
                                                                                                  builder: (_) => CameraPage(
                                                                                                      cameras: value,
                                                                                                      customerDetail:
                                                                                                          filteredCustomers[
                                                                                                              index]))));
                                                                                    } else {
                                                                                      // ignore: use_build_context_synchronously
                                                                                      showDialog(
                                                                                        context: context,
                                                                                        builder: (context) {
                                                                                          return AlertDialog(
                                                                                            title: Text(
                                                                                                AppLocalizations.of(
                                                                                                        context)!
                                                                                                    .uyari),
                                                                                            actions: [
                                                                                              ElevatedButton(
                                                                                                  style: ElevatedButton
                                                                                                      .styleFrom(
                                                                                                          backgroundColor:
                                                                                                              anaRenk),
                                                                                                  onPressed: () =>
                                                                                                      Navigator.of(
                                                                                                              context)
                                                                                                          .pop(),
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
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment.center,
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.center,
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
                                                                                  AppLocalizations.of(context)!
                                                                                      .fotografCek,
                                                                                  style: const TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            )),
                                                                        ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                                backgroundColor: anaRenk),
                                                                            onPressed: () {
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  return StatefulBuilder(
                                                                                    builder: (context, setState) {
                                                                                      return AlertDialog(
                                                                                        title: const Text(
                                                                                            "İptal Nedeni Seç"),
                                                                                        content: FutureBuilder(
                                                                                          future: VisitRepository
                                                                                              .getVisitReasons(),
                                                                                          builder: (context, snapshot) {
                                                                                            if (snapshot.hasData) {
                                                                                              List<
                                                                                                      DropdownMenuItem<
                                                                                                          String>>
                                                                                                  list = [];
                                                                                              var data = jsonDecode(
                                                                                                  snapshot.data!);
                                                                                              for (var i = 0;
                                                                                                  i <
                                                                                                      data["content"]
                                                                                                          .length;
                                                                                                  i++) {
                                                                                                list.add(
                                                                                                    DropdownMenuItem(
                                                                                                  value: data["content"]
                                                                                                          [i]["id"]
                                                                                                      .toString(),
                                                                                                  child: Text(
                                                                                                      data["content"][i]
                                                                                                          ["value"]),
                                                                                                ));
                                                                                              }
                                                                                              return DropdownButton(
                                                                                                hint: Text(
                                                                                                  AppLocalizations.of(
                                                                                                          context)!
                                                                                                      .seciniz,
                                                                                                  softWrap: false,
                                                                                                  overflow:
                                                                                                      TextOverflow.clip,
                                                                                                ),
                                                                                                items: list,
                                                                                                value: selectedValue,
                                                                                                onChanged: (value) {
                                                                                                  setState(() {
                                                                                                    selectedValue =
                                                                                                        value!;
                                                                                                  });
                                                                                                },
                                                                                              );
                                                                                            }
                                                                                            return const Text(
                                                                                                "Lütfen Bekleyiniz...");
                                                                                          },
                                                                                        ),
                                                                                        actions: [
                                                                                          ElevatedButton(
                                                                                              style: ElevatedButton
                                                                                                  .styleFrom(
                                                                                                      backgroundColor:
                                                                                                          anaRenk),
                                                                                              onPressed: isLoading
                                                                                                  ? null
                                                                                                  : () async {
                                                                                                      SharedPreferences
                                                                                                          prefs =
                                                                                                          await SharedPreferences
                                                                                                              .getInstance();
                                                                                                      setState(
                                                                                                        () {
                                                                                                          isLoading =
                                                                                                              true;
                                                                                                        },
                                                                                                      );
                                                                                                      bool isSuccess = await VisitRepository.sendVisitReason(
                                                                                                          prefs.getString(
                                                                                                              "customerVisit")!,
                                                                                                          selectedValue
                                                                                                              .toString());
                                                                                                      if (isSuccess) {
                                                                                                        // ignore: use_build_context_synchronously
                                                                                                        showDialog(
                                                                                                          context:
                                                                                                              context,
                                                                                                          builder:
                                                                                                              (context) {
                                                                                                            return AlertDialog(
                                                                                                              actions: [
                                                                                                                ElevatedButton(
                                                                                                                    style:
                                                                                                                        ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                                                                                                    onPressed: () {
                                                                                                                      Navigator.of(context).pop();
                                                                                                                      Navigator.of(context).pop();
                                                                                                                    },
                                                                                                                    child: const Text("OK"))
                                                                                                              ],
                                                                                                              title: const Text(
                                                                                                                  "Durum"),
                                                                                                              content:
                                                                                                                  const Text(
                                                                                                                      "Başarıyla Gönderildi"),
                                                                                                            );
                                                                                                          },
                                                                                                        );
                                                                                                        setState(() {
                                                                                                          isLoading =
                                                                                                              false;
                                                                                                        });
                                                                                                      }
                                                                                                    },
                                                                                              child: Text(
                                                                                                  AppLocalizations.of(
                                                                                                          context)!
                                                                                                      .gonder))
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                },
                                                                              );
                                                                            },
                                                                            child: Row(
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment.center,
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.center,
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
                                                                                  AppLocalizations.of(context)!
                                                                                      .ziyaretEdememeNedeni,
                                                                                  style: const TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            )),
                                                                        Visibility(
                                                                          visible: ziyaret,
                                                                          child: ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: const Color.fromARGB(
                                                                                      255, 173, 42, 32)),
                                                                              onPressed: isLoading
                                                                                  ? null
                                                                                  : () async {
                                                                                      setState(
                                                                                        () {
                                                                                          isLoading = true;
                                                                                        },
                                                                                      );
                                                                                      final prefs =
                                                                                          await SharedPreferences
                                                                                              .getInstance();
                                                                                      AuthenticateManager
                                                                                          authenticateManager =
                                                                                          AuthenticateManager();
                                                                                      await authenticateManager.init();
                                                                                      bool isSuccess =
                                                                                          await VisitRepository.finishVisit(
                                                                                              filteredCustomers[index]
                                                                                                  .customerSapCode
                                                                                                  .toString(),
                                                                                              authenticateManager
                                                                                                  .getEmail()!,
                                                                                              prefs.getString(
                                                                                                  "ziyaretBaslangic")!);
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
                                                                                                      Navigator.of(
                                                                                                              context)
                                                                                                          .pop();
                                                                                                      Navigator.of(
                                                                                                              context)
                                                                                                          .pop();
                                                                                                    },
                                                                                                    child: const Text(
                                                                                                        "OK"))
                                                                                              ],
                                                                                              title: Text(
                                                                                                  AppLocalizations.of(
                                                                                                          context)!
                                                                                                      .durum),
                                                                                              content: const Text(
                                                                                                  "Başarıyla Ziyaret Tamamlandı"),
                                                                                            );
                                                                                          },
                                                                                        );
                                                                                        setState(() {
                                                                                          isLoading = false;
                                                                                        });
                                                                                      }
                                                                                      await prefs.setBool(
                                                                                          "ziyaret", false);
                                                                                      setState(() {
                                                                                        ziyaret = false;
                                                                                      });
                                                                                    },
                                                                              child: Row(
                                                                                crossAxisAlignment:
                                                                                    CrossAxisAlignment.center,
                                                                                mainAxisAlignment:
                                                                                    MainAxisAlignment.center,
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
                                                                                    AppLocalizations.of(context)!
                                                                                        .ziyaretiBitir,
                                                                                    style: const TextStyle(
                                                                                        color: Colors.white,
                                                                                        fontSize: 12),
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
                                                                    builder: (_) => CameraPage(
                                                                        cameras: value,
                                                                        customerDetail: filteredCustomers[index]))));
                                                          }
                                                        }),
                                                  ),
                                                ].expand((x) => [const SizedBox(width: 5), x]).skip(1).toList(),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                                },
                                title: Text(
                                  filteredCustomers[index].customerName.toString(),
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                ));
                          }),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ));
}
