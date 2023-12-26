class Transactions {
  Transactions({
    required this.id,
    required this.dateTime,
    required this.customerSapCode,
    required this.unvan,
    required this.replyInterval,
    required this.numberOfFiles,
    required this.maxShootDistance,
    required this.planogramRealizationScore,
    required this.planogramAvailabilityScore,
    required this.drinksMusthaveScore,
    required this.shelfShareScore,
    required this.totalNumberOfProducts,
  });

  final int? id;
  final DateTime? dateTime;
  final int? customerSapCode;
  final String? unvan;
  final double? replyInterval;
  final int? numberOfFiles;
  final int? maxShootDistance;
  final int? planogramRealizationScore;
  final int? planogramAvailabilityScore;
  final int? drinksMusthaveScore;
  final Map<String, ShelfShareScore> shelfShareScore;
  final int? totalNumberOfProducts;

  factory Transactions.fromJson(Map<String, dynamic> json) {
    return Transactions(
      id: json["id"],
      dateTime: DateTime.tryParse(json["date_time"] ?? ""),
      customerSapCode: json["customer_sap_code"],
      unvan: json["unvan"],
      replyInterval: json["reply_interval"],
      numberOfFiles: json["number_of_files"],
      maxShootDistance: json["max_shoot_distance"],
      planogramRealizationScore: json["planogram_realization_score"],
      planogramAvailabilityScore: json["planogram_availability_score"],
      drinksMusthaveScore: json["drinks_musthave_score"],
      shelfShareScore: Map.from(json["shelf_share_score"])
          .map((k, v) => MapEntry<String, ShelfShareScore>(k, ShelfShareScore.fromJson(v))),
      totalNumberOfProducts: json["total_number_of_products"],
    );
  }
}

class ShelfShareScore {
  ShelfShareScore({
    required this.counted,
    required this.percentage,
  });

  final int? counted;
  final double? percentage;

  factory ShelfShareScore.fromJson(Map<String, dynamic> json) {
    return ShelfShareScore(
      counted: json["counted"],
      percentage: double.tryParse(json["percentage"].toString()),
    );
  }
}
