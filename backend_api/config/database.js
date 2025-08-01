const { Sequelize } = require('sequelize');
require('dotenv').config();

// Veritabanı konfigürasyonu
const config = {
  development: {
    dialect: 'sqlite',
    storage: './database/stok_takibi.sqlite',
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    define: {
      timestamps: true,
      underscored: true,
      freezeTableName: true
    }
  },
  test: {
    username: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'password',
    database: process.env.DB_NAME_TEST || 'stok_takibi_test',
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    logging: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  },
  production: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    logging: false,
    pool: {
      max: 20,
      min: 5,
      acquire: 60000,
      idle: 10000
    },
    dialectOptions: {
      ssl: process.env.DB_SSL === 'true' ? {
        require: true,
        rejectUnauthorized: false
      } : false
    }
  }
};

const env = process.env.NODE_ENV || 'development';
const dbConfig = config[env];

// Sequelize instance oluştur
const sequelize = dbConfig.dialect === 'sqlite' 
  ? new Sequelize({
      dialect: 'sqlite',
      storage: dbConfig.storage,
      logging: dbConfig.logging,
      pool: dbConfig.pool,
      define: dbConfig.define
    })
  : new Sequelize(
      dbConfig.database,
      dbConfig.username,
      dbConfig.password,
      {
        host: dbConfig.host,
        port: dbConfig.port,
        dialect: dbConfig.dialect,
        logging: dbConfig.logging,
        pool: dbConfig.pool,
        define: dbConfig.define,
        dialectOptions: dbConfig.dialectOptions || {}
      }
    );

// Veritabanı bağlantısını test etme fonksiyonu
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Veritabanı bağlantısı başarılı.');
    return true;
  } catch (error) {
    console.error('❌ Veritabanı bağlantısı başarısız:', error.message);
    return false;
  }
};

// Veritabanı senkronizasyonu
const syncDatabase = async (options = {}) => {
  try {
    await sequelize.sync(options);
    console.log('✅ Veritabanı tabloları senkronize edildi.');
    return true;
  } catch (error) {
    console.error('❌ Veritabanı senkronizasyonu başarısız:', error.message);
    return false;
  }
};

// Veritabanı bağlantısını kapatma
const closeConnection = async () => {
  try {
    await sequelize.close();
    console.log('✅ Veritabanı bağlantısı kapatıldı.');
  } catch (error) {
    console.error('❌ Veritabanı bağlantısı kapatılırken hata:', error.message);
  }
};

module.exports = {
  sequelize,
  config,
  testConnection,
  syncDatabase,
  closeConnection
};