import 'package:flutter/material.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class KvkkPage extends StatefulWidget {
  const KvkkPage({super.key});

  @override
  State<KvkkPage> createState() => _KvkkPageState();
}

class _KvkkPageState extends State<KvkkPage> {
  bool isAccept = false;
  late final WebViewController controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('https://www.neocortex.com.tr/kvkkonaymetni'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: anaRenk,
        title: const Text("KVKK Onay Metni"),
      ),
      body: WebViewWidget(controller: controller),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Column(
          children: [
            Expanded(
              child: Material(
                child: CheckboxListTile(
                  contentPadding: const EdgeInsets.all(0),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: anaRenk,
                  title: Text("Okudum ve onaylıyorum."),
                  value: isAccept,
                  onChanged: (bool? value) {
                    setState(() {
                      isAccept = value!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: ElevatedButton(
                  onPressed: isAccept == false || isLoading == true
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          AuthenticateManager authenticateManager = AuthenticateManager();
                          await authenticateManager.init();
                          var prefs = await SharedPreferences.getInstance();
                          await prefs.setBool("isAcceptedKVKK", true);
                          await http.post(Uri.parse("https://labelmd.neocortexs.com/servis"), body: <String, String>{
                            "username": "ozan.kocer.rest_user",
                            "password": "#Z825!/8;Sz4g*r(",
                            "servis": "kvkk",
                            "kullanici": authenticateManager.getFullName()!
                          });
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                  child: Text(isLoading ? "Bekleyiniz" : "Kaydet"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
