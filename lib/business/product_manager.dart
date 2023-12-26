import 'package:neocortexapp/core/cache/cache.dart';
import 'package:neocortexapp/dataaccess/product_repository.dart';

class ProductManager {
  static Future<List<String>> getCachedPifList() async {
    List<String>? pifList = [];
    pifList = await CacheData.getCachedPifList();
    if (pifList == null || pifList.isEmpty) {
      pifList = await ProductRepository.getPifList();
    }
    return pifList;
  }
}
