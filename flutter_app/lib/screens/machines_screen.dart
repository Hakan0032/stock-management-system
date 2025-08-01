import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../services/api_service.dart';

class MachinesScreen extends StatefulWidget {
  const MachinesScreen({super.key});

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  List<Machine> _machines = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final machines = await ApiService.instance.getAllMachines();
      setState(() {
        _machines = machines;
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
      appBar: AppBar(
        title: Text('Makineler'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMachines,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMachineDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Hata: $_error'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMachines,
                        child: Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Makine Durumu Özeti
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade100, Colors.orange.shade50],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatusCard(
                              'Aktif',
                              _machines.where((m) => m.status == 'active').length.toString(),
                              Colors.green,
                              Icons.check_circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatusCard(
                              'Bakımda',
                              _machines.where((m) => m.status == 'maintenance').length.toString(),
                              Colors.orange,
                              Icons.build,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatusCard(
                              'Pasif',
                              _machines.where((m) => m.status == 'inactive').length.toString(),
                              Colors.red,
                              Icons.cancel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Makine Listesi
                    Expanded(
                      child: _machines.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.precision_manufacturing, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('Henüz makine eklenmemiş'),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _showAddMachineDialog(),
                                    child: Text('İlk Makineyi Ekle'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _machines.length,
                              itemBuilder: (context, index) {
                                final machine = _machines[index];
                                return _MachineCard(
                                  machine: machine,
                                  onTap: () => _showMachineDetails(machine),
                                  onEdit: () => _showEditMachineDialog(machine),
                                  onDelete: () => _deleteMachine(machine),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatusCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMachineDialog() {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isLoading = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Yeni Makine Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Makine Adı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: typeController,
                decoration: InputDecoration(
                  labelText: 'Makine Türü',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Konum',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (nameController.text.isNotEmpty && typeController.text.isNotEmpty) {
                  setDialogState(() {
                    isLoading = true;
                  });
                  
                  try {
                    final newMachine = Machine(
                      name: nameController.text,
                      type: typeController.text,
                      status: 'active',
                      location: locationController.text.isEmpty ? null : locationController.text,
                      description: descriptionController.text.isEmpty ? null : descriptionController.text,
                    );
                    
                    await ApiService.instance.createMachine(newMachine);
                    Navigator.pop(context);
                    _loadMachines(); // Refresh the list
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Makine başarıyla eklendi')),
                    );
                  } catch (e) {
                    setDialogState(() {
                      isLoading = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: isLoading 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMachineDetails(Machine machine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(machine.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tür', machine.type),
            _buildDetailRow('Durum', _getStatusText(machine.status)),
            if (machine.location != null) _buildDetailRow('Konum', machine.location!),
            if (machine.description != null) _buildDetailRow('Açıklama', machine.description!),
            if (machine.lastMaintenanceDate != null) 
              _buildDetailRow('Son Bakım', _formatDate(machine.lastMaintenanceDate!)),
            if (machine.nextMaintenanceDate != null) 
              _buildDetailRow('Sonraki Bakım', _formatDate(machine.nextMaintenanceDate!)),
            if (machine.purchaseDate != null) 
              _buildDetailRow('Satın Alma', _formatDate(machine.purchaseDate!)),
            if (machine.warrantyEndDate != null) 
              _buildDetailRow('Garanti Bitiş', _formatDate(machine.warrantyEndDate!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditMachineDialog(Machine machine) {
    final nameController = TextEditingController(text: machine.name);
    final typeController = TextEditingController(text: machine.type);
    final locationController = TextEditingController(text: machine.location ?? '');
    final descriptionController = TextEditingController(text: machine.description ?? '');
    String selectedStatus = machine.status;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Makineyi Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Makine Adı',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: 'Makine Türü',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Konum',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Durum',
                    border: OutlineInputBorder(),
                  ),
                  items: ['active', 'maintenance', 'inactive'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getStatusText(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (nameController.text.isNotEmpty && typeController.text.isNotEmpty) {
                  setDialogState(() {
                    isLoading = true;
                  });
                  
                  try {
                    final updatedMachine = Machine(
                      id: machine.id,
                      name: nameController.text,
                      type: typeController.text,
                      status: selectedStatus,
                      location: locationController.text.isEmpty ? null : locationController.text,
                      description: descriptionController.text.isEmpty ? null : descriptionController.text,
                      lastMaintenanceDate: machine.lastMaintenanceDate,
                      nextMaintenanceDate: machine.nextMaintenanceDate,
                      purchaseDate: machine.purchaseDate,
                      warrantyEndDate: machine.warrantyEndDate,
                      createdAt: machine.createdAt,
                      updatedAt: DateTime.now(),
                    );
                    
                    await ApiService.instance.updateMachine(machine.id!, updatedMachine);
                    Navigator.pop(context);
                    _loadMachines(); // Refresh the list
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Makine başarıyla güncellendi')),
                    );
                  } catch (e) {
                    setDialogState(() {
                      isLoading = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: isLoading 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMachine(Machine machine) {
    bool isLoading = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Makineyi Sil'),
          content: Text('${machine.name} makinesini silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (machine.id != null) {
                  setDialogState(() {
                    isLoading = true;
                  });
                  
                  try {
                    await ApiService.instance.deleteMachine(machine.id!);
                    Navigator.pop(context);
                    _loadMachines(); // Refresh the list
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Makine başarıyla silindi')),
                    );
                  } catch (e) {
                    setDialogState(() {
                      isLoading = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: isLoading 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Sil'),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'maintenance':
        return 'Bakımda';
      case 'inactive':
        return 'Pasif';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _MachineCard extends StatelessWidget {
  final Machine machine;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MachineCard({
    required this.machine,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    switch (machine.status) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'maintenance':
        statusColor = Colors.orange;
        statusIcon = Icons.build;
        break;
      case 'inactive':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      machine.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            const SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    machine.type,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (machine.location != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      machine.location!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              if (machine.nextMaintenanceDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Sonraki Bakım: ${_formatDate(machine.nextMaintenanceDate!)}',
                      style: TextStyle(
                        color: machine.nextMaintenanceDate!.isBefore(DateTime.now().add(Duration(days: 7)))
                            ? Colors.red
                            : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}