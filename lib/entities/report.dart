class Report {
  int? userId;
  String? userName;
  String? positionCode;
  int? positionNo;
  String? positionName;
  String? upperLevelPositionCode;
  int? numberOfCustomers;
  PeriodicResults? periodicResults;

  Report(
      {this.userId,
      this.userName,
      this.positionCode,
      this.positionNo,
      this.positionName,
      this.upperLevelPositionCode,
      this.numberOfCustomers,
      this.periodicResults});

  Report.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['user_name'];
    positionCode = json['position_code'];
    positionNo = json['position_no'];
    positionName = json['position_name'];
    upperLevelPositionCode = json['upper_level_position_code'];
    numberOfCustomers = json['number_of_customers'];
    periodicResults = json['periodic_results'] != null ? PeriodicResults.fromJson(json['periodic_results']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['position_code'] = positionCode;
    data['position_no'] = positionNo;
    data['position_name'] = positionName;
    data['upper_level_position_code'] = upperLevelPositionCode;
    data['number_of_customers'] = numberOfCustomers;
    if (periodicResults != null) {
      data['periodic_results'] = periodicResults!.toJson();
    }
    return data;
  }
}

class PeriodicResults {
  ThisMonthsPeriodicResults? thisMonthsPeriodicResults;
  ThisWeeksPeriodicResults? thisWeeksPeriodicResults;
  TodaysPeriodicResults? todaysPeriodicResults;

  PeriodicResults({this.thisMonthsPeriodicResults, this.thisWeeksPeriodicResults, this.todaysPeriodicResults});

  PeriodicResults.fromJson(Map<String, dynamic> json) {
    thisMonthsPeriodicResults = json['this_months_periodic_results'] != null
        ? ThisMonthsPeriodicResults.fromJson(json['this_months_periodic_results'])
        : null;
    thisWeeksPeriodicResults = json['this_weeks_periodic_results'] != null
        ? ThisWeeksPeriodicResults.fromJson(json['this_weeks_periodic_results'])
        : null;
    todaysPeriodicResults = json['todays_periodic_results'] != null
        ? TodaysPeriodicResults.fromJson(json['todays_periodic_results'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (thisMonthsPeriodicResults != null) {
      data['this_months_periodic_results'] = thisMonthsPeriodicResults!.toJson();
    }
    if (thisWeeksPeriodicResults != null) {
      data['this_weeks_periodic_results'] = thisWeeksPeriodicResults!.toJson();
    }
    if (todaysPeriodicResults != null) {
      data['todays_periodic_results'] = todaysPeriodicResults!.toJson();
    }
    return data;
  }
}

class ThisMonthsPeriodicResults {
  int? numberOfPhotos;
  int? visitedCustomers;
  int? planogramRealizationScore;
  int? planogramAvailabilityScore;
  int? drinkMusthaveScore;
  int? shelfShareScore;
  int? numberOfPhotosComparedToLastMonth;
  int? visitedCustomersComparedToLastMonth;
  int? planogramRealizationScoreComparedToLastMonth;
  int? planogramAvailabilityScoreComparedToLastMonth;
  int? drinkMusthaveScoreComparedToLastMonth;
  int? shelfShareScoreComparedToLastMonth;

  ThisMonthsPeriodicResults(
      {this.numberOfPhotos,
      this.visitedCustomers,
      this.planogramRealizationScore,
      this.planogramAvailabilityScore,
      this.drinkMusthaveScore,
      this.shelfShareScore,
      this.numberOfPhotosComparedToLastMonth,
      this.visitedCustomersComparedToLastMonth,
      this.planogramRealizationScoreComparedToLastMonth,
      this.planogramAvailabilityScoreComparedToLastMonth,
      this.drinkMusthaveScoreComparedToLastMonth,
      this.shelfShareScoreComparedToLastMonth});

  ThisMonthsPeriodicResults.fromJson(Map<String, dynamic> json) {
    numberOfPhotos = json['number_of_photos'];
    visitedCustomers = json['visited_customers'];
    planogramRealizationScore = json['planogram_realization_score'];
    planogramAvailabilityScore = json['planogram_availability_score'];
    drinkMusthaveScore = json['drink_musthave_score'];
    shelfShareScore = json['shelf_share_score'];
    numberOfPhotosComparedToLastMonth = json['number_of_photos_compared_to_last_month'];
    visitedCustomersComparedToLastMonth = json['visited_customers_compared_to_last_month'];
    planogramRealizationScoreComparedToLastMonth = json['planogram_realization_score_compared_to_last_month'];
    planogramAvailabilityScoreComparedToLastMonth = json['planogram_availability_score_compared_to_last_month'];
    drinkMusthaveScoreComparedToLastMonth = json['drink_musthave_score_compared_to_last_month'];
    shelfShareScoreComparedToLastMonth = json['shelf_share_score_compared_to_last_month'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number_of_photos'] = numberOfPhotos;
    data['visited_customers'] = visitedCustomers;
    data['planogram_realization_score'] = planogramRealizationScore;
    data['planogram_availability_score'] = planogramAvailabilityScore;
    data['drink_musthave_score'] = drinkMusthaveScore;
    data['shelf_share_score'] = shelfShareScore;
    data['number_of_photos_compared_to_last_month'] = numberOfPhotosComparedToLastMonth;
    data['visited_customers_compared_to_last_month'] = visitedCustomersComparedToLastMonth;
    data['planogram_realization_score_compared_to_last_month'] = planogramRealizationScoreComparedToLastMonth;
    data['planogram_availability_score_compared_to_last_month'] = planogramAvailabilityScoreComparedToLastMonth;
    data['drink_musthave_score_compared_to_last_month'] = drinkMusthaveScoreComparedToLastMonth;
    data['shelf_share_score_compared_to_last_month'] = shelfShareScoreComparedToLastMonth;
    return data;
  }
}

class ThisWeeksPeriodicResults {
  int? numberOfPhotos;
  int? visitedCustomers;
  int? planogramRealizationScore;
  int? planogramAvailabilityScore;
  int? drinkMusthaveScore;
  int? shelfShareScore;
  int? numberOfPhotosComparedToLastWeek;
  int? visitedCustomersComparedToLastWeek;
  int? planogramRealizationScoreComparedToLastWeek;
  int? planogramAvailabilityScoreComparedToLastWeek;
  int? drinkMusthaveScoreComparedToLastWeek;
  int? shelfShareScoreComparedToLastWeek;

  ThisWeeksPeriodicResults(
      {this.numberOfPhotos,
      this.visitedCustomers,
      this.planogramRealizationScore,
      this.planogramAvailabilityScore,
      this.drinkMusthaveScore,
      this.shelfShareScore,
      this.numberOfPhotosComparedToLastWeek,
      this.visitedCustomersComparedToLastWeek,
      this.planogramRealizationScoreComparedToLastWeek,
      this.planogramAvailabilityScoreComparedToLastWeek,
      this.drinkMusthaveScoreComparedToLastWeek,
      this.shelfShareScoreComparedToLastWeek});

  ThisWeeksPeriodicResults.fromJson(Map<String, dynamic> json) {
    numberOfPhotos = json['number_of_photos'];
    visitedCustomers = json['visited_customers'];
    planogramRealizationScore = json['planogram_realization_score'];
    planogramAvailabilityScore = json['planogram_availability_score'];
    drinkMusthaveScore = json['drink_musthave_score'];
    shelfShareScore = json['shelf_share_score'];
    numberOfPhotosComparedToLastWeek = json['number_of_photos_compared_to_last_week'];
    visitedCustomersComparedToLastWeek = json['visited_customers_compared_to_last_week'];
    planogramRealizationScoreComparedToLastWeek = json['planogram_realization_score_compared_to_last_week'];
    planogramAvailabilityScoreComparedToLastWeek = json['planogram_availability_score_compared_to_last_week'];
    drinkMusthaveScoreComparedToLastWeek = json['drink_musthave_score_compared_to_last_week'];
    shelfShareScoreComparedToLastWeek = json['shelf_share_score_compared_to_last_week'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number_of_photos'] = numberOfPhotos;
    data['visited_customers'] = visitedCustomers;
    data['planogram_realization_score'] = planogramRealizationScore;
    data['planogram_availability_score'] = planogramAvailabilityScore;
    data['drink_musthave_score'] = drinkMusthaveScore;
    data['shelf_share_score'] = shelfShareScore;
    data['number_of_photos_compared_to_last_week'] = numberOfPhotosComparedToLastWeek;
    data['visited_customers_compared_to_last_week'] = visitedCustomersComparedToLastWeek;
    data['planogram_realization_score_compared_to_last_week'] = planogramRealizationScoreComparedToLastWeek;
    data['planogram_availability_score_compared_to_last_week'] = planogramAvailabilityScoreComparedToLastWeek;
    data['drink_musthave_score_compared_to_last_week'] = drinkMusthaveScoreComparedToLastWeek;
    data['shelf_share_score_compared_to_last_week'] = shelfShareScoreComparedToLastWeek;
    return data;
  }
}

class TodaysPeriodicResults {
  int? numberOfPhotos;
  int? visitedCustomers;
  int? planogramRealizationScore;
  int? planogramAvailabilityScore;
  int? drinkMusthaveScore;
  int? shelfShareScore;
  int? numberOfPhotosComparedToYesterday;
  int? visitedCustomersComparedToYesterday;
  int? planogramRealizationScoreComparedToYesterday;
  int? planogramAvailabilityScoreComparedToYesterday;
  int? drinkMusthaveScoreComparedToYesterday;
  int? shelfShareScoreComparedToYesterday;

  TodaysPeriodicResults(
      {this.numberOfPhotos,
      this.visitedCustomers,
      this.planogramRealizationScore,
      this.planogramAvailabilityScore,
      this.drinkMusthaveScore,
      this.shelfShareScore,
      this.numberOfPhotosComparedToYesterday,
      this.visitedCustomersComparedToYesterday,
      this.planogramRealizationScoreComparedToYesterday,
      this.planogramAvailabilityScoreComparedToYesterday,
      this.drinkMusthaveScoreComparedToYesterday,
      this.shelfShareScoreComparedToYesterday});

  TodaysPeriodicResults.fromJson(Map<String, dynamic> json) {
    numberOfPhotos = json['number_of_photos'];
    visitedCustomers = json['visited_customers'];
    planogramRealizationScore = json['planogram_realization_score'];
    planogramAvailabilityScore = json['planogram_availability_score'];
    drinkMusthaveScore = json['drink_musthave_score'];
    shelfShareScore = json['shelf_share_score'];
    numberOfPhotosComparedToYesterday = json['number_of_photos_compared_to_yesterday'];
    visitedCustomersComparedToYesterday = json['visited_customers_compared_to_yesterday'];
    planogramRealizationScoreComparedToYesterday = json['planogram_realization_score_compared_to_yesterday'];
    planogramAvailabilityScoreComparedToYesterday = json['planogram_availability_score_compared_to_yesterday'];
    drinkMusthaveScoreComparedToYesterday = json['drink_musthave_score_compared_to_yesterday'];
    shelfShareScoreComparedToYesterday = json['shelf_share_score_compared_to_yesterday'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number_of_photos'] = numberOfPhotos;
    data['visited_customers'] = visitedCustomers;
    data['planogram_realization_score'] = planogramRealizationScore;
    data['planogram_availability_score'] = planogramAvailabilityScore;
    data['drink_musthave_score'] = drinkMusthaveScore;
    data['shelf_share_score'] = shelfShareScore;
    data['number_of_photos_compared_to_yesterday'] = numberOfPhotosComparedToYesterday;
    data['visited_customers_compared_to_yesterday'] = visitedCustomersComparedToYesterday;
    data['planogram_realization_score_compared_to_yesterday'] = planogramRealizationScoreComparedToYesterday;
    data['planogram_availability_score_compared_to_yesterday'] = planogramAvailabilityScoreComparedToYesterday;
    data['drink_musthave_score_compared_to_yesterday'] = drinkMusthaveScoreComparedToYesterday;
    data['shelf_share_score_compared_to_yesterday'] = shelfShareScoreComparedToYesterday;
    return data;
  }
}
