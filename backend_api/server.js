const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const { sequelize } = require('./config/database');
const apiRoutes = require('./routes/index');

const app = express();
const PORT = process.env.PORT || 8080;

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 dakika
  max: 100, // IP başına maksimum 100 istek
  message: {
    error: 'Çok fazla istek gönderildi, lütfen daha sonra tekrar deneyin.'
  }
});

// Middleware
app.use(helmet()); // Güvenlik başlıkları
app.use(compression()); // Gzip sıkıştırma
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    
    // Allow all localhost and 127.0.0.1 origins
    if (origin.includes('localhost') || origin.includes('127.0.0.1')) {
      return callback(null, true);
    }
    
    // Allow specific origins from environment variable
    const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || [];
    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    
    // For development, allow all origins
    if (process.env.NODE_ENV === 'development') {
      return callback(null, true);
    }
    
    callback(new Error('Not allowed by CORS'));
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  optionsSuccessStatus: 200
}));
app.use(morgan('combined')); // HTTP isteklerini logla
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use('/api', limiter); // Rate limiting sadece API rotalarına uygula

// Routes
app.use('/api', apiRoutes);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint bulunamadı',
    path: req.originalUrl
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Sunucu hatası',
    error: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// Veritabanı bağlantısını test et ve sunucuyu başlat
async function startServer() {
  try {
    // Veritabanı bağlantısını test et
    await sequelize.authenticate();
    console.log('✅ PostgreSQL veritabanına başarıyla bağlanıldı.');
    
    // Tabloları senkronize et (geliştirme ortamında)
    if (process.env.NODE_ENV !== 'production') {
      await sequelize.sync({ alter: true });
      console.log('✅ Veritabanı tabloları senkronize edildi.');
    }
    
    // Sunucuyu başlat
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Sunucu http://0.0.0.0:${PORT} adresinde çalışıyor`);
      console.log(`📊 API Dokümantasyonu: http://localhost:${PORT}/api/health`);
      console.log(`🔧 Ortam: ${process.env.NODE_ENV || 'development'}`);
    });
    
  } catch (error) {
    console.error('❌ Sunucu başlatılamadı:', error.message);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('\n🔄 SIGTERM sinyali alındı, sunucu kapatılıyor...');
  await sequelize.close();
  console.log('✅ Veritabanı bağlantısı kapatıldı.');
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('\n🔄 SIGINT sinyali alındı, sunucu kapatılıyor...');
  await sequelize.close();
  console.log('✅ Veritabanı bağlantısı kapatıldı.');
  process.exit(0);
});

// Unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('❌ Unhandled Promise Rejection:', err.message);
  process.exit(1);
});

// Uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err.message);
  process.exit(1);
});

startServer();

module.exports = app;