import 'package:http/http.dart' as http;

class VisitRepository {
  static Future<String> getVisitReasons() async {
    final response = await http.post(Uri.parse("https://labelmd.neocortexs.com/servis"), body: <String, String>{
      "username": "ozan.kocer.rest_user",
      "password": "#Z825!/8;Sz4g*r(",
      "servis": "ziyaret_edememe_nedenleri"
    });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('error');
    }
  }

  static Future<bool> sendVisitReason(String musteriKodu, String neden) async {
    final response = await http.post(Uri.parse("https://labelmd.neocortexs.com/servis"), body: <String, String>{
      "username": "ozan.kocer.rest_user",
      "password": "#Z825!/8;Sz4g*r(",
      "servis": "ziyaret_edememe",
      "musteri_kodu": musteriKodu,
      "ziyaret_edememe_nedeni": neden
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> finishVisit(String musteriKodu, String kullanici, String startDate) async {
    final response = await http.post(Uri.parse("https://labelmd.neocortexs.com/servis"), body: <String, String>{
      "username": "ozan.kocer.rest_user",
      "password": "#Z825!/8;Sz4g*r(",
      "servis": "ziyaret_basla_bitir",
      "musteri_kodu": musteriKodu,
      "kullanici": kullanici,
      "start_date": startDate,
      "end_date": DateTime.now().toString()
    });
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
