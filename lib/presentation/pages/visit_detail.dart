import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/presentation/Widget/v1widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;

class VisitDetail extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final transactions;

  const VisitDetail({Key? key, required this.transactions}) : super(key: key);

  @override
  State<VisitDetail> createState() => _VisitDetailState();
}

class _VisitDetailState extends State<VisitDetail> {
  AuthenticateManager authenticateManager = AuthenticateManager();
    
  @override
  void initState() {
    super.initState();
    authenticateManager.init();
  }

  Future postItiraz(int id, int itirazTipi) async {
    var request = http.MultipartRequest(
        "POST", Uri.parse("https://labelmd.neocortexs.com/servis"));
    request.fields['username'] = 'ozan.kocer.rest_user';
    request.fields['password'] = '#Z825!/8;Sz4g*r(';
    request.fields['servis'] = 'itirazlar';
    request.fields['tip_kodu'] = '4';
    request.fields['kullanici'] = authenticateManager.getFullName()!;
    request.fields['be_id'] = id.toString();
    request.fields['type'] = "1";
    request.fields['itiraz_tipi'] = itirazTipi.toString();

    final streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    var baslik = "";
    var msg = "";
    var icon;

    print(jsonDecode(response.body));
    if (jsonDecode(response.body)["status"] == 200) {
      baslik = "Bilgi";
      msg = jsonDecode(response.body)["content"];
      icon = const Icon(
        Icons.check,
        color: Colors.green,
      );
    } else {
      baslik = "Hata";
      msg = jsonDecode(response.body)["content"];
      icon = const Icon(
        Icons.close,
        color: Colors.red,
      );
    }

    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: anaRenk,
        title: Text(
          AppLocalizations.of(context)!.ziyaretdetay,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: MaterialButton(
              color: Colors.white,
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text(
                            AppLocalizations.of(context)!.uyari,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: anaRenk),
                                    onPressed: () {
                                      postItiraz(widget.transactions.id,1);
                                    },
                                    child: Text(AppLocalizations.of(context)!
                                        .yanlisGiris))),
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: anaRenk),
                                    onPressed: () {
                                      postItiraz(widget.transactions.id,2);
                                    },
                                    child: Text(AppLocalizations.of(context)!
                                        .yanlisUrunTanima))),
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.iptal)))
                          ],
                          content: Text(
                            AppLocalizations.of(context)!.silmeTalepMetni,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Text(
                AppLocalizations.of(context)!.silmeTalepEt,
                style: const TextStyle(
                    color: anaRenk, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 10.0, bottom: 5.0),
            child: defaultBox(
              child: ListTile(
                leading: const Icon(
                  Icons.circle,
                  color: anaRenk,
                ),
                title: Text(widget.transactions.unvan),
                subtitle: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: anaRenk,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        widget.transactions.customerSapCode.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.black,
                          ),
                          Text(DateFormat('dd.MM.yyyy HH:mm')
                              .format(widget.transactions.dateTime)
                              .toString()),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.image,
                            color: Colors.black,
                          ),
                          Text(widget.transactions.numberOfFiles.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Text(AppLocalizations.of(context)!.planogram),
                        ),
                        CircularPercentIndicator(
                          radius: 60.0,
                          lineWidth: 15.0,
                          animation: true,
                          percent:
                              widget.transactions.planogramRealizationScore /
                                  100,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                (widget.transactions.planogramRealizationScore)
                                    .toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0),
                              ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: anaRenk.withGreen(
                              widget.transactions.planogramRealizationScore),
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
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Text(AppLocalizations.of(context)!.bulunurluk),
                        ),
                        CircularPercentIndicator(
                          radius: 60.0,
                          lineWidth: 15.0,
                          animation: true,
                          percent:
                              widget.transactions.planogramAvailabilityScore /
                                  100,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.transactions.planogramAvailabilityScore
                                    .toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0),
                              ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: anaRenk.withGreen(20),
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
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Text(AppLocalizations.of(context)!.mustHave),
                        ),
                        CircularPercentIndicator(
                          radius: 60.0,
                          lineWidth: 15.0,
                          animation: true,
                          percent: widget.transactions.drinksMusthaveScore
                                   /
                              100,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                (widget.transactions.drinksMusthaveScore
                                        )
                                    .toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0),
                              ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: anaRenk.withGreen(10),
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
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Text(AppLocalizations.of(context)!.gelisim),
                        ),
                        CircularPercentIndicator(
                          radius: 60.0,
                          lineWidth: 15.0,
                          animation: true,
                          percent: widget.transactions.shelfShareScore["Efes"]
                                  .percentage /
                              100,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                 (widget.transactions.shelfShareScore["Efes"]
                                        .percentage).round()
                                    .toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0),
                              ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: anaRenk.withGreen(20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
