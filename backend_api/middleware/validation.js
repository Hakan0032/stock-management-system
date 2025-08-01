const { body, param, query } = require('express-validator');
const { StockTransaction } = require('../models');

// Ürün validation kuralları
const productValidation = {
  create: [
    body('barcode')
      .notEmpty()
      .withMessage('Barkod gereklidir')
      .isLength({ min: 1, max: 50 })
      .withMessage('Barkod 1-50 karakter arasında olmalıdır')
      .trim(),
    
    body('name')
      .notEmpty()
      .withMessage('Ürün adı gereklidir')
      .isLength({ min: 2, max: 255 })
      .withMessage('Ürün adı 2-255 karakter arasında olmalıdır')
      .trim(),
    
    body('description')
      .optional()
      .isLength({ max: 1000 })
      .withMessage('Açıklama en fazla 1000 karakter olabilir')
      .trim(),
    
    body('category')
      .notEmpty()
      .withMessage('Kategori gereklidir')
      .isLength({ min: 2, max: 100 })
      .withMessage('Kategori 2-100 karakter arasında olmalıdır')
      .trim(),
    
    body('price')
      .isFloat({ min: 0 })
      .withMessage('Fiyat 0 veya pozitif bir sayı olmalıdır')
      .toFloat(),
    
    body('current_stock')
      .optional()
      .isInt({ min: 0 })
      .withMessage('Mevcut stok 0 veya pozitif bir tamsayı olmalıdır')
      .toInt(),
    
    body('min_stock_level')
      .optional()
      .isInt({ min: 0 })
      .withMessage('Minimum stok seviyesi 0 veya pozitif bir tamsayı olmalıdır')
      .toInt(),
    
    body('unit')
      .optional()
      .isLength({ min: 1, max: 20 })
      .withMessage('Birim 1-20 karakter arasında olmalıdır')
      .trim()
  ],
  
  update: [
    param('id')
      .isInt({ min: 1 })
      .withMessage('Geçerli bir ürün ID\'si gereklidir'),
    
    body('barcode')
      .optional()
      .isLength({ min: 1, max: 50 })
      .withMessage('Barkod 1-50 karakter arasında olmalıdır')
      .trim(),
    
    body('name')
      .optional()
      .isLength({ min: 2, max: 255 })
      .withMessage('Ürün adı 2-255 karakter arasında olmalıdır')
      .trim(),
    
    body('description')
      .optional()
      .isLength({ max: 1000 })
      .withMessage('Açıklama en fazla 1000 karakter olabilir')
      .trim(),
    
    body('category')
      .optional()
      .isLength({ min: 2, max: 100 })
      .withMessage('Kategori 2-100 karakter arasında olmalıdır')
      .trim(),
    
    body('price')
      .optional()
      .isFloat({ min: 0 })
      .withMessage('Fiyat 0 veya pozitif bir sayı olmalıdır')
      .toFloat(),
    
    body('current_stock')
      .optional()
      .isInt({ min: 0 })
      .withMessage('Mevcut stok 0 veya pozitif bir tamsayı olmalıdır')
      .toInt(),
    
    body('min_stock_level')
      .optional()
      .isInt({ min: 0 })
      .withMessage('Minimum stok seviyesi 0 veya pozitif bir tamsayı olmalıdır')
      .toInt(),
    
    body('unit')
      .optional()
      .isLength({ min: 1, max: 20 })
      .withMessage('Birim 1-20 karakter arasında olmalıdır')
      .trim()
  ],
  
  getById: [
    param('id')
      .isInt({ min: 1 })
      .withMessage('Geçerli bir ürün ID\'si gereklidir')
  ],
  
  getByBarcode: [
    param('barcode')
      .isLength({ min: 1, max: 50 })
      .withMessage('Barkod 1-50 karakter arasında olmalıdır')
      .trim()
  ],
  
  list: [
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Sayfa numarası 1 veya daha büyük olmalıdır')
      .toInt(),
    
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit 1-100 arasında olmalıdır')
      .toInt(),
    
    query('search')
      .optional()
      .isLength({ min: 1, max: 255 })
      .withMessage('Arama terimi 1-255 karakter arasında olmalıdır')
      .trim(),
    
    query('category')
      .optional()
      .isLength({ min: 1, max: 100 })
      .withMessage('Kategori 1-100 karakter arasında olmalıdır')
      .trim(),
    
    query('sortBy')
      .optional()
      .isIn(['name', 'barcode', 'category', 'price', 'current_stock', 'created_at', 'updated_at'])
      .withMessage('Geçersiz sıralama alanı'),
    
    query('sortOrder')
      .optional()
      .isIn(['ASC', 'DESC', 'asc', 'desc'])
      .withMessage('Sıralama yönü ASC veya DESC olmalıdır'),
    
    query('lowStock')
      .optional()
      .isBoolean()
      .withMessage('lowStock boolean değer olmalıdır')
  ]
};

