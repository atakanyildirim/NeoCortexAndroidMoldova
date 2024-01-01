import 'dart:convert';
import 'dart:io';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:need_resume/need_resume.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/business/planogram_manager.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/core/db/db_helper.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:neocortexapp/presentation/pages/home_page.dart';
import 'package:neocortexapp/presentation/pages/image_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class ImagesPage extends StatefulWidget {
  const ImagesPage({Key? key, required this.customerDetail}) : super(key: key);
  final Customer customerDetail;
  // ignore: library_private_types_in_public_api, annotate_overrides, no_logic_in_create_state
  _ImagesPageState createState() => _ImagesPageState(customerDetail);
}

class _ImagesPageState extends ResumableState<ImagesPage> with TickerProviderStateMixin {
  Customer customerDetail;
  AuthenticateManager? authenticateManager;

  bool isSuccess = false;
  _ImagesPageState(this.customerDetail);
  late AnimationController controller;
  var helper = DbHelper();
  // ignore: prefer_typing_uninitialized_variables
  var userId;
  @override
  void initState() {
    authenticateManager = AuthenticateManager();
    authenticateManager!.init().asStream();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    //controller.repeat(reverse: false);

    getPictureList();
    super.initState();
  }

  final Stopwatch _stopwatch = Stopwatch();

  void startTimer() {
    setState(() {
      _stopwatch.start();
    });
  }

  var debug = false; // Webde sqflite çalışmıyor . bu yüzden bu parameter var .
  var dolap = [];
  var teshir = [];
  var tabela = [];
  var sicak = [];
  var topluSil = false;
  var silinecekler = [];

  var dolapTamam = 0;
  var teshirTamam = 0;
  var tabelaTamam = 0;
  var sicakTamam = 0;

  var upload = false;
  var completed = false;

  Future uploadDolapImage() async {
    AuthenticateManager authenticateManager = AuthenticateManager();
    await authenticateManager.init();
    setState(() {
      upload = true;
    });

    if (debug == false) {
      List<File> files = [];
      var filenames = [];
      String? userId = authenticateManager.getUserID();

      var i = 1;
      for (var element in dolap) {
        var fileName = "${element['udate'].substring(0, 10)}-${element['customerCode']}-$userId-C-$i.jpg";

        files.add(File(element["image"]));
        filenames.add(fileName);
        i++;
      }

      String? token = authenticateManager.getToken();
      String? project_id = authenticateManager.getProjectId();

      String apiUrl = '${AppConfig.baseApiUrl}/mobuploadimageswithvariableplanograms';
      var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));
      final headers = {"Content-type": "multipart/form-data", "token": "$token", "project_id": "$project_id"};

