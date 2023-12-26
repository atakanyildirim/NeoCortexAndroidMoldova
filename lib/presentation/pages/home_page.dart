import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:need_resume/need_resume.dart';
import 'package:neocortexapp/business/customer_manager.dart';
import 'package:neocortexapp/business/report_manager.dart';
import 'package:neocortexapp/business/transactions_manager.dart';
import 'package:neocortexapp/core/map/location.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:neocortexapp/entities/report.dart';
import 'package:neocortexapp/entities/transaction.dart';
import 'package:neocortexapp/presentation/pages/customer_page.dart';
import 'package:neocortexapp/presentation/pages/dashboard_page.dart';
import 'package:neocortexapp/presentation/pages/kvkk_page.dart';
import 'package:neocortexapp/presentation/pages/map_page.dart';
import 'package:neocortexapp/presentation/pages/report_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ResumableState<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, SingleTickerProviderStateMixin {
  bool isLoading = true;
  late TabController controller;
  List<Customer> customers = List.empty();
  List<Transactions> transactions = List.empty();
  Report? report;
  Position? currentPosition;
  List<Placemark> placemarks = List.empty();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 5, vsync: this, animationDuration: Duration.zero);
    loadDatas();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isLoading
        ? Scaffold(backgroundColor: Colors.white, body: Center(child: Lottie.asset('assets/animations/loading.json')))
        : DefaultTabController(
            length: 5,
            initialIndex: 0,
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: controller,
              children: [
                DashboardPage(
                  tabController: controller,
                  placemarks: placemarks,
                  report: report ?? Report(),
                  customer: customers.first,
                  transactions: transactions,
                  customers: customers,
                  stopWatchTimer: _stopWatchTimer,
                ),
                CustomerPage(
                  tabController: controller,
                  customers: customers,
                  stopWatchTimer: _stopWatchTimer,
                ),
                DashboardPage(
                  transactions: transactions,
                  tabController: controller,
                  placemarks: placemarks,
                  customer: customers.first,
                  customers: customers,
                  report: report ?? Report(),
                  stopWatchTimer: _stopWatchTimer,
                ),
                ReportPage(tabController: controller, report: report),
                MapPage(
                  tabController: controller,
                  customers: customers,
                  position: currentPosition,
                  stopWatchtimer: _stopWatchTimer,
                )
              ],
            ));
  }

  @override
  bool get wantKeepAlive => true;

  void refresh() {
    setState(() {});
  }

  Future<void> loadDatas() async {
    var prefs = await SharedPreferences.getInstance();

    await CustomerManager.getCachedCustomerData().then((value) {
      setState(() {
        customers = value;
      });
    }).onError((error, stackTrace) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.hata),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.ok))
            ],
            content: Text(error.toString())),
      );
    });

    await ReportManager.getCachedReportData().then((value) {
      setState(() {
        report = value;
      });
    }).onError((error, stackTrace) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.hata),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.ok))
            ],
            content: Text(error.toString())),
      );
    });

    // ignore: use_build_context_synchronously
    await TransactionsManager.getCachedTransactionsData(context).then((value) {
      setState(() {
        transactions = value;
        transactions.sort((b, a) => a.dateTime!.compareTo(b.dateTime!));
      });
    }).onError((error, stackTrace) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.hata),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.ok))
            ],
            content: Text(error.toString())),
      );
    });

    await determinePosition().then((position) {
      placemarkFromCoordinates(position.latitude, position.longitude).then((address) {
        setState(() {
          isLoading = false;
          currentPosition = position;
          placemarks = address;
          customers = CustomerManager.calculateDistance(customers, currentPosition!);
          customers.sort((a, b) => a.mesafe!.compareTo(b.mesafe!));
        });
      });
    }).onError((error, stackTrace) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.hata),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.ok))
            ],
            content: Text(error.toString())),
      );
    });
    if (prefs.getBool("isAcceptedKVKK") == null || prefs.getBool("isAcceptedKVKK") == false) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const KvkkPage(),
      ));
    }
  }
}
