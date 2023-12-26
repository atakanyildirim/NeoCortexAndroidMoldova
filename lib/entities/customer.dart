import 'package:neocortexapp/entities/cooler_info.dart';
import 'package:neocortexapp/entities/doors.dart';

class Customer {
  int? customerSapCode;
  String? customerName;
  String? satisMudurluguAdi;
  String? bayiiDistributorAdi;
  String? unvan;
  String? yetkili;
  int? musteriKanaliGrubu;
  String? musteriPozisyon;
  String? musteriGrubuMetni;
  String? sevkAdresi;
  String? il;
  String? ilce;
  String? customerLatitude;
  String? customerLongitude;
  String? lastVisitDateTime;
  String? mesafe;
  int? efesDoorCount;
  int? competitorDoorCount;
  int? storeCoolerDoorCount;
  CoolerInfo? coolerInfo;
  List<Door>? target_planogram_for_this_customer;

  Customer({
    this.customerSapCode,
    this.customerName,
    this.satisMudurluguAdi,
    this.bayiiDistributorAdi,
    this.unvan,
    this.yetkili,
    this.musteriKanaliGrubu,
    this.musteriPozisyon,
    this.musteriGrubuMetni,
    this.sevkAdresi,
    this.il,
    this.ilce,
    this.customerLatitude,
    this.customerLongitude,
    this.lastVisitDateTime,
    this.efesDoorCount,
    this.competitorDoorCount,
    this.storeCoolerDoorCount,
    this.coolerInfo,
    this.target_planogram_for_this_customer,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    customerSapCode = json['customer_sap_code'];
    customerName = json['customer_name'];
    satisMudurluguAdi = json['satis_mudurlugu_adi'];
    bayiiDistributorAdi = json['bayii_distributor_adi'];
    unvan = json['unvan'];
    yetkili = json['yetkili'];
    musteriKanaliGrubu = json['musteri_kanali_grubu'];
    musteriPozisyon = json['musteri_pozisyon'];
    musteriGrubuMetni = json['musteri_grubu_metni'];
    sevkAdresi = json['sevk_adresi'];
    il = json['il'];
    ilce = json['ilce'];
    customerLatitude = json['customer_latitude'];
    customerLongitude = json['customer_longitude'];
    lastVisitDateTime = json['last_visit_date_time'];
    efesDoorCount = json['efes_door_count'];
    competitorDoorCount = json['competitor_door_count'];
    storeCoolerDoorCount = json['store_cooler_door_count'];
    coolerInfo = json['cooler_info'] != null ? CoolerInfo.fromJson(json['cooler_info']) : null;
    target_planogram_for_this_customer = <Door>[];

    Map x = json['target_planogram_for_this_customer'];

    int count2 = x.length;
    for (var i = 0; i < count2; i++) {
      var dataCooler = x[x.keys.elementAt(i)];
      target_planogram_for_this_customer!.add(Door.fromJson(dataCooler));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customer_sap_code'] = customerSapCode;
    data['customer_name'] = customerName;
    data['satis_mudurlugu_adi'] = satisMudurluguAdi;
    data['bayii_distributor_adi'] = bayiiDistributorAdi;
    data['unvan'] = unvan;
    data['yetkili'] = yetkili;
    data['musteri_kanali_grubu'] = musteriKanaliGrubu;
    data['musteri_pozisyon'] = musteriPozisyon;
    data['musteri_grubu_metni'] = musteriGrubuMetni;
    data['sevk_adresi'] = sevkAdresi;
    data['il'] = il;
    data['ilce'] = ilce;
    data['customer_latitude'] = customerLatitude;
    data['customer_longitude'] = customerLongitude;
    data['last_visit_date_time'] = lastVisitDateTime;
    data['efes_door_count'] = efesDoorCount;
    data['competitor_door_count'] = competitorDoorCount;
    data['store_cooler_door_count'] = storeCoolerDoorCount;
    if (coolerInfo != null) {
      data['cooler_info'] = coolerInfo!.toJson();
    }
    return data;
  }
}
