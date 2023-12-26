class CoolerInfo {
  String? coolerBarcode;
  String? coolerName;

  CoolerInfo({this.coolerBarcode, this.coolerName});

  CoolerInfo.fromJson(Map<String, dynamic> json) {
    coolerBarcode = json['cooler_barcode'];
    coolerName = json['cooler_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cooler_barcode'] = coolerBarcode;
    data['cooler_name'] = coolerName;
    return data;
  }
}
