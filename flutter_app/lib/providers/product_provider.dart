import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService.instance;
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  
  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  
  List<Product> get lowStockProducts => _products.where((p) => p.isLowStock).toList();
  int get totalProductCount => _products.length;
  int get lowStockCount => lowStockProducts.length;
  
  List<String> get categories {
    final cats = ['Tümü'];
    final uniqueCategories = _products.map((p) => p.category).toSet().toList();
    cats.addAll(uniqueCategories);
    return cats;
  }
  
  double get totalInventoryValue {
    return _products.fold(0.0, (sum, product) => sum + (product.salePrice * product.currentStock));
  }
  
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _products = await _apiService.getAllProducts();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading products: $e');
      _products = [];
      _filteredProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadLowStockProducts() async {
    try {
      final lowStock = await _apiService.getLowStockProducts();
      // Update the main products list with low stock info
      for (final product in _products) {
        final lowStockProduct = lowStock.firstWhere(
          (p) => p.id == product.id,
          orElse: () => Product(
            barcode: '',
            code: '',
            name: '',
            description: '',
            category: '',
            purchasePrice: 0,
            salePrice: 0,
            currentStock: 0,
            minStockLevel: 0,
            unit: '',
          ),
        );
        if (lowStockProduct.id != null) {
          product.currentStock = lowStockProduct.currentStock;
        }
      }
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading low stock products: $e');
    }
  }
  
  Future<void> addProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final newProduct = await _apiService.addProduct(product);
      _products.add(newProduct);
      _applyFilters();
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final updatedProduct = await _apiService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteProduct(int id) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _apiService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      _applyFilters();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      return await _apiService.getProductByBarcode(barcode);
    } catch (e) {
      debugPrint('Error getting product by barcode: $e');
      return null;
    }
  }
  
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _applyFilters();
    } else {
      try {
        _isLoading = true;
        notifyListeners();
        
        final searchResults = await _apiService.searchProducts(query);
        _filteredProducts = searchResults;
      } catch (e) {
        debugPrint('Error searching products: $e');
        _applyFilters(); // Fallback to local filtering
      } finally {
        _isLoading = false;
      }
    }
    
    notifyListeners();
  }
  
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }
  
  void _applyFilters() {
    _filteredProducts = _products;
    
    // Kategori filtresi
    if (_selectedCategory != 'Tümü') {
      _filteredProducts = _filteredProducts
          .where((product) => product.category == _selectedCategory)
          .toList();
    }
    
    // Arama filtresi (sadece yerel arama için)
    if (_searchQuery.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               product.barcode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }
  
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'Tümü';
    _applyFilters();
    notifyListeners();
  }
  
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      return await _apiService.getStatistics();
    } catch (e) {
      debugPrint('Error getting statistics: $e');
      return {
        'totalProducts': _products.length,
        'lowStockProducts': lowStockCount,
        'totalValue': totalInventoryValue,
      };
    }
  }
  
  Future<bool> checkConnection() async {
    return await _apiService.checkConnection();
  }
  
  // Ürün ID'sinden ürün adını al
  String getProductNameById(int productId) {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      return product.name;
    } catch (e) {
      return 'Ürün #$productId';
    }
  }
}