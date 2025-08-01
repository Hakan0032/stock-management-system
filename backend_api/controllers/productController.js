const { Product, StockTransaction } = require('../models');
const { Op } = require('sequelize');
const { validationResult } = require('express-validator');

class ProductController {
  // Tüm ürünleri getir
  async getAllProducts(req, res) {
    try {
      const {
        page = 1,
        limit = 50,
        search,
        category,
        sortBy = 'name',
        sortOrder = 'ASC',
        lowStock = false
      } = req.query;

      const offset = (page - 1) * limit;
      let whereClause = { is_active: true };
      
      // Arama filtresi
      if (search) {
        whereClause[Op.or] = [
          { name: { [Op.iLike]: `%${search}%` } },
          { barcode: { [Op.iLike]: `%${search}%` } },
          { category: { [Op.iLike]: `%${search}%` } },
          { description: { [Op.iLike]: `%${search}%` } }
        ];
      }
      
      // Kategori filtresi
      if (category) {
        whereClause.category = category;
      }
      
      // Düşük stok filtresi
      if (lowStock === 'true') {
        whereClause[Op.and] = [
          { current_stock: { [Op.lte]: { [Op.col]: 'min_stock_level' } } }
        ];
      }
      
      const { count, rows } = await Product.findAndCountAll({
        where: whereClause,
        order: [[sortBy, sortOrder.toUpperCase()]],
        limit: parseInt(limit),
        offset: parseInt(offset),
        include: [
          {
            model: StockTransaction,
            as: 'transactions',
            limit: 5,
            order: [['created_at', 'DESC']],
            required: false
          }
        ]
      });
      
      res.json({
        success: true,
        data: {
          products: rows,
          pagination: {
            currentPage: parseInt(page),
            totalPages: Math.ceil(count / limit),
            totalItems: count,
            itemsPerPage: parseInt(limit)
          }
        }
      });
      
    } catch (error) {
      console.error('Get all products error:', error);
      res.status(500).json({
        success: false,
        message: 'Ürünler getirilirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // ID ile ürün getir
  async getProductById(req, res) {
    try {
      const { id } = req.params;
      
      const product = await Product.findOne({
        where: { id, is_active: true },
        include: [
          {
            model: StockTransaction,
            as: 'transactions',
            order: [['created_at', 'DESC']],
            limit: 20
          }
        ]
      });
      
      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Ürün bulunamadı'
        });
      }
      
      res.json({
        success: true,
        data: product
      });
      
    } catch (error) {
      console.error('Get product by ID error:', error);
      res.status(500).json({
        success: false,
        message: 'Ürün getirilirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // Barkod ile ürün getir
  async getProductByBarcode(req, res) {
    try {
      const { barcode } = req.params;
      
      const product = await Product.findByBarcode(barcode);
      
      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Ürün bulunamadı'
        });
      }
      
      res.json({
        success: true,
        data: product
      });
      
    } catch (error) {
      console.error('Get product by barcode error:', error);
      res.status(500).json({
        success: false,
        message: 'Ürün getirilirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // Yeni ürün oluştur
  async createProduct(req, res) {
    try {
      console.log('Received product data:', req.body);
      
      // Validation hatalarını kontrol et
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        console.log('Validation errors:', errors.array());
        return res.status(400).json({
          success: false,
          message: 'Geçersiz veri',
          errors: errors.array()
        });
      }
      
      const {
        barcode,
        name,
        description = '',
        category,
        price,
        current_stock = 0,
        min_stock_level = 0,
        unit = 'adet'
      } = req.body;
      
      // Barkod benzersizliğini kontrol et
      const existingProduct = await Product.findByBarcode(barcode);
      if (existingProduct) {
        return res.status(409).json({
          success: false,
          message: 'Bu barkod zaten kullanılıyor'
        });
      }
      
      const product = await Product.create({
        barcode,
        name,
        description,
        category,
        price: parseFloat(price),
        current_stock: parseInt(current_stock),
        min_stock_level: parseInt(min_stock_level),
        unit
      });
      
      res.status(201).json({
        success: true,
        message: 'Ürün başarıyla oluşturuldu',
        data: product
      });
      
    } catch (error) {
      console.error('Create product error:', error);
      
      if (error.name === 'SequelizeUniqueConstraintError') {
        return res.status(409).json({
          success: false,
          message: 'Bu barkod zaten kullanılıyor'
        });
      }
      
      res.status(500).json({
        success: false,
        message: 'Ürün oluşturulurken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // Ürün güncelle
  async updateProduct(req, res) {
    try {
      // Validation hatalarını kontrol et
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Geçersiz veri',
          errors: errors.array()
        });
      }
      
      const { id } = req.params;
      const updateData = req.body;
      
      const product = await Product.findOne({
        where: { id, is_active: true }
      });
      
      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Ürün bulunamadı'
        });
      }
      
      // Barkod değiştiriliyorsa benzersizliğini kontrol et
      if (updateData.barcode && updateData.barcode !== product.barcode) {
        const existingProduct = await Product.findByBarcode(updateData.barcode);
        if (existingProduct) {
          return res.status(409).json({
            success: false,
            message: 'Bu barkod zaten kullanılıyor'
          });
        }
      }
      
      // Fiyat ve stok değerlerini parse et
      if (updateData.price) {
        updateData.price = parseFloat(updateData.price);
      }
      if (updateData.current_stock !== undefined) {
        updateData.current_stock = parseInt(updateData.current_stock);
      }
      if (updateData.min_stock_level !== undefined) {
        updateData.min_stock_level = parseInt(updateData.min_stock_level);
      }
      
      await product.update(updateData);
      
      res.json({
        success: true,
        message: 'Ürün başarıyla güncellendi',
        data: product
      });
      
    } catch (error) {
      console.error('Update product error:', error);
      
      if (error.name === 'SequelizeUniqueConstraintError') {
        return res.status(409).json({
          success: false,
          message: 'Bu barkod zaten kullanılıyor'
        });
      }
      
      res.status(500).json({
        success: false,
        message: 'Ürün güncellenirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // Ürün sil (soft delete)
  async deleteProduct(req, res) {
    try {
      const { id } = req.params;
      
      const product = await Product.findOne({
        where: { id, is_active: true }
      });
      
      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Ürün bulunamadı'
        });
      }
      
      // İlişkili stok işlemlerini sil
      await StockTransaction.destroy({
        where: { product_id: id }
      });
      
      // Ürünü tamamen sil (hard delete)
      await product.destroy();
      
      res.json({
        success: true,
        message: 'Ürün ve ilişkili veriler başarıyla silindi'
      });
      
    } catch (error) {
      console.error('Delete product error:', error);
      res.status(500).json({
        success: false,
        message: 'Ürün silinirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // Kategorileri getir
  async getCategories(req, res) {
    try {
      const categories = await Product.getCategories();
      
      res.json({
        success: true,
        data: categories
      });
      
    } catch (error) {
      console.error('Get categories error:', error);
      res.status(500).json({
        success: false,
        message: 'Kategoriler getirilirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // Düşük stoklu ürünleri getir
  async getLowStockProducts(req, res) {
    try {
      const products = await Product.findLowStock();
      
      res.json({
        success: true,
        data: products
      });
      
    } catch (error) {
      console.error('Get low stock products error:', error);
      res.status(500).json({
        success: false,
        message: 'Düşük stoklu ürünler getirilirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // Ürün istatistikleri
  async getProductStatistics(req, res) {
    try {
      const statistics = await Product.getStatistics();
      
      res.json({
        success: true,
        data: statistics
      });
      
    } catch (error) {
      console.error('Get product statistics error:', error);
      res.status(500).json({
        success: false,
        message: 'İstatistikler getirilirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
}

module.exports = new ProductController();