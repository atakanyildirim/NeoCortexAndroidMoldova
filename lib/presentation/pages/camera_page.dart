import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_exif/native_exif.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:native_shutter_sound/native_shutter_sound.dart';
import 'package:need_resume/need_resume.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/core/db/db_helper.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:neocortexapp/entities/picture_v1.dart';
import 'package:neocortexapp/presentation/pages/home_page.dart';
import 'package:neocortexapp/presentation/pages/images_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  const CameraPage(
      {Key? key, required this.cameras, required this.customerDetail})
      : super(key: key);

  final List<CameraDescription>? cameras;
  final Customer customerDetail;

  @override
  State<CameraPage> createState() => _CameraPageState(customerDetail);
}

class _CameraPageState extends ResumableState<CameraPage> {
  Customer customerDetail;

  _CameraPageState(this.customerDetail);
  late CameraController _cameraController;
  final ScrollController _scrollController = ScrollController();
  AuthenticateManager? authenticateManager;
  var cekilenresim = null;
  int tab = 0;
  final debug = false;
  Color color = Colors.red;
  Color kcolor = Colors.white;
  Color tcolor = const Color(0x43ffffff);
  Color tacolor = const Color(0x43ffffff);
  Color srcolor = const Color(0x43ffffff);

  var aktifindex = 1;
  var tip = 1;
  var dolaplar = [];
  var teshirler = [];
  var tabelalar = [];
  var sicaRaflar = [];
  var arr = [];
  var helper = DbHelper();
  var camera = 0;

  // Crop için eklenen alanlar.
  var resim = null;
  var resimuint8List = null;
  final _controller = CropController();

  //panoramik çekim ekranında düzenleme
  bool horizantel = false;
  bool vertical = false;
  bool isPano = false;
  bool yanyana = false;
  var images = [];
  final dylib = Platform.isAndroid
      ? DynamicLibrary.open("libOpenCV_ffi.so")
      : DynamicLibrary.process();

  bool preloader = false;

  double top = 17;
  double left = 17;
  var flash = false;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  var gorunsun = true;

// ignore: no_leading_underscores_for_local_identifiers
  Future<void> _dialogBuilder2(BuildContext context) async {
    showDialog<void>(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Visibility(
          visible: gorunsun,
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            titlePadding: const EdgeInsets.all(0),
            title: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(CupertinoIcons.trash),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(AppLocalizations.of(context)!.fotografiSil),
                ),
              ],
            ),
            content: Text(
              AppLocalizations.of(context)!.secilenResimSil,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white,
                        shadowColor: Colors.greenAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.vazgec,
                        style: const TextStyle(color: anaRenk, fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
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
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.sil,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () async {
                        helper.deleteAllPictures(
                            customerDetail.customerSapCode.toString());
                        final prefs = await SharedPreferences.getInstance();
                        bool? needClearCache = prefs.getBool("needClearCache");
                        if (needClearCache != null && needClearCache == true) {
                          prefs.setBool("needClearCache", false);
                          // ignore: use_build_context_synchronously
                          await Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()),
                            (route) => false,
                          );
                        } else {
                          setState(() {
                            gorunsun = false;
                          });
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ignore: no_leading_underscores_for_local_identifiers
  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          titlePadding: const EdgeInsets.all(0),
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(child: Text(AppLocalizations.of(context)!.cekilen)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.toplamCekim(
                    customerDetail.customerName.toString(),
                    customerDetail.customerSapCode.toString()),
                textAlign: TextAlign.center,
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.grey,
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
                child: ListTile(
                  leading: Text(AppLocalizations.of(context)!.dolap),
                  title: Text(AppLocalizations.of(context)!.adetResimCekildi(
                      dolaplar
                          .where((element) => element["resim"].toString() != "")
                          .length
                          .toString())),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.grey,
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
                child: ListTile(
                  leading: Text(AppLocalizations.of(context)!.teshir),
                  title: Text(AppLocalizations.of(context)!
                      .adetResimCekildi(teshirler.length.toString())),
                ),
              ),
              Visibility(
                visible: authenticateManager != null &&
                    authenticateManager!.getProjectId() != "5",
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListTile(
                      leading: Text(AppLocalizations.of(context)!.tabela),
                      title: Text(AppLocalizations.of(context)!
                          .adetResimCekildi(tabelalar.length.toString()))),
                ),
              ),
              Visibility(
                visible: authenticateManager != null &&
                    authenticateManager!.getProjectId() == "5",
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListTile(
                      leading: Text(AppLocalizations.of(context)!.sicakRaf),
                      title: Text(AppLocalizations.of(context)!
                          .adetResimCekildi(sicaRaflar.length.toString()))),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Column(
              children: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: anaRenk,
                      shadowColor: Colors.greenAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.okumayaDevamEt,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white,
                      shadowColor: Colors.greenAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.islemiTamamla,
                      style: const TextStyle(color: anaRenk, fontSize: 20),
                    ),
                    onPressed: () {
                      //burada veritabanı kaydı yapacak.
                      helper.deleteAllPictures(
                          customerDetail.customerSapCode.toString());
                      dolaplar.forEach((item) async => await ekle(1, item));
                      teshirler.forEach((item) async => await ekle(2, item));
                      tabelalar.forEach((item) async => await ekle(3, item));
                      sicaRaflar.forEach((item) async => await ekle(4, item));
                      Navigator.of(context).pop();

                      push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ImagesPage(customerDetail: customerDetail)));
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    authenticateManager = AuthenticateManager();
    authenticateManager!.init().asStream();
    determinePosition();
    if (widget.cameras!.isNotEmpty) {
      initCamera(widget.cameras![camera]);
    }
    arr = dolaplar;
    if (customerDetail.efesDoorCount == null) customerDetail.efesDoorCount = 0;
    for (var i = 1; i <= customerDetail.efesDoorCount!.toInt(); i++) {
      dolaplar.add({
        "tip": 1,
        "sira": i,
        "resim": "",
        "tarih": "",
        "secilenrenk": Colors.transparent,
        "renk": Colors.transparent,
      });
    }
  }

  @override
  void onResume() {
    dolaplar.clear();
    teshirler.clear();
    tabelalar.clear();
    sicaRaflar.clear();

    helper.getPictures(customerDetail.customerSapCode.toString()).then((value) {
      value?.forEach((localData) {
        /*arr.remove(arr
            .firstWhere((element) => element["resim"] != localData["image"]));
          id, 
          customerCode ,
          imageType, 
          image,
          orderNumber,
          udate,
          status
        */

        if (localData["imageType"] == 1) {
          dolaplar.add({
            "tip": localData["imageType"],
            "sira": localData["orderNumber"],
            "resim": localData["image"],
            "tarih": localData["udate"],
            "secilenrenk": Colors.transparent,
            "renk": Colors.transparent,
          });
        } else if (localData["imageType"] == 2) {
          teshirler.add({
            "tip": localData["imageType"],
            "sira": localData["orderNumber"],
            "resim": localData["image"],
            "tarih": localData["udate"],
            "secilenrenk": Colors.transparent,
            "renk": Colors.transparent,
          });
        } else if (localData["imageType"] == 3) {
          tabelalar.add({
            "tip": localData["imageType"],
            "sira": localData["orderNumber"],
            "resim": localData["image"],
            "tarih": localData["udate"],
            "secilenrenk": Colors.transparent,
            "renk": Colors.transparent,
          });
        } else if (localData["imageType"] == 4) {
          sicaRaflar.add({
            "tip": localData["imageType"],
            "sira": localData["orderNumber"],
            "resim": localData["image"],
            "tarih": localData["udate"],
            "secilenrenk": Colors.transparent,
            "renk": Colors.transparent,
          });
        }
      });
    });
    setState(() {});
  }

  var pos;

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(AppLocalizations.of(context)!.konumHizmetiDevreDisi);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(AppLocalizations.of(context)!.konumIzinleriRed);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(AppLocalizations.of(context)!.konumKaliciRed);
    }

    pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5));
    setState(() {});
  }

  Timer? _timer;
  var seri = false;

  Future takePicture() async {
    if (isPano == false && color == Colors.red) {
      Fluttertoast.showToast(
          msg: "Gyro Yeşile Dönmeden Çekim Yapılamaz.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return null;
    }

    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      if (debug == false) {
        if (Platform.isAndroid || Platform.isIOS) {
          await _cameraController.setFlashMode(FlashMode.off);
          await _cameraController.setFocusMode(FocusMode.locked);
          await _cameraController.setExposureMode(ExposureMode.locked);
        }
      }
      if (horizantel || vertical) {
        setState(() {
          seri = true;
        });
        NativeShutterSound.play();

        _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
          if (!_cameraController.value.isInitialized) {
            return null;
          }
          if (_cameraController.value.isTakingPicture) {
            return null;
          }
          var x = await _cameraController.takePicture();
          setState(() {
            images.add(x.path);
          });
        });
      } else if (yanyana) {
        NativeShutterSound.play();
        var x = await _cameraController.takePicture();
        setState(() {
          images.add(x.path);
        });
      } else {
        NativeShutterSound.play();
        XFile picture = await _cameraController.takePicture();
        //dosya boyutunu hesaplama
        final bytes = (await picture.readAsBytes()).lengthInBytes;
        final kb = bytes / 1024;
        print(picture.path);
        print(kb);
        print(pos);
        //List gpsData = convertCoordinatesToGPSData(pos.latitude, pos.longitude);
        //print(gpsData);
        if (pos == null) {
          determinePosition();
        }

        if (debug == false && pos != null) {
          final exif = await Exif.fromPath(picture.path);
          await exif.writeAttributes({
            'GPSLatitude': pos.latitude,
            'GPSLatitudeRef': (pos.latitude >= 0) ? 'N' : 'S',
            'GPSLongitude': pos.longitude,
            'GPSLongitudeRef': (pos.longitude >= 0) ? 'E' : 'W',
          });
        }

        if (debug == false) {
          if (Platform.isAndroid || Platform.isIOS) {
            await _cameraController.setFocusMode(FocusMode.auto);
            await _cameraController.setExposureMode(ExposureMode.auto);
          }
        }

        var tarih = DateTime.now().toUtc().millisecondsSinceEpoch;
        setState(() {
          if (debug == false) {
            if (Platform.isAndroid || Platform.isIOS) {
              cekilenresim = picture.path;
            }
          }

          if (aktifindex > arr.length) {
            arr.add({
              "tip": tip,
              "sira": aktifindex,
              "resim": picture.path,
              "tarih": tarih,
              "secilenrenk": Colors.transparent,
              "renk": const Color(0xff059305),
            });
            aktifindex++;
          } else {
            arr[aktifindex - 1]["renk"] = const Color(0xff059305);
            arr[aktifindex - 1]["resim"] = picture.path;
            arr[aktifindex - 1]["tarih"] = tarih;
            aktifindex++;
          }
        });
      }
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
    /*
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1), curve: Curves.fastOutSlowIn);
    });
    */
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
        cameraDescription, ResolutionPreset.veryHigh,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  void changed() {
    setState(() {
      flash = !flash;
      if (flash) {
        _cameraController.setFlashMode(FlashMode.torch);
      } else {
        _cameraController.setFlashMode(FlashMode.off);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: anaRenk,
    ));

    double scale = 0;
    if (_cameraController.value.isInitialized) {
      var camera = _cameraController.value;
      // fetch screen size
      final size = MediaQuery.of(context).size;

      // calculate scale depending on screen and camera ratios
      // this is actually size.aspectRatio / (1 / camera.aspectRatio)
      // because camera preview size is received as landscape
      // but we're calculating for portrait orientation
      scale = size.aspectRatio * camera.aspectRatio;

      // to prevent scaling down, invert the value
      if (scale < 1) scale = 1 / scale;
    }

    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            if (event.x > 8 || event.y > 8 || -8 > event.x || -8 > event.y) {
              color = Colors.green;
            } else {
              color = Colors.red;
            }

            left = event.x + 17;
            if (event.y == 0) {
              top = 17;
            } else {
              top = event.y + 7;
            }

            if (top == 17 && left == 17) {
              color = Colors.green;
            }
          });
        },
      ),
    );
    Future<Uint8List> _rotateBytes(List<int> bytes) async {
      var _rotationAngle = 180;
      // Döndürülmüş resmi oluşturun
      ui.Image originalImage =
          await decodeImageFromList(Uint8List.fromList(bytes));
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)
        ..translate(originalImage.width / 2, originalImage.height / 2)
        ..rotate(_rotationAngle * (3.1415926535897932 / 180))
        ..translate(-originalImage.width / 2, -originalImage.height / 2)
        ..drawImage(originalImage, Offset(0, 0), Paint());
      final rotatedImage = await recorder
          .endRecording()
          .toImage(originalImage.width, originalImage.height);
      ByteData? rotatedByteData =
          await rotatedImage.toByteData(format: ui.ImageByteFormat.png);
      return rotatedByteData!.buffer.asUint8List();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (bool isClosed) {
        if (dolaplar
                    .where((element) => element["resim"].toString() != "")
                    .length >
                0 ||
            teshirler
                    .where((element) => element["resim"].toString() != "")
                    .length >
                0 ||
            tabelalar
                    .where((element) => element["resim"].toString() != "")
                    .length >
                0 ||
            sicaRaflar
                    .where((element) => element["resim"].toString() != "")
                    .length >
                0) {
          _dialogBuilder2(context);
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (dolaplar
                            .where(
                                (element) => element["resim"].toString() != "")
                            .length >
                        0 ||
                    teshirler
                            .where(
                                (element) => element["resim"].toString() != "")
                            .length >
                        0 ||
                    tabelalar
                            .where(
                                (element) => element["resim"].toString() != "")
                            .length >
                        0 ||
                    sicaRaflar
                            .where(
                                (element) => element["resim"].toString() != "")
                            .length >
                        0) {
                  _dialogBuilder2(context);
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                }
              },
            ),
            elevation: 0,
            centerTitle: false,
            backgroundColor: anaRenk,
            actions: [
              GestureDetector(
                onTap: () {
                  changed();
                },
                child: flash
                    ? const Icon(Icons.flash_on, color: Colors.green)
                    : const Icon(Icons.flash_off, color: Colors.red),
              ),
              debug
                  ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ImagesPage(
                                    customerDetail: customerDetail)));
                      },
                      child: const Icon(Icons.abc, color: Colors.green),
                    )
                  : const Text(""),
            ],
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        kcolor = Colors.white;
                        tcolor = const Color(0x43ffffff);
                        tacolor = const Color(0x43ffffff);
                        srcolor = const Color(0x43ffffff);
                        tip = 1;
                        arr = dolaplar;
                        aktifindex = arr.length + 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kcolor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${AppLocalizations.of(context)!.sogutucu} ",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 10),
                          ),
                          Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: anaRenk,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 16,
                            ),
                            child: Text(
                              "${dolaplar.where((element) => element["resim"].toString() != "").length} / ${customerDetail.efesDoorCount!.toInt()}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tcolor = Colors.white;
                        kcolor = const Color(0x43ffffff);
                        tacolor = const Color(0x43ffffff);
                        srcolor = const Color(0x43ffffff);
                        tip = 2;
                        arr = teshirler;
                        aktifindex = arr.length + 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: tcolor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${AppLocalizations.of(context)!.teshir} ",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 10),
                          ),
                          Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: anaRenk,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              (teshirler.length).toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Visibility(
                    visible: authenticateManager != null &&
                        authenticateManager!.getProjectId() != "5",
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          tcolor = const Color(0x43ffffff);
                          kcolor = const Color(0x43ffffff);
                          srcolor = const Color(0x43ffffff);
                          tacolor = Colors.white;
                          tip = 3;
                          arr = tabelalar;
                          aktifindex = arr.length + 1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tacolor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${AppLocalizations.of(context)!.tabela} ",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 10),
                            ),
                            Container(
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: anaRenk,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                (tabelalar.length).toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                      visible: authenticateManager != null &&
                          authenticateManager!.getProjectId() != "5",
                      child: const SizedBox(width: 10)),
                  Visibility(
                    visible: authenticateManager != null &&
                        authenticateManager!.getProjectId() == "5",
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          tcolor = const Color(0x43ffffff);
                          kcolor = const Color(0x43ffffff);
                          tacolor = const Color(0x43ffffff);
                          srcolor = Colors.white;
                          tip = 4;
                          arr = sicaRaflar;
                          aktifindex = arr.length + 1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: srcolor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${AppLocalizations.of(context)!.sicakRaf} ",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 10),
                            ),
                            Container(
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: anaRenk,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                (sicaRaflar.length).toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Stack(children: [
              (widget.cameras!.isNotEmpty &&
                      _cameraController.value.isInitialized)
                  ? Transform.scale(
                      scale: scale,
                      child: Center(
                        child: CameraPreview(_cameraController!),
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
              if (preloader)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: anaRenk.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (preloader == false)
                Container(
                  width: MediaQuery.of(context).size.width - 70,
                  height: MediaQuery.of(context).size.height - 200,
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {
                      takePicture();
                    },
                  ),
                ),
              if ((vertical || horizantel) && preloader == false)
                Positioned(
                  bottom: 110,
                  right: 50,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      color: Colors.black,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          vertical = false;
                          horizantel = false;
                          yanyana = false;
                          isPano = false;
                        });
                      },
                    ),
                  ),
                ),
              if (yanyana && preloader == false)
                Positioned(
                  bottom: 110,
                  right: 5,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(Icons.save),
                      color: Colors.green,
                      onPressed: () async {
                        // burada images dolu ise çalışması lazım.
                        if (images.length > 1) {
                          setState(() {
                            preloader = true;
                          });
                          final stitch = dylib.lookupFunction<
                              Void Function(
                                  Pointer<Utf8>, Pointer<Utf8>, Int32),
                              void Function(
                                  Pointer<Utf8>, Pointer<Utf8>, int)>('stitch');
                          String dirpath =
                              (await getApplicationDocumentsDirectory()).path +
                                  "/" +
                                  DateTime.now().toString() +
                                  "_.jpg";

                          stitch(images.toString().toNativeUtf8(),
                              dirpath.toNativeUtf8(), 3);

                          final exif = await Exif.fromPath(dirpath);

                          final attributes = await exif.getAttributes();
                          attributes?['GPSLatitude'] = pos!.latitude;
                          attributes?['GPSLatitudeRef'] =
                              (pos!.latitude >= 0) ? 'N' : 'S';
                          attributes?['GPSLongitude'] = pos!.longitude;
                          attributes?['GPSLongitudeRef'] =
                              (pos!.longitude >= 0) ? 'E' : 'W';

                          await exif.writeAttributes(attributes!);

                          setState(() {
                            vertical = false;
                            horizantel = false;
                            isPano = false;
                            yanyana = false;
                            imageCache.clear();

                            var tarih =
                                DateTime.now().toUtc().millisecondsSinceEpoch;

                            if (debug == false) {
                              if (Platform.isAndroid || Platform.isIOS) {
                                cekilenresim = dirpath;
                              }
                            }
                            preloader = false;
                            if (aktifindex > arr.length) {
                              arr.add({
                                "tip": tip,
                                "sira": aktifindex,
                                "resim": dirpath,
                                "tarih": tarih,
                                "secilenrenk": Colors.transparent,
                                "renk": const Color(0xff059305),
                              });
                              aktifindex++;
                            } else {
                              arr[aktifindex - 1]["renk"] =
                                  const Color(0xff059305);
                              arr[aktifindex - 1]["resim"] = dirpath;
                              arr[aktifindex - 1]["tarih"] = tarih;
                              aktifindex++;
                            }
                          });
                        } else {
                          Fluttertoast.showToast(
                              msg:
                                  "Panoramik çekim için en az 2 adet resim çekiniz",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                    ),
                  ),
                ),
              if ((vertical || horizantel) && preloader == false)
                Positioned(
                  bottom: 110,
                  right: 5,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(Icons.save),
                      color: Colors.green,
                      onPressed: () async {
                        // burada images dolu ise çalışması lazım.
                        if (images.length > 1) {
                          _timer?.cancel();
                          setState(() {
                            seri = false;
                            preloader = true;
                          });
                          final stitch = dylib.lookupFunction<
                              Void Function(
                                  Pointer<Utf8>, Pointer<Utf8>, Int32),
                              void Function(
                                  Pointer<Utf8>, Pointer<Utf8>, int)>('stitch');
                          String dirpath =
                              (await getApplicationDocumentsDirectory()).path +
                                  "/" +
                                  DateTime.now().toString() +
                                  "_.jpg";

                          stitch(images.toString().toNativeUtf8(),
                              dirpath.toNativeUtf8(), vertical ? 1 : 0);
                          if (vertical) {
                            Uint8List rotatedBytes = await _rotateBytes(
                                File(dirpath).readAsBytesSync());
                            img.Image? image = img
                                .decodeImage(Uint8List.fromList(rotatedBytes));
                            List<int> jpgBytes = img.encodeJpg(image!);

                            File(dirpath).writeAsBytesSync(jpgBytes);
                          }

                          final exif = await Exif.fromPath(dirpath);

                          final attributes = await exif.getAttributes();
                          attributes?['GPSLatitude'] = pos!.latitude;
                          attributes?['GPSLatitudeRef'] =
                              (pos!.latitude >= 0) ? 'N' : 'S';
                          attributes?['GPSLongitude'] = pos!.longitude;
                          attributes?['GPSLongitudeRef'] =
                              (pos!.longitude >= 0) ? 'E' : 'W';

                          await exif.writeAttributes(attributes!);

                          setState(() {
                            vertical = false;
                            horizantel = false;
                            yanyana = false;
                            isPano = false;
                            imageCache.clear();

                            var tarih =
                                DateTime.now().toUtc().millisecondsSinceEpoch;

                            if (debug == false) {
                              if (Platform.isAndroid || Platform.isIOS) {
                                cekilenresim = dirpath;
                              }
                            }
                            preloader = false;
                            if (aktifindex > arr.length) {
                              arr.add({
                                "tip": tip,
                                "sira": aktifindex,
                                "resim": dirpath,
                                "tarih": tarih,
                                "secilenrenk": Colors.transparent,
                                "renk": const Color(0xff059305),
                              });
                              aktifindex++;
                            } else {
                              arr[aktifindex - 1]["renk"] =
                                  const Color(0xff059305);
                              arr[aktifindex - 1]["resim"] = dirpath;
                              arr[aktifindex - 1]["tarih"] = tarih;
                              aktifindex++;
                            }
                          });
                        } else {
                          Fluttertoast.showToast(
                              msg:
                                  "Panoramik çekim için en az 2 adet resim çekiniz",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                    ),
                  ),
                ),
              if (vertical && preloader == false) // Dikey Panoramic
                Container(
                  margin: EdgeInsets.only(bottom: 50, top: 0),
                  width: 50,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Image.file(
                                File(images[index]),
                                height: 50,
                              );
                            },
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_downward),
                    ],
                  ),
                ),
              if (horizantel && preloader == false) // Yatay Panoramic
                Container(
                  margin: EdgeInsets.only(top: 0),
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Image.file(
                                File(images[index]),
                                height: 80,
                              );
                            },
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              if (yanyana && preloader == false) // Yatay Panoramic
                Container(
                  margin: EdgeInsets.only(top: 0),
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Image.file(
                                File(images[index]),
                                height: 80,
                              );
                            },
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              if (isPano == false &&
                  resim != null &&
                  preloader == false) // Crop Ekranı
                Visibility(
                  replacement: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: Image.file(
                      fit: BoxFit.contain,
                      File(
                        resim,
                      ),
                    ),
                  ),
                  child: Crop(
                    image: resimuint8List,
                    controller: _controller,
                    onCropped: (image) async {
                      File file = File(resim);
                      await file.writeAsBytes(image);

                      final exif = await Exif.fromPath(resim);
                      final attributes = await exif.getAttributes();
                      attributes?['GPSLatitude'] = pos.latitude;
                      attributes?['GPSLatitudeRef'] =
                          (pos.latitude >= 0) ? 'N' : 'S';
                      attributes?['GPSLongitude'] = pos.longitude;
                      attributes?['GPSLongitudeRef'] =
                          (pos.longitude >= 0) ? 'E' : 'W';

                      await exif.writeAttributes(attributes!);

                      setState(() {
                        imageCache.clear();
                        resim = null;
                      });
                    },
                    initialSize: 0.8,
                    baseColor: Colors.blue.shade900,
                    maskColor: Colors.black.withAlpha(100),
                    cornerDotBuilder: (size, edgeAlignment) =>
                        const DotControl(color: Colors.blue),
                  ),
                ),
              if (isPano == false &&
                  resim != null &&
                  preloader == false) // Crop Ekranı Kapatma Buttonu
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      color: Colors.black,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          resim = null;
                        });
                      },
                    ),
                  ),
                ),
              if (isPano == false &&
                  resim != null &&
                  preloader == false) // Crop Ekranı Kesme Buttonu
                Positioned(
                  bottom: 50,
                  right: 5,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      color: Colors.black,
                      icon: Icon(Icons.cut),
                      onPressed: () {
                        _controller.crop();
                      },
                    ),
                  ),
                ),
              if (isPano == false &&
                  resim == null &&
                  preloader == false) // Crop Yapma Buttonu
                Positioned(
                  bottom: 110,
                  right: 5,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(Icons.crop),
                      color: Colors.green,
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              AppLocalizations.of(context)!.resimKirpma,
                              textAlign: TextAlign.center,
                            ),
                            actions: [
                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: anaRenk),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text(
                                          AppLocalizations.of(context)!.ok)))
                            ],
                            content: Container(
                              width: 100,
                              height: 100,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: arr.length,
                                itemBuilder: (context, i) {
                                  print("orhan $arr");
                                  if (arr[i]["resim"].toString().isNotEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: GestureDetector(
                                        onTap: () async {
                                          File imageFile =
                                              File(arr[i]["resim"]);

                                          List<int> imageBytes =
                                              await imageFile.readAsBytes();
                                          Uint8List uint8List =
                                              Uint8List.fromList(imageBytes);

                                          setState(() {
                                            resim = arr[i]["resim"];
                                            resimuint8List = uint8List;
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: Image.file(
                                          fit: BoxFit.cover,
                                          File(
                                            arr[i]["resim"],
                                          ),
                                          scale: 5,
                                        ),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 300,
                  right: 5,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(Icons.cameraswitch_sharp),
                      color: Colors.green,
                      onPressed: () {
                        setState(() {
                          camera = camera+1;
                          if(camera > widget.cameras!.length) camera = -1;
                          initCamera(widget.cameras![camera+1]);
                        });
                      },
                    ),
                  ),
                ),
              if (resim == null && preloader == false)
                Positioned(
                  bottom: 250,
                  right: 5,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(Icons.copy),
                      color: Colors.green,
                      onPressed: () {
                        setState(() {
                          imageCache.clear();
                          images = [];
                          yanyana = !yanyana;
                          vertical = false;
                          horizantel = false;
                          isPano = yanyana;
                        });
                      },
                    ),
                  ),
                ),
              if (resim == null &&
                  preloader == false) // Panoramic Yatay Buttonu
                Positioned(
                  bottom: 200,
                  right: 5,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(Icons.panorama_horizontal),
                      color: Colors.green,
                      onPressed: () {
                        setState(() {
                          imageCache.clear();
                          images = [];
                          horizantel = !horizantel;
                          vertical = false;
                          yanyana = false;
                          isPano = horizantel;
                        });
                      },
                    ),
                  ),
                ),
              if (resim == null &&
                  preloader == false) // Panoramic Dikey Buttonu
                Positioned(
                  bottom: 155,
                  right: 5,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(Icons.panorama_vertical),
                      color: Colors.green,
                      onPressed: () {
                        setState(() {
                          imageCache.clear();
                          images = [];
                          horizantel = false;
                          yanyana = false;
                          vertical = !vertical;
                          isPano = vertical;
                        });
                      },
                    ),
                  ),
                ),
              if (isPano == false && resim == null && preloader == false)
                (customerDetail.efesDoorCount == null)
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          child: const Text(""),
                        ),
                      )
                    : Visibility(
                        visible: tip ==
                            5, // yalnızca kapı çekilirken gelsin İPTAL EDİLDİ 5 OLMADIĞI İÇİN 5 VERDİM SİLMEK YERİNE
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.all(15),
                          height: 95,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white.withAlpha(90),
                          ),
                          child: checklist(),
                        ),
                      ),
              if (resim == null && preloader == false)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      color: anaRenk,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                margin: const EdgeInsets.all(15),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    SizedBox(
                                      height: 51,
                                      width: 51,
                                      child: Image.asset(
                                        "assets/images/gyro.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: top,
                                      left: left,
                                      child: ClipOval(
                                        child: Container(
                                          width: 17,
                                          height: 17,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                margin: const EdgeInsets.all(15),
                                child: IconButton(
                                  onPressed: () async {
                                    if (seri) {
                                      // burada images dolu ise çalışması lazım.
                                      if (images.length > 1) {
                                        _timer?.cancel();
                                        setState(() {
                                          seri = false;
                                          preloader = true;
                                        });
                                        final stitch = dylib.lookupFunction<
                                            Void Function(Pointer<Utf8>,
                                                Pointer<Utf8>, Int32),
                                            void Function(Pointer<Utf8>,
                                                Pointer<Utf8>, int)>('stitch');
                                        String dirpath =
                                            (await getApplicationDocumentsDirectory())
                                                    .path +
                                                "/" +
                                                DateTime.now().toString() +
                                                "_.jpg";

                                        stitch(
                                            images.toString().toNativeUtf8(),
                                            dirpath.toNativeUtf8(),
                                            vertical ? 1 : 0);
                                        if (vertical) {
                                          Uint8List rotatedBytes =
                                              await _rotateBytes(File(dirpath)
                                                  .readAsBytesSync());
                                          img.Image? image = img.decodeImage(
                                              Uint8List.fromList(rotatedBytes));
                                          List<int> jpgBytes =
                                              img.encodeJpg(image!);

                                          File(dirpath)
                                              .writeAsBytesSync(jpgBytes);
                                        }

                                        final exif =
                                            await Exif.fromPath(dirpath);

                                        final attributes =
                                            await exif.getAttributes();
                                        attributes?['GPSLatitude'] =
                                            pos!.latitude;
                                        attributes?['GPSLatitudeRef'] =
                                            (pos!.latitude >= 0) ? 'N' : 'S';
                                        attributes?['GPSLongitude'] =
                                            pos!.longitude;
                                        attributes?['GPSLongitudeRef'] =
                                            (pos!.longitude >= 0) ? 'E' : 'W';

                                        await exif.writeAttributes(attributes!);

                                        setState(() {
                                          vertical = false;
                                          horizantel = false;
                                          isPano = false;
                                          imageCache.clear();

                                          var tarih = DateTime.now()
                                              .toUtc()
                                              .millisecondsSinceEpoch;

                                          if (debug == false) {
                                            if (Platform.isAndroid ||
                                                Platform.isIOS) {
                                              cekilenresim = dirpath;
                                            }
                                          }
                                          preloader = false;
                                          if (aktifindex > arr.length) {
                                            arr.add({
                                              "tip": tip,
                                              "sira": aktifindex,
                                              "resim": dirpath,
                                              "tarih": tarih,
                                              "secilenrenk": Colors.transparent,
                                              "renk": const Color(0xff059305),
                                            });
                                            aktifindex++;
                                          } else {
                                            arr[aktifindex - 1]["renk"] =
                                                const Color(0xff059305);
                                            arr[aktifindex - 1]["resim"] =
                                                dirpath;
                                            arr[aktifindex - 1]["tarih"] =
                                                tarih;
                                            aktifindex++;
                                          }
                                        });
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Panoramik çekim için en az 2 adet resim çekiniz",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      }
                                    } else {
                                      takePicture();
                                    }
                                  },
                                  iconSize: 50,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: (seri
                                      ? const Icon(Icons.stop,
                                          color: Colors.white)
                                      : (vertical || horizantel
                                          ? const Icon(Icons.play_arrow,
                                              color: Colors.white)
                                          : const Icon(Icons.photo_camera,
                                              color: Colors.white))),
                                ),
                              ),
                            ),
                          ),
                        ),
                        cekilenresim != null &&
                                    dolaplar
                                        .where((element) =>
                                            element["resim"].toString() != "")
                                        .isNotEmpty ||
                                teshirler
                                    .where((element) =>
                                        element["resim"].toString() != "")
                                    .isNotEmpty ||
                                tabelalar
                                    .where((element) =>
                                        element["resim"].toString() != "")
                                    .isNotEmpty ||
                                sicaRaflar
                                    .where((element) =>
                                        element["resim"].toString() != "")
                                    .isNotEmpty
                            ? Expanded(
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      _dialogBuilder(context);
                                    },
                                    child: Container(
                                      width: 80,
                                      color: Colors.white,
                                      margin: const EdgeInsets.all(15),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        clipBehavior: Clip.none,
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            child: (cekilenresim != null)
                                                ? Image.file(
                                                    File(cekilenresim),
                                                    fit: BoxFit.cover,
                                                  )
                                                : const Text(""),
                                          ),
                                          Positioned(
                                            top: -10,
                                            left: -10,
                                            child: ClipOval(
                                              child: Container(
                                                width: 25,
                                                height: 25,
                                                color: anaRenk,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Text(
                                                    cekilenresim != null
                                                        ? (dolaplar
                                                                    .where((element) =>
                                                                        element[
                                                                            "resim"] !=
                                                                        "")
                                                                    .length +
                                                                teshirler
                                                                    .where((element) =>
                                                                        element[
                                                                            "resim"] !=
                                                                        "")
                                                                    .length +
                                                                tabelalar
                                                                    .where((element) =>
                                                                        element[
                                                                            "resim"] !=
                                                                        "")
                                                                    .length +
                                                                sicaRaflar
                                                                    .where((element) =>
                                                                        element[
                                                                            "resim"] !=
                                                                        "")
                                                                    .length)
                                                            .toString()
                                                        : "",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const Expanded(
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Material(
                                    child: Text(""),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
            ]),
          )),
    );
  }

  Widget checklist() {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: arr.length,
      itemBuilder: (BuildContext context, int index) {
        return Row(
          children: [
            if (index > 0)
              const Column(
                children: [
                  Text(""),
                  Icon(
                    Icons.remove,
                    color: Colors.green,
                    size: 30,
                  ),
                ],
              ),
            Container(
              color: arr[index]["secilenrenk"],
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        aktifindex = arr[index]["sira"];
                        arr[index]["secilenrenk"] =
                            const Color.fromARGB(255, 208, 218, 233);
                      });
                    },
                    child: (arr[index]["renk"] == Colors.transparent)
                        ? Icon(Icons.close, color: Colors.white)
                        : Icon(Icons.check, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(
                        side: BorderSide(width: 2, color: Colors.white),
                      ),
                      padding: const EdgeInsets.all(1),
                      backgroundColor: arr[index]["renk"],
                    ),
                  ),
                  Text(
                      (index + 1).toString() +
                          "." +
                          AppLocalizations.of(context)!.sogutucu,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  ekle(sira, item) {
    if (item["resim"] != "") {
      PictureV1 picture = PictureV1(
        customerDetail.customerSapCode.toString(),
        sira,
        item["resim"],
        item["sira"],
        item["tarih"].toString(),
        0,
      );
      helper.insertPicture(picture);
      print("Resimler Insert oldu");
    }
  }
}
