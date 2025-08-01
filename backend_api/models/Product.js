const { DataTypes, Op } = require('sequelize');
const { sequelize } = require('../config/database');

const Product = sequelize.define('Product', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  barcode: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
    validate: {
      notEmpty: {
        msg: 'Barkod boş olamaz'
      },
      len: {
        args: [1, 50],
        msg: 'Barkod 1-50 karakter arasında olmalıdır'
      }
    }
  },
  name: {
    type: DataTypes.STRING(200),
    allowNull: false,
    validate: {
      notEmpty: {
        msg: 'Ürün adı boş olamaz'
      },
      len: {
        args: [1, 200],
        msg: 'Ürün adı 1-200 karakter arasında olmalıdır'
      }
    }
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
    defaultValue: ''
  },
  category: {
    type: DataTypes.STRING(100),
    allowNull: false,
    validate: {
      notEmpty: {
        msg: 'Kategori boş olamaz'
      },
      len: {
        args: [1, 100],
        msg: 'Kategori 1-100 karakter arasında olmalıdır'
      }
    }
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    validate: {
      isDecimal: {
        msg: 'Fiyat geçerli bir sayı olmalıdır'
      },
      min: {
        args: [0],
        msg: 'Fiyat 0 veya daha büyük olmalıdır'
      }
    }
  },
  current_stock: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    validate: {
      isInt: {
        msg: 'Mevcut stok tam sayı olmalıdır'
      },
      min: {
        args: [0],
        msg: 'Mevcut stok 0 veya daha büyük olmalıdır'
      }
    }
  },
  min_stock_level: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    validate: {
      isInt: {
        msg: 'Minimum stok seviyesi tam sayı olmalıdır'
      },
      min: {
        args: [0],
        msg: 'Minimum stok seviyesi 0 veya daha büyük olmalıdır'
      }
    }
  },
  unit: {
    type: DataTypes.STRING(20),
    allowNull: false,
    defaultValue: 'adet',
    validate: {
      notEmpty: {
        msg: 'Birim boş olamaz'
      },
      len: {
        args: [1, 20],
        msg: 'Birim 1-20 karakter arasında olmalıdır'
      }
    }
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: true
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
  tableName: 'products',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      unique: true,
      fields: ['barcode']
    },
    {
      fields: ['name']
    },
    {
      fields: ['category']
    },
    {
      fields: ['current_stock']
    },
    {
      fields: ['is_active']
    }
  ]
});

// Instance methods
Product.prototype.isLowStock = function() {
  return this.current_stock <= this.min_stock_level;
};

Product.prototype.updateStock = function(quantity, operation = 'add') {
  if (operation === 'add') {
    this.current_stock += quantity;
  } else if (operation === 'subtract') {
    this.current_stock = Math.max(0, this.current_stock - quantity);
  } else if (operation === 'set') {
    this.current_stock = Math.max(0, quantity);
  }
  this.updated_at = new Date();
};

// Class methods
Product.findByBarcode = function(barcode) {
  return this.findOne({ where: { barcode, is_active: true } });
};

Product.findByCategory = function(category) {
  return this.findAll({ 
    where: { category, is_active: true },
    order: [['name', 'ASC']]
  });
};

Product.findLowStock = function() {
  return this.findAll({
    where: {
      is_active: true,
      [sequelize.Op.and]: [
        sequelize.where(
          sequelize.col('current_stock'),
          '<=',
          sequelize.col('min_stock_level')
        )
      ]
    },
    order: [['current_stock', 'ASC']]
  });
};

Product.searchProducts = function(searchTerm) {
  const { Op } = require('sequelize');
  return this.findAll({
    where: {
      is_active: true,
      [Op.or]: [
        { name: { [Op.iLike]: `%${searchTerm}%` } },
        { barcode: { [Op.iLike]: `%${searchTerm}%` } },
        { category: { [Op.iLike]: `%${searchTerm}%` } },
        { description: { [Op.iLike]: `%${searchTerm}%` } }
      ]
    },
    order: [['name', 'ASC']]
  });
};

Product.getCategories = async function() {
  const result = await this.findAll({
    attributes: [[sequelize.fn('DISTINCT', sequelize.col('category')), 'category']],
    where: { is_active: true },
    order: [['category', 'ASC']]
  });
  return result.map(item => item.category);
};

Product.getStatistics = async function() {
  const totalProducts = await this.count({ where: { is_active: true } });
  const lowStockProducts = await this.count({
    where: {
      is_active: true,
      [Op.and]: [
        sequelize.where(
          sequelize.col('current_stock'),
          '<=',
          sequelize.col('min_stock_level')
        )
      ]
    }
  });
  
  const totalValue = await this.sum('price', {
    where: { is_active: true }
  }) || 0;
  
  const totalStockValue = await this.findAll({
    attributes: [
      [sequelize.fn('SUM', sequelize.literal('price * current_stock')), 'total_value']
    ],
    where: { is_active: true }
  });
  
  return {
    totalProducts,
    lowStockProducts,
    totalValue: parseFloat(totalValue),
    totalStockValue: parseFloat(totalStockValue[0]?.dataValues?.total_value || 0)
  };
};

// Hooks
Product.beforeUpdate((product) => {
  product.updated_at = new Date();
});

module.exports = Product;