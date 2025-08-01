import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';

import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isConnected = false;
  bool _isCheckingConnection = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isCheckingConnection = true;
    });

    try {
      final isConnected = await context.read<ProductProvider>().checkConnection();
      setState(() {
        _isConnected = isConnected;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    } finally {
      setState(() {
        _isCheckingConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tema Ayarları
          _buildThemeSettings(),
          
          const SizedBox(height: 24),
          
          // Bağlantı Durumu
          _buildConnectionStatus(),
          
          const SizedBox(height: 24),
          
          // Veri Yönetimi
          _buildDataManagement(),
          
          const SizedBox(height: 24),
          
          // Uygulama Bilgileri
          _buildAppInfo(),
        ],
      ),
    );
  }



  Widget _buildThemeSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema Ayarları',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return SwitchListTile(
                  title: Text('Koyu Tema'),
                  subtitle: Text('Koyu modu etkinleştir'),
                  value: themeProvider.isDarkMode,
                  onChanged: (bool value) {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bağlantı Durumu',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isConnected ? 'Bağlı' : 'Bağlantı Yok',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        _isConnected 
                            ? 'Sunucuya bağlı'
                            : 'Sunucuya bağlanılamıyor',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isCheckingConnection)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: _checkConnection,
                    icon: const Icon(Icons.refresh),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagement() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Veri Yönetimi',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text('Verileri Yenile'),
              subtitle: Text('Tüm verileri sunucudan yeniden yükle'),
              onTap: _refreshAllData,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.backup),
              title: Text('Veri Yedekle'),
              subtitle: Text('Verileri yerel dosyaya kaydet'),
              onTap: _showBackupDialog,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text('Veri Geri Yükle'),
              subtitle: Text('Yedeği geri yükle'),
              onTap: _showRestoreDialog,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(
                'Tüm Verileri Sil',
                style: const TextStyle(color: Colors.red),
              ),
              subtitle: Text('Tüm ürün ve işlem verilerini sil'),
              onTap: _showDeleteAllDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uygulama Bilgileri',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text('Sürüm'),
              subtitle: const Text('1.0.0'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.developer_mode),
              title: Text('Geliştirici'),
              subtitle: Text('Stok Takibi Ekibi'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: Text('Yardım'),
              subtitle: Text('Uygulama kullanımı hakkında bilgi'),
              onTap: _showHelpDialog,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: Text('Gizlilik Politikası'),
              subtitle: Text('Veri gizliliği ve güvenlik'),
              onTap: _showPrivacyDialog,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshAllData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('Veriler yenileniyor...'),
          ],
        ),
      ),
    );

    try {
      await Future.wait([
        context.read<ProductProvider>().loadProducts(),
        context.read<TransactionProvider>().loadTransactions(),
      ]);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veriler başarıyla yenilendi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Veri Yedekleme'),
        content: Text('Bu özellik geliştirme aşamasındadır'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Veri Geri Yükleme'),
        content: Text('Veri geri yükleme özelliği geliştirme aşamasındadır'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tüm Verileri Sil'),
        content: Text('Tüm veriler kalıcı olarak silinecek. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete all data
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yardım'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kullanım Kılavuzu',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text('Ana Sayfa:'),
              Text('Genel özet ve hızlı işlemler'),
              const SizedBox(height: 12),
              Text('Ürünler:'),
              Text('Ürün ekleme, düzenleme ve görüntüleme'),
              const SizedBox(height: 12),
              Text('İşlemler:'),
              Text('Stok giriş/çıkış işlemleri'),
              const SizedBox(height: 12),
              Text('Raporlar:'),
              Text('Detaylı analiz ve raporlar'),
              const SizedBox(height: 12),
              Text('Ayarlar:'),
              Text('Uygulama ayarları ve konfigürasyon'),
              const SizedBox(height: 16),
              Text(
                'Destek için geliştirici ile iletişime geçin',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gizlilik Politikası'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Veri Toplama',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text('Bu uygulama sadece yerel verileri kullanır ve kişisel bilgilerinizi toplamaz.'),
              const SizedBox(height: 16),
              Text(
                'Veri Güvenliği',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text('Tüm verileriniz cihazınızda güvenli bir şekilde saklanır.'),
              const SizedBox(height: 16),
              Text(
                'İletişim',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text('Sorularınız için geliştirici ekibi ile iletişime geçebilirsiniz.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }
}