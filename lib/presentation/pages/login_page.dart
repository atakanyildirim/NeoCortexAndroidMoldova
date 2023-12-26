import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/business/location_manager.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/presentation/Widget/appbar/appbar_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/presentation/pages/home_page.dart';
import 'package:neocortexapp/presentation/pages/location_permission_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiver/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum Strength {
  empty('', 0 / 4, Colors.transparent),
  weak('cake', 1 / 4, Colors.red),
  medium('easy', 2 / 4, Colors.yellow),
  strong('medium', 3 / 4, Colors.blue),
  veryStrong('hard', 4 / 4, Colors.green),
  ;

  final String text;
  final double value;
  final Color color;

  const Strength(this.text, this.value, this.color);
}

class _LoginPageState extends State<LoginPage> {
  var emailTextEditingController = TextEditingController(text: "");
  var passwordTextEditingController = TextEditingController(text: "");
  var againPasswordTextEditingController = TextEditingController(text: "");
  var confirmCodeTextEditingController = TextEditingController(text: "");
  bool isRemember = false;
  bool isLoading = false;
  var info = "";
  bool mailGonderildi = false;
  int _remainingTimeInSeconds = 180; // 3 dakika

  Strength _strength = Strength.empty;

  Strength _calculatePasswordStrength(String value) {
    if (value.contains(RegExp(r'^\d{3}$'))) {
      return Strength.weak;
    } else if (value.contains(RegExp(r'^[a-zA-Z0-9]{4,}$'))) {
      return Strength.medium;
    } else if (value
        .contains(RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{7,}$'))) {
      return Strength.strong;
    } else if (value.contains(RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'))) {
      return Strength.veryStrong;
    } else {
      return Strength.empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: anaRenk,
        title: neoCortexTitleWidget(),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            AppLocalizations.of(context)!.kullanimKosulu,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.hosgeldiniz,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              AppLocalizations.of(context)!.girisYap,
              style: const TextStyle(fontSize: 13),
            ),
            TextField(
              controller: emailTextEditingController,
              onChanged: (value) {
                emailTextEditingController.value = TextEditingValue(
                    text: value,
                    selection: emailTextEditingController.selection);
              },
              decoration: InputDecoration(
                  fillColor: inputBackgroundColor,
                  filled: true,
                  prefixIcon: const Icon(Icons.email),
                  prefixIconColor: const Color.fromARGB(255, 141, 141, 141),
                  focusedBorder:
                      const OutlineInputBorder(borderSide: BorderSide.none),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: AppLocalizations.of(context)!.email),
            ),
            TextField(
              controller: passwordTextEditingController,
              obscureText: true,
              decoration: InputDecoration(
                  fillColor: inputBackgroundColor,
                  filled: true,
                  prefixIconColor: const Color.fromARGB(255, 141, 141, 141),
                  prefixIcon: const Icon(Icons.lock_open),
                  focusedBorder:
                      const OutlineInputBorder(borderSide: BorderSide.none),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: AppLocalizations.of(context)!.sifre),
            ),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                onPressed: () async {
                  if (isLoading == false) {
                    final prefs = await SharedPreferences.getInstance();
                    setState(() {
                      isLoading = true;
                    });
                    PackageInfo packageInfo = await PackageInfo.fromPlatform();

                    AuthenticateManager.attempt(
                            emailTextEditingController.text,
                            passwordTextEditingController.text,
                            packageInfo.version)
                        .then((response) async {
                      if (response.statusCode == 200) {
                        await prefs.setBool("isRemember", isRemember);
                        await prefs.setBool("isTutorialWatched", true);
                        await prefs.setString(
                            "token", jsonDecode(response.body)["Content"]);
                        if (context.mounted) {
                          LocationPermission permission =
                              await LocationManager.hasPermission();
                          if (permission != LocationPermission.always &&
                              permission != LocationPermission.whileInUse) {
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LocationPermissionPage()));
                            }
                          } else {
                            if (context.mounted) {
                              prefs.remove("customerwithvariableplanograms");
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()));
                            }
                          }
                        }
                      } else {
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!
                                  .kullaniciBulunamadi),
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
                              content: Text(AppLocalizations.of(context)!
                                  .kullaniciBulunamadiUyariMesaj)),
                        );
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }).onError((error, stackTrace) {
                      setState(() {
                        isLoading = false;
                      });
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                            title: Text(AppLocalizations.of(context)!
                                .sunucuBaglantisiProblemi),
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
                            content: Text(AppLocalizations.of(context)!
                                .sunucuBaglantiProblemMesaj)),
                      );
                    });
                  }
                },
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        AppLocalizations.of(context)!.girisYap,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Material(
                    child: CheckboxListTile(
                      contentPadding: const EdgeInsets.all(0),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: anaRenk,
                      title: Text(AppLocalizations.of(context)!.beniHatirla),
                      value: isRemember,
                      onChanged: (bool? value) {
                        setState(() {
                          isRemember = value!;
                        });
                      },
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      info = "";
                      confirmCodeTextEditingController.text = "";
                      passwordTextEditingController.text = "";
                      againPasswordTextEditingController.text = "";
                      emailTextEditingController.text = "";
                    });

                    showDialog<void>(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Text(
                                  AppLocalizations.of(context)!.sifremiUnuttum),
                              actions: [
                                SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: anaRenk),
                                        onPressed: () async {
                                          if (passwordTextEditingController
                                                  .text !=
                                              againPasswordTextEditingController
                                                  .text) {
                                            setState(() {
                                              info =
                                                  AppLocalizations.of(context)!
                                                      .sifrelerUyusmuyor;
                                            });
                                          } else {
                                            CountdownTimer countdownTimer =
                                                CountdownTimer(
                                              Duration(
                                                  seconds:
                                                      _remainingTimeInSeconds),
                                              Duration(seconds: 1),
                                            );

                                            var sub =
                                                countdownTimer.listen(null);
                                            final response;
                                            if (mailGonderildi == false) {
                                              response = await http.post(
                                                  Uri.parse(
                                                      "$baseApiUrl/forgetpassword"),
                                                  body: jsonEncode(<String,
                                                      String>{
                                                    'email':
                                                        emailTextEditingController
                                                            .text
                                                  }));

                                              var j = jsonDecode(response.body);
                                              if (j["Status"] == "Error") {
                                                setState(() {
                                                  info = j["Content"];
                                                });
                                              } else {
                                                setState(() {
                                                  info = j["Content"];
                                                  mailGonderildi = true;
                                                });

                                                sub.onData(
                                                    (CountdownTimer duration) {
                                                  setState(() {
                                                    _remainingTimeInSeconds =
                                                        _remainingTimeInSeconds -
                                                            1;
                                                    info =
                                                        "Telefonunuza gelen onay kodunu giriniz. Kalan süre ${_remainingTimeInSeconds.toString()} saniye";
                                                  });
                                                });

                                                sub.onDone(() {
                                                  sub.cancel();
                                                  setState(() {
                                                    mailGonderildi = false;
                                                    _remainingTimeInSeconds =
                                                        180;
                                                  });
                                                });
                                              }
                                            } else {
                                              if (_strength.text != "cake") {
                                                setState(() {
                                                  info = AppLocalizations.of(
                                                          context)!
                                                      .sifrelerSifrelemeAlgoritmasinaUygunDegil;
                                                });
                                              } else {
                                                response = await http.post(
                                                    Uri.parse(
                                                        "$baseApiUrl/confirmpassword"),
                                                    body: jsonEncode(<String,
                                                        String>{
                                                      'confirmation_code':
                                                          confirmCodeTextEditingController
                                                              .text,
                                                      'new_password':
                                                          passwordTextEditingController
                                                              .text
                                                    }));

                                                var j =
                                                    jsonDecode(response.body);
                                                if (j["Status"] == "Error") {
                                                  setState(() {
                                                    info = j["Content"];
                                                  });
                                                } else {
                                                  setState(() {
                                                    info = "";
                                                    mailGonderildi = false;
                                                    sub.cancel();
                                                    Fluttertoast.showToast(
                                                        msg: "İşlem Başarılı.",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.green,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);

                                                    Future.delayed(
                                                        Duration(seconds: 2),
                                                        () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    });
                                                  });
                                                }
                                              }
                                            }
                                          }
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .sifirla)))
                              ],
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    info,
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Visibility(
                                    visible: !mailGonderildi,
                                    child: TextField(
                                      controller: emailTextEditingController,
                                      onChanged: (value) {
                                        emailTextEditingController.value =
                                            TextEditingValue(
                                                text: value,
                                                selection:
                                                    emailTextEditingController
                                                        .selection);
                                      },
                                      decoration: InputDecoration(
                                          fillColor: inputBackgroundColor,
                                          filled: true,
                                          prefixIcon: const Icon(Icons.email),
                                          prefixIconColor: const Color.fromARGB(
                                              255, 141, 141, 141),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                                  borderSide: BorderSide.none),
                                          border: const OutlineInputBorder(
                                              borderSide: BorderSide.none),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never,
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .email),
                                    ),
                                  ),
                                  Visibility(
                                    visible: mailGonderildi,
                                    child: const SizedBox(
                                      height: 10,
                                    ),
                                  ),
                                  Visibility(
                                    visible: false,
                                    child: LinearProgressIndicator(
                                      minHeight: 20,
                                      value: _strength.value,
                                      backgroundColor: Colors.grey,
                                      color: _strength.color,
                                    ),
                                  ),
                                  Visibility(
                                    visible: false,
                                    child: Text(_strength.text.isNotEmpty
                                        ? 'Şifreniz : ${_strength.text}'
                                        : ''),
                                  ),
                                  Visibility(
                                    visible: mailGonderildi,
                                    child: TextField(
                                      controller:
                                          confirmCodeTextEditingController,
                                      decoration: InputDecoration(
                                          fillColor: inputBackgroundColor,
                                          filled: true,
                                          prefixIconColor: const Color.fromARGB(
                                              255, 141, 141, 141),
                                          prefixIcon:
                                              const Icon(Icons.password),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                                  borderSide: BorderSide.none),
                                          border: const OutlineInputBorder(
                                              borderSide: BorderSide.none),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never,
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .onayKodu),
                                    ),
                                  ),
                                  Visibility(
                                    visible: mailGonderildi,
                                    child: const SizedBox(
                                      height: 10,
                                    ),
                                  ),
                                  Visibility(
                                    visible: mailGonderildi,
                                    child: TextField(
                                      onChanged: (value) => {
                                        setState(() {
                                          _strength =
                                              _calculatePasswordStrength(value);
                                        })
                                      },
                                      controller: passwordTextEditingController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          fillColor: inputBackgroundColor,
                                          filled: true,
                                          prefixIconColor: const Color.fromARGB(
                                              255, 141, 141, 141),
                                          prefixIcon:
                                              const Icon(Icons.lock_open),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                                  borderSide: BorderSide.none),
                                          border: const OutlineInputBorder(
                                              borderSide: BorderSide.none),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never,
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .yeniSifre),
                                    ),
                                  ),
                                  Visibility(
                                    visible: mailGonderildi,
                                    child: const SizedBox(
                                      height: 10,
                                    ),
                                  ),
                                  Visibility(
                                    visible: mailGonderildi,
                                    child: TextField(
                                      controller:
                                          againPasswordTextEditingController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          fillColor: inputBackgroundColor,
                                          filled: true,
                                          prefixIconColor: const Color.fromARGB(
                                              255, 141, 141, 141),
                                          prefixIcon:
                                              const Icon(Icons.lock_open),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                                  borderSide: BorderSide.none),
                                          border: const OutlineInputBorder(
                                              borderSide: BorderSide.none),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never,
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .sifreYeniden),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.sifremiUnuttum,
                    style: const TextStyle(color: anaRenk, fontSize: 15),
                  ),
                ),
              ],
            ),
          ].expand((x) => [const SizedBox(height: 12), x]).skip(1).toList(),
        ),
      ),
    );
  }
}
