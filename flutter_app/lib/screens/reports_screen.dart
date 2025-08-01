import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/product_provider.dart';
import '../models/stock_transaction.dart';
import '../l10n/app_localizations.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'daily';
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatistics();
    });
  }

  Future<void> _loadStatistics() async {
    final transactionProvider = context.read<TransactionProvider>();
    final productProvider = context.read<ProductProvider>();
    
    await Future.wait([
      transactionProvider.loadTransactions(),
      productProvider.loadProducts(),
    ]);
    
    final stats = await productProvider.getStatistics();
    setState(() {
      _statistics = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raporlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dönem Seçici
              _buildPeriodSelector(),
              
              const SizedBox(height: 24),
              
              // Genel İstatistikler
              _buildGeneralStats(),
              
              const SizedBox(height: 24),
              
              // İşlem İstatistikleri
              _buildTransactionStats(),
              
              const SizedBox(height: 24),
              
              // Stok Durumu
              _buildStockStatus(),
              
              const SizedBox(height: 24),
              
              // En Çok İşlem Gören Ürünler
              _buildTopProducts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rapor Dönemi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'daily',
                  label: Text('Günlük'),
                ),
                ButtonSegment(
                  value: 'weekly',
                  label: Text('Haftalık'),
                ),
                ButtonSegment(
                  value: 'monthly',
                  label: Text('Aylık'),
                ),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _selectedPeriod = selection.first;
                });
                _loadStatistics();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Genel İstatistikler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Toplam Ürün',
                    '${_statistics['totalProducts'] ?? 0}',
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Düşük Stok',
                    '${_statistics['lowStockProducts'] ?? 0}',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Toplam Değer',
                    '₺${(_statistics['totalValue'] ?? 0).toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Toplam İşlem',
                    '${_statistics['totalTransactions'] ?? 0}',
                    Icons.swap_horiz,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionStats() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final stats = provider.getStatistics();
        final periodStats = stats[_selectedPeriod] ?? {};
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getPeriodName(_selectedPeriod)} İşlem İstatistikleri',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Stok Girişi',
                        '${periodStats['stockIn'] ?? 0}',
                        Icons.add_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Stok Çıkışı',
                        '${periodStats['stockOut'] ?? 0}',
                        Icons.remove_circle,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Düzeltme',
                        '${periodStats['adjustment'] ?? 0}',
                        Icons.edit,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockStatus() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final lowStockProducts = provider.lowStockProducts;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stok Durumu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (lowStockProducts.isEmpty)
                  const Text('Tüm ürünler yeterli stok seviyesinde.')
                else
                  Column(
                    children: lowStockProducts.take(5).map((product) {
                      return ListTile(
                        leading: const Icon(
                          Icons.warning,
                          color: Colors.orange,
                        ),
                        title: Text(product.name),
                        subtitle: Text('Mevcut: ${product.currentStock}'),
                        trailing: Text(
                          'Min: ${product.minStockLevel}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                if (lowStockProducts.length > 5)
                  TextButton(
                    onPressed: () {
                      // Tüm düşük stoklu ürünleri göster
                    },
                    child: Text('${lowStockProducts.length - 5} ürün daha...'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopProducts() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // En çok işlem gören ürünleri hesapla
        final productTransactionCount = <int, int>{};
        
        for (final transaction in provider.transactions) {
          productTransactionCount[transaction.productId] = 
              (productTransactionCount[transaction.productId] ?? 0) + 1;
        }
        
        final sortedProducts = productTransactionCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'En Çok İşlem Gören Ürünler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (sortedProducts.isEmpty)
                  Text('İşlem bulunamadı')
                else
                  Column(
                    children: sortedProducts.take(5).map((entry) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${sortedProducts.indexOf(entry) + 1}'),
                        ),
                        title: Text('Ürün ID ${entry.key}'),
                        trailing: Text(
                          '${entry.value} işlem',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPeriodName(String period) {
    switch (period) {
      case 'daily':
        return 'Günlük';
      case 'weekly':
        return 'Haftalık';
      case 'monthly':
        return 'Aylık';
      default:
        return 'Günlük';
    }
  }
}