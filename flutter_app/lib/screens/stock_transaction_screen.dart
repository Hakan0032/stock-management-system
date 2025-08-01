import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../l10n/app_localizations.dart';

class StockTransactionScreen extends StatefulWidget {
  final String transactionType; // 'in' veya 'out'
  final Product? selectedProduct;

  const StockTransactionScreen({
    super.key,
    required this.transactionType,
    this.selectedProduct,
  });

  @override
  State<StockTransactionScreen> createState() => _StockTransactionScreenState();
}

class _StockTransactionScreenState extends State<StockTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _barcodeController = TextEditingController();
  
  Product? _selectedProduct;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.selectedProduct;
  }

  @override
  Widget build(BuildContext context) {
    final isStockIn = widget.transactionType == 'in';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isStockIn ? 'Stok Girişi' : 'Stok Çıkışı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ürün Seçimi
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ürün Seçimi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Barkod ile arama
                      TextFormField(
                        controller: _barcodeController,
                        decoration: InputDecoration(
                          labelText: 'Barkod',
                          hintText: 'Barkod girin veya tarayın',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner),
                            onPressed: _scanBarcode,
                          ),
                        ),
                        onChanged: _searchProductByBarcode,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Ürün dropdown
                      Consumer<ProductProvider>(
                        builder: (context, provider, child) {
                          return DropdownButtonFormField<Product>(
                            value: _selectedProduct,
                            decoration: InputDecoration(
                              labelText: 'Ürün Seçin',
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Lütfen bir ürün seçin';
                              }
                              return null;
                            },
                            items: provider.products.map((product) {
                              return DropdownMenuItem(
                                value: product,
                                child: Text('${product.name} (Stok: ${product.currentStock})'),
                              );
                            }).toList(),
                            onChanged: (product) {
                              setState(() {
                                _selectedProduct = product;
                                if (product != null) {
                                  _barcodeController.text = product.barcode;
                                }
                              });
                            },
                          );
                        },
                      ),
                      
                      if (_selectedProduct != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seçilen Ürün: ${_selectedProduct!.name}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Mevcut Stok: ${_selectedProduct!.currentStock} ${_selectedProduct!.unit}'),
                              Text('Kategori: ${_selectedProduct!.category}'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // İşlem Detayları
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İşlem Detayları',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Miktar',
                          hintText: isStockIn ? 'Giriş miktarı' : 'Çıkış miktarı',
                          suffixText: _selectedProduct?.unit ?? '',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen miktar girin';
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return 'Lütfen geçerli bir miktar girin';
                          }
                          if (!isStockIn && _selectedProduct != null) {
                            if (quantity > _selectedProduct!.currentStock) {
                              return 'Yetersiz stok';
                            }
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notlar (İsteğe bağlı)',
                          hintText: 'İşlem açıklaması',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isStockIn ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isStockIn ? 'Stok Girişi Yap' : 'Stok Çıkışı Yap',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scanBarcode() {
    // Barkod tarama ekranına git
    Navigator.pushNamed(context, '/barcode-scanner');
  }

  void _searchProductByBarcode(String barcode) {
    if (barcode.isNotEmpty) {
      final productProvider = context.read<ProductProvider>();
      final product = productProvider.products.firstWhere(
        (p) => p.barcode == barcode,
        orElse: () => Product(
          id: 0,
          name: '',
          barcode: '',
          code: '',
          category: '',
          unit: '',
          purchasePrice: 0,
          salePrice: 0,
          currentStock: 0,
          minStockLevel: 0,
          description: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      if (product.id != 0) {
        setState(() {
          _selectedProduct = product;
        });
      }
    }
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final quantity = int.parse(_quantityController.text);
      final notes = _notesController.text.trim();
      
      final transaction = Transaction(
        id: 0, // API tarafından atanacak
        productId: _selectedProduct!.id!,
        type: widget.transactionType,
        quantity: quantity,
        unitPrice: _selectedProduct!.salePrice,
        notes: notes.isEmpty ? '' : notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await context.read<TransactionProvider>().addTransaction(transaction);
      
      // Ürün stokunu güncelle
      final updatedStock = widget.transactionType == 'in'
          ? _selectedProduct!.currentStock + quantity
          : _selectedProduct!.currentStock - quantity;
      
      final updatedProduct = Product(
        id: _selectedProduct!.id,
        name: _selectedProduct!.name,
        barcode: _selectedProduct!.barcode,
        code: _selectedProduct!.code,
        category: _selectedProduct!.category,
        unit: _selectedProduct!.unit,
        purchasePrice: _selectedProduct!.purchasePrice,
        salePrice: _selectedProduct!.salePrice,
        currentStock: updatedStock,
        minStockLevel: _selectedProduct!.minStockLevel,
        description: _selectedProduct!.description,
        createdAt: _selectedProduct!.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await context.read<ProductProvider>().updateProduct(updatedProduct);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transactionType == 'in'
                  ? 'Stok girişi başarıyla kaydedildi'
                : 'Stok çıkışı başarıyla kaydedildi',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }
}