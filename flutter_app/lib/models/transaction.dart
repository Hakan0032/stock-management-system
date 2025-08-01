class Transaction {
  int? id;
  late int productId;
  late String type; // 'in', 'out', 'adjustment'
  late int quantity;
  late double unitPrice;
  late String notes;
  late String reason; // Backend için gerekli alan
  late DateTime createdAt;
  late DateTime updatedAt;

  Transaction({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.notes,
    this.reason = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    // Backend için transaction_type değerini dönüştür
    int transactionType;
    switch (type) {
      case 'in':
        transactionType = 0; // STOCK_IN
        break;
      case 'out':
        transactionType = 1; // STOCK_OUT
        break;
      case 'adjustment':
        transactionType = 2; // ADJUSTMENT
        break;
      default:
        transactionType = 0;
    }
    
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'transaction_type': transactionType,
      'quantity': quantity,
      'reason': reason.isNotEmpty ? reason : 'Stok işlemi',
      'notes': notes,
      'transaction_date': createdAt.toIso8601String(),
      'created_by': 'flutter_app',
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Backend'den gelen transaction_type değerini dönüştür
    String type;
    int transactionType = json['transaction_type'] ?? 0;
    switch (transactionType) {
      case 0:
        type = 'in';
        break;
      case 1:
        type = 'out';
        break;
      case 2:
        type = 'adjustment';
        break;
      default:
        type = 'in';
    }
    
    return Transaction(
      id: json['id'],
      productId: json['product_id'],
      type: type,
      quantity: json['quantity'],
      unitPrice: 0.0, // Backend'de unit_price yok
      notes: json['notes'] ?? '',
      reason: json['reason'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  double get totalValue => quantity * unitPrice;

  @override
  String toString() {
    return 'Transaction{id: $id, productId: $productId, type: $type, quantity: $quantity}';
  }
}