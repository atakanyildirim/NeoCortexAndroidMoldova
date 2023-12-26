import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:need_resume/need_resume.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:neocortexapp/presentation/Widget/homepage/footer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/presentation/pages/customer_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:turkish/turkish.dart';

class CustomerPage extends StatefulWidget {
  final TabController tabController;
  final List<Customer> customers;
  final StopWatchTimer stopWatchTimer;
  const CustomerPage({super.key, required this.tabController, required this.customers, required this.stopWatchTimer});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends ResumableState<CustomerPage> {
  TextEditingController searchController = TextEditingController();
  List<Customer> filteredCustomers = List.empty();
  int? acikKanalGrubu;
  int? kapaliKanalGrubu;
  int? ekominiGrubu;
  int? carrefourGrubu;
  int? migrosGrubu;
  int? macroGrubu;
  int? digerleriGrubu;
  String selectedCustomerGroup = "";
  bool haftalikZiyaretEdilmeyenSwitch = false;
  String? newValue;

  @override
  void onResume() {
    SharedPreferences.getInstance().then((value) {
      var endTime = DateTime.now();
      var startTime = DateTime.parse(value.getString("ziyaretBaslangic")!);
      widget.stopWatchTimer.setPresetTime(mSec: endTime.difference(startTime).inMilliseconds);
      widget.stopWatchTimer.onStartTimer();
    });
  }

  @override
  void initState() {
    super.initState();
    filteredCustomers = widget.customers;
    acikKanalGrubu = filteredCustomers.where((x) => x.musteriKanaliGrubu == 1).length;
    kapaliKanalGrubu = filteredCustomers.where((x) => x.musteriKanaliGrubu == 2).length;
    ekominiGrubu = filteredCustomers.where((x) => x.musteriKanaliGrubu == 3).length;

    carrefourGrubu = filteredCustomers.where((x) => x.musteriKanaliGrubu == 4).length;
    migrosGrubu = filteredCustomers.where((x) => x.musteriKanaliGrubu == 5).length;
    macroGrubu = filteredCustomers.where((x) => x.musteriKanaliGrubu == 6).length;
    digerleriGrubu = filteredCustomers.where((x) => x.musteriKanaliGrubu == 7).length;

    searchController.addListener(() {
      setState(() {
        if (widget.customers.isNotEmpty) {
          filteredCustomers = widget.customers
              .where((element) =>
                  (element.customerName!).toLowerCaseTr().contains(searchController.text.toLowerCaseTr()) ||
                  (element.customerSapCode.toString()!).toLowerCaseTr().contains(searchController.text.toLowerCaseTr()))
              .toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: anaRenk,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            AppLocalizations.of(context)!.musteriler,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.arrow_2_circlepath_circle))],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, right: 5, top: 10, bottom: 10),
            decoration: const BoxDecoration(color: anaRenk, border: Border(top: BorderSide(color: Colors.grey))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        hintText: AppLocalizations.of(context)!.arama,
                        fillColor: Colors.white,
                        filled: true,
                        suffixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, setNewState) {
                              return Container(
                                color: Colors.white,
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.siralama,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        width: double.infinity,
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          dropdownColor: Colors.white,
                                          elevation: 0,
                                          onChanged: (changedValue) {
                                            setNewState(() {
                                              newValue = changedValue.toString();
                                            });
                                          },
                                          value: newValue,
                                          hint: Text(AppLocalizations.of(context)!.seciniz),
                                          items: <String>[
                                            AppLocalizations.of(context)!.ismeGore,
                                            AppLocalizations.of(context)!.konumaGore,
                                          ].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                height: 45,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                                                  child: Text(
                                                    AppLocalizations.of(context)!.filtrele,
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (newValue == AppLocalizations.of(context)!.ismeGore) {
                                                        filteredCustomers
                                                            .sort((a, b) => a.customerName!.compareTo(b.customerName!));
                                                      } else {
                                                        filteredCustomers
                                                            .sort((a, b) => a.mesafe!.compareTo(b.mesafe!));
                                                      }
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.filter_alt,
                      color: Colors.white,
                      size: 30,
                    ))
              ],
            ),
          ),
          SizedBox(
              width: double.infinity,
              height: 60,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(children: [
                    Material(
                        child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedCustomerGroup = "all";
                                });
                                hepsiniGetir();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: selectedCustomerGroup == "all" ? anaRenk : anaAcikRenk,
                                ),
                                padding: const EdgeInsets.all(7),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(
                                    AppLocalizations.of(context)!.toplamMusteri,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedCustomerGroup == "all" ? Colors.white : anaRenk),
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: selectedCustomerGroup == "all" ? Colors.white : anaRenk,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      widget.customers.length.toString(),
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          backgroundColor: selectedCustomerGroup == "all" ? Colors.white : anaRenk,
                                          color: selectedCustomerGroup == "all" ? anaRenk : Colors.white),
                                    ),
                                  )
                                ]),
                              ),
                            ))),
                    Visibility(
                      visible: acikKanalGrubu! > 0 ? true : false,
                      child: Material(
                          child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedCustomerGroup = "open";
                            });
                            aciklariGetir();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: selectedCustomerGroup == "open" ? anaRenk : anaAcikRenk,
                            ),
                            padding: const EdgeInsets.all(7),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(
                                AppLocalizations.of(context)!.acikKanal,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedCustomerGroup == "open" ? Colors.white : anaRenk),
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: selectedCustomerGroup == "open" ? Colors.white : anaRenk,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  acikKanalGrubu.toString(),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      backgroundColor: selectedCustomerGroup == "open" ? Colors.white : anaRenk,
                                      color: selectedCustomerGroup == "open" ? anaRenk : Colors.white),
                                ),
                              )
                            ]),
                          ),
                        ),
                      )),
                    ),
                    Visibility(
                      visible: kapaliKanalGrubu! > 0 ? true : false,
                      child: Material(
                          child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedCustomerGroup = "close";
                            });
                            kapalilariGetir();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: selectedCustomerGroup == "close" ? anaRenk : anaAcikRenk,
                            ),
                            padding: const EdgeInsets.all(7),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(
                                AppLocalizations.of(context)!.kapaliKanal,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedCustomerGroup == "close" ? Colors.white : anaRenk),
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: selectedCustomerGroup == "close" ? Colors.white : anaRenk,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  kapaliKanalGrubu.toString(),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      backgroundColor: selectedCustomerGroup == "close" ? Colors.white : anaRenk,
                                      color: selectedCustomerGroup == "close" ? anaRenk : Colors.white),
                                ),
                              )
                            ]),
                          ),
                        ),
                      )),
                    ),
                    Visibility(
                      visible: ekominiGrubu! > 0 ? true : false,
                      child: Material(
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedCustomerGroup = "eko";
                              });
                              ekolariGetir();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: selectedCustomerGroup == "eko" ? anaRenk : anaAcikRenk,
                              ),
                              padding: const EdgeInsets.all(7),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(
                                  "Ekomini",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedCustomerGroup == "eko" ? Colors.white : anaRenk),
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: selectedCustomerGroup == "eko" ? Colors.white : anaRenk,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                    ekominiGrubu.toString(),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        backgroundColor: selectedCustomerGroup == "eko" ? Colors.white : anaRenk,
                                        color: selectedCustomerGroup == "eko" ? anaRenk : Colors.white),
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: carrefourGrubu! > 0 ? true : false,
                      child: Material(
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedCustomerGroup = "carrefour";
                              });
                              carrefourlariGetir();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: selectedCustomerGroup == "carrefour" ? anaRenk : anaAcikRenk,
                              ),
                              padding: const EdgeInsets.all(7),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(
                                  "Carrefour",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedCustomerGroup == "carrefour" ? Colors.white : anaRenk),
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: selectedCustomerGroup == "carrefour" ? Colors.white : anaRenk,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                    carrefourGrubu.toString(),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        backgroundColor: selectedCustomerGroup == "carrefour" ? Colors.white : anaRenk,
                                        color: selectedCustomerGroup == "carrefour" ? anaRenk : Colors.white),
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: migrosGrubu! > 0 ? true : false,
                      child: Material(
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedCustomerGroup = "migros";
                              });
                              migroslariGetir();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: selectedCustomerGroup == "migros" ? anaRenk : anaAcikRenk,
                              ),
                              padding: const EdgeInsets.all(7),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(
                                  "Migros",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedCustomerGroup == "migros" ? Colors.white : anaRenk),
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: selectedCustomerGroup == "migros" ? Colors.white : anaRenk,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                    migrosGrubu.toString(),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        backgroundColor: selectedCustomerGroup == "migros" ? Colors.white : anaRenk,
                                        color: selectedCustomerGroup == "migros" ? anaRenk : Colors.white),
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: macroGrubu! > 0 ? true : false,
                      child: Material(
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedCustomerGroup = "macro";
                              });
                              macrolariGetir();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: selectedCustomerGroup == "macro" ? anaRenk : anaAcikRenk,
                              ),
                              padding: const EdgeInsets.all(7),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(
                                  "Macro Center",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedCustomerGroup == "macro" ? Colors.white : anaRenk),
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: selectedCustomerGroup == "macro" ? Colors.white : anaRenk,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                    macroGrubu.toString(),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        backgroundColor: selectedCustomerGroup == "macro" ? Colors.white : anaRenk,
                                        color: selectedCustomerGroup == "macro" ? anaRenk : Colors.white),
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: digerleriGrubu! > 0 ? true : false,
                      child: Material(
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedCustomerGroup = "digerleri";
                              });
                              digerleriGetir();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: selectedCustomerGroup == "digerleri" ? anaRenk : anaAcikRenk,
                              ),
                              padding: const EdgeInsets.all(7),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(
                                  "Diğerleri",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedCustomerGroup == "digerleri" ? Colors.white : anaRenk),
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: selectedCustomerGroup == "digerleri" ? Colors.white : anaRenk,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                    digerleriGrubu.toString(),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        backgroundColor: selectedCustomerGroup == "digerleri" ? Colors.white : anaRenk,
                                        color: selectedCustomerGroup == "digerleri" ? anaRenk : Colors.white),
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]))),
          Container(
            height: 40,
            margin: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: anaAcikRenk,
            ),
            padding: const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                AppLocalizations.of(context)!.aylikZiyaretEdilmeyen,
                style: const TextStyle(color: anaRenk, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Switch(
                  value: haftalikZiyaretEdilmeyenSwitch,
                  onChanged: (bool value) {
                    setState(() {
                      haftalikZiyaretEdilmeyenSwitch = value;
                    });
                    if (haftalikZiyaretEdilmeyenSwitch) {
                      filteredCustomers = widget.customers
                          .where((customer) =>
                              customer.lastVisitDateTime == null ||
                              DateTime.parse(customer.lastVisitDateTime!).month != DateTime.now().month)
                          .toList();
                    } else {
                      filteredCustomers = widget.customers;
                    }
                    acikKanalGrubu = filteredCustomers.where((x) => x.musteriKanaliGrubu == 1).length;
                    kapaliKanalGrubu = filteredCustomers.where((x) => x.musteriKanaliGrubu == 2).length;
                    ekominiGrubu = filteredCustomers.where((x) => x.musteriKanaliGrubu == 3).length;
                  })
            ]),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: filteredCustomers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 5),
                        Text(AppLocalizations.of(context)!.veriBulunamadi)
                      ],
                    )),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: filteredCustomers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        elevation: 3,
                        shadowColor: const Color.fromARGB(255, 242, 242, 242),
                        child: ListTile(
                            titleAlignment: ListTileTitleAlignment.center,
                            onTap: () {
                              push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CustomerDetailPage(
                                            customer: filteredCustomers[index],
                                            tabController: widget.tabController,
                                            stopWatchTimer: widget.stopWatchTimer,
                                          )));
                            },
                            minVerticalPadding: 0,
                            contentPadding: const EdgeInsets.all(0),
                            leading: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: filteredCustomers[index].lastVisitDateTime != null &&
                                        DateTime.parse(filteredCustomers[index].lastVisitDateTime!).month ==
                                            DateTime.now().month
                                    ? Colors.green
                                    : filteredCustomers[index].musteriKanaliGrubu == 1 ||
                                            filteredCustomers[index].musteriKanaliGrubu == 3
                                        ? Colors.blue
                                        : Colors.purple,
                                child: Container(
                                  alignment: Alignment.center, // use aligment
                                  child: Image.asset(
                                    fit: BoxFit.cover,
                                    getLogoByKanalGrup(index),
                                    width: 38,
                                    height: 38,
                                  ),
                                ),
                              ),
                            ),
                            trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: inputBackgroundColor,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: Text(
                                      filteredCustomers[index].mesafe != null
                                          ? filteredCustomers[index].mesafe.toString()
                                          : "-",
                                      style: const TextStyle(color: Colors.black, fontSize: 11),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: anaRenk,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: Text(
                                      filteredCustomers[index].customerSapCode.toString(),
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ),
                                ]),
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                filteredCustomers[index].customerName.toString(),
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 0.0, left: 8, bottom: 10),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Visibility(
                                    visible: filteredCustomers[index].sevkAdresi != null,
                                    child: Text(
                                      filteredCustomers[index].sevkAdresi.toString(),
                                      style: const TextStyle(color: Colors.black),
                                    )),
                                filteredCustomers[index].lastVisitDateTime != null &&
                                        (filteredCustomers[index].lastVisitDateTime != null &&
                                            DateTime.parse(filteredCustomers[index].lastVisitDateTime!).month ==
                                                DateTime.now().month)
                                    ? Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: const Color.fromARGB(255, 232, 232, 232),
                                        ),
                                        padding: const EdgeInsets.all(3),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Row(
                                            children: [
                                              const Text(
                                                "Son Ziyaret: ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromARGB(255, 0, 0, 0),
                                                    fontSize: 11),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                filteredCustomers[index].lastVisitDateTime != null
                                                    ? DateFormat("dd-MM-yyyy HH:MM").format(
                                                        DateTime.parse(filteredCustomers[index].lastVisitDateTime!))
                                                    : "-",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromARGB(255, 0, 0, 0),
                                                    fontSize: 11),
                                              )
                                            ],
                                          ),
                                        ))
                                    : const Text("")
                              ]),
                            )),
                      );
                    },
                  ),
          ))
        ],
      ),
      bottomNavigationBar: FooterPageWidget(
        tabBarController: widget.tabController,
        isPopEnabled: false,
      ),
    );
  }

  String getLogoByKanalGrup(int index) {
    switch (filteredCustomers[index].musteriKanaliGrubu) {
      case 1:
        return "assets/images/map2.png";
      case 2:
        return "assets/images/map1.png";
      case 3:
        return "assets/images/map3.png";
      case 4:
        return "assets/images/map4.png";
      case 5:
        return "assets/images/map5.png";
      case 6:
        return "assets/images/map6.png";
      case 7:
        return "assets/images/map7.png";
      default:
        return "assets/images/map7.png";
    }
  }

  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  aciklariGetir() {
    setState(() {
      filteredCustomers = widget.customers.where((element) => element.musteriKanaliGrubu == 1).toList();
      if (haftalikZiyaretEdilmeyenSwitch) {
        filteredCustomers = filteredCustomers
            .where((customer) =>
                customer.lastVisitDateTime == null ||
                DateTime.parse(customer.lastVisitDateTime!).day < findFirstDateOfTheWeek(DateTime.now()).day)
            .toList();
      }
    });
  }

  kapalilariGetir() {
    setState(() {
      filteredCustomers = widget.customers.where((element) => element.musteriKanaliGrubu == 2).toList();
      if (haftalikZiyaretEdilmeyenSwitch) {
        filteredCustomers = filteredCustomers
            .where((customer) =>
                customer.lastVisitDateTime == null ||
                DateTime.parse(customer.lastVisitDateTime!).day < findFirstDateOfTheWeek(DateTime.now()).day)
            .toList();
      }
    });
  }

  ekolariGetir() {
    setState(() {
      filteredCustomers = widget.customers.where((element) => element.musteriKanaliGrubu == 3).toList();
      if (haftalikZiyaretEdilmeyenSwitch) {
        filteredCustomers = filteredCustomers
            .where((customer) =>
                customer.lastVisitDateTime == null ||
                DateTime.parse(customer.lastVisitDateTime!).day < findFirstDateOfTheWeek(DateTime.now()).day)
            .toList();
      }
    });
  }

  carrefourlariGetir() {
    setState(() {
      filteredCustomers = widget.customers.where((element) => element.musteriKanaliGrubu == 4).toList();
      if (haftalikZiyaretEdilmeyenSwitch) {
        filteredCustomers = filteredCustomers
            .where((customer) =>
                customer.lastVisitDateTime == null ||
                DateTime.parse(customer.lastVisitDateTime!).day < findFirstDateOfTheWeek(DateTime.now()).day)
            .toList();
      }
    });
  }

  migroslariGetir() {
    setState(() {
      filteredCustomers = widget.customers.where((element) => element.musteriKanaliGrubu == 5).toList();
      if (haftalikZiyaretEdilmeyenSwitch) {
        filteredCustomers = filteredCustomers
            .where((customer) =>
                customer.lastVisitDateTime == null ||
                DateTime.parse(customer.lastVisitDateTime!).day < findFirstDateOfTheWeek(DateTime.now()).day)
            .toList();
      }
    });
  }

  macrolariGetir() {
    setState(() {
      filteredCustomers = widget.customers.where((element) => element.musteriKanaliGrubu == 6).toList();
      if (haftalikZiyaretEdilmeyenSwitch) {
        filteredCustomers = filteredCustomers
            .where((customer) =>
                customer.lastVisitDateTime == null ||
                DateTime.parse(customer.lastVisitDateTime!).day < findFirstDateOfTheWeek(DateTime.now()).day)
            .toList();
      }
    });
  }

  digerleriGetir() {
    setState(() {
      filteredCustomers = widget.customers.where((element) => element.musteriKanaliGrubu == 7).toList();
      if (haftalikZiyaretEdilmeyenSwitch) {
        filteredCustomers = filteredCustomers
            .where((customer) =>
                customer.lastVisitDateTime == null ||
                DateTime.parse(customer.lastVisitDateTime!).day < findFirstDateOfTheWeek(DateTime.now()).day)
            .toList();
      }
    });
  }

  hepsiniGetir() {
    setState(() {
      filteredCustomers = widget.customers;
    });
  }
}