// Stok işlemi validation kuralları
const transactionValidation = {
  create: [
    body('product_id')
      .isInt({ min: 1 })
      .withMessage('Geçerli bir ürün ID\'si gereklidir')
      .toInt(),
    
    body('quantity')
      .isInt({ min: 1 })
      .withMessage('Miktar 1 veya daha büyük bir tamsayı olmalıdır')
      .toInt(),
    
    body('transaction_type')
      .isIn(Object.values(StockTransaction.TRANSACTION_TYPES))
      .withMessage('Geçersiz işlem türü'),
    
    body('reason')
      .optional()
      .isLength({ max: 255 })
      .withMessage('Sebep en fazla 255 karakter olabilir')
      .trim(),
    
    body('notes')
      .optional()
      .isLength({ max: 1000 })
      .withMessage('Notlar en fazla 1000 karakter olabilir')
      .trim(),
    
    body('transaction_date')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir tarih formatı gereklidir')
      .toDate(),
    
    body('created_by')
      .optional()
      .isLength({ min: 1, max: 100 })
      .withMessage('Oluşturan 1-100 karakter arasında olmalıdır')
      .trim()
  ],
  
  getById: [
    param('id')
      .isInt({ min: 1 })
      .withMessage('Geçerli bir işlem ID\'si gereklidir')
  ],
  
  getByProduct: [
    param('product_id')
      .isInt({ min: 1 })
      .withMessage('Geçerli bir ürün ID\'si gereklidir'),
    
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Sayfa numarası 1 veya daha büyük olmalıdır')
      .toInt(),
    
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit 1-100 arasında olmalıdır')
      .toInt(),
    
    query('start_date')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir başlangıç tarihi formatı gereklidir'),
    
    query('end_date')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir bitiş tarihi formatı gereklidir'),
    
    query('transaction_type')
      .optional()
      .isIn(Object.values(StockTransaction.TRANSACTION_TYPES))
      .withMessage('Geçersiz işlem türü')
  ],
  
  list: [
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Sayfa numarası 1 veya daha büyük olmalıdır')
      .toInt(),
    
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit 1-100 arasında olmalıdır')
      .toInt(),
    
    query('product_id')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Geçerli bir ürün ID\'si gereklidir')
      .toInt(),
    
    query('transaction_type')
      .optional()
      .isIn(Object.values(StockTransaction.TRANSACTION_TYPES))
      .withMessage('Geçersiz işlem türü'),
    
    query('start_date')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir başlangıç tarihi formatı gereklidir'),
    
    query('end_date')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir bitiş tarihi formatı gereklidir'),
    
    query('sortBy')
      .optional()
      .isIn(['transaction_date', 'quantity', 'transaction_type', 'created_at'])
      .withMessage('Geçersiz sıralama alanı'),
    
    query('sortOrder')
      .optional()
      .isIn(['ASC', 'DESC', 'asc', 'desc'])
      .withMessage('Sıralama yönü ASC veya DESC olmalıdır')
  ],
  
  statistics: [
    query('start_date')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir başlangıç tarihi formatı gereklidir'),
    
    query('end_date')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir bitiş tarihi formatı gereklidir'),
    
    query('product_id')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Geçerli bir ürün ID\'si gereklidir')
      .toInt()
  ],
  
  dailySummary: [
    query('date')
      .optional()
      .isDate()
      .withMessage('Geçerli bir tarih formatı gereklidir (YYYY-MM-DD)')
  ]
};

// Genel validation kuralları
const generalValidation = {
  pagination: [
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Sayfa numarası 1 veya daha büyük olmalıdır')
      .toInt(),
    
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit 1-100 arasında olmalıdır')
      .toInt()
  ],
  
  dateRange: [
    query('start_date')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir başlangıç tarihi formatı gereklidir'),
    
    query('end_date')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir bitiş tarihi formatı gereklidir')
  ],
  
  id: [
    param('id')
      .isInt({ min: 1 })
      .withMessage('Geçerli bir ID gereklidir')
  ]
};

// Custom validation middleware'i
const customValidation = {
  // Tarih aralığı kontrolü
  validateDateRange: (req, res, next) => {
    const { start_date, end_date } = req.query;
    
    if (start_date && end_date) {
      const startDate = new Date(start_date);
      const endDate = new Date(end_date);
      
      if (startDate > endDate) {
        return res.status(400).json({
          success: false,
          message: 'Başlangıç tarihi bitiş tarihinden sonra olamaz'
        });
      }
      
      // Maksimum 1 yıllık aralık kontrolü
      const oneYearInMs = 365 * 24 * 60 * 60 * 1000;
      if (endDate - startDate > oneYearInMs) {
        return res.status(400).json({
          success: false,
          message: 'Tarih aralığı en fazla 1 yıl olabilir'
        });
      }
    }
    
    next();
  },
  
  // Stok düzeltmesi için özel validation
  validateStockAdjustment: (req, res, next) => {
    const { transaction_type, quantity } = req.body;
    
    if (transaction_type === StockTransaction.TRANSACTION_TYPES.ADJUSTMENT) {
      if (!quantity || quantity < 0) {
        return res.status(400).json({
          success: false,
          message: 'Stok düzeltmesi için geçerli bir yeni stok miktarı gereklidir'
        });
      }
    }
    
    next();
  },
  
  // Dosya boyutu kontrolü (gelecekte kullanım için)
  validateFileSize: (maxSize = 5 * 1024 * 1024) => {
    return (req, res, next) => {
      if (req.file && req.file.size > maxSize) {
        return res.status(400).json({
          success: false,
          message: `Dosya boyutu ${maxSize / (1024 * 1024)}MB'dan büyük olamaz`
        });
      }
      next();
    };
  }
};

// Makine validation kuralları
const machineValidation = {
  create: [
    body('name')
      .notEmpty()
      .withMessage('Makine adı gereklidir')
      .isLength({ min: 2, max: 255 })
      .withMessage('Makine adı 2-255 karakter arasında olmalıdır')
      .trim(),
    
    body('type')
      .notEmpty()
      .withMessage('Makine türü gereklidir')
      .isLength({ min: 2, max: 100 })
      .withMessage('Makine türü 2-100 karakter arasında olmalıdır')
      .trim(),
    
    body('status')
      .optional()
      .isIn(['active', 'inactive', 'maintenance'])
      .withMessage('Geçersiz makine durumu'),
    
    body('location')
      .optional()
      .isLength({ max: 255 })
      .withMessage('Konum en fazla 255 karakter olabilir')
      .trim(),
    
    body('description')
      .optional()
      .isLength({ max: 1000 })
      .withMessage('Açıklama en fazla 1000 karakter olabilir')
      .trim(),
    
    body('purchaseDate')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir satın alma tarihi formatı gereklidir')
      .toDate(),
    
    body('warrantyExpiry')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir garanti bitiş tarihi formatı gereklidir')
      .toDate(),
    
    body('maintenanceInterval')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Bakım aralığı pozitif bir tamsayı olmalıdır')
      .toInt(),
    
    body('lastMaintenanceDate')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir son bakım tarihi formatı gereklidir')
      .toDate(),
    
    body('nextMaintenanceDate')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir sonraki bakım tarihi formatı gereklidir')
      .toDate()
  ],
  
  update: [
    param('id')
      .isInt({ min: 1 })
      .withMessage('Geçerli bir makine ID\'si gereklidir'),
    
    body('name')
      .optional()
      .isLength({ min: 2, max: 255 })
      .withMessage('Makine adı 2-255 karakter arasında olmalıdır')
      .trim(),
    
    body('type')
      .optional()
      .isLength({ min: 2, max: 100 })
      .withMessage('Makine türü 2-100 karakter arasında olmalıdır')
      .trim(),
    
    body('status')
      .optional()
      .isIn(['active', 'inactive', 'maintenance'])
      .withMessage('Geçersiz makine durumu'),
    
    body('location')
      .optional()
      .isLength({ max: 255 })
      .withMessage('Konum en fazla 255 karakter olabilir')
      .trim(),
    
    body('description')
      .optional()
      .isLength({ max: 1000 })
      .withMessage('Açıklama en fazla 1000 karakter olabilir')
      .trim()
  ]
};

// Planlama validation kuralları
const planningValidation = {
  create: [
    body('title')
      .notEmpty()
      .withMessage('Plan başlığı gereklidir')
      .isLength({ min: 2, max: 255 })
      .withMessage('Plan başlığı 2-255 karakter arasında olmalıdır')
      .trim(),
    
    body('description')
      .optional()
      .isLength({ max: 1000 })
      .withMessage('Açıklama en fazla 1000 karakter olabilir')
      .trim(),
    
    body('category')
      .optional()
      .isLength({ min: 1, max: 100 })
      .withMessage('Kategori 1-100 karakter arasında olmalıdır')
      .trim(),
    
    body('priority')
      .optional()
      .isIn(['low', 'medium', 'high', 'urgent'])
      .withMessage('Geçersiz öncelik seviyesi'),
    
    body('status')
      .optional()
      .isIn(['pending', 'in_progress', 'completed', 'cancelled'])
      .withMessage('Geçersiz plan durumu'),
    
    body('startDate')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir başlangıç tarihi formatı gereklidir')
      .toDate(),
    
    body('endDate')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir bitiş tarihi formatı gereklidir')
      .toDate(),
    
    body('dueDate')
      .optional()
      .isISO8601()
      .withMessage('Geçerli bir teslim tarihi formatı gereklidir')
      .toDate(),
    
    body('assignedTo')
      .optional()
      .isLength({ min: 1, max: 100 })
      .withMessage('Atanan kişi 1-100 karakter arasında olmalıdır')
      .trim(),
    
    body('estimatedHours')
      .optional()
      .isFloat({ min: 0 })
      .withMessage('Tahmini saat pozitif bir sayı olmalıdır')
      .toFloat(),
    
    body('actualHours')
      .optional()
      .isFloat({ min: 0 })
      .withMessage('Gerçek saat pozitif bir sayı olmalıdır')
      .toFloat(),
    
    body('budget')
      .optional()
      .isFloat({ min: 0 })
      .withMessage('Bütçe pozitif bir sayı olmalıdır')
      .toFloat(),
    
    body('actualCost')
      .optional()
      .isFloat({ min: 0 })
      .withMessage('Gerçek maliyet pozitif bir sayı olmalıdır')
      .toFloat(),
    
    body('notes')
      .optional()
      .isLength({ max: 1000 })
      .withMessage('Notlar en fazla 1000 karakter olabilir')
      .trim()
  ],
  
  update: [
    param('id')
      .isInt({ min: 1 })
      .withMessage('Geçerli bir plan ID\'si gereklidir'),
    
    body('title')
      .optional()
      .isLength({ min: 2, max: 255 })
      .withMessage('Plan başlığı 2-255 karakter arasında olmalıdır')
      .trim(),
    
    body('description')
      .optional()
      .isLength({ max: 1000 })
      .withMessage('Açıklama en fazla 1000 karakter olabilir')
      .trim(),
    
    body('category')
      .optional()
      .isLength({ min: 1, max: 100 })
      .withMessage('Kategori 1-100 karakter arasında olmalıdır')
      .trim(),
    
    body('priority')
      .optional()
      .isIn(['low', 'medium', 'high', 'urgent'])
      .withMessage('Geçersiz öncelik seviyesi'),
    
    body('status')
      .optional()
      .isIn(['pending', 'in_progress', 'completed', 'cancelled'])
      .withMessage('Geçersiz plan durumu')
  ]
};

// Validation middleware fonksiyonları
const validateMachine = machineValidation.create;
const validateMachineUpdate = machineValidation.update;
const validatePlanning = planningValidation.create;
const validatePlanningUpdate = planningValidation.update;

module.exports = {
  productValidation,
  transactionValidation,
  machineValidation,
  planningValidation,
  generalValidation,
  customValidation,
  validateMachine,
  validateMachineUpdate,
  validatePlanning,
  validatePlanningUpdate
};