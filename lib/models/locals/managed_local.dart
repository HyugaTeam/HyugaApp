class ManagedLocal{
  bool reservations;
  String id;
  String name;
  String description;
  int cost;
  int capacity;
  int retainedPercentage;
  String ambiance;
  Map<String,dynamic> profile;
  Map<String,dynamic> discounts;
  Map<String,dynamic> analytics;
  Map<String,dynamic> schedule;
  /// analytics field should contain:
  /// all_time_income
  /// 

  ManagedLocal({this.reservations,this.id,this.name,this.description,this.cost,this.capacity,this.ambiance,this.profile,this.discounts,this.analytics,this.retainedPercentage, this.schedule});
}
