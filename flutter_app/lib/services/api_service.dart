import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/machine.dart';
import '../models/planning.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  
  ApiService._();
  
  // Product API Methods
  
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['data']['products'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
  
  Future<Product> getProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }
  
  Future<Product> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/barcode/$barcode'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Failed to load product by barcode: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product by barcode: $e');
    }
  }
  
  Future<Product> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
        body: json.encode(product.toMap()),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Failed to add product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding product: $e');
    }
  }
  
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: _headers,
        body: json.encode(product.toMap()),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }
  
  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }
  
  Future<List<Product>> searchProducts(String searchTerm) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search?q=$searchTerm'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['data']['products'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }
  
  Future<List<Product>> getLowStockProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/low-stock'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['data']['products'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load low stock products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching low stock products: $e');
    }
  }
  
  // Transaction API Methods
  
  Future<List<Transaction>> getAllTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> transactionsJson = data['data']['transactions'];
        return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }
  
  Future<Transaction> addTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transaction.toJson()),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Transaction.fromJson(data['data']);
      } else {
        throw Exception('Failed to add transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }
  
  Future<List<Transaction>> getTransactionsByProduct(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/product/$productId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> transactionsJson = data['data'];
        return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load product transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product transactions: $e');
    }
  }
  
  // Statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/statistics'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching statistics: $e');
    }
  }
  
  // Health check
  Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Machine API Methods
  
  Future<List<Machine>> getAllMachines() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/machines'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> machinesJson = data['data']['machines'];
        return machinesJson.map((json) => Machine.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load machines: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching machines: $e');
    }
  }
  
  Future<Machine> getMachine(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/machines/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Machine.fromJson(data['data']);
      } else {
        throw Exception('Failed to load machine: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching machine: $e');
    }
  }
  
  Future<Machine> createMachine(Machine machine) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/machines'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(machine.toJson()),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Machine.fromJson(data['data']);
      } else {
        throw Exception('Failed to create machine: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating machine: $e');
    }
  }
  
  Future<Machine> updateMachine(int id, Machine machine) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/machines/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(machine.toJson()),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Machine.fromJson(data['data']);
      } else {
        throw Exception('Failed to update machine: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating machine: $e');
    }
  }
  
  Future<void> deleteMachine(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/machines/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete machine: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting machine: $e');
    }
  }

  // Planning API Methods
  
  Future<List<Planning>> getAllPlannings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plannings'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> planningsJson = data['data']['plannings'];
        return planningsJson.map((json) => Planning.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load plannings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching plannings: $e');
    }
  }
  
  Future<Planning> getPlanning(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plannings/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Planning.fromJson(data['data']);
      } else {
        throw Exception('Failed to load planning: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching planning: $e');
    }
  }
  
  Future<Planning> createPlanning(Planning planning) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/plannings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(planning.toJson()),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Planning.fromJson(data['data']);
      } else {
        throw Exception('Failed to create planning: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating planning: $e');
    }
  }
  
  Future<Planning> updatePlanning(int id, Planning planning) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/plannings/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(planning.toJson()),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Planning.fromJson(data['data']);
      } else {
        throw Exception('Failed to update planning: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating planning: $e');
    }
  }
  
  Future<void> deletePlanning(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/plannings/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete planning: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting planning: $e');
    }
  }

  // Stats API
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stats'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading stats: $e');
    }
  }
}