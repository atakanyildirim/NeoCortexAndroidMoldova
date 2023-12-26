import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FooterPageWidget extends StatefulWidget {
  final TabController tabBarController;
  final bool isPopEnabled;
  const FooterPageWidget({Key? key, required this.tabBarController, required this.isPopEnabled}) : super(key: key);
  @override
  // ignore: no_logic_in_create_state
  BottomNavigatorBarState createState() => BottomNavigatorBarState();
}

class BottomNavigatorBarState extends State<FooterPageWidget> {
  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      shadowColor: Colors.grey.shade400,
      style: TabStyle.fixedCircle,
      backgroundColor: Colors.white,
      color: Colors.grey,
      activeColor: Colors.black,
      controller: widget.tabBarController,
      items: [
        TabItem(
          icon: Icons.home,
          title: AppLocalizations.of(context)!.anasayfa,
        ),
        TabItem(
          icon: CupertinoIcons.person_3_fill,
          title: AppLocalizations.of(context)!.musteriler,
        ),
        TabItem(
          icon: Image.asset('assets/images/bottomlogo.png', fit: BoxFit.contain),
        ),
        TabItem(
          icon: Icons.bar_chart_rounded,
          title: AppLocalizations.of(context)!.raporlar,
        ),
        TabItem(
          icon: Icons.map,
          title: AppLocalizations.of(context)!.haritalar,
        ),
      ],
      onTap: (int i) {
        if (widget.isPopEnabled) {
          Navigator.pop(context);
        }
        if (i == 0) {
          widget.tabBarController.index = 0;
        }
        if (i == 1) {
          widget.tabBarController.index = 1;
        }
        if (i == 2) {
          widget.tabBarController.index = 0;
        }
        if (i == 3) {
          widget.tabBarController.index = 3;
        }
        if (i == 4) {
          widget.tabBarController.index = 4;
        }
      },
    );
  }
}
