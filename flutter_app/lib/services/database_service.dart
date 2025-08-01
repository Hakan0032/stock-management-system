import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/inventory_transaction.dart';

class DatabaseService {
  static SharedPreferences? _prefs;
  static const String _productsKey = 'products';
  static const String _transactionsKey = 'transactions';

  static Future<SharedPreferences> get prefs async {
    print('DatabaseService.prefs çağrıldı');
    if (_prefs != null) {
      print('Mevcut SharedPreferences döndürülüyor');
      return _prefs!;
    }
    print('Yeni SharedPreferences başlatılıyor...');
    _prefs = await SharedPreferences.getInstance();
    print('SharedPreferences başarıyla başlatıldı');
    return _prefs!;
  }



  // Product operations - Basitleştirilmiş SharedPreferences versiyonu
  static Future<List<Product>> getAllProducts() async {
    try {
      final prefs = await DatabaseService.prefs;
      List<String> products = prefs.getStringList(_productsKey) ?? [];
      return products.map((productJson) => Product.fromMap(jsonDecode(productJson))).toList();
    } catch (e) {
      print('Ürün listesi alma hatası: $e');
      return [];
    }
  }

  static Future<bool> insertProduct(Product product) async {
    try {
      final prefs = await DatabaseService.prefs;
      List<String> products = prefs.getStringList(_productsKey) ?? [];
      
      Map<String, dynamic> productMap = product.toMap();
      productMap['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      
      products.add(jsonEncode(productMap));
      await prefs.setStringList(_productsKey, products);
      return true;
    } catch (e) {
      print('Ürün ekleme hatası: $e');
      return false;
    }
  }

  // Transaction operations - Basitleştirilmiş SharedPreferences versiyonu
  static Future<List<InventoryTransaction>> getAllTransactions() async {
    try {
      final prefs = await DatabaseService.prefs;
      List<String> transactions = prefs.getStringList(_transactionsKey) ?? [];
      return transactions.map((transactionJson) => InventoryTransaction.fromMap(jsonDecode(transactionJson))).toList();
    } catch (e) {
      print('İşlem listesi alma hatası: $e');
      return [];
    }
  }

  static Future<bool> insertTransaction(InventoryTransaction transaction) async {
    try {
      final prefs = await DatabaseService.prefs;
      List<String> transactions = prefs.getStringList(_transactionsKey) ?? [];
      
      Map<String, dynamic> transactionMap = transaction.toMap();
      transactionMap['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      
      transactions.add(jsonEncode(transactionMap));
      await prefs.setStringList(_transactionsKey, transactions);
      return true;
    } catch (e) {
      print('İşlem ekleme hatası: $e');
      return false;
    }
  }

  // Basit istatistik metodları - SharedPreferences versiyonu
  static Future<int> getTotalProducts() async {
    try {
      final products = await getAllProducts();
      return products.length;
    } catch (e) {
      print('Toplam ürün sayısı alma hatası: $e');
      return 0;
    }
  }

  static Future<int> getTotalTransactions() async {
    try {
      final transactions = await getAllTransactions();
      return transactions.length;
    } catch (e) {
      print('Toplam işlem sayısı alma hatası: $e');
      return 0;
    }
  }
}