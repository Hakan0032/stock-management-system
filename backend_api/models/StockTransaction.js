const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

// Transaction types enum
const TRANSACTION_TYPES = {
  STOCK_IN: 0,
  STOCK_OUT: 1,
  ADJUSTMENT: 2
};

const StockTransaction = sequelize.define('StockTransaction', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  product_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'products',
      key: 'id'
    },
    validate: {
      notNull: {
        msg: 'Ürün ID boş olamaz'
      },
      isInt: {
        msg: 'Ürün ID tam sayı olmalıdır'
      }
    }
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      notNull: {
        msg: 'Miktar boş olamaz'
      },
      isInt: {
        msg: 'Miktar tam sayı olmalıdır'
      },
      min: {
        args: [1],
        msg: 'Miktar 1 veya daha büyük olmalıdır'
      }
    }
  },
  transaction_type: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      notNull: {
        msg: 'İşlem tipi boş olamaz'
      },
      isIn: {
        args: [Object.values(TRANSACTION_TYPES)],
        msg: 'Geçersiz işlem tipi'
      }
    }
  },
  reason: {
    type: DataTypes.STRING(200),
    allowNull: false,
    validate: {
      notEmpty: {
        msg: 'İşlem sebebi boş olamaz'
      },
      len: {
        args: [1, 200],
        msg: 'İşlem sebebi 1-200 karakter arasında olmalıdır'
      }
    }
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true,
    defaultValue: ''
  },
  previous_stock: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      isInt: {
        msg: 'Önceki stok tam sayı olmalıdır'
      },
      min: {
        args: [0],
        msg: 'Önceki stok 0 veya daha büyük olmalıdır'
      }
    }
  },
  new_stock: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      isInt: {
        msg: 'Yeni stok tam sayı olmalıdır'
      },
      min: {
        args: [0],
        msg: 'Yeni stok 0 veya daha büyük olmalıdır'
      }
    }
  },
  transaction_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    validate: {
      isDate: {
        msg: 'Geçerli bir tarih giriniz'
      }
    }
  },
  created_by: {
    type: DataTypes.STRING(100),
    allowNull: true,
    defaultValue: 'system'
  },
  created_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  },
  updated_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'stock_transactions',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      fields: ['product_id']
    },
    {
      fields: ['transaction_type']
    },
    {
      fields: ['transaction_date']
    },
    {
      fields: ['created_at']
    }
  ]
});

// Instance methods
StockTransaction.prototype.getTypeDisplayName = function() {
  switch (this.transaction_type) {
    case TRANSACTION_TYPES.STOCK_IN:
      return 'Stok Girişi';
    case TRANSACTION_TYPES.STOCK_OUT:
      return 'Stok Çıkışı';
    case TRANSACTION_TYPES.ADJUSTMENT:
      return 'Düzeltme';
    default:
      return 'Bilinmeyen';
  }
};

StockTransaction.prototype.getStockChange = function() {
  return this.new_stock - this.previous_stock;
};

// Class methods
StockTransaction.findByProduct = function(productId, options = {}) {
  return this.findAll({
    where: { product_id: productId },
    order: [['transaction_date', 'DESC'], ['created_at', 'DESC']],
    ...options
  });
};

StockTransaction.findByDateRange = function(startDate, endDate, options = {}) {
  const { Op } = require('sequelize');
  return this.findAll({
    where: {
      transaction_date: {
        [Op.between]: [startDate, endDate]
      }
    },
    order: [['transaction_date', 'DESC'], ['created_at', 'DESC']],
    ...options
  });
};

StockTransaction.findByType = function(transactionType, options = {}) {
  return this.findAll({
    where: { transaction_type: transactionType },
    order: [['transaction_date', 'DESC'], ['created_at', 'DESC']],
    ...options
  });
};

StockTransaction.getStatistics = async function(options = {}) {
  const { startDate, endDate, productId } = options;
  const { Op } = require('sequelize');
  
  let whereClause = {};
  
  if (startDate && endDate) {
    whereClause.transaction_date = {
      [Op.between]: [startDate, endDate]
    };
  }
  
  if (productId) {
    whereClause.product_id = productId;
  }
  
  const totalTransactions = await this.count({ where: whereClause });
  
  const transactionsByType = await this.findAll({
    attributes: [
      'transaction_type',
      [sequelize.fn('COUNT', sequelize.col('id')), 'count'],
      [sequelize.fn('SUM', sequelize.col('quantity')), 'total_quantity']
    ],
    where: whereClause,
    group: ['transaction_type']
  });
  
  const dailyStats = await this.findAll({
    attributes: [
      [sequelize.fn('DATE', sequelize.col('transaction_date')), 'date'],
      [sequelize.fn('COUNT', sequelize.col('id')), 'count'],
      [sequelize.fn('SUM', sequelize.col('quantity')), 'total_quantity']
    ],
    where: whereClause,
    group: [sequelize.fn('DATE', sequelize.col('transaction_date'))],
    order: [[sequelize.fn('DATE', sequelize.col('transaction_date')), 'DESC']]
  });
  
  return {
    totalTransactions,
    transactionsByType: transactionsByType.map(item => ({
      type: item.transaction_type,
      typeName: item.getTypeDisplayName(),
      count: parseInt(item.dataValues.count),
      totalQuantity: parseInt(item.dataValues.total_quantity || 0)
    })),
    dailyStats: dailyStats.map(item => ({
      date: item.dataValues.date,
      count: parseInt(item.dataValues.count),
      totalQuantity: parseInt(item.dataValues.total_quantity || 0)
    }))
  };
};

StockTransaction.createTransaction = async function(data, transaction = null) {
  const Product = require('./Product');
  
  return await sequelize.transaction(async (t) => {
    const dbTransaction = transaction || t;
    
    // Ürünü bul
    const product = await Product.findByPk(data.product_id, {
      transaction: dbTransaction,
      lock: true
    });
    
    if (!product) {
      throw new Error('Ürün bulunamadı');
    }
    
    // Önceki stok miktarını kaydet
    const previousStock = product.current_stock;
    let newStock = previousStock;
    
    // Yeni stok miktarını hesapla
    switch (data.transaction_type) {
      case TRANSACTION_TYPES.STOCK_IN:
        newStock = previousStock + data.quantity;
        break;
      case TRANSACTION_TYPES.STOCK_OUT:
        if (previousStock < data.quantity) {
          throw new Error(`Yetersiz stok! Mevcut: ${previousStock}, İstenen: ${data.quantity}`);
        }
        newStock = previousStock - data.quantity;
        break;
      case TRANSACTION_TYPES.ADJUSTMENT:
        newStock = data.quantity;
        break;
      default:
        throw new Error('Geçersiz işlem tipi');
    }
    
    // Stok işlemini oluştur
    const stockTransaction = await this.create({
      ...data,
      previous_stock: previousStock,
      new_stock: newStock
    }, { transaction: dbTransaction });
    
    // Ürün stokunu güncelle
    await product.update({
      current_stock: newStock
    }, { transaction: dbTransaction });
    
    return stockTransaction;
  });
};

// Hooks
StockTransaction.beforeUpdate((transaction) => {
  transaction.updated_at = new Date();
});

// Export constants
StockTransaction.TRANSACTION_TYPES = TRANSACTION_TYPES;

module.exports = StockTransaction;