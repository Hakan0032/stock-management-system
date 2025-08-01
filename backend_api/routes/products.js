const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const { productValidation, customValidation } = require('../middleware/validation');

// Ürün rotaları

// GET /api/products - Tüm ürünleri getir
router.get('/', 
  productValidation.list,
  productController.getAllProducts
);

// GET /api/products/categories - Kategorileri getir
router.get('/categories', 
  productController.getCategories
);

// GET /api/products/low-stock - Düşük stoklu ürünleri getir
router.get('/low-stock', 
  productController.getLowStockProducts
);

// GET /api/products/statistics - Ürün istatistikleri
router.get('/statistics', 
  productController.getProductStatistics
);

// GET /api/products/barcode/:barcode - Barkod ile ürün getir
router.get('/barcode/:barcode', 
  productValidation.getByBarcode,
  productController.getProductByBarcode
);

// GET /api/products/:id - ID ile ürün getir
router.get('/:id', 
  productValidation.getById,
  productController.getProductById
);

// POST /api/products - Yeni ürün oluştur
router.post('/', 
  productValidation.create,
  productController.createProduct
);

// PUT /api/products/:id - Ürün güncelle
router.put('/:id', 
  productValidation.update,
  productController.updateProduct
);

// DELETE /api/products/:id - Ürün sil (soft delete)
router.delete('/:id', 
  productValidation.getById,
  productController.deleteProduct
);

module.exports = router;