class PlanogramColors {
  String? name;
  String? colorCode;

  PlanogramColors({this.name, this.colorCode});

  PlanogramColors.fromJson(Map<String, dynamic> json) {
    name = json['isim'];
    colorCode = json['renkKodu'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isim'] = name;
    data['renkKodu'] = colorCode;
    return data;
  }
}
