import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/products_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/add_edit_product_screen.dart';
import '../screens/stock_transaction_screen.dart';
import '../screens/barcode_scanner_screen.dart';
import '../screens/planning_screen.dart';
import '../screens/machines_screen.dart';
import '../screens/admin_panel_screen.dart';
import '../screens/user_settings_screen.dart';

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        width: themeProvider.isSidebarOpen ? 280 : 0,
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: 280,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            opacity: themeProvider.isSidebarOpen ? 1.0 : 0.0,
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                boxShadow: themeProvider.isSidebarOpen ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ] : [],
              ),
              child: themeProvider.isSidebarOpen
                  ? Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF3B82F6), const Color(0xFF1E40AF)]
                            : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.inventory_2_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            IconButton(
                              onPressed: themeProvider.closeSidebar,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Stok Takibi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Envanter Yönetim Sistemi',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.dashboard_rounded,
                          title: 'Ana Sayfa',
                          onTap: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                            themeProvider.closeSidebar();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.inventory_2_rounded,
                          title: 'Ürünler',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ProductsScreen(),
                              ),
                            );
                            themeProvider.closeSidebar();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.add_box_rounded,
                          title: 'Ürün Ekle',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AddEditProductScreen(),
                              ),
                            );
                            themeProvider.closeSidebar();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.qr_code_scanner_rounded,
                          title: 'Barkod Tarayıcı',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const BarcodeScannerScreen(),
                              ),
                            );
                            themeProvider.closeSidebar();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.swap_horiz_rounded,
                          title: 'Stok İşlemleri',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const StockTransactionScreen(
                                transactionType: 'in',
                              ),
                              ),
                            );
                            themeProvider.closeSidebar();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.history_rounded,
                          title: 'İşlem Geçmişi',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const TransactionsScreen(),
                              ),
                            );
                            themeProvider.closeSidebar();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.analytics_rounded,
                          title: 'Raporlar',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ReportsScreen(),
                              ),
                            );
                            themeProvider.closeSidebar();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.calendar_today_rounded,
                          title: 'Planlama',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PlanningScreen(),
                              ),
                            );
                            themeProvider.closeSidebar();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.precision_manufacturing_rounded,
                          title: 'Makineler',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MachinesScreen(),
                              ),
                            );
                            themeProvider.closeSidebar();
                          },
                        ),
                        const Divider(height: 32),
                        _buildMenuItem(
                          context,
                          icon: Icons.admin_panel_settings_rounded,
                          title: 'Admin Paneli',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AdminPanelScreen(),
                              ),
                            );
                            themeProvider.closeSidebar();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.person_rounded,
                          title: 'Kullanıcı Ayarları',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const UserSettingsScreen(),
                              ),
                            );
                            themeProvider.closeSidebar();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.settings_rounded,
                          title: 'Ayarlar',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                            themeProvider.closeSidebar();
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Theme Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: isDark ? Colors.amber : Colors.indigo,
                        ),
                        title: Text(
                          isDark ? 'Açık Tema' : 'Koyu Tema',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Switch(
                          value: isDark,
                          onChanged: (value) => themeProvider.toggleTheme(),
                          activeColor: const Color(0xFF3B82F6),
                        ),
                        onTap: themeProvider.toggleTheme,
                      ),
                    ),
                  ),
                  

                ],
              )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF2563EB).withOpacity(0.1),
          splashColor: isDark
              ? Colors.white.withOpacity(0.2)
              : const Color(0xFF2563EB).withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF374151),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}