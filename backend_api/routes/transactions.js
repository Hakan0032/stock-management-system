const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');
const { transactionValidation, customValidation } = require('../middleware/validation');

// Stok işlemi rotaları

// GET /api/transactions - Tüm işlemleri getir
router.get('/', 
  transactionValidation.list,
  customValidation.validateDateRange,
  transactionController.getAllTransactions
);

// GET /api/transactions/types - İşlem türlerini getir
router.get('/types', 
  transactionController.getTransactionTypes
);

// GET /api/transactions/statistics - İşlem istatistikleri
router.get('/statistics', 
  transactionValidation.statistics,
  customValidation.validateDateRange,
  transactionController.getTransactionStatistics
);

// GET /api/transactions/daily-summary - Günlük işlem özeti
router.get('/daily-summary', 
  transactionValidation.dailySummary,
  transactionController.getDailyTransactionSummary
);

// GET /api/transactions/product/:product_id - Ürüne göre işlemleri getir
router.get('/product/:product_id', 
  transactionValidation.getByProduct,
  customValidation.validateDateRange,
  transactionController.getTransactionsByProduct
);

// GET /api/transactions/:id - ID ile işlem getir
router.get('/:id', 
  transactionValidation.getById,
  transactionController.getTransactionById
);

// POST /api/transactions - Yeni stok işlemi oluştur
router.post('/', 
  transactionValidation.create,
  customValidation.validateStockAdjustment,
  transactionController.createTransaction
);

module.exports = router;