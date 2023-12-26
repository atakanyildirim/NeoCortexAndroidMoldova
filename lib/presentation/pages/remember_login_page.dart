import 'package:flutter/material.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/presentation/Widget/appbar/appbar_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/presentation/pages/home_page.dart';
import 'package:neocortexapp/presentation/pages/login_page.dart';

class RememberLoginPage extends StatefulWidget {
  const RememberLoginPage({super.key});

  @override
  State<RememberLoginPage> createState() => _RememberLoginPageState();
}

class _RememberLoginPageState extends State<RememberLoginPage> {
  var emailTextEditingController;
  AuthenticateManager authenticateManager = AuthenticateManager();
  @override
  void initState() {
    authenticateManager.init().then((value) {
      emailTextEditingController = TextEditingController(text: authenticateManager.getEmail()!);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: anaRenk,
        title: neoCortexTitleWidget(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(21.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder(
                  future: authenticateManager.init(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "${AppLocalizations.of(context)!.hosgeldiniz}, ",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(
                                authenticateManager.getFullName()!,
                                style: const TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            child: Text(
                              AppLocalizations.of(context)!.girisYap,
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                          Container(
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, 228, 228, 228)),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 60,
                                  color: Color.fromARGB(255, 124, 124, 124),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25, bottom: 10, left: 10, right: 10),
                            child: TextField(
                              style: const TextStyle(color: Color.fromARGB(255, 75, 75, 75)),
                              controller: emailTextEditingController,
                              onChanged: (value) {
                                emailTextEditingController.value = TextEditingValue(
                                    text: value.toLowerCase(), selection: emailTextEditingController.selection);
                              },
                              enabled: false,
                              decoration: InputDecoration(
                                  fillColor: const Color.fromARGB(255, 242, 242, 242),
                                  filled: true,
                                  prefixIcon: const Icon(Icons.email),
                                  prefixIconColor: const Color.fromARGB(255, 154, 154, 154),
                                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  hintText: AppLocalizations.of(context)!.email),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(color: anaRenk, borderRadius: BorderRadius.circular(8)),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    Navigator.pushReplacement(
                                        context, MaterialPageRoute(builder: (context) => const HomePage()));
                                  });
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.devamEt,
                                  style: const TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context, MaterialPageRoute(builder: (context) => const LoginPage()));
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.farkliKullaniciIleGirisYap,
                                  style: const TextStyle(color: anaRenk, fontWeight: FontWeight.bold, fontSize: 13),
                                )),
                          )
                        ],
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
