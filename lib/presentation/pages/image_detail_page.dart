import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/business/customer_manager.dart';
import 'package:neocortexapp/business/product_manager.dart';
import 'package:neocortexapp/business/report_manager.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/core/db/db_helper.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:neocortexapp/presentation/Widget/status_information.dart';
import 'package:neocortexapp/presentation/Widget/v1widget.dart';
import 'package:neocortexapp/presentation/pages/compare_page.dart';
import 'package:neocortexapp/presentation/pages/customer_detail_external_page.dart';
import 'package:neocortexapp/presentation/pages/customer_detail_page.dart';
import 'package:neocortexapp/presentation/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageDetailPage extends StatefulWidget {
  const ImageDetailPage({Key? key, required this.type}) : super(key: key);
  final String type;
  // ignore: library_private_types_in_public_api, annotate_overrides
  _ImageDetailPageState createState() => _ImageDetailPageState(type);
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  final slider = PageController(initialPage: 0, viewportFraction: 0.5, keepPage: false);
  final imageSliderController = PageController(initialPage: 0, viewportFraction: 0.5, keepPage: false);
  final listController = PageController(initialPage: 0, viewportFraction: 0.33, keepPage: false);
  String type;
  _ImageDetailPageState(this.type);
  AuthenticateManager? authenticateManager;

  var json = [];
  var imageType;
  var dolapDataJson;
  var teshirDataJson;
  var tabelaDataJson;
  var sicakDataJson;

  var teshirAdlari = [];
  var tabelaAdlari = [];

  List<String> data2 = [];
  var debug = false;
  var toplamUrun = 0;
  var toplamUrunSicakRaf = 0;
  Map<String, List<Map<String, dynamic>>> urunler = {};
  Map<String, List<Map<String, dynamic>>> sicakRafUrunler = {};
  var kategoriler = [];
  var sonListe = [];
  var sonListeSicakRaf = [];
  var helper = DbHelper();
  var token;
  var projectId;
  Map<String, dynamic> musthave = {};
  Map<String, dynamic> shelfShare = {};
  Map<String, dynamic> sicakRafHesaplamalar1 = {};
  Map<String, dynamic> sicakRafHesaplamalar2 = {};
  Map<String, dynamic> sicakRafHesaplamalar3 = {};
  Map products = {};
  Map sicakRafProducts = {};
  Map tabelaAdi = {};
  Map tehsirAdi = {};
  var pages = [];
  var kategoriListesi = [];

  var imagesSlider = [];

  @override
  void initState() {
    super.initState();
    authenticateManager = AuthenticateManager();
    authenticateManager!.init().asStream();
    json = jsonDecode(type);
    //print("Json : $json");
    imageType = json[0]["imageType"];
    getData(imageType);
    CustomerManager.getCachedCustomerData();
    ReportManager.getCachedReportData();
  }

  @override
  void dispose() {
    slider.dispose();
    imageSliderController.dispose();
    listController.dispose();
    super.dispose();
  }

  Future<void> getData(imageType) async {
    AuthenticateManager authenticateManager = AuthenticateManager();
    await authenticateManager.init();

    token = authenticateManager.getToken();
    projectId = authenticateManager.getProjectId();
    var sharedPreferences = await SharedPreferences.getInstance();
    data2 = await ProductManager.getCachedPifList();

    var dolapdata = sharedPreferences.getString("dolapdata");
    var teshirdata = sharedPreferences.getString("teshirdata");
    var tabeladata = sharedPreferences.getString("tabeladata");
    var sicakdata = sharedPreferences.getString("sicakdata");

    if (dolapdata != null) dolapDataJson = jsonDecode(dolapdata);
    if (teshirdata != null) teshirDataJson = jsonDecode(teshirdata);
    if (tabeladata != null) tabelaDataJson = jsonDecode(tabeladata);
    if (sicakdata != null) sicakDataJson = jsonDecode(sicakdata);

    if (dolapdata != null && dolapDataJson.containsKey('Content')) {
      /* toplamUrun = dolapDataJson['Content']['planogram_result']
          ['total_number_of_products']; */

      musthave = dolapDataJson['Content']['planogram_result']['not_found_musthave_products'];

      shelfShare = dolapDataJson['Content']['planogram_result']['shelf_share_score'];
    }

    /* Tabela adları için  */
    if (tabeladata != null && tabelaDataJson.containsKey('Content')) {
      if (tabelaDataJson['Content'] is String) {
        // 1 tabela resminde Efes veya rakip tabelası algılanamadı, fotoğraf kaydedildi!
      } else {
        tabelaAdi = tabelaDataJson['Content']['Signs']['Received_Files'];
        tabelaAdi.forEach((key, value) {
          Map File_Inference_Output = value["File_Inference_Output"];
          File_Inference_Output.forEach((key2, value2) {
            tabelaAdlari.add(value2["label"]);
          });
        });
      }
    }

    /* Tabela adları için  */

    /* tehsirAdi adları için  */
    if (teshirdata != null && teshirDataJson.containsKey('Content')) {
      tehsirAdi = teshirDataJson['Content']['Products'];

      tehsirAdi.forEach((key, value) {
        teshirAdlari.add(value["Image_Display_Category"]);
      });
    }

    /* tehsirAdi adları için  */

    /* Sıcak Raf için */
    if (sicakdata != null && sicakDataJson.containsKey('Content')) {
      sicakRafProducts = sicakDataJson['Content']['Products'];

      sicakRafHesaplamalar1 = sicakDataJson['Content']['Calculation_1'];
      sicakRafHesaplamalar2 = sicakDataJson['Content']['Calculation_2'];
      sicakRafHesaplamalar3 = sicakDataJson['Content']['Calculation_3'];

      sicakRafProducts.forEach((key, value) {
        Map File_Inference_Output = value["File_Inference_Output"];
        File_Inference_Output.forEach((key2, value2) {
          toplamUrunSicakRaf++;
          String yeniAnahtar = value2["sap_code"];
          String label = value2["label"];

          if (sicakRafUrunler.containsKey(yeniAnahtar)) {
            // Eğer anahtar zaten varsa, "sayi" değerini 1 arttır.
            sicakRafUrunler[yeniAnahtar]?[0]["sayi"] = sicakRafUrunler[yeniAnahtar]?[0]["sayi"] + 1;
          } else {
            // Eğer anahtar yoksa, yeni bir anahtar oluştur ve "sayi" değerini 1 olarak ayarla.

            for (var d in data2) {
              if (d.split('-')[1] == yeniAnahtar) {
                sicakRafUrunler[yeniAnahtar] = [
                  {"label": label, "sap_code": yeniAnahtar, "sayi": 1, "shelf_share_category": "Efes", "full_name": d}
                ];
                break;
              }
            }
          }
        });
      });
    }
    /* Sıcak Raf için */

    if (dolapdata != null && dolapDataJson.containsKey('Content')) {
      products = dolapDataJson['Content']['products'];

      products.forEach((key, value) {
        Map File_Inference_Output = value["File_Inference_Output"];
        File_Inference_Output.forEach((key2, value2) {
          toplamUrun++;
          String yeniAnahtar = value2["sap_code"];
          String label = value2["label"];

          if (!kategoriler.contains(value2["shelf_share_category"])) {
            kategoriler.add(value2["shelf_share_category"]);
          }

          if (urunler.containsKey(yeniAnahtar)) {
            // Eğer anahtar zaten varsa, "sayi" değerini 1 arttır.
            urunler[yeniAnahtar]?[0]["sayi"] = urunler[yeniAnahtar]?[0]["sayi"] + 1;
          } else {
            // Eğer anahtar yoksa, yeni bir anahtar oluştur ve "sayi" değerini 1 olarak ayarla.

            for (var d in data2) {
              if (d.split('-')[1] == yeniAnahtar) {
                urunler[yeniAnahtar] = [
                  {
                    "label": label,
                    "sap_code": yeniAnahtar,
                    "sayi": 1,
                    "shelf_share_category": value2["shelf_share_category"],
                    "full_name": d
                  }
                ];
                break;
              }
            }
          }
        });
      });
    }

    kategoriler.sort((a, b) {
      // "Efes" değeri ilk sırada olmalı, diğer değerlerin önemi yok
      if (a == "Efes") {
        return -1; // "Efes"i önce getir
      } else if (b == "Efes") {
        return 1; // "Efes"i diğer değerlerden sonraya yerleştir
      } else {
        return 0; // Diğer durumlarda sıralamada değişiklik yapma
      }
    });
    //print(kategoriler);

    List filteredUrunler = [];
    urunler.forEach((anahtar, urunListesi) {
      List filteredUrunlerForKey = urunListesi.where((urun) {
        return urun["shelf_share_category"] == kategoriler[0];
      }).toList();
      filteredUrunler.addAll(filteredUrunlerForKey);
    });

    sonListe = filteredUrunler;

    List filteredUrunlerSicakRaf = [];
    sicakRafUrunler.forEach((anahtar, urunListesi) {
      List filteredUrunlerForKey = urunListesi.where((urun) {
        return urun["shelf_share_category"] == "Efes";
      }).toList();
      filteredUrunlerSicakRaf.addAll(filteredUrunlerForKey);
    });

    sonListeSicakRaf = filteredUrunlerSicakRaf;

    setState(() {});
  }

  final customCacheManager = CacheManager(Config(
    'customCacheKey',
    stalePeriod: const Duration(days: 365),
    maxNrOfCacheObjects: 2000,
  ));
  @override
  Widget build(BuildContext context) {
    void _showAlertDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.mustHave),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: musthave.length, // Öğelerin sayısı
                itemBuilder: (BuildContext context, int index) {
                  // Her bir öğe için oluşturulacak widget
                  final key = musthave.keys.elementAt(index);
                  final value = musthave[key];

                  var x = data2.where((element) => element.split('-')[1] == key);
                  var full_name = "";
                  for (var item in x) {
                    full_name = item;
                  }
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: CachedNetworkImage(
                        cacheManager: customCacheManager,
                        key: UniqueKey(),
                        httpHeaders: {'token': token, 'project_id': projectId},
                        imageUrl: "${AppConfig.baseApiUrl}/getimagefile/$full_name",
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    title: Text(value),
                    onTap: () {
                      // Öğeye tıklanıldığında yapılacak işlemler
                      Navigator.of(context).pop(); // AlertDialog'ı kapat
                      // Diğer işlemleri burada yapabilirsiniz.
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () {
                  Navigator.of(context).pop(); // AlertDialog'ı kapat
                },
              ),
            ],
          );
        },
      );
    }

    void _showAlertDialog2(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.shelfShare),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: shelfShare.length, // Öğelerin sayısı
                itemBuilder: (BuildContext context, int index) {
                  final key = shelfShare.keys.elementAt(index);
                  final value = shelfShare[key];

                  return defaultBox(
                    child: ListTile(
                      title: Text(
                        key,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Wrap(
                        direction: Axis.vertical,
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            value["counted"].toString(),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          circularIndicator(
                            text: value["percentage"].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                            color: Colors.blue,
                            percent: (value["percentage"] / 100),
                            lineWidth: 5,
                            radius: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void _showAlertDialog3(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.sicakRaf),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.hesaplama1),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: sicakRafHesaplamalar1.length, // Öğelerin sayısı
                      itemBuilder: (BuildContext context, int index) {
                        final key = sicakRafHesaplamalar1.keys.elementAt(index);
                        final value = sicakRafHesaplamalar1[key];
                        var yuzde = value * 100;

                        return defaultBox(
                          child: ListTile(
                            title: Text(
                              key,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Wrap(
                              direction: Axis.vertical,
                              alignment: WrapAlignment.center,
                              children: [
                                circularIndicator(
                                  text: yuzde.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                                  color: Colors.blue,
                                  percent: value,
                                  lineWidth: 5,
                                  radius: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Text(AppLocalizations.of(context)!.hesaplama2),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: sicakRafHesaplamalar2.length, // Öğelerin sayısı
                      itemBuilder: (BuildContext context, int index) {
                        final key = sicakRafHesaplamalar2.keys.elementAt(index);
                        final value = sicakRafHesaplamalar2[key];
                        var yuzde = value * 100;

                        return defaultBox(
                          child: ListTile(
                            title: Text(
                              key,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Wrap(
                              direction: Axis.vertical,
                              alignment: WrapAlignment.center,
                              children: [
                                circularIndicator(
                                  text: yuzde.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                                  color: Colors.blue,
                                  percent: value,
                                  lineWidth: 5,
                                  radius: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Text(AppLocalizations.of(context)!.hesaplama3),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: sicakRafHesaplamalar3.length, // Öğelerin sayısı
                      itemBuilder: (BuildContext context, int index) {
                        final key = sicakRafHesaplamalar3.keys.elementAt(index);
                        final value = sicakRafHesaplamalar3[key];
                        var yuzde = value * 100;

                        return defaultBox(
                          child: ListTile(
                            title: Text(
                              key,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Wrap(
                              direction: Axis.vertical,
                              alignment: WrapAlignment.center,
                              children: [
                                circularIndicator(
                                  text: yuzde.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                                  color: Colors.blue,
                                  percent: value,
                                  lineWidth: 5,
                                  radius: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    var dizi = [];
    if (dolapDataJson != null) {
      dizi.add({
        "baslik": "Must Have",
        "tip": 1,
        "text": "${dolapDataJson['Content']['planogram_result']['drinks_musthave_score']}%",
        "yuzde": dolapDataJson['Content']['planogram_result']['drinks_musthave_score'] / 100,
      });

      dizi.add({
        "baslik": "Planogram İdeal",
        "tip": 2,
        "text": "${dolapDataJson['Content']['planogram_result']['planogram_realization_score']}%",
        "yuzde": dolapDataJson['Content']['planogram_result']['planogram_realization_score'] / 100,
      });

      dizi.add({
        "baslik": "Planogram Bulunurluk",
        "tip": 3,
        "text": "${dolapDataJson['Content']['planogram_result']['planogram_availability_score']}%",
        "yuzde": dolapDataJson['Content']['planogram_result']['planogram_availability_score'] / 100,
      });

      dizi.add({
        "baslik": "Shelf Share",
        "tip": 4,
        "text": "${dolapDataJson['Content']['planogram_result']['shelf_share_score']['Efes']['percentage']}%",
        "yuzde": dolapDataJson['Content']['planogram_result']['shelf_share_score']['Efes']['percentage'] / 100,
      });
    }

    if (sicakDataJson != null) {
      var x1 = sicakDataJson['Content']['Calculation_3']['AEFES'] * 100;
      x1 = x1.toStringAsFixed(1);
      dizi.add({
        "baslik": "Sıcak Raf",
        "tip": 5,
        "text": "${x1} %",
        "yuzde": sicakDataJson['Content']['Calculation_3']['AEFES'],
      });
    }

    pages = List.generate(
      dizi.length,
      (index) => dizi[index]["tip"] == 1
          ? Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Stack(
                children: [
                  durumBilgileriDondur(
                      baslik: dizi[index]["baslik"],
                      text: dizi[index]["text"],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                      color: Colors.blueAccent,
                      percent: dizi[index]["yuzde"],
                      lineWidth: 15.0,
                      radius: 60.0),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: IconButton(
                      onPressed: () {
                        _showAlertDialog(context);
                      },
                      icon: const Icon(Icons.bar_chart),
                    ),
                  ),
                ],
              ),
            )
          : dizi[index]["tip"] == 4
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Stack(
                    children: [
                      durumBilgileriDondur(
                          baslik: dizi[index]["baslik"],
                          text: dizi[index]["text"],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                          color: Colors.blueAccent,
                          percent: dizi[index]["yuzde"],
                          lineWidth: 15.0,
                          radius: 60.0),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: IconButton(
                          onPressed: () {
                            _showAlertDialog2(context);
                          },
                          icon: const Icon(Icons.bar_chart),
                        ),
                      ),
                    ],
                  ),
                )
              : dizi[index]["tip"] == 5
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Stack(
                        children: [
                          durumBilgileriDondur(
                              baslik: dizi[index]["baslik"],
                              text: dizi[index]["text"],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                              color: Colors.blueAccent,
                              percent: dizi[index]["yuzde"],
                              lineWidth: 15.0,
                              radius: 60.0),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: IconButton(
                              onPressed: () {
                                _showAlertDialog3(context);
                              },
                              icon: const Icon(Icons.bar_chart),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: durumBilgileriDondur(
                          baslik: dizi[index]["baslik"],
                          text: dizi[index]["text"],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                          color: Colors.blueAccent,
                          percent: dizi[index]["yuzde"],
                          lineWidth: 15.0,
                          radius: 60.0),
                    ),
    );

    if (dolapDataJson != null && kategoriler.length > 0) {
      kategoriListesi = List.generate(kategoriler.length, (index) {
        List filteredUrunler = [];
        urunler.forEach((anahtar, urunListesi) {
          List filteredUrunlerForKey = urunListesi.where((urun) {
            return urun["shelf_share_category"] == kategoriler[index];
          }).toList();
          filteredUrunler.addAll(filteredUrunlerForKey);
        });

        return GestureDetector(
          onTap: () {
            setState(() {
              sonListe = filteredUrunler;
            });
            //print(sonListe);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(2),
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
            child: Row(
              children: [
                Text(
                  kategoriler[index],
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    filteredUrunler.length.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: anaRenk,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      });
    }

    if (json.length > 0) {
      imagesSlider = List.generate(
        json.length,
        (index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: debug == false
                      ? GestureDetector(
                          onTap: () {
                            showImageViewer(context, Image.file(File(json[index]["image"])).image,
                                swipeDismissible: true, doubleTapZoomable: true);
                          },
                          child: Image.file(
                            File(json[index]["image"]),
                            fit: BoxFit.cover,
                            color: Colors.white.withOpacity(0.8),
                            colorBlendMode: BlendMode.modulate,
                          ),
                        )
                      : Image.asset(
                          json[index]["image"],
                          fit: BoxFit.cover,
                          color: Colors.white.withOpacity(0.8),
                          colorBlendMode: BlendMode.modulate,
                        ),
                ),
              ),
              if (dolapDataJson != null && json[index]["imageType"] == 1)
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.bar_chart),
                    color: Colors.white,
                    onPressed: () {
                      dolapDataJson["giden_resim"] = json[index]["image"];
                      dolapDataJson["giden_index"] = index;
                      dolapDataJson["target_planogram_for_this_customer"] =
                          json[index]["target_planogram_for_this_customer"];
                      dolapDataJson["planogram_category_colors"] = json[index]["planogram_category_colors"];
                      //print("Data : $data");
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ComparePage(data: jsonEncode(dolapDataJson))));
                    },
                  ),
                ),
              Visibility(
                visible: true, // burada proje kontrolü kaldırıldı.
                child: Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    margin: const EdgeInsets.only(top: 3, bottom: 3, left: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      (json[index]["imageType"] == 1
                          ? "${AppLocalizations.of(context)!.sogutucu}"
                          : json[index]["imageType"] == 2
                              ? "${AppLocalizations.of(context)!.teshir}"
                              : json[index]["imageType"] == 3
                                  ? "${AppLocalizations.of(context)!.tabela}"
                                  : "${AppLocalizations.of(context)!.sicakRaf}"),
                      style: const TextStyle(color: Colors.black, fontSize: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: anaRenk),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.okumaVerileri,
            style: const TextStyle(color: anaRenk),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: anaRenk),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  child: SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: imageSliderController,
                      itemCount: json.length,
                      padEnds: false,
                      itemBuilder: (_, index) {
                        return imagesSlider[index % imagesSlider.length];
                      },
                    ),
                  ),
                ),
                if (toplamUrun > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                    child: defaultBox(
                      child: ListTile(
                        leading: Text(
                          AppLocalizations.of(context)!.toplamSayilanUrunSayisi,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(AppLocalizations.of(context)!.analizAdet(toplamUrun.toString())),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                  child: defaultBox(
                    child: ListTile(
                      leading: Text(
                        AppLocalizations.of(context)!.analizIcinGecenSure,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.gecenSure(json[0]["gecensure"].toString())),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.insights_rounded,
                            color: Colors.pink,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (teshirAdlari.length > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                    child: defaultBox(
                      child: ListTile(
                        leading: Text(
                          AppLocalizations.of(context)!.teshir,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(teshirAdlari[0]),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.insights_rounded,
                              color: Colors.pink,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                  child: defaultBox(
                    child: ListTile(
                      onTap: () async {
                        var customers = await CustomerManager.getCachedCustomerData();
                        print(customers);
                        Customer customerDetail = customers
                            .where(
                                (element) => element.customerSapCode.toString() == json[0]["customerCode"].toString())
                            .first;
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerDetailExternalPage(customer: customerDetail),
                            ));
                      },
                      leading: const Icon(Icons.radio_button_checked, color: anaRenk),
                      title: Text(
                        json[0]["customerName"],
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Wrap(
                        direction: Axis.vertical,
                        children: [
                          Text(
                            json[0]["customerAdress"],
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 3, bottom: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: anaRenk,
                            ),
                            padding: const EdgeInsets.all(3),
                            child: Text(
                              json[0]["customerCode"].toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                      ),
                    ),
                  ),
                ),
                if (dizi.length > 0) // Dolap ise burada işlem yapılacak
                  Container(
                    height: 210.0,
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 210,
                            child: PageView.builder(
                              controller: slider,
                              itemCount: dizi.length,
                              padEnds: false,
                              itemBuilder: (_, index) {
                                return pages[index % pages.length];
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (tabelaAdlari.length > 0) // Tabela var burada ekrana tabelaları basacak
                  Container(
                    height: 50.0,
                    margin: const EdgeInsets.only(left: 18, top: 15, right: 18),
                    alignment: Alignment.center,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // Yatay kaydırma için
                      itemCount: tabelaAdlari.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(2),
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
                          child: Text(
                            tabelaAdlari[index],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                if (kategoriListesi.length > 0) // Kategori varsa burayı dolduracak
                  Container(
                    height: 50.0,
                    margin: const EdgeInsets.only(left: 18, top: 15, right: 18),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 50,
                            child: PageView.builder(
                              controller: listController,
                              itemCount: kategoriListesi.length,
                              padEnds: false,
                              itemBuilder: (_, index) {
                                return kategoriListesi[index % kategoriListesi.length];
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (sonListe.length > 0)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 2000, minHeight: 56.0),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14, left: 14, top: 15, bottom: 15),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sonListe.length,
                        itemBuilder: (BuildContext context, int index) {
                          double urunYuzdesi = (sonListe[index]["sayi"] / toplamUrun);

                          return defaultBox(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: CachedNetworkImage(
                                  cacheManager: customCacheManager,
                                  key: UniqueKey(),
                                  httpHeaders: {'token': token, 'project_id': projectId},
                                  imageUrl: "${AppConfig.baseApiUrl}/getimagefile/${sonListe[index]["full_name"]}",
                                  imageBuilder: (context, imageProvider) => Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                              title: Text(
                                sonListe[index]["label"],
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              trailing: Wrap(
                                direction: Axis.vertical,
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    sonListe[index]["sayi"].toString(),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  circularIndicator(
                                    text: (urunYuzdesi * 100).round().toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                                    color: Colors.blue,
                                    percent: urunYuzdesi,
                                    lineWidth: 5,
                                    radius: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (sonListeSicakRaf.length > 0)
                  Container(
                    height: 50.0,
                    margin: const EdgeInsets.only(left: 18, top: 15, right: 18),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
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
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.sicakRaf,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            sonListeSicakRaf.length.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: anaRenk,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                if (sonListeSicakRaf.length > 0)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 2000, minHeight: 56.0),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14, left: 14, top: 15, bottom: 15),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sonListeSicakRaf.length,
                        itemBuilder: (BuildContext context, int index) {
                          double urunYuzdesi = (sonListeSicakRaf[index]["sayi"] / toplamUrunSicakRaf);

                          return defaultBox(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: CachedNetworkImage(
                                  cacheManager: customCacheManager,
                                  key: UniqueKey(),
                                  httpHeaders: {'token': token, 'project_id': projectId},
                                  imageUrl:
                                      "${AppConfig.baseApiUrl}/getimagefile/${sonListeSicakRaf[index]["full_name"]}",
                                  imageBuilder: (context, imageProvider) => Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                              title: Text(
                                sonListeSicakRaf[index]["label"],
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              trailing: Wrap(
                                direction: Axis.vertical,
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    sonListeSicakRaf[index]["sayi"].toString(),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  circularIndicator(
                                    text: (urunYuzdesi * 100).round().toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                                    color: Colors.blue,
                                    percent: urunYuzdesi,
                                    lineWidth: 5,
                                    radius: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
