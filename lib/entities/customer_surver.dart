class CustomerSurvey {
  int? projectId;
  String? kullanici;
  String? lastVisitDateTime;
  String? satisMudurluguAdi;
  String? musteriGrubuMetni;
  int? customerSapCode;
  String? enlem;
  String? boylam;
  String? musteriAdi;
  String? sevkAdresi;
  String? il;
  String? ilce;
  String? bayiiDistributorAdi;
  String? musteriPozisyon;
  int? ziyaretVar;
  String? mesafe;
  String? fraud;

  CustomerSurvey(
      {this.projectId,
      this.kullanici,
      this.lastVisitDateTime,
      this.satisMudurluguAdi,
      this.musteriGrubuMetni,
      this.customerSapCode,
      this.enlem,
      this.boylam,
      this.musteriAdi,
      this.sevkAdresi,
      this.il,
      this.ilce,
      this.bayiiDistributorAdi,
      this.musteriPozisyon,
      this.ziyaretVar,
      this.fraud});

  CustomerSurvey.fromJson(Map<String, dynamic> json) {
    projectId = json['project_id'];
    kullanici = json['kullanici'];
    lastVisitDateTime = json['last_visit_date_time'];
    satisMudurluguAdi = json['satis_mudurlugu_adi'];
    musteriGrubuMetni = json['musteri_grubu_metni'];
    customerSapCode = json['customer_sap_code'];
    enlem = json['enlem'];
    boylam = json['boylam'];
    musteriAdi = json['musteri_adi'];
    sevkAdresi = json['sevk_adresi'];
    il = json['il'];
    ilce = json['ilce'];
    bayiiDistributorAdi = json['bayii_distributor_adi'];
    musteriPozisyon = json['musteri_pozisyon'];
    ziyaretVar = json['ziyaret_var'];
    fraud = json['Fraud'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['project_id'] = this.projectId;
    data['kullanici'] = this.kullanici;
    data['last_visit_date_time'] = this.lastVisitDateTime;
    data['satis_mudurlugu_adi'] = this.satisMudurluguAdi;
    data['musteri_grubu_metni'] = this.musteriGrubuMetni;
    data['customer_sap_code'] = this.customerSapCode;
    data['enlem'] = this.enlem;
    data['boylam'] = this.boylam;
    data['musteri_adi'] = this.musteriAdi;
    data['sevk_adresi'] = this.sevkAdresi;
    data['il'] = this.il;
    data['ilce'] = this.ilce;
    data['bayii_distributor_adi'] = this.bayiiDistributorAdi;
    data['musteri_pozisyon'] = this.musteriPozisyon;
    data['ziyaret_var'] = this.ziyaretVar;
    data['Fraud'] = this.fraud;
    return data;
  }
}
