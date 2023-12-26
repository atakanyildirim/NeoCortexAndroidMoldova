import 'package:flutter/material.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/entities/report.dart';
import 'package:neocortexapp/presentation/Widget/homepage/footer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/presentation/Widget/report/report_widget.dart';

class ReportPage extends StatefulWidget {
  final TabController tabController;
  final Report? report;
  const ReportPage({super.key, required this.tabController, this.report});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with TickerProviderStateMixin {
  late TabController tabBarController;
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: anaRenk,
        title: Text(
          AppLocalizations.of(context)!.raporlar,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(shrinkWrap: true, children: [
        TabBar(
          padding: const EdgeInsets.all(20),
          controller: tabBarController,
          labelColor: const Color.fromARGB(255, 36, 36, 36),
          indicatorColor: inputBackgroundColor,
          indicator: const BoxDecoration(
              color: Color.fromARGB(255, 226, 225, 225), borderRadius: BorderRadius.all(Radius.circular(10))),
          tabs: <Widget>[
            Tab(
              icon: Text(AppLocalizations.of(context)!.bugun),
            ),
            Tab(
              icon: Text(AppLocalizations.of(context)!.buHafta),
            ),
            Tab(
              icon: Text(AppLocalizations.of(context)!.buAy),
            ),
          ],
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
        reportWidget(tabBarController, context, widget.report, selectedIndex),
      ]),
      bottomNavigationBar: FooterPageWidget(tabBarController: widget.tabController, isPopEnabled: false),
    );
  }
}
