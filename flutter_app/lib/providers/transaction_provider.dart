import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService.instance;
  
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType;
  
  List<Transaction> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get selectedType => _selectedType;
  
  int get totalTransactionCount => _transactions.length;
  
  Map<String, int> get transactionCountByType {
    final counts = <String, int>{};
    final types = ['in', 'out', 'adjustment'];
    for (final type in types) {
      counts[type] = _transactions.where((t) => t.type == type).length;
    }
    return counts;
  }
  
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _transactions = await _apiService.getAllTransactions();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      _transactions = [];
      _filteredTransactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addTransaction(Transaction transaction) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final newTransaction = await _apiService.addTransaction(transaction);
      _transactions.insert(0, newTransaction); // Add to beginning for newest first
      _applyFilters();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addStockIn({
    required Product product,
    required int quantity,
    required String reason,
    String notes = '',
  }) async {
    final transaction = Transaction(
      productId: product.id!,
      quantity: quantity,
      type: 'in',
      unitPrice: 0.0,
      reason: reason,
      notes: notes,
    );
    
    await addTransaction(transaction);
  }
  
  Future<void> addStockOut({
    required Product product,
    required int quantity,
    required String reason,
    String notes = '',
  }) async {
    // Stok kontrolü
    if (product.currentStock < quantity) {
      throw Exception('Yetersiz stok! Mevcut: ${product.currentStock}, İstenen: $quantity');
    }
    
    final transaction = Transaction(
      productId: product.id!,
      quantity: quantity,
      type: 'out',
      unitPrice: 0.0,
      reason: reason,
      notes: notes,
    );
    
    await addTransaction(transaction);
  }
  
  Future<void> addStockAdjustment({
    required Product product,
    required int newQuantity,
    required String reason,
    String notes = '',
  }) async {
    final transaction = Transaction(
      productId: product.id!,
      quantity: newQuantity,
      type: 'adjustment',
      unitPrice: 0.0,
      reason: reason,
      notes: notes,
    );
    
    await addTransaction(transaction);
  }
  
  Future<List<Transaction>> getTransactionsByProduct(int productId) async {
    try {
      return await _apiService.getTransactionsByProduct(productId);
    } catch (e) {
      debugPrint('Error getting transactions by product: $e');
      return [];
    }
  }
  
  void filterByDateRange(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    _applyFilters();
    notifyListeners();
  }
  
  void filterByType(String? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }
  
  void _applyFilters() {
    _filteredTransactions = _transactions;
    
    // Tarih filtresi
    if (_startDate != null && _endDate != null) {
      _filteredTransactions = _filteredTransactions.where((transaction) {
        final transactionDate = transaction.createdAt;
        return transactionDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
               transactionDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }
    
    // Tip filtresi
    if (_selectedType != null) {
      _filteredTransactions = _filteredTransactions
          .where((transaction) => transaction.type == _selectedType)
          .toList();
    }
    
    // Tarihe göre sırala (en yeni önce)
    _filteredTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _selectedType = null;
    _applyFilters();
    notifyListeners();
  }
  
  // İstatistikler
  
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: now.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);
    
    final todayTransactions = _transactions.where((t) => 
        t.createdAt.isAfter(today.subtract(const Duration(days: 1)))).toList();
    
    final weekTransactions = _transactions.where((t) => 
        t.createdAt.isAfter(thisWeek.subtract(const Duration(days: 1)))).toList();
    
    final monthTransactions = _transactions.where((t) => 
        t.createdAt.isAfter(thisMonth.subtract(const Duration(days: 1)))).toList();
    
    return {
      'today': {
        'total': todayTransactions.length,
        'stockIn': todayTransactions.where((t) => t.type == 'in').length,
        'stockOut': todayTransactions.where((t) => t.type == 'out').length,
        'adjustment': todayTransactions.where((t) => t.type == 'adjustment').length,
      },
      'week': {
        'total': weekTransactions.length,
        'stockIn': weekTransactions.where((t) => t.type == 'in').length,
        'stockOut': weekTransactions.where((t) => t.type == 'out').length,
        'adjustment': weekTransactions.where((t) => t.type == 'adjustment').length,
      },
      'month': {
        'total': monthTransactions.length,
        'stockIn': monthTransactions.where((t) => t.type == 'in').length,
        'stockOut': monthTransactions.where((t) => t.type == 'out').length,
        'adjustment': monthTransactions.where((t) => t.type == 'adjustment').length,
      },
    };
  }
  
  Future<bool> checkConnection() async {
    return await _apiService.checkConnection();
  }
}