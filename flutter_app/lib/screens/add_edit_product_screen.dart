import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../l10n/app_localizations.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _unitController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _barcodeController.text = product.barcode;
    _categoryController.text = product.category;
    _unitController.text = product.unit;

    _currentStockController.text = product.currentStock.toString();
    _minStockController.text = product.minStock.toString();
    _descriptionController.text = product.description;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _currentStockController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Ürün Düzenle' : 'Ürün Ekle'),
        actions: [
          TextButton(
            onPressed: _saveProduct,
            child: Text('Kaydet'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Temel Bilgiler
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temel Bilgiler',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Ürün Adı *',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ürün adı gereklidir';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _barcodeController,
                        decoration: InputDecoration(
                          labelText: 'Barkod *',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Barkod gereklidir';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _categoryController,
                              decoration: InputDecoration(
                                labelText: 'Kategori *',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Kategori gereklidir';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _unitController,
                              decoration: const InputDecoration(
                                labelText: 'Birim *',
                                border: OutlineInputBorder(),
                                hintText: 'adet, kg, lt, vb.',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Birim gereklidir';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Açıklama',
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              
              // Stok Bilgileri
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stok Bilgileri',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _currentStockController,
                              decoration: InputDecoration(
                                labelText: 'Stok *',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Mevcut stok gereklidir';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Lütfen geçerli bir stok girin';
                                }
                                if (double.parse(value) < 0) {
                                  return 'Stok negatif olamaz';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _minStockController,
                              decoration: InputDecoration(
                                labelText: 'Minimum Stok *',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Minimum stok gerekli';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Lütfen geçerli bir stok girin';
                                }
                                if (double.parse(value) < 0) {
                                  return 'Stok negatif olamaz';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isEditing ? 'Değişiklikleri Kaydet' : 'Ürünü Kaydet',
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

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final product = Product(
      id: isEditing ? widget.product!.id : null,
      name: _nameController.text.trim(),
      barcode: _barcodeController.text.trim(),
      code: _barcodeController.text.trim(), // Barkod kodu olarak kullanıyoruz
      category: _categoryController.text.trim(),
      unit: _unitController.text.trim(),
      purchasePrice: 0.0,
      salePrice: 0.0,
      currentStock: int.parse(_currentStockController.text),
      minStockLevel: int.parse(_minStockController.text),
      minStock: int.parse(_minStockController.text),
      description: _descriptionController.text.trim(),
      createdAt: isEditing ? widget.product!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final provider = context.read<ProductProvider>();
      
      if (isEditing) {
        await provider.updateProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ürün başarıyla güncellendi')),
          );
        }
      } else {
        await provider.addProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ürün başarıyla eklendi')),
          );
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}