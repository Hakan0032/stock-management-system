class Machine {
  final int? id;
  final String name;
  final String type;
  final String status;
  final String? location;
  final String? description;
  final DateTime? purchaseDate;
  final DateTime? warrantyEndDate;
  final int? maintenanceIntervalDays;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final Map<String, dynamic>? specifications;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Machine({
    this.id,
    required this.name,
    required this.type,
    this.status = 'active',
    this.location,
    this.description,
    this.purchaseDate,
    this.warrantyEndDate,
    this.maintenanceIntervalDays,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.specifications,
    this.createdAt,
    this.updatedAt,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      status: json['status'] ?? 'active',
      location: json['location'],
      description: json['description'],
      purchaseDate: json['purchase_date'] != null 
          ? DateTime.parse(json['purchase_date']) 
          : null,
      warrantyEndDate: json['warranty_end_date'] != null 
          ? DateTime.parse(json['warranty_end_date']) 
          : null,
      maintenanceIntervalDays: json['maintenance_interval_days'],
      lastMaintenanceDate: json['last_maintenance_date'] != null 
          ? DateTime.parse(json['last_maintenance_date']) 
          : null,
      nextMaintenanceDate: json['next_maintenance_date'] != null 
          ? DateTime.parse(json['next_maintenance_date']) 
          : null,
      specifications: json['specifications'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'location': location,
      'description': description,
      'purchase_date': purchaseDate?.toIso8601String(),
      'warranty_end_date': warrantyEndDate?.toIso8601String(),
      'maintenance_interval_days': maintenanceIntervalDays,
      'last_maintenance_date': lastMaintenanceDate?.toIso8601String(),
      'next_maintenance_date': nextMaintenanceDate?.toIso8601String(),
      'specifications': specifications,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Machine copyWith({
    int? id,
    String? name,
    String? type,
    String? status,
    String? location,
    String? description,
    DateTime? purchaseDate,
    DateTime? warrantyEndDate,
    int? maintenanceIntervalDays,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    Map<String, dynamic>? specifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Machine(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      description: description ?? this.description,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyEndDate: warrantyEndDate ?? this.warrantyEndDate,
      maintenanceIntervalDays: maintenanceIntervalDays ?? this.maintenanceIntervalDays,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}