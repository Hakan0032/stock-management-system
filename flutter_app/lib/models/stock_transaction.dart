import 'product.dart';

enum TransactionType {
  stockIn,  // Stok Girişi
  stockOut, // Stok Çıkışı
  adjustment, // Düzeltme
}

class StockTransaction {
  int? id;
  int? productId;
  late int quantity;
  late int transactionType;
  late String reason;
  late String notes;
  late DateTime transactionDate;
  late DateTime createdAt;
  
  StockTransaction();
  
  StockTransaction.create({
    this.id,
    required this.productId,
    required this.quantity,
    required TransactionType type,
    required this.reason,
    this.notes = '',
    DateTime? transactionDate,
    DateTime? createdAt,
  }) {
    transactionType = type.index;
    this.transactionDate = transactionDate ?? DateTime.now();
    this.createdAt = createdAt ?? DateTime.now();
  }
  
  TransactionType get type => TransactionType.values[transactionType];
  
  String get typeDisplayName {
    switch (type) {
      case TransactionType.stockIn:
        return 'Stok Girişi';
      case TransactionType.stockOut:
        return 'Stok Çıkışı';
      case TransactionType.adjustment:
        return 'Düzeltme';
    }
  }
  
  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'quantity': quantity,
      'transaction_type': transactionType,
      'reason': reason,
      'notes': notes,
      'transaction_date': transactionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction.create(
      id: json['id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      type: TransactionType.values[json['transaction_type']],
      reason: json['reason'],
      notes: json['notes'] ?? '',
      transactionDate: DateTime.parse(json['transaction_date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  @override
  String toString() {
    return 'StockTransaction{id: $id, productId: $productId, quantity: $quantity, type: ${typeDisplayName}}';
  }
}