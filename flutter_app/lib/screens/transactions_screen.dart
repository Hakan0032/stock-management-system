import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/product_provider.dart';
import '../models/transaction.dart';
import '../models/product.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showAll = false;
  final int _defaultItemCount = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İşlemler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              context.read<TransactionProvider>().clearFilters();
              setState(() {
                _selectedType = null;
                _startDate = null;
                _endDate = null;
              });
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.transactions.isEmpty) {
            return Center(
              child: Text('Henüz işlem bulunmuyor'),
            );
          }

          final displayCount = _showAll ? provider.transactions.length : 
              (provider.transactions.length > _defaultItemCount ? _defaultItemCount : provider.transactions.length);
          
          return RefreshIndicator(
            onRefresh: () => provider.loadTransactions(),
            child: Column(
              children: [
                if (provider.transactions.length > _defaultItemCount)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _showAll 
                              ? 'Tüm işlemler gösteriliyor (${provider.transactions.length})'
                              : 'Son ${_defaultItemCount} işlem gösteriliyor',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAll = !_showAll;
                            });
                          },
                          child: Text(_showAll ? 'Daha Az Göster' : 'Tümünü Gör'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: displayCount,
                    itemBuilder: (context, index) {
                      final transaction = provider.transactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTransactionColor(transaction.type),
          child: Icon(
            _getTransactionIcon(transaction.type),
            color: Colors.white,
          ),
        ),
        title: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            final product = productProvider.products.firstWhere(
              (p) => p.id == transaction.productId,
              orElse: () => Product(
                barcode: '',
                code: '',
                name: 'Bilinmeyen Ürün',
                description: '',
                category: '',
                unit: '',
                purchasePrice: 0,
                salePrice: 0,
                currentStock: 0,
                minStockLevel: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
            return Text(product.name);
          },
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.notes ?? ''),
            Text(
              _formatDate(transaction.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${transaction.type == 'out' ? '-' : '+'}${transaction.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: transaction.type == 'out' 
                ? Colors.red 
                : Colors.green,
          ),
        ),
      ),
    );
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'in':
        return Colors.green;
      case 'out':
        return Colors.red;
      case 'adjustment':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'in':
        return Icons.add;
      case 'out':
        return Icons.remove;
      case 'adjustment':
        return Icons.edit;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'İşlem Türü',
              ),
              items: ['in', 'out', 'adjustment'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTransactionTypeName(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Başlangıç Tarihi',
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _startDate != null ? _formatDate(_startDate!) : '',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Bitiş Tarihi',
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _endDate != null ? _formatDate(_endDate!) : '',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (_selectedType != null) {
                context.read<TransactionProvider>().filterByType(_selectedType!);
              }
              if (_startDate != null && _endDate != null) {
                context.read<TransactionProvider>().filterByDateRange(_startDate!, _endDate!);
              }
              Navigator.pop(context);
            },
            child: Text('Uygula'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    final formKey = GlobalKey<FormState>();
    int? productId;
    String? type;
    int? quantity;
    String? reason;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İşlem Ekle'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Ürün ID',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ürün ID gerekli';
                  }
                  return null;
                },
                onSaved: (value) {
                  productId = int.tryParse(value!);
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'İşlem Türü',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'İşlem türü gerekli';
                  }
                  return null;
                },
                items: ['in', 'out', 'adjustment'].map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(_getTransactionTypeName(t)),
                  );
                }).toList(),
                onChanged: (value) {
                  type = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Miktar',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen miktar girin';
                  }
                  return null;
                },
                onSaved: (value) {
                  quantity = int.tryParse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Notlar',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Not gerekli';
                  }
                  return null;
                },
                onSaved: (value) {
                  reason = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                
                final transaction = Transaction(
                  productId: productId!,
                  type: type!,
                  quantity: quantity!,
                  unitPrice: 0.0,
                  notes: reason!,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await context.read<TransactionProvider>().addTransaction(transaction);
                Navigator.pop(context);
              }
            },
            child: Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  String _getTransactionTypeName(String type) {
    switch (type) {
      case 'in':
        return 'Stok Girişi';
      case 'out':
        return 'Stok Çıkışı';
      case 'adjustment':
        return 'Stok Düzeltmesi';
      default:
        return 'Bilinmeyen';
    }
  }
}