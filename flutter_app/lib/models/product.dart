class Product {
  int? id;
  late String barcode;
  
  late String name;
  late String description;
  late String category;
  late double purchasePrice;
  late double salePrice;
  late int currentStock;
  late int minStockLevel;
  late String unit; // adet, kg, lt, etc.
  int? minStock;
  
  late DateTime createdAt;
  late DateTime updatedAt;
  
  Product({
    this.id,
    required this.barcode,
    required this.name,
    required this.description,
    required this.category,
    required this.purchasePrice,
    required this.salePrice,
    required this.currentStock,
    required this.minStockLevel,
    required this.unit,
    String? code,
    double? price,
    int? minStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }
  
  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'barcode': barcode,
      'name': name,
      'description': description,
      'category': category,
      'price': salePrice, // Backend expects 'price' field
      'current_stock': currentStock,
      'min_stock_level': minStockLevel,
      'unit': unit,
    };
  }
  
  // Database serialization
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'barcode': barcode,
      'name': name,
      'description': description,
      'category': category,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'current_stock': currentStock,
      'min_stock_level': minStockLevel,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      barcode: map['barcode'],
      name: map['name'],
      description: map['description'] ?? '',
      category: map['category'],
      purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (map['sale_price'] as num?)?.toDouble() ?? 0.0,
      currentStock: map['current_stock'] ?? 0,
      minStockLevel: map['min_stock_level'] ?? 0,
      unit: map['unit'] ?? 'adet',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
    );
  }
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      barcode: json['barcode'],
      name: json['name'],
      description: json['description'] ?? '',
      category: json['category'],
      purchasePrice: (json['price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['price'] as num?)?.toDouble() ?? 0.0,
      currentStock: json['current_stock'] ?? 0,
      minStockLevel: json['min_stock_level'] ?? 0,
      unit: json['unit'] ?? 'adet',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }
  
  bool get isLowStock => currentStock <= minStockLevel;
  
  // Getter for stock (alias for currentStock)
  int get stock => currentStock;
  
  // Getter for code (alias for barcode)
  String get code => barcode;
  
  @override
  String toString() {
    return 'Product{id: $id, name: $name, currentStock: $currentStock}';
  }
}