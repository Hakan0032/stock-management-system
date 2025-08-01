class Planning {
  final int? id;
  final String title;
  final String? description;
  final String category;
  final String priority;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? assignedTo;
  final double? estimatedHours;
  final double? actualHours;
  final double? budget;
  final double? actualCost;
  final String? notes;
  final List<String> tags;
  final List<Map<String, dynamic>> materials;
  final List<Map<String, dynamic>> attachments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Planning({
    this.id,
    required this.title,
    this.description,
    this.category = 'Genel',
    this.priority = 'medium',
    this.status = 'pending',
    this.startDate,
    this.endDate,
    this.dueDate,
    this.completedAt,
    this.assignedTo,
    this.estimatedHours,
    this.actualHours,
    this.budget,
    this.actualCost,
    this.notes,
    this.tags = const [],
    this.materials = const [],
    this.attachments = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Planning.fromJson(Map<String, dynamic> json) {
    return Planning(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'] ?? 'Genel',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date']) 
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      assignedTo: json['assigned_to'],
      estimatedHours: json['estimated_hours']?.toDouble(),
      actualHours: json['actual_hours']?.toDouble(),
      budget: json['budget']?.toDouble(),
      actualCost: json['actual_cost']?.toDouble(),
      notes: json['notes'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : [],
      materials: json['materials'] != null 
          ? List<Map<String, dynamic>>.from(json['materials']) 
          : [],
      attachments: json['attachments'] != null 
          ? List<Map<String, dynamic>>.from(json['attachments']) 
          : [],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'assigned_to': assignedTo,
      'estimated_hours': estimatedHours,
      'actual_hours': actualHours,
      'budget': budget,
      'actual_cost': actualCost,
      'notes': notes,
      'tags': tags,
      'materials': materials,
      'attachments': attachments,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Planning copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueDate,
    DateTime? completedAt,
    String? assignedTo,
    double? estimatedHours,
    double? actualHours,
    double? budget,
    double? actualCost,
    String? notes,
    List<String>? tags,
    List<Map<String, dynamic>>? materials,
    List<Map<String, dynamic>>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Planning(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      budget: budget ?? this.budget,
      actualCost: actualCost ?? this.actualCost,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      materials: materials ?? this.materials,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}