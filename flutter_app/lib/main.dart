import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart';
import 'providers/product_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/theme_provider.dart';
import 'models/product.dart';

import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/planning_screen.dart';
import 'screens/product_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Web platformu için sqflite_common_ffi_web'i başlat
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  

  
  runApp(const StokTakibiApp());
}

class StokTakibiApp extends StatelessWidget {
  const StokTakibiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Stok Takibi',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/planning': (context) => const PlanningScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/product-detail') {
                final product = settings.arguments as Product;
                return MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}