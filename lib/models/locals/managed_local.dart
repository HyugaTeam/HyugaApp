class ManagedLocal{
  bool? reservations;
  String? id;
  String? name;
  String? description;
  int? cost;
  int? capacity;
  double? retainedPercentage;
  String? ambiance;
  Map<String,dynamic>? profile;
  Map<String,dynamic>? discounts;
  Map<String,dynamic>? deals;
  Map<String,dynamic>? analytics;
  Map<String,dynamic>? schedule;
  int? maturity;

  ManagedLocal(
    {
      this.reservations,
      this.id,
      this.name,
      this.description,
      this.cost,
      this.capacity,
      this.ambiance,
      this.profile,
      this.discounts,
      this.deals,
      this.analytics,
      this.retainedPercentage, 
      this.schedule,
      this.maturity
    }
  );
}
