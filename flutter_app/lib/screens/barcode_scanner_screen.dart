import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  String? scannedCode;
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barkod Tara'),
        actions: [
          IconButton(
            icon: Icon(isScanning ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (isScanning) {
                controller.stop();
              } else {
                controller.start();
              }
              setState(() {
                isScanning = !isScanning;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () async {
              await controller.toggleTorch();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: controller,
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (scannedCode != null)
                    Text(
                      'Taranan Kod: $scannedCode',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Barkodu görüş alanına getirin',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && isScanning) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          scannedCode = barcode.rawValue;
          isScanning = false;
        });
        controller.stop();
        _handleScannedCode(barcode.rawValue!);
      }
    }
  }

  void _handleScannedCode(String code) async {
    final productProvider = context.read<ProductProvider>();
    
    // Barkoda göre ürün ara
    final product = productProvider.products.firstWhere(
      (p) => p.barcode == code,
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
      // Ürün bulundu, detay sayfasına git
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      ).then((_) {
        // Geri dönüldüğünde taramaya devam et
        setState(() {
          isScanning = true;
          scannedCode = null;
        });
        controller.start();
      });
    } else {
      // Ürün bulunamadı
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ürün Bulunamadı'),
          content: Text('Barkod "$code" ile eşleşen ürün bulunamadı.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isScanning = true;
                  scannedCode = null;
                });
                controller.start();
              },
              child: Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}