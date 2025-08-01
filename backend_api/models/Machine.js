const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Machine = sequelize.define('Machine', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      notEmpty: true,
      len: [1, 255]
    }
  },
  type: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      notEmpty: true
    }
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive', 'maintenance'),
    defaultValue: 'active'
  },
  location: {
    type: DataTypes.STRING,
    allowNull: true
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  purchaseDate: {
    type: DataTypes.DATE,
    allowNull: true
  },
  warrantyExpiry: {
    type: DataTypes.DATE,
    allowNull: true
  },
  maintenanceInterval: {
    type: DataTypes.INTEGER, // gün cinsinden
    allowNull: true
  },
  lastMaintenanceDate: {
    type: DataTypes.DATE,
    allowNull: true
  },
  nextMaintenanceDate: {
    type: DataTypes.DATE,
    allowNull: true
  },
  specifications: {
    type: DataTypes.JSON,
    allowNull: true
  }
}, {
  tableName: 'machines',
  timestamps: true,
  indexes: [
    {
      fields: ['name']
    },
    {
      fields: ['type']
    },
    {
      fields: ['status']
    }
  ]
});

module.exports = Machine;