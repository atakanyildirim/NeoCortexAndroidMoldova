import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_exif/native_exif.dart';
import 'package:native_shutter_sound/native_shutter_sound.dart';
import 'package:need_resume/need_resume.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ana uygulama widget'ınız
class CameraApp extends StatefulWidget {
  final Customer customerSurver;
  final Position? position;

  const CameraApp(
      {super.key, required this.customerSurver, required this.position});
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends ResumableState<CameraApp> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List resimler = [];
  final _controller = CropController();
  var resim = null;
  var resimuint8List = null;
  bool horizantel = false;
  bool vertical = false;
  bool startStream = false;
  bool isPano = false;
  var images = [];

  final dylib = Platform.isAndroid
      ? DynamicLibrary.open("libOpenCV_ffi.so")
      : DynamicLibrary.process();

  @override
  void initState() {
    super.initState();

    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras!.isNotEmpty) {
        // Kamera listesinden bir kamera seç
        setState(() {
          controller = CameraController(cameras![0], ResolutionPreset.high,
              enableAudio: false,
              imageFormatGroup : ImageFormatGroup.yuv420);
        });

        // Kamerayı başlat
        controller?.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: Stack(
        children: [
          cameraWidget(context),
          Container(
            width: MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height - 60,
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                takePicture();
              },
            ),
          ),
          if (vertical || horizantel)
            Positioned(
              bottom: 5,
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
                      isPano = false;
                    });
                  },
                ),
              ),
            ),
          if (vertical || horizantel)
            Positioned(
              bottom: 5,
              right: 5,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: IconButton(
                  padding: const EdgeInsets.all(8),
                  icon: const Icon(Icons.save),
                  color: Colors.green,
                  onPressed: () async {
                    final stitch = dylib.lookupFunction<
                        Void Function(Pointer<Utf8>, Pointer<Utf8>, Int32),
                        void Function(
                            Pointer<Utf8>, Pointer<Utf8>, int)>('stitch');
                    String dirpath =
                        (await getApplicationDocumentsDirectory()).path +
                            "/" +
                            DateTime.now().toString() +
                            "_.jpg";

                    stitch(images.toString().toNativeUtf8(),
                        dirpath.toNativeUtf8(), vertical ? 1 : 0);

                      final exif = await Exif.fromPath(dirpath);
                      final attributes = await exif.getAttributes();
                      attributes?['GPSLatitude'] = widget.position!.latitude;
                      attributes?['GPSLatitudeRef'] =
                          (widget.position!.latitude >= 0) ? 'N' : 'S';
                      attributes?['GPSLongitude'] = widget.position!.longitude;
                      attributes?['GPSLongitudeRef'] =
                          (widget.position!.longitude >= 0) ? 'E' : 'W';

                      await exif.writeAttributes(attributes!);
                      final SharedPreferences prefs = await _prefs;

                    setState(() {
                      vertical = false;
                      horizantel = false;
                      isPano = false;
                      imageCache.clear();

                      resimler.add(dirpath);
                      
                      prefs.setString("resimler", jsonEncode(resimler));
                      setState(() {});
                    });
                  },
                ),
              ),
            ),
          if (vertical) // Dikey Panoramic
            Container(
              margin: EdgeInsets.only(bottom: 50, top: 50),
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
          if (horizantel) // Yatay Panoramic
            Container(
              margin: EdgeInsets.only(top: 50),
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
          if (isPano == false && resim != null) // Crop Ekranı
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
                  attributes?['GPSLatitude'] = widget.position!.latitude;
                  attributes?['GPSLatitudeRef'] =
                      (widget.position!.latitude >= 0) ? 'N' : 'S';
                  attributes?['GPSLongitude'] = widget.position!.longitude;
                  attributes?['GPSLongitudeRef'] =
                      (widget.position!.longitude >= 0) ? 'E' : 'W';

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
          if (isPano == false && resim != null) // Crop Ekranı Kapatma Buttonu
            Positioned(
              bottom: 5,
              right: 50,
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
          if (isPano == false && resim != null) // Crop Ekranı Kesme Buttonu
            Positioned(
              bottom: 5,
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
          if (resim == null) // Panoramic Yatay Buttonu
            Positioned(
              bottom: 150,
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
                      isPano = horizantel;
                    });
                  },
                ),
              ),
            ),
          if (resim == null) // Panoramic Dikey Buttonu
            Positioned(
              bottom: 100,
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
                      vertical = !vertical;
                      isPano = vertical;
                    });
                  },
                ),
              ),
            ),
          if (isPano == false && resim == null) // Çekilen Resim Adedi
            Positioned(
              left: 5,
              bottom: 5,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Text(resimler.length.toString()),
              ),
            ),
          if (resim == null) // Resim Çekme İkonu
            Positioned(
              bottom: 5,
              left: MediaQuery.of(context).size.width / 2 - 20,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: IconButton(
                  padding: EdgeInsets.all(8),
                  icon: const Icon(Icons.camera_alt),
                  color: Colors.blue,
                  onPressed: () {
                    takePicture();
                  },
                ),
              ),
            ),
          if (isPano == false && resim == null) // Crop Yapma Buttonu
            Positioned(
              bottom: 50,
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
                                  onPressed: () => Navigator.of(context).pop(),
                                  child:
                                      Text(AppLocalizations.of(context)!.ok)))
                        ],
                        content: Container(
                          width: 100,
                          height: 100,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: resimler.length,
                            itemBuilder: (context, i) {
                              if (resimler[i] != null) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: GestureDetector(
                                    onTap: () async {
                                      File imageFile = File(resimler[i]);

                                      List<int> imageBytes =
                                          await imageFile.readAsBytes();
                                      Uint8List uint8List =
                                          Uint8List.fromList(imageBytes);

                                      setState(() {
                                        resim = resimler[i];
                                        resimuint8List = uint8List;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Image.file(
                                      fit: BoxFit.cover,
                                      File(
                                        resimler[i],
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
          if (isPano == false && resim == null) // İşlemi Tamamla Buttonu
            Positioned(
              bottom: 5,
              right: 5,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: IconButton(
                  padding: const EdgeInsets.all(8),
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget cameraWidget(context) {
    var camera = controller!.value;
    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * camera.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(controller!),
      ),
    );
  }

  Future<void> takePicture() async {
    if (!controller!.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }

    if (controller!.value.isTakingPicture) {
      // Eğer bir resim zaten çekiliyorsa, yeni bir çekime izin verme
      return;
    }

    try {
      await controller?.setFocusMode(FocusMode.locked);
      await controller?.setExposureMode(ExposureMode.locked);

      if (horizantel || vertical) {
        NativeShutterSound.play();
        var x = await controller!.takePicture();
        setState(() {
          images.add(x.path);
        });
      } else {
        NativeShutterSound.play();
        var x = await controller!.takePicture();

        final exif = await Exif.fromPath(x.path);
        final attributes = await exif.getAttributes();
        attributes?['GPSLatitude'] = widget.position!.latitude;
        attributes?['GPSLatitudeRef'] =
            (widget.position!.latitude >= 0) ? 'N' : 'S';
        attributes?['GPSLongitude'] = widget.position!.longitude;
        attributes?['GPSLongitudeRef'] =
            (widget.position!.longitude >= 0) ? 'E' : 'W';

        await exif.writeAttributes(attributes!);

        resimler.add(x.path);
        final SharedPreferences prefs = await _prefs;
        prefs.setString("resimler", jsonEncode(resimler));
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
