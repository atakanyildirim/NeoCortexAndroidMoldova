import 'package:geolocator/geolocator.dart';
import 'package:neocortexapp/core/cache/cache.dart';
import 'package:neocortexapp/dataaccess/customer_repository.dart';
import 'package:neocortexapp/entities/customer.dart';

class CustomerManager {
  static Future<List<Customer>> getCachedCustomerData() async {
    var cached = await CacheData.getCachedCustomersWithPlanograms();
    if (cached.isEmpty) {
      return CustomerRepository.getAll();
    }
    return cached;
  }

  static List<Customer> calculateDistance(List<Customer> customers, Position currentPosition) {
    for (var customer in customers) {
      var distance = Geolocator.distanceBetween(currentPosition.latitude, currentPosition.longitude,
          double.parse(customer.customerLatitude!), double.parse(customer.customerLongitude!));
      customer.mesafe = "${(distance / 1000).toStringAsFixed(2)} ${(distance) >= 1000 ? "km" : "m"}";
    }
    return customers;
  }
}