      var z = 0;
      for (var file in files) {
        var filename = filenames[z];
        http.MultipartFile multipartFile =
            http.MultipartFile('file', file.readAsBytes().asStream(), file.lengthSync(), filename: "$filename");

        request.files.add(multipartFile);
        z++;
      }
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final respStr = await response.stream.bytesToString();
      var json = jsonDecode(respStr);
      if (response.statusCode == 401) {
        // ignore: use_build_context_synchronously
        await AuthenticateManager.logout(context);
      }
      setState(() {
        upload = false;
      });
      if (json["Status"] == "Normal") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('dolapdata', respStr);
        setState(() {
          dolapTamam = 1;
        });
        return true;
      } else {
        setState(() {
          dolapTamam = 2;
        });
        mesajGoster("Dolap Analiz Hatası : ${json["Content"]}");
      }
    } else {
      final String respStr = await rootBundle.loadString('assets/test.json');
      var json = jsonDecode(respStr);

      await writeDataToFile("Dolap json : ${respStr}");
      setState(() {
        upload = false;
      });
      if (json["Status"] == "Normal") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('dolapdata', respStr);
        return true;
      } else {
        mesajGoster(json["Content"]);
      }
    }
  }

  Future uploadTeshirImage() async {
    setState(() {
      upload = true;
    });
    AuthenticateManager authenticateManager = AuthenticateManager();
    await authenticateManager.init();

    List<File> files = [];
    var filenames = [];

    String? userId = authenticateManager.getUserID();

    var k = 1;
    for (var element in teshir) {
      var fileName = "${element['udate'].substring(0, 10)}-${element['customerCode']}-$userId-D-$k.jpg";

      files.add(File(element["image"]));
      filenames.add(fileName);
      k++;
    }

    String? token = authenticateManager.getToken();
    String? project_id = authenticateManager.getProjectId();

    String apiUrl = '${AppConfig.baseApiUrl}/mobuploaddisplayimages';
    var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));
    final headers = {"Content-type": "multipart/form-data", "token": "$token", "project_id": "$project_id"};

    var z = 0;
    for (var file in files) {
      var filename = filenames[z];
      http.MultipartFile multipartFile =
          http.MultipartFile('file', file.readAsBytes().asStream(), file.lengthSync(), filename: "$filename");

      request.files.add(multipartFile);
      z++;
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 401) {
      // ignore: use_build_context_synchronously
      await AuthenticateManager.logout(context);
    }
    final respStr = await response.stream.bytesToString();

    var json = jsonDecode(respStr);
    await writeDataToFile("Teşhir json : ${respStr}");
    setState(() {
      upload = false;
    });
    if (json["Status"] == "Normal") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teshirdata', respStr);
      setState(() {
        teshirTamam = 1;
      });
      return true;
    } else {
      setState(() {
        teshirTamam = 2;
      });
      mesajGoster("Teşhir Analiz Hatası : ${json["Content"]}");
    }
  }

  Future uploadTabelaImage() async {
    setState(() {
      upload = true;
    });

    AuthenticateManager authenticateManager = AuthenticateManager();
    await authenticateManager.init();

    List<File> files = [];
    var filenames = [];
    String? userId = authenticateManager.getUserID();

    var j = 1;
    for (var element in tabela) {
      var fileName = "${element['udate'].substring(0, 10)}-${element['customerCode']}-$userId-S-$j.jpg";

      files.add(File(element["image"]));
      filenames.add(fileName);
      j++;
    }

    String? token = authenticateManager.getToken();
    String? project_id = authenticateManager.getProjectId();

    String apiUrl = '${AppConfig.baseApiUrl}/mobuploadsignimages';
    var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));
    final headers = {"Content-type": "multipart/form-data", "token": "$token", "project_id": "$project_id"};

    var z = 0;
    for (var file in files) {
      var filename = filenames[z];
      http.MultipartFile multipartFile =
          http.MultipartFile('file', file.readAsBytes().asStream(), file.lengthSync(), filename: "$filename");

      request.files.add(multipartFile);
      z++;
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 401) {
      // ignore: use_build_context_synchronously
      await AuthenticateManager.logout(context);
    }
    final respStr = await response.stream.bytesToString();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tabeladata', respStr);
    var json = jsonDecode(respStr);
    await writeDataToFile("Tabela json : ${respStr}");
    setState(() {
      upload = false;
    });
    if (json["Status"] == "Normal") {
      setState(() {
        tabelaTamam = 1;
      });
      return true;
    } else {
      setState(() {
        tabelaTamam = 2;
      });
      mesajGoster("Tabela Analiz Hatası : ${json["Content"]}");
    }
  }

  Future uploadSicakImage() async {
    setState(() {
      upload = true;
    });

    AuthenticateManager authenticateManager = AuthenticateManager();
    await authenticateManager.init();

    List<File> files = [];
    var filenames = [];
    String? userId = authenticateManager.getUserID();

    var j = 1;
    for (var element in sicak) {
      var fileName = "${element['udate'].substring(0, 10)}-${element['customerCode']}-$userId-SH-$j.jpg";

      files.add(File(element["image"]));
      filenames.add(fileName);
      j++;
    }

    String? token = authenticateManager.getToken();
    String? project_id = authenticateManager.getProjectId();

    String apiUrl = '${AppConfig.baseApiUrl}/mobuploadshelfimages';
    var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));
    final headers = {"Content-type": "multipart/form-data", "token": "$token", "project_id": "$project_id"};

    var z = 0;
    for (var file in files) {
      var filename = filenames[z];
      http.MultipartFile multipartFile =
          http.MultipartFile('file', file.readAsBytes().asStream(), file.lengthSync(), filename: "$filename");

      request.files.add(multipartFile);
      z++;
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 401) {
      // ignore: use_build_context_synchronously
      await AuthenticateManager.logout(context);
    }
    final respStr = await response.stream.bytesToString();

    var json = jsonDecode(respStr);
    await writeDataToFile("Sıcak Raf json : ${respStr}");
    setState(() {
      upload = false;
    });
    if (json["Status"] == "Normal") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sicakdata', respStr);
      setState(() {
        sicakTamam = 1;
      });
      return true;
    } else {
      setState(() {
        sicakTamam = 2;
      });
      mesajGoster("Sıcak Raf Analiz Hatası : ${json["Content"]}");
    }
  }

  Future<void> writeDataToFile(String data) async {
    //debugPrint(data);
  }

  mesajGoster(String mesaj) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.hata),
        content: Text(mesaj),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, AppLocalizations.of(context)!.devamEt),
            child: Text(AppLocalizations.of(context)!.devamEt),
          ),
        ],
      ),
    );
  }

  Future<void> getPictureList() async {
    if (debug == true) {
      dolap.add({
        "customerCode": 2137569,
        "planogram_category_colors": await PlanogramManager.getCachedPlanogramCategoryColors(),
        "target_planogram_for_this_customer": customerDetail.target_planogram_for_this_customer,
        "customerName": customerDetail.customerName,
        "customerAdress": customerDetail.sevkAdresi,
        "imageType": 1,
        "image": "assets/1696417127-2041235-551-C-1.jpg",
        "orderNumber": 1,
        "check": false,
        "udate": "16964171074"
      });

      dolap.add({
        "customerCode": 2137569,
        "planogram_category_colors": await PlanogramManager.getCachedPlanogramCategoryColors(),
        "target_planogram_for_this_customer": customerDetail.target_planogram_for_this_customer,
        "customerName": customerDetail.customerName,
        "customerAdress": customerDetail.sevkAdresi,
        "imageType": 1,
        "image": "assets/1696417107-2041235-551-C-2.jpg",
        "orderNumber": 1,
        "check": false,
        "udate": "16964171073"
      });

      setState(() {});
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        helper.getPictures(customerDetail.customerSapCode.toString()).then((value) {
          value?.forEach((element) async {
            if (element["imageType"] == 1) {
              dolap.add({
                "customerCode": element["customerCode"].toString(),
                "planogram_category_colors": await PlanogramManager.getCachedPlanogramCategoryColors(),
                "target_planogram_for_this_customer": customerDetail.target_planogram_for_this_customer,
                "customerName": customerDetail.customerName,
                "customerAdress": customerDetail.sevkAdresi,
                "imageType": element["imageType"],
                "image": element["image"].toString(),
                "orderNumber": element["orderNumber"].toString(),
                "check": false,
                "udate": element["udate"].toString(),
              });
            } else if (element["imageType"] == 2) {
              teshir.add({
                "customerCode": element["customerCode"].toString(),
                "planogram_category_colors": await PlanogramManager.getCachedPlanogramCategoryColors(),
                "target_planogram_for_this_customer": customerDetail.target_planogram_for_this_customer,
                "customerName": customerDetail.customerName,
                "customerAdress": customerDetail.sevkAdresi,
                "imageType": element["imageType"],
                "image": element["image"].toString(),
                "orderNumber": element["orderNumber"].toString(),
                "check": false,
                "udate": element["udate"].toString(),
              });
            } else if (element["imageType"] == 3) {
              tabela.add({
                "customerCode": element["customerCode"].toString(),
                "planogram_category_colors": await PlanogramManager.getCachedPlanogramCategoryColors(),
                "target_planogram_for_this_customer": customerDetail.target_planogram_for_this_customer,
                "customerName": customerDetail.customerName,
                "customerAdress": customerDetail.sevkAdresi,
                "imageType": element["imageType"],
                "image": element["image"].toString(),
                "orderNumber": element["orderNumber"].toString(),
                "check": false,
                "udate": element["udate"].toString(),
              });
            } else if (element["imageType"] == 4) {
              sicak.add({
                "customerCode": element["customerCode"].toString(),
                "planogram_category_colors": await PlanogramManager.getCachedPlanogramCategoryColors(),
                "target_planogram_for_this_customer": customerDetail.target_planogram_for_this_customer,
                "customerName": customerDetail.customerName,
                "customerAdress": customerDetail.sevkAdresi,
                "imageType": element["imageType"],
                "image": element["image"].toString(),
                "orderNumber": element["orderNumber"].toString(),
                "check": false,
                "udate": element["udate"].toString(),
              });
            }
          });
          setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          backgroundColor: anaRenk,
          title: Text(AppLocalizations.of(context)!.okumalar),
          actions: [
            upload == false
                ? completed == false
                    ? IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            topluSil = !topluSil;
                          });
                        },
                      )
                    : const Text("")
                : const Text(""),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dolap.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)!.dolap,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                    )
                  : const Padding(padding: EdgeInsets.all(8)),
              Container(
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: dolap.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ), // The size of the grid box
                  itemBuilder: (context, index) => Stack(
                    children: [
                      GestureDetector(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: (debug == false
                                ? GestureDetector(
                                    onTap: () {
                                      showImageViewer(context, Image.file(File(dolap[index]["image"])).image,
                                          swipeDismissible: true, doubleTapZoomable: true);
                                    },
                                    child: Image.file(
                                      File(dolap[index]["image"]),
                                      fit: BoxFit.cover,
                                      color: (dolapTamam == 1
                                          ? Colors.yellow.withOpacity(0.8)
                                          : (dolapTamam == 2
                                              ? Colors.red.withOpacity(0.8)
                                              : Colors.white.withOpacity(0.8))),
                                      colorBlendMode: BlendMode.modulate,
                                    ),
                                  )
                                : GestureDetector(
                                    child: Image.asset(
                                      dolap[index]["image"],
                                      fit: BoxFit.cover,
                                      color: Colors.white.withOpacity(0.8),
                                      colorBlendMode: BlendMode.modulate,
                                    ),
                                  )),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: false,
                        child: Positioned(
                            child: Expanded(
                          child: Container(
                            color: isSuccess ? const Color.fromARGB(81, 255, 235, 59) : Color.fromARGB(81, 244, 39, 39),
                          ),
                        )),
                      ),
                      upload == false
                          ? Positioned(
                              child: topluSil == false
                                  ? completed == false
                                      ? IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.white,
                                          onPressed: () {
                                            helper.deletePictures(dolap[index]["image"]);
                                            setState(() {
                                              dolap.removeWhere((item) => item["image"] == dolap[index]["image"]);
                                            });
                                          },
                                        )
                                      : Text("")
                                  : Checkbox(
                                      fillColor: MaterialStateProperty.all<Color>(Colors.white),
                                      checkColor: Colors.red,
                                      activeColor: Colors.white,
                                      value: dolap[index]["check"],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          dolap[index]["check"] = value!;
                                        });
                                        silinecekler.add(dolap[index]);
                                      },
                                    ),
                            )
                          : const Positioned(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                    ],
                  ),
                ),
              ),
              teshir.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)!.teshir,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                    )
                  : const Padding(padding: EdgeInsets.all(8)),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: teshir.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ), // The size of the grid box
                  itemBuilder: (context, index) => Stack(
                    children: [
                      GestureDetector(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: (debug == false
                                ? GestureDetector(
                                    onTap: () {
                                      showImageViewer(context, Image.file(File(teshir[index]["image"])).image,
                                          swipeDismissible: true, doubleTapZoomable: true);
                                    },
                                    child: Image.file(
                                      File(teshir[index]["image"]),
                                      fit: BoxFit.cover,
                                      color: (teshirTamam == 1
                                          ? Colors.yellow.withOpacity(0.8)
                                          : (teshirTamam == 2
                                              ? Colors.red.withOpacity(0.8)
                                              : Colors.white.withOpacity(0.8))),
                                      colorBlendMode: BlendMode.modulate,
                                    ),
                                  )
                                : Image.asset(
                                    teshir[index]["image"],
                                    fit: BoxFit.cover,
                                    color: Colors.white.withOpacity(0.8),
                                    colorBlendMode: BlendMode.modulate,
                                  )),
                          ),
                        ),
                      ),
                      upload == false
                          ? Positioned(
                              child: topluSil == false
                                  ? completed == false
                                      ? IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.white,
                                          onPressed: () {
                                            helper.deletePictures(teshir[index]["image"]);
                                            setState(() {
                                              teshir.removeWhere((item) => item["image"] == teshir[index]["image"]);
                                            });
                                          },
                                        )
                                      : const Text("")
                                  : Checkbox(
                                      fillColor: MaterialStateProperty.all<Color>(Colors.white),
                                      checkColor: Colors.red,
                                      activeColor: Colors.white,
                                      value: teshir[index]["check"],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          teshir[index]["check"] = value!;
                                        });
                                        silinecekler.add(teshir[index]);
                                      },
                                    ),
                            )
                          : const Positioned(child: Center(child: CircularProgressIndicator())),
                    ],
                  ),
                ),
              ),
              tabela.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)!.tabela,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                    )
                  : const Padding(padding: EdgeInsets.all(8)),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: tabela.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ), // The size of the grid box
                  itemBuilder: (context, index) => Stack(
                    children: [
                      GestureDetector(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: (debug == false
                                ? GestureDetector(
                                    onTap: () {
                                      showImageViewer(context, Image.file(File(tabela[index]["image"])).image,
                                          swipeDismissible: true, doubleTapZoomable: true);
                                    },
                                    child: Image.file(
                                      File(tabela[index]["image"]),
                                      fit: BoxFit.cover,
                                      color: (tabelaTamam == 1
                                          ? Colors.yellow.withOpacity(0.8)
                                          : (tabelaTamam == 2
                                              ? Colors.red.withOpacity(0.8)
                                              : Colors.white.withOpacity(0.8))),
                                      colorBlendMode: BlendMode.modulate,
                                    ),
                                  )
                                : Image.asset(
                                    tabela[index]["image"],
                                    fit: BoxFit.cover,
                                    color: Colors.white.withOpacity(0.8),
                                    colorBlendMode: BlendMode.modulate,
                                  )),
                          ),
                        ),
                      ),
                      upload == false
                          ? Positioned(
                              child: topluSil == false
                                  ? completed == false
                                      ? IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.white,
                                          onPressed: () {
                                            helper.deletePictures(tabela[index]["image"]);
                                            setState(() {
                                              tabela.removeWhere((item) => item["image"] == tabela[index]["image"]);
                                            });
                                          },
                                        )
                                      : const Text("")
                                  : Checkbox(
                                      fillColor: MaterialStateProperty.all<Color>(Colors.white),
                                      checkColor: Colors.red,
                                      activeColor: Colors.white,
                                      value: tabela[index]["check"],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          tabela[index]["check"] = value!;
                                        });
                                        silinecekler.add(tabela[index]);
                                      },
                                    ),
                            )
                          : const Positioned(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                    ],
                  ),
                ),
              ),
              sicak.isNotEmpty && authenticateManager != null && authenticateManager!.getProjectId() == "5"
                  ? Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)!.sicakRaf,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                    )
                  : const Padding(padding: EdgeInsets.all(8)),
              Container(
                padding: const EdgeInsets.only(top: 8, bottom: 100, left: 8, right: 8),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: sicak.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ), // The size of the grid box
                  itemBuilder: (context, index) => Stack(
                    children: [
                      GestureDetector(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: (debug == false
                                ? GestureDetector(
                                    onTap: () {
                                      showImageViewer(context, Image.file(File(sicak[index]["image"])).image,
                                          swipeDismissible: true, doubleTapZoomable: true);
                                    },
                                    child: Image.file(
                                      File(sicak[index]["image"]),
                                      fit: BoxFit.cover,
                                      color: (sicakTamam == 1
                                          ? Colors.yellow.withOpacity(0.8)
                                          : (sicakTamam == 2
                                              ? Colors.red.withOpacity(0.8)
                                              : Colors.white.withOpacity(0.8))),
                                      colorBlendMode: BlendMode.modulate,
                                    ),
                                  )
                                : Image.asset(
                                    sicak[index]["image"],
                                    fit: BoxFit.cover,
                                    color: Colors.white.withOpacity(0.8),
                                    colorBlendMode: BlendMode.modulate,
                                  )),
                          ),
                        ),
                      ),
                      upload == false
                          ? Positioned(
                              child: topluSil == false
                                  ? completed == false
                                      ? IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.white,
                                          onPressed: () {
                                            helper.deletePictures(sicak[index]["image"]);
                                            setState(() {
                                              sicak.removeWhere((item) => item["image"] == sicak[index]["image"]);
                                            });
                                          },
                                        )
                                      : const Text("")
                                  : Checkbox(
                                      fillColor: MaterialStateProperty.all<Color>(Colors.white),
                                      checkColor: Colors.red,
                                      activeColor: Colors.white,
                                      value: sicak[index]["check"],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          sicak[index]["check"] = value!;
                                        });
                                        silinecekler.add(sicak[index]);
                                      },
                                    ),
                            )
                          : const Positioned(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: const EdgeInsets.all(25),
          width: double.infinity,
          child: topluSil == false
              ? upload == false
                  ? completed == false
                      ? FloatingActionButton.extended(
                          onPressed: () async {
                            startTimer();
                            final prefs = await SharedPreferences.getInstance();

                            prefs.remove("dolapdata");
                            prefs.remove("teshirdata");
                            prefs.remove("tabeladata");
                            prefs.remove("sicakdata");

                            if (dolap.isNotEmpty) await uploadDolapImage();
                            if (teshir.isNotEmpty) await uploadTeshirImage();
                            if (tabela.isNotEmpty) await uploadTabelaImage();
                            if (sicak.isNotEmpty) await uploadSicakImage();

                            setState(() {
                              completed = true;
                            });

                            //prefs.remove("customerwithvariableplanograms");
                            prefs.remove("reports");
                            prefs.setBool("needClearCache", true);

                            setState(() {
                              _stopwatch.stop();
                            });
                            var x = _stopwatch.elapsed.inSeconds % 60;
                            for (var element in dolap) {
                              element["gecensure"] = x;
                            }

                            for (var element in teshir) {
                              element["gecensure"] = x;
                            }

                            for (var element in tabela) {
                              element["gecensure"] = x;
                            }

                            for (var element in sicak) {
                              element["gecensure"] = x;
                            }
                          },
                          label: Text(AppLocalizations.of(context)!.analizEt),
                          backgroundColor: anaRenk,
                        )
                      : FloatingActionButton.extended(
                          onPressed: () async {
                            var newList = dolap + teshir + tabela + sicak;
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => ImageDetailPage(type: jsonEncode(newList))));
                          },
                          label: Text(AppLocalizations.of(context)!.analizSonucu),
                          backgroundColor: anaRenk,
                        )
                  : FloatingActionButton.extended(
                      onPressed: () async {},
                      label: const Center(child: CircularProgressIndicator()),
                      backgroundColor: anaRenk,
                    )
              : FloatingActionButton.extended(
                  onPressed: () {
                    for (var element in silinecekler) {
                      helper.deletePictures(element["image"]);
                      if (element["imageType"] == 1) {
                        dolap.removeWhere((item) => item["image"] == element["image"]);
                      } else if (element["imageType"] == 2) {
                        teshir.removeWhere((item) => item["image"] == element["image"]);
                      } else if (element["imageType"] == 3) {
                        tabela.removeWhere((item) => item["image"] == element["image"]);
                      } else if (element["imageType"] == 4) {
                        sicak.removeWhere((item) => item["image"] == element["image"]);
                      }
                    }
                    setState(() {});
                  },
                  label: Text(AppLocalizations.of(context)!.sil),
                  backgroundColor: anaRenk,
                ),
        ),
      ),
    );
  }
}
