import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:neocortexapp/business/location_manager.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/presentation/pages/home_page.dart';

class LocationPermissionPage extends StatefulWidget {
  const LocationPermissionPage({super.key});

  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset('assets/animations/location.json'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.konumIzni,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          AppLocalizations.of(context)!.izinMesaj,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(5),
                          backgroundColor: MaterialStateProperty.all(anaRenk),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0), side: const BorderSide(color: anaRenk))),
                        ),
                        onPressed: () {
                          LocationManager.requestPermission(context).then((permisson) {
                            if (permisson) {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
                            }
                          }).catchError((error, stackTrace) {
                            showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                  title: Text(AppLocalizations.of(context)!.hata),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text(AppLocalizations.of(context)!.ok))
                                  ],
                                  content: Text(error.toString())),
                            );
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            AppLocalizations.of(context)!.konumEtkinlestir,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomePage()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            AppLocalizations.of(context)!.gec,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 75, 75, 75), fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                ]),
          ),
        ));
  }
}
