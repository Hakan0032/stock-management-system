import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/planning.dart';
import '../services/api_service.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'active';
  
  List<Planning> _plannings = [];
  bool _isLoading = false;
  String? _error;

  final Map<String, String> _categoryLabels = {
    'active': 'Aktif Planlar',
    'pending': 'Bekleyen Planlar',
    'completed': 'Tamamlanan Planlar',
  };

  @override
  void initState() {
    super.initState();
    _loadPlannings();
  }

  Future<void> _loadPlannings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final plannings = await ApiService.instance.getAllPlannings();
      setState(() {
        _plannings = plannings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildAddPlanForm(),
            const SizedBox(height: 30),
            _buildCategoryTabs(),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 64, color: Colors.red[400]),
                              const SizedBox(height: 16),
                              Text('Hata: $_error'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadPlannings,
                                child: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        )
                      : _buildPlanningGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planlama Yönetimi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Projelerinizi planlayın ve takip edin',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPlanForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yeni Plan Ekle',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Plan Adı',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6366F1)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6366F1)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6366F1)),
                    ),
                  ),
                  items: _categoryLabels.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _addPlanningItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Oluştur'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _categoryLabels.entries.map((entry) {
          final isSelected = _selectedCategory == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = entry.key;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlanningGrid() {
    final plans = _plannings.where((plan) => plan.status == _selectedCategory).toList();
    
    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Bu kategoride henüz plan bulunmuyor',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'active';
                });
              },
              child: const Text('İlk planınızı oluşturun'),
            ),
          ],
        ),
      );
    }

    return MasonryGridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: plans.length,
      itemBuilder: (context, index) {
        return _buildPlanCard(plans[index]);
      },
    );
  }

  Widget _buildPlanCard(Planning plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deletePlanningItem(plan);
                  } else if (value == 'toggle') {
                    _toggleCompletion(plan);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(plan.status == 'completed' ? 'Tamamlanmadı olarak işaretle' : 'Tamamlandı olarak işaretle'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Sil'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan.description ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          if (plan.materials != null && plan.materials!.isNotEmpty) ...[
            const Text(
              'Malzemeler:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            ...plan.materials!.map((material) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '• ${material['name']} (${material['quantity']})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 16),
                    onPressed: () => _removeMaterial(plan, material),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.red[400],
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddMaterialDialog(plan),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Malzeme Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: plan.status == 'completed' ? Colors.green[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              plan.status == 'completed' ? 'Tamamlandı' : plan.status == 'pending' ? 'Beklemede' : 'Devam Ediyor',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: plan.status == 'completed' ? Colors.green[700] : Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addPlanningItem() async {
    if (_nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      try {
        final newPlanning = Planning(
          title: _nameController.text,
          description: _descriptionController.text,
          status: _selectedCategory,
          materials: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await ApiService.instance.createPlanning(newPlanning);
        _nameController.clear();
        _descriptionController.clear();
        _loadPlannings(); // Refresh the list
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan başarıyla oluşturuldu')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deletePlanningItem(Planning plan) async {
    if (plan.id != null) {
      try {
        await ApiService.instance.deletePlanning(plan.id!);
        _loadPlannings(); // Refresh the list
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan başarıyla silindi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleCompletion(Planning plan) async {
    if (plan.id != null) {
      try {
        String newStatus;
        if (plan.status == 'completed') {
          newStatus = 'active';
        } else {
          newStatus = 'completed';
        }
        
        final updatedPlanning = plan.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        
        await ApiService.instance.updatePlanning(plan.id!, updatedPlanning);
        _loadPlannings(); // Refresh the list
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plan durumu güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddMaterialDialog(Planning plan) {
    showDialog(
      context: context,
      builder: (context) => _AddMaterialDialog(
        onMaterialAdded: (material) async {
          if (plan.id != null) {
            try {
              final updatedMaterials = List<Map<String, dynamic>>.from(plan.materials ?? []);
              updatedMaterials.add({
                'name': material.name,
                'quantity': material.quantity,
              });
              
              final updatedPlanning = plan.copyWith(
                materials: updatedMaterials,
                updatedAt: DateTime.now(),
              );
              
              await ApiService.instance.updatePlanning(plan.id!, updatedPlanning);
              _loadPlannings(); // Refresh the list
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Malzeme başarıyla eklendi')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hata: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _removeMaterial(Planning plan, Map<String, dynamic> material) async {
    if (plan.id != null) {
      try {
        final updatedMaterials = List<Map<String, dynamic>>.from(plan.materials ?? []);
        updatedMaterials.removeWhere((m) => m['name'] == material['name'] && m['quantity'] == material['quantity']);
        
        final updatedPlanning = plan.copyWith(
          materials: updatedMaterials,
          updatedAt: DateTime.now(),
        );
        
        await ApiService.instance.updatePlanning(plan.id!, updatedPlanning);
        _loadPlannings(); // Refresh the list
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Malzeme başarıyla kaldırıldı')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _AddMaterialDialog extends StatefulWidget {
  final Function(({String name, int quantity})) onMaterialAdded;

  const _AddMaterialDialog({required this.onMaterialAdded});

  @override
  State<_AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends State<_AddMaterialDialog> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Malzeme Ekle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _productController,
            decoration: const InputDecoration(
              labelText: 'Ürün Adı',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Miktar',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_productController.text.isNotEmpty && _quantityController.text.isNotEmpty) {
              final quantity = int.tryParse(_quantityController.text) ?? 0;
              if (quantity > 0) {
                widget.onMaterialAdded(
                  (
                    name: _productController.text,
                    quantity: quantity,
                  ),
                );
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}