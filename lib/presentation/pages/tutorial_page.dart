import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/presentation/Widget/appbar/appbar_widget.dart';
import 'package:neocortexapp/presentation/Widget/tutorial/tutorial_widget.dart';
import 'package:neocortexapp/presentation/pages/login_page.dart';
import 'package:neocortexapp/presentation/pages/remember_login_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  PageController tutorialSliderController = PageController(viewportFraction: 1, keepPage: true);
  bool? isLoggedData;
  bool? isTutorialWatched = true;
  bool? isRemember = false;
  bool? isLoading = true;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    checkUpdate();
    isLogged();
  }

  Future<void> checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if (AppConfig.version != packageInfo.version) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            icon: Icon(Icons.download),
            title: const Text("NeoCortex"),
            content: Text(AppLocalizations.of(context)!.guncelleMesaji),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                    onPressed: () async {
                      if (await canLaunchUrl(Uri.parse(AppConfig.apkUrl))) launchUrl(Uri.parse(AppConfig.apkUrl));
                    },
                    child: Text(AppLocalizations.of(context)!.guncelle)),
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == true
        ? Scaffold(backgroundColor: Colors.white, body: Center(child: Lottie.asset('assets/animations/loading.json')))
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: anaRenk,
              title: neoCortexTitleWidget(),
              actions: [appBarIndicatorWidget(3, tutorialSliderController)],
            ),
            body: TutorialSliderWidget(sliderController: tutorialSliderController),
          );
  }

  Future<void> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    AuthenticateManager authenticateManager = AuthenticateManager();
    await authenticateManager.init();

    authenticateManager.isLogged().then((value) async {
      isLoggedData = value;
      isRemember = prefs.getBool("isRemember");

      if (isLoggedData == true && isRemember == true) {
        if (context.mounted) {
          if (isRemember == true) {
            await Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) => const RememberLoginPage()));
          }
        }
      } else {
        prefs.remove("isRemember");
        prefs.remove("token");
        setState(() {
          isLoggedData = false;
          isRemember = false;
        });
        isTutorialWatched = prefs.getBool("isTutorialWatched");
        if (isTutorialWatched == true) {
          await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    });
  }
}
