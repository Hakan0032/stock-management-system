const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Planning = sequelize.define('Planning', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      notEmpty: true,
      len: [1, 255]
    }
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  category: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'Genel'
  },
  priority: {
    type: DataTypes.ENUM('low', 'medium', 'high', 'urgent'),
    defaultValue: 'medium'
  },
  status: {
    type: DataTypes.ENUM('pending', 'in_progress', 'completed', 'cancelled'),
    defaultValue: 'pending'
  },
  startDate: {
    type: DataTypes.DATE,
    allowNull: true
  },
  endDate: {
    type: DataTypes.DATE,
    allowNull: true
  },
  dueDate: {
    type: DataTypes.DATE,
    allowNull: true
  },
  completedAt: {
    type: DataTypes.DATE,
    allowNull: true
  },
  assignedTo: {
    type: DataTypes.STRING,
    allowNull: true
  },
  estimatedHours: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true
  },
  actualHours: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true
  },
  budget: {
    type: DataTypes.DECIMAL(15, 2),
    allowNull: true
  },
  actualCost: {
    type: DataTypes.DECIMAL(15, 2),
    allowNull: true
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  tags: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: []
  },
  materials: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: []
  },
  attachments: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: []
  }
}, {
  tableName: 'plannings',
  timestamps: true,
  indexes: [
    {
      fields: ['title']
    },
    {
      fields: ['category']
    },
    {
      fields: ['status']
    },
    {
      fields: ['priority']
    },
    {
      fields: ['due_date']
    }
  ]
});

module.exports = Planning;