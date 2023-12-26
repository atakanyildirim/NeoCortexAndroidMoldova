import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/presentation/Widget/v1widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({Key? key, required this.data}) : super(key: key);
  final String data;
  // ignore: library_private_types_in_public_api, annotate_overrides
  _ComparePageState createState() => _ComparePageState(data);
}

class _ComparePageState extends State<ComparePage> {
  String data;
  _ComparePageState(this.data);
  var forAndroid = false;
  var yukseklik = 720.0;
  var json;
  var debug = false;
  final listController =
      PageController(initialPage: 0, viewportFraction: 0.33, keepPage: false);

  List sonListe = [];

  final _key = GlobalKey();
  late var position;
  late var size;
  var orgiW;
  var orgiH;

  var lastW;
  var lastH;

  var aspW;
  var aspH;

  List urunler = [
    "PILSEN-50-KUTU",
    "PILSEN-33-KUTU",
    "PILSEN-50*6-KUTU",
    "PILSEN-50*8-KUTU",
    "PILSEN-50*4-KUTU",
    "PILSEN-50-SISE",
    "PILSEN-50*4-SISE",
    "PILSEN-30-SISE",
    "PILSEN-30*4-SISE",
    "PILSEN-1LT-KUTU",
    "RETRO-50-SISE",
    "YENIPILSEN-50-SISE",
    "YENIPILSEN-50*4-SISE",
    "YENIPILSEN-33-SISE",
    "EXTRA-50-KUTU",
    "EXTRA-50*4-KUTU",
    "EXTRA-23-KUTU",
    "BOMONTI-FABRIKA-50-SISE",
    "BOMONTI-FABRIKA-50*4-SISE",
    "BOMONTI-FABRIKA-33-SISE",
    "BOMONTI-FILTRESIZ-SISE",
    "BOMONTI-FILTRESIZ-50*4-SISE",
    "BOMONTI-REDALE-SISE",
    "BOMONTI-BLACK-SISE",
    "BOMONTI-IPA-SISE",
    "MALT-KUTU",
    "MALT-50*4-KUTU",
    "MALT-50-SISE",
    "MALT-33-SISE",
    "MALT-50*6-KUTU",
    "MALT-50*4-SISE",
    "OZELSERI-50-SISE",
    "OZELSERI-50*4-SISE",
    "OZELSERI-50-KUTU",
    "OZELSERI-50*6-KUTU",
    "BREMEN-KUTU",
    "BREMEN-YUKSEKALKOL-KUTU",
    "VARIM-45-KUTU",
    "VARIM-ELMA-33-KUTU",
    "VARIM-SEFTALI-33-KUTU",
    "VARIM-GREYFURT-33-KUTU",
    "VARIM-LIMON-45-KUTU",
    "VARIM-LIMON-45*6-KUTU",
    "VARIM-45*6-KUTU",
    "EFES-LIGHT-33-SISE",
    "GRAPEALE-75-SISE",
    "AMSTERDAM-50-KUTU",
    "AMSTERDAM-50*2-KUTU",
    "AMSTERDAM-50-SISE",
    "MILLER-33-SISE",
    "MILLER-50-KUTU",
    "MILLER-50-SISE",
    "MILLER-50*4-SISE",
    "MILLER-50*6-SISE",
    "MILLER-33*6-SISE",
    "BECKS-50-SISE",
    "BECKS-50*4-SISE",
    "BECKS-50-KUTU",
    "BECKS-50*4-KUTU",
    "BECKS-33-SISE",
    "DUVEL-33-SISE",
    "CORONA-35-SISE",
    "CORONA-35*6-SISE",
    "BUD-50-KUTU",
    "BUD-50-SISE",
    "BUD-50*4-SISE",
    "LEFFE-BRUNE-33-SISE",
    "LEFFE-BLONDE-33-SISE",
    "MARMARA-1-SISE",
    "SUMMERBLUE-50-SISE",
    "WINTERBLUE-50-SISE",
    "GLUTENSIZ-50-SISE",
    "FICI-50-KUTU",
    "BUDWEISER-33-SISE",
    "BUDWEISER-50-KUTU",
    "ERDINGER-33-SISE",
    "ERDINGER-DUNKEL-33-SISE",
    "GROLSCH-45-SISE",
    "HOEGAARDEN-33-SISE",
    "TB-GOLD-33-SISE",
    "TB-GOLD-50-SISE",
    "TB-GOLD-50*4-SISE",
    "TB-GOLD-50-KUTU",
    "TB-GOLD-50*6-KUTU",
    "TB-GOLD-50*4-KUTU",
    "TB-GOLD-25-KUTU",
    "TB-GOLD-33-KUTU",
    "TB-SPECIAL-25-KUTU",
    "TB-SPECIAL-50-KUTU",
    "TB-SPECIAL-50*4-KUTU",
    "TB-FILTRESIZ-50-SISE",
    "TB-FILTRESIZ-50*4-SISE",
    "TB-FILTRESIZ-50-KUTU",
    "TB-FILTRESIZ-50*4-KUTU",
    "TB-AMBER-50-KUTU",
    "TB-AMBER-50*4-KUTU",
    "TB-AMBER-50-SISE",
    "TB-AMBER-50*4-SISE",
    "TB-AMBER-33-SISE",
    "TB-SUMMER-50-KUTU",
    "TB-SUMMER-50*4-KUTU",
    "TB-SUMMER-50-SISE",
    "TB-SUMMER-50*4-SISE",
    "TB-WAVE-50-KUTU",
    "TB-WAVE-50*4-KUTU",
    "TB-WAVE-50-SISE",
    "TB-WAVE-50*4-SISE",
    "TB-WINTER-50-KUTU",
    "TB-WINTER-50-SISE",
    "CRLBERG-50-SISE",
    "CRLBERG-50*4-SISE",
    "CRLBERG-LUNA-50-KUTU",
    "CRLBERG-LUNA-50*4-KUTU",
    "CRLBERG-LUNA-50-SISE",
    "CRLBERG-50-KUTU",
    "CRLBERG-50*6-KUTU",
    "CRLBERG-33-SISE",
    "CRLBERG-33*6-SISE",
    "CRLBERG-33-KUTU",
    "TB-GOLD-50*4-KUTU",
    "BLANC-33*6-SISE",
    "BOHEM-50-KUTU",
    "BOHEM-50-SISE",
    "BOHEM-50*4-KUTU",
    "BOHEM-50*4-SISE",
    "DESPERADO-SISE",
    "GRIMBERGEN-BLONDE-33-SISE",
    "GRIMBERGEN-AMBREE-33-SISE",
    "SKOL-PETSISE",
    "WEIHENS-VITUS-50-SISE",
    "WEIHENS-VITUS-33-SISE",
    "WEIHENS-VITUS-33*6-SISE",
    "WEIHENS-HEFEWEISEN-50-SISE",
    "WEIHENS-HEFEWEISEN-50*6-SISE",
    "WEIHENS-HEFEWEISEN-33-SISE",
    "GUINNESS-BLONDE-33*6",
    "GUINNESS-44*8-KUTU",
    "GUINNESS-DOUBLE-33*6-SISE",
    "GUINNESS-KUTU",
    "DESPERADOS-33-SISE",
    "DESPERADOS-33*6-SISE",
    "SOL-33-SISE",
    "SOL-33*6-SISE",
    "FRD-BROWNALE-SISE",
    "FRD-INDIAPALE-SISE",
    "FRD-MARZEN-SISE",
    "FRD-WHEAT-SISE",
    "FRD-YAKIMA-SISE",
    "GOAT-50-SISE",
    "GOAT-33-SISE",
    "GOAT-BEYAZ-33-SISE",
    "PERGE-SISE",
    "PERGE-SISE",
    "HEINEKEN-33-SISE",
    "HEINEKEN-33*6-SISE",
    "HEINEKEN-50-KUTU",
    "HEINEKEN-33-KUTU",
    "HEINEKEN-50-SISE",
    "AMSTEL-SISE",
    "AMSTEL-KUTU",
    "STRONGBOW-SISE",
    "BOMBARDIER-SISE",
    "PAULANER-SISE",
    "KIRIN-SISE",
    "LONDON-PRIDE-SISE",
    "FRANZISKANER-WEISSBIER-50-SISE",
    "HOBGOBLIN-50-SISE",
    "CUMARTESI-LIME",
    "CUMARTESI-PEACH",
    "EDELMEISTER",
    "OMER-50-KUTU",
    "PEJA-33-SISE",
    "VOLIM-KUCUK",
    "VOLIM-1LT",
    "SARAP",
    "YUKSEK-ALKOL",
    "SU",
    "ALKOLSUZ-URUN",
    "YABANCI-URUN",
    "KRONENBOURG-BLANC-SISE",
    "YABANCI-BIRA",
    "KRONENBOURG-33*6-SISE",
    "KROMBACHER-SISE",
    "BELFAST-50-KUTU",
    "BELFAST-50-SISE",
    "BOMONTI-FILTRESIZ-50-KUTU",
    "BOMONTI-FILTRESIZ-50*16-SISE",
    "BOMONTI-FILTRESIZ-BUGDAY-50-SISE",
    "BOMONTI-FILTRESIZ-BUGDAY-50*4-SISE",
    "BUD-50*16-SISE",
    "BREMEN-50-SISE",
    "EFES-EVEREST-50-KUTU",
    "EFES-KOZMOZ-LIMON-SISE",
    "EFES-KOZMOZ-ORMANMEYVE-SISE",
    "MALT-50*16-SISE",
    "MARMARA-50-KUTU",
    "OZELSERI-50*16-SISE",
    "PILSEN-RESERVE-50-KUTU",
    "PILSEN-RESERVE-50-SISE",
    "TB-WINTER-50*4-KUTU",
    "YENIPILSEN-50*16-SISE",
    "ALECOQ",
    "BLUEMOON-33-SISE",
    "CRLBERG-50*4-KUTU",
    "CRLBERG-50*6-SISE",
    "CRLBERG-LUNA-50*4-SISE",
    "GRIMBERGEN-BLONDE-33*6-SISE",
    "VARIM-ORMANMEYVELI-33-KUTU",
    "SUMMERBREW-50-SISE",
    "SUMMERBREW-50-KUTU",
    "WEIHENS-HEFEWEISEN-33*6-SISE",
    "GARAGUZU-BLONDEALE-33-SISE",
    "GARAGUZU-AMBERALE-33-SISE",
    "GARAGUZU-SUMMERIPA-33-SISE",
    "GARAGUZU-MAYHOS-33-SISE",
    "GARAGUZU-REDALE-33-SISE",
    "GARAGUZU-WEISSBEER-33-SISE",
    "GARAGUZU-GARA-33-SISE",
    "GARAGUZU-SARIMEMED-33-SISE",
    "GARAGUZU-MESELI-33-SISE",
    "GARAGUZU-KARLIKAYIN-33-SISE",
    "GARAGUZU-TERSKOSE-33-SISE",
    "GARAGUZU-IPA4C-33-SISE",
    "GARAGUZU-BLONDEALE-33-KUTU",
    "GARAGUZU-AMBERALE-33-KUTU",
    "GARAGUZU-SUMMERIPA-33-KUTU",
    "GARAGUZU-MAYHOS-33-KUTU",
    "GARAGUZU-REDALE-33-KUTU",
    "GARAGUZU-WEISSBEER-33-KUTU",
    "GARAGUZU-GARA-33-KUTU",
    "GARAGUZU-SARIMEMED-33-KUTU",
    "GARAGUZU-MESELI-33-KUTU",
    "GARAGUZU-KARLIKAYIN-33-KUTU",
    "GARAGUZU-TERSKOSE-33-KUTU",
    "GARAGUZU-IPA4C-33-KUTU",
    "ESTRELLA-DAMM-50-SISE",
    "ESTRELLA-DAMM-50-KUTU",
    "MAISEL-WESTCOAST-IPA",
    "MAISEL-HELL",
    "MAISEL-PALEALE",
    "MAISEL-ALKOHOLFREI",
    "MAISEL-INDIA-PALEALE",
    "GUINNESS-FOREIGN-EXTRA",
    "HEINEKEN-50*4-KUTU",
    "STARY-MELNIK-SISE"
  ];

  List urunrenkleri = [
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff000080),
    const Color(0xff000080),
    const Color(0xff000080),
    const Color(0xff964b00),
    const Color(0xff964b00),
    const Color(0xff964b00),
    const Color(0xff964b00),
    const Color(0xff964b00),
    const Color(0xff964b00),
    const Color(0xff964b00),
    const Color(0xff964b00),
    const Color(0xffFFD700),
    const Color(0xffFFD700),
    const Color(0xffFFD700),
    const Color(0xffFFD700),
    const Color(0xffFFD700),
    const Color(0xffFFD700),
    const Color(0xff008000),
    const Color(0xff008000),
    const Color(0xff008000),
    const Color(0xff008000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xffFFFFFF),
    const Color(0xffFFFFFF),
    const Color(0xffFFFFFF),
    const Color(0xffFFFFFF),
    const Color(0xffFFFFFF),
    const Color(0xffFFFFFF),
    const Color(0xffFFFFFF),
    const Color(0xff800080),
    const Color(0xff800080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xffFF0000),
    const Color(0xffFF0000),
    const Color(0xffFF0000),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff800080),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff800080),
    const Color(0xff0000FF),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff008000),
    const Color(0xff008000),
    const Color(0xff964b00),
    const Color(0xff964b00),
    const Color(0xff964b00),
    const Color(0xff964b00),
    const Color(0xffFF0000),
    const Color(0xff000000),
    const Color(0xff0000FF),
    const Color(0xff808080),
    const Color(0xff808080),
    const Color(0xffFFD700),
    const Color(0xff800080),
    const Color(0xff008000),
    const Color(0xff800000),
    const Color(0xff800000),
    const Color(0xff000000),
    const Color(0xff0000FF),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xffFFFFFF),
    const Color(0xff0000FF),
    const Color(0xff0000FF),
    const Color(0xff000000),
    const Color(0xff000024),
    const Color(0xff000023),
    const Color(0xff000022),
    const Color(0xff000021),
    const Color(0xff000020),
    const Color(0xff000019),
    const Color(0xff000018),
    const Color(0xff000017),
    const Color(0xff000016),
    const Color(0xff000015),
    const Color(0xff000014),
    const Color(0xff000013),
    const Color(0xff000012),
    const Color(0xff000011),
    const Color(0xff000010),
    const Color(0xff000009),
    const Color(0xff000008),
    const Color(0xff000007),
    const Color(0xff000006),
    const Color(0xff000005),
    const Color(0xff000004),
    const Color(0xff000003),
    const Color(0xff000002),
    const Color(0xff000001),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000),
    const Color(0xff000000)
  ];

  var inx;
  var cizimListesi;
  var dolapPlanogram;
  var kategoriListesi;
  var target_planogram_for_this_customer;
  var planogram_category_colors;
  var planogramListesi = {};
  var planogramRenkListesi = {};

  List<dynamic> parseString(String inputString) {
    List<dynamic> parsedList = [];

    RegExp regExp = RegExp(r'{(.*?)}');
    Iterable<Match> matches = regExp.allMatches(inputString);

    for (Match match in matches) {
      String? keyValueString = match.group(1);
      List<String> keyValueList = keyValueString!.split(':');
      if (keyValueList.length == 2) {
        String key = keyValueList[0].trim();
        int value = int.tryParse(keyValueList[1].trim()) ?? 100;
        parsedList.add(key);
        parsedList.add(value);
      }
    }

    return parsedList;
  }

  @override
  void initState() {
    super.initState();
    json = jsonDecode(data);
    inx = json["giden_index"];

    target_planogram_for_this_customer =
        json["target_planogram_for_this_customer"];
    planogram_category_colors = json["planogram_category_colors"];

    dolapPlanogram =
        json["Content"]["planogram_result"]["planogram_analyze_result"];

    var count = target_planogram_for_this_customer.length;

    for (var i = 0; i < count; i++) {
      if (dolapPlanogram.keys.contains("door-${i + 1}")) {
        planogramListesi[i] = target_planogram_for_this_customer[i];
      }
    }

    var count2 = planogram_category_colors.length;

    for (var i = 0; i < count2; i++) {
      var isim = planogram_category_colors[i]["isim"];
      var renkKodu = planogram_category_colors[i]["renkKodu"];
      planogramRenkListesi[isim] = renkKodu;
    }

    cizimListesi = json["Content"]["products"][(++inx).toString()]
        ["File_Inference_Output"];

    var i = 1;
    dolapPlanogram.forEach((anahtar, deger) {
      if (i == 1) {
        sonListe.add(deger);
      }
      i++;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Size> _calculateImageDimension(String s) {
    Completer<Size> completer = Completer();
    Image image;
    if (debug) {
      image = Image.asset((s));
    } else {
      image = Image.file(File(s));
    }

    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
  }

  void calculateposition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? box =
          _key.currentContext?.findRenderObject() as RenderBox?;
      position = box?.localToGlobal(Offset.zero);
      size = box?.size;
      if (size.width != null) {
        lastW = size.width;
      }
      if (size.height != null) {
        lastH = size.height;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    calculateposition();

    _calculateImageDimension(json["giden_resim"]).then((size) {
      setState(() {
        orgiW = size.width;
        orgiH = size.height;
        aspW = orgiW / lastW;
        aspH = orgiH / lastH;
      });
    });

    kategoriListesi = List.generate(planogramListesi.length, (index) {
      var s = index + 1;
      return GestureDetector(
        onTap: () {
          setState(() {
            var i = 1;

            List filteredUrunler = [];
            dolapPlanogram.forEach((anahtar, deger) {
              if (i == s) {
                filteredUrunler.add(deger);
              }

              i++;
            });

            sonListe = filteredUrunler;
          });
        },
        child: Container(
          alignment: Alignment.center,
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
            s.toString() + " . " +AppLocalizations.of(context)!.dolap,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: anaRenk,
        title: Text(AppLocalizations.of(context)!.karsilastirma),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: yukseklik,
                decoration: BoxDecoration(
                  color: anaRenk,
                  borderRadius: BorderRadius.circular(7),
                ),
                margin: const EdgeInsets.all(20),
                child: ContainedTabBarView(
                  tabs: [
                    SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(context)!
                                .realogramZiyaretBaslangic,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(context)!.planogram,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                  tabBarProperties: TabBarProperties(
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(7),
                          topLeft: Radius.circular(7),
                        ),
                      ),
                    ),
                    indicator: const ContainerTabIndicator(
                      radius: BorderRadius.only(
                        topRight: Radius.circular(7),
                        topLeft: Radius.circular(7),
                      ),
                      color: anaRenk,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white,
                  ),
                  views: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Stack(
                            children: [
                              debug
                                  ? Image.asset(
                                      json["giden_resim"],
                                      alignment: Alignment.topCenter,
                                      fit: BoxFit.contain,
                                      key: _key,
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        showImageViewer(
                                            context,
                                            Image.file(
                                                    File(json["giden_resim"]))
                                                .image,
                                            swipeDismissible: true,
                                            doubleTapZoomable: true);
                                      },
                                      child: Image.file(
                                        File(json["giden_resim"]),
                                        alignment: Alignment.topCenter,
                                        fit: BoxFit.contain,
                                        key: _key,
                                      ),
                                    ),
                              if (forAndroid)
                                CustomPaint(
                                  painter: (YourRect(aspW, aspH, cizimListesi!,
                                      urunler, urunrenkleri)),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.gercekFotograf,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
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
                                height: 30, //set desired REAL HEIGHT
                                width: 50, //set desired REAL WIDTH
                                child: Transform.scale(
                                  transformHitTests: false,
                                  scale: .8,
                                  child: CupertinoSwitch(
                                    thumbColor: anaRenk,
                                    value: forAndroid,
                                    onChanged: (value) {
                                      setState(() {
                                        forAndroid = value;
                                      });
                                    },
                                    activeColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                AppLocalizations.of(context)!.analizGorsel,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (yukseklik == 700.0)
                      Row(
                        children: [
                          for (var i = 0; i < planogramListesi.length; i++)
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  for (var k = 0;
                                      k < planogramListesi[i].length;
                                      k++)
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: [
                                          for (var j = 0;
                                              j <
                                                  planogramListesi[i]
                                                          ["slot-${i + 1}"]
                                                      .length;
                                              j++)
                                            Flexible(
                                              flex: 100 ~/
                                                  parseString(planogramListesi[
                                                                  i]
                                                              ["slot-${i + 1}"]
                                                          ["${j + 1}"]
                                                      .toString())[1],
                                              fit: FlexFit.tight,
                                              child: Container(
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Color(int.parse(
                                                      planogramRenkListesi[parseString(
                                                              planogramListesi[
                                                                              i]
                                                                          [
                                                                          "slot-${i + 1}"]
                                                                      [
                                                                      "${j + 1}"]
                                                                  .toString())[0]]
                                                          .replaceAll('#', '0xff'))),
                                                ),
                                                child: Center(
                                                    child: Text(
                                                        parseString(planogramListesi[
                                                                            i][
                                                                        "slot-${i + 1}"]
                                                                    ["${j + 1}"]
                                                                .toString())[0]
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                              ), //Container
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    if (yukseklik == 720.0)
                      CircularPercentIndicator(radius: 20),
                  ],
                  // ignore: avoid_print
                  onChange: (index) {
                    if (index == 0) {
                      setState(() {
                        yukseklik = 720.0;
                      });
                    }
                    if (index == 1) {
                      setState(() {
                        yukseklik = 700.0;
                      });
                    }
                  },
                ),
              ),
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
                            return kategoriListesi[
                                index % kategoriListesi.length];
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxHeight: 2000, minHeight: 56.0),
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 14, left: 14, top: 15, bottom: 15),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sonListe[0].length - 1,
                    itemBuilder: (BuildContext context, int index) {
                      var arr = [];

                      Map x = sonListe[0];

                      x.forEach((key, value) {
                        if (key != "Cooler") {
                          Map v = value;
                          v.forEach((key2, value2) {
                            arr.add({
                              "raf": key,
                              "k": key2,
                              "v": value2,
                            });
                          });
                        }
                      });

                      return Column(
                        children: [
                          defaultBox(
                            child: ListTile(
                              leading: const Icon(
                                Icons.warning_rounded,
                                color: Colors.red,
                              ),
                              title: Text(arr[index]["k"]),
                              subtitle: Text(arr[index]["raf"]),
                              trailing: Text(arr[index]["v"]),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class YourRect extends CustomPainter {
  var aspW;
  var aspH;
  var result;
  List urunler;
  List urunrenkleri;

  YourRect(this.aspW, this.aspH, this.result, this.urunler, this.urunrenkleri);
  @override
  void paint(Canvas canvas, Size size) {
    Map x = result;
    x.forEach((key, s) {
      Color colorX = Colors.red;
      int index = urunler.indexWhere((item) => item == s["label"]);
      if (index > -1) {
        colorX = urunrenkleri[index];
      }
      canvas.drawRect(
          Rect.fromLTRB(s["x_min"] / aspW, s["y_max"] / aspW, s["x_max"] / aspW,
              s["y_min"] / aspW),
          Paint()
            ..color = colorX
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0);
    });
  }

  @override
  bool shouldRepaint(YourRect oldDelegate) {
    return false;
  }
}
