const { StockTransaction, Product } = require('../models');
const { Op } = require('sequelize');
const { validationResult } = require('express-validator');

class TransactionController {
  // Tüm işlemleri getir
  async getAllTransactions(req, res) {
    try {
      const {
        page = 1,
        limit = 50,
        product_id,
        transaction_type,
        start_date,
        end_date,
        sortBy = 'created_at',
        sortOrder = 'DESC'
      } = req.query;

      const offset = (page - 1) * limit;
      let whereClause = {};
      
      // Ürün filtresi
      if (product_id) {
        whereClause.product_id = product_id;
      }
      
      // İşlem türü filtresi
      if (transaction_type) {
        whereClause.transaction_type = transaction_type;
      }
      
      // Tarih aralığı filtresi
      if (start_date || end_date) {
        whereClause.transaction_date = {};
        if (start_date) {
          whereClause.transaction_date[Op.gte] = new Date(start_date);
        }
        if (end_date) {
          whereClause.transaction_date[Op.lte] = new Date(end_date);
        }
      }
      
      const { count, rows } = await StockTransaction.findAndCountAll({
        where: whereClause,
        order: [[sortBy, sortOrder.toUpperCase()]],
        limit: parseInt(limit),
        offset: parseInt(offset),
        include: [
          {
            model: Product,
            as: 'product',
            attributes: ['id', 'name', 'barcode', 'category', 'unit']
          }
        ]
      });
      
      res.json({
        success: true,
        data: {
          transactions: rows,
          pagination: {
            currentPage: parseInt(page),
            totalPages: Math.ceil(count / limit),
            totalItems: count,
            itemsPerPage: parseInt(limit)
          }
        }
      });
      
    } catch (error) {
      console.error('Get all transactions error:', error);
      res.status(500).json({
        success: false,
        message: 'İşlemler getirilirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // ID ile işlem getir
  async getTransactionById(req, res) {
    try {
      const { id } = req.params;
      
      const transaction = await StockTransaction.findByPk(id, {
        include: [
          {
            model: Product,
            as: 'product',
            attributes: ['id', 'name', 'barcode', 'category', 'unit', 'current_stock']
          }
        ]
      });
      
      if (!transaction) {
        return res.status(404).json({
          success: false,
          message: 'İşlem bulunamadı'
        });
      }
      
      res.json({
        success: true,
        data: transaction
      });
      
    } catch (error) {
      console.error('Get transaction by ID error:', error);
      res.status(500).json({
        success: false,
        message: 'İşlem getirilirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // Yeni stok işlemi oluştur
  async createTransaction(req, res) {
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
      
      const {
        product_id,
        quantity,
        transaction_type,
        reason = '',
        notes = '',
        transaction_date = new Date(),
        created_by = 'system'
      } = req.body;
      
      // Ürünün varlığını kontrol et
      const product = await Product.findOne({
        where: { id: product_id, is_active: true }
      });
      
      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Ürün bulunamadı'
        });
      }
      
      // Stok çıkışı için yeterli stok kontrolü
      if (transaction_type === StockTransaction.TRANSACTION_TYPES.STOCK_OUT) {
        if (product.current_stock < quantity) {
          return res.status(400).json({
            success: false,
            message: `Yetersiz stok! Mevcut stok: ${product.current_stock} ${product.unit}`
          });
        }
      }
      
      // Önceki stok miktarını kaydet
      const previousStock = product.current_stock;
      
      // Yeni stok miktarını hesapla
      let newStock;
      switch (transaction_type) {
        case StockTransaction.TRANSACTION_TYPES.STOCK_IN:
          newStock = previousStock + parseInt(quantity);
          break;
        case StockTransaction.TRANSACTION_TYPES.STOCK_OUT:
          newStock = previousStock - parseInt(quantity);
          break;
        case StockTransaction.TRANSACTION_TYPES.ADJUSTMENT:
          newStock = parseInt(quantity); // Düzeltmede quantity yeni stok miktarıdır
          break;
        default:
          return res.status(400).json({
            success: false,
            message: 'Geçersiz işlem türü'
          });
      }
      
      // Negatif stok kontrolü
      if (newStock < 0) {
        return res.status(400).json({
          success: false,
          message: 'Stok miktarı negatif olamaz'
        });
      }
      
      // İşlemi oluştur
      const transaction = await StockTransaction.create({
        product_id,
        quantity: transaction_type === StockTransaction.TRANSACTION_TYPES.ADJUSTMENT 
          ? Math.abs(newStock - previousStock) 
          : parseInt(quantity),
        transaction_type,
        reason,
        notes,
        previous_stock: previousStock,
        new_stock: newStock,
        transaction_date: new Date(transaction_date),
        created_by
      });
      
      // Ürünün stok miktarını güncelle
      await product.update({ current_stock: newStock });
      
      // İşlemi ürün bilgileriyle birlikte getir
      const createdTransaction = await StockTransaction.findByPk(transaction.id, {
        include: [
          {
            model: Product,
            as: 'product',
            attributes: ['id', 'name', 'barcode', 'category', 'unit', 'current_stock']
          }
        ]
      });
      
      res.status(201).json({
        success: true,
        message: 'Stok işlemi başarıyla oluşturuldu',
        data: createdTransaction
      });
      
    } catch (error) {
      console.error('Create transaction error:', error);
      res.status(500).json({
        success: false,
        message: 'Stok işlemi oluşturulurken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // Ürüne göre işlemleri getir
  async getTransactionsByProduct(req, res) {
    try {
      const { product_id } = req.params;
      const {
        page = 1,
        limit = 20,
        start_date,
        end_date,
        transaction_type
      } = req.query;
      
      const offset = (page - 1) * limit;
      let whereClause = { product_id };
      
      // İşlem türü filtresi
      if (transaction_type) {
        whereClause.transaction_type = transaction_type;
      }
      
      // Tarih aralığı filtresi
      if (start_date || end_date) {
        whereClause.transaction_date = {};
        if (start_date) {
          whereClause.transaction_date[Op.gte] = new Date(start_date);
        }
        if (end_date) {
          whereClause.transaction_date[Op.lte] = new Date(end_date);
        }
      }
      
      const { count, rows } = await StockTransaction.findAndCountAll({
        where: whereClause,
        order: [['transaction_date', 'DESC']],
        limit: parseInt(limit),
        offset: parseInt(offset),
        include: [
          {
            model: Product,
            as: 'product',
            attributes: ['id', 'name', 'barcode', 'category', 'unit']
          }
        ]
      });
      
      res.json({
        success: true,
        data: {
          transactions: rows,
          pagination: {
            currentPage: parseInt(page),
            totalPages: Math.ceil(count / limit),
            totalItems: count,
            itemsPerPage: parseInt(limit)
          }
        }
      });
      
    } catch (error) {
      console.error('Get transactions by product error:', error);
      res.status(500).json({
        success: false,
        message: 'Ürün işlemleri getirilirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // İşlem istatistikleri
  async getTransactionStatistics(req, res) {
    try {
      const {
        start_date,
        end_date,
        product_id
      } = req.query;
      
      let whereClause = {};
      
      // Ürün filtresi
      if (product_id) {
        whereClause.product_id = product_id;
      }
      
      // Tarih aralığı filtresi
      if (start_date || end_date) {
        whereClause.transaction_date = {};
        if (start_date) {
          whereClause.transaction_date[Op.gte] = new Date(start_date);
        }
        if (end_date) {
          whereClause.transaction_date[Op.lte] = new Date(end_date);
        }
      }
      
      const statistics = await StockTransaction.getStatistics(whereClause);
      
      res.json({
        success: true,
        data: statistics
      });
      
    } catch (error) {
      console.error('Get transaction statistics error:', error);
      res.status(500).json({
        success: false,
        message: 'İşlem istatistikleri getirilirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // İşlem türlerini getir
  async getTransactionTypes(req, res) {
    try {
      const types = Object.values(StockTransaction.TRANSACTION_TYPES).map(type => ({
        value: type,
        label: this.getTransactionTypeLabel(type)
      }));
      
      res.json({
        success: true,
        data: types
      });
      
    } catch (error) {
      console.error('Get transaction types error:', error);
      res.status(500).json({
        success: false,
        message: 'İşlem türleri getirilirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  // İşlem türü etiketini getir
  getTransactionTypeLabel(type) {
    const labels = {
      [StockTransaction.TRANSACTION_TYPES.STOCK_IN]: 'Stok Girişi',
      [StockTransaction.TRANSACTION_TYPES.STOCK_OUT]: 'Stok Çıkışı',
      [StockTransaction.TRANSACTION_TYPES.ADJUSTMENT]: 'Stok Düzeltmesi'
    };
    
    return labels[type] || type;
  }
  
  // Günlük işlem özeti
  async getDailyTransactionSummary(req, res) {
    try {
      const { date = new Date().toISOString().split('T')[0] } = req.query;
      
      const startOfDay = new Date(date);
      startOfDay.setHours(0, 0, 0, 0);
      
      const endOfDay = new Date(date);
      endOfDay.setHours(23, 59, 59, 999);
      
      const transactions = await StockTransaction.findAll({
        where: {
          transaction_date: {
            [Op.between]: [startOfDay, endOfDay]
          }
        },
        include: [
          {
            model: Product,
            as: 'product',
            attributes: ['id', 'name', 'barcode', 'category']
          }
        ],
        order: [['transaction_date', 'DESC']]
      });
      
      // İstatistikleri hesapla
      const summary = {
        date,
        total_transactions: transactions.length,
        stock_in_count: transactions.filter(t => t.transaction_type === StockTransaction.TRANSACTION_TYPES.STOCK_IN).length,
        stock_out_count: transactions.filter(t => t.transaction_type === StockTransaction.TRANSACTION_TYPES.STOCK_OUT).length,
        adjustment_count: transactions.filter(t => t.transaction_type === StockTransaction.TRANSACTION_TYPES.ADJUSTMENT).length,
        total_stock_in: transactions
          .filter(t => t.transaction_type === StockTransaction.TRANSACTION_TYPES.STOCK_IN)
          .reduce((sum, t) => sum + t.quantity, 0),
        total_stock_out: transactions
          .filter(t => t.transaction_type === StockTransaction.TRANSACTION_TYPES.STOCK_OUT)
          .reduce((sum, t) => sum + t.quantity, 0),
        transactions: transactions
      };
      
      res.json({
        success: true,
        data: summary
      });
      
    } catch (error) {
      console.error('Get daily transaction summary error:', error);
      res.status(500).json({
        success: false,
        message: 'Günlük işlem özeti getirilirken hata oluştu',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
}

module.exports = new TransactionController();