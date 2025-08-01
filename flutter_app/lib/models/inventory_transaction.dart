class InventoryTransaction {
  int? id;
  late int productId;
  late String type; // 'in' or 'out'
  late int quantity;
  late String reason;
  late DateTime createdAt;
  late DateTime updatedAt;

  InventoryTransaction({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.reason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  // Database serialization
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory InventoryTransaction.fromMap(Map<String, dynamic> map) {
    return InventoryTransaction(
      id: map['id'],
      productId: map['product_id'],
      type: map['type'],
      quantity: map['quantity'],
      reason: map['reason'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    return InventoryTransaction(
      id: json['id'],
      productId: json['product_id'],
      type: json['type'],
      quantity: json['quantity'],
      reason: json['reason'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'InventoryTransaction{id: $id, productId: $productId, type: $type, quantity: $quantity}';
  }
}