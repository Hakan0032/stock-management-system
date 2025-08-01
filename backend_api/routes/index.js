const express = require('express');
const router = express.Router();
const { sequelize } = require('../config/database');

// Alt rotaları import et
const productsRoutes = require('./products');
const transactionsRoutes = require('./transactions');
const machinesRoutes = require('./machines');
const planningsRoutes = require('./plannings');

// API sağlık kontrolü
router.get('/health', async (req, res) => {
  try {
    // Veritabanı bağlantısını test et
    await sequelize.authenticate();
    
    const healthStatus = {
      status: 'OK',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV || 'development',
      version: process.env.npm_package_version || '1.0.0',
      database: {
        status: 'connected',
        host: process.env.DB_HOST || 'localhost',
        name: process.env.DB_NAME || 'stok_takibi'
      },
      memory: {
        used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024 * 100) / 100,
        total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024 * 100) / 100,
        external: Math.round(process.memoryUsage().external / 1024 / 1024 * 100) / 100
      },
      cpu: {
        usage: process.cpuUsage()
      }
    };
    
    res.json({
      success: true,
      data: healthStatus
    });
    
  } catch (error) {
    console.error('Health check failed:', error);
    
    res.status(503).json({
      success: false,
      status: 'ERROR',
      timestamp: new Date().toISOString(),
      message: 'Servis kullanılamıyor',
      error: {
        database: 'Veritabanı bağlantısı başarısız',
        details: process.env.NODE_ENV === 'development' ? error.message : undefined
      }
    });
  }
});

// API bilgileri
router.get('/info', (req, res) => {
  res.json({
    success: true,
    data: {
      name: 'Stok Takibi API',
      description: 'Flutter mobil uygulaması için stok takip sistemi API\'si',
      version: process.env.npm_package_version || '1.0.0',
      environment: process.env.NODE_ENV || 'development',
      author: 'Stok Takibi Ekibi',
      endpoints: {
        products: '/api/products',
        transactions: '/api/transactions',
        health: '/api/health',
        info: '/api/info'
      },
      documentation: {
        swagger: '/api/docs', // Gelecekte eklenebilir
        postman: '/api/postman' // Gelecekte eklenebilir
      },
      features: [
        'Ürün yönetimi (CRUD)',
        'Stok işlemleri (Giriş, Çıkış, Düzeltme)',
        'Barkod ile ürün arama',
        'Kategori bazlı filtreleme',
        'Düşük stok uyarıları',
        'İstatistiksel raporlar',
        'Sayfalama ve sıralama',
        'Tarih aralığı filtreleme',
        'Veri doğrulama',
        'Hata yönetimi'
      ],
      database: {
        type: 'PostgreSQL',
        orm: 'Sequelize',
        features: [
          'ACID uyumluluğu',
          'İlişkisel veri modeli',
          'Otomatik migration',
          'Soft delete',
          'Timestamp tracking'
        ]
      },
      security: [
        'CORS koruması',
        'Helmet güvenlik başlıkları',
        'Rate limiting',
        'Input validation',
        'SQL injection koruması'
      ]
    }
  });
});

// API istatistikleri (basit)
router.get('/stats', async (req, res) => {
  try {
    const { Product, StockTransaction } = require('../models');
    
    // Temel istatistikleri al
    const [totalProducts, totalTransactions, lowStockCount] = await Promise.all([
      Product.count({ where: { is_active: true } }),
      StockTransaction.count(),
      Product.count({
        where: {
          is_active: true,
          current_stock: {
            [require('sequelize').Op.lte]: require('sequelize').col('min_stock_level')
          }
        }
      })
    ]);
    
    // Bugünkü işlem sayısı
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    const todayTransactions = await StockTransaction.count({
      where: {
        created_at: {
          [require('sequelize').Op.gte]: today,
          [require('sequelize').Op.lt]: tomorrow
        }
      }
    });
    
    res.json({
      success: true,
      data: {
        overview: {
          total_products: totalProducts,
          total_transactions: totalTransactions,
          low_stock_products: lowStockCount,
          today_transactions: todayTransactions
        },
        last_updated: new Date().toISOString(),
        api_version: process.env.npm_package_version || '1.0.0'
      }
    });
    
  } catch (error) {
    console.error('Stats error:', error);
    res.status(500).json({
      success: false,
      message: 'İstatistikler alınırken hata oluştu',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Test endpoint (sadece development)
if (process.env.NODE_ENV === 'development') {
  router.get('/test', (req, res) => {
    res.json({
      success: true,
      message: 'Test endpoint çalışıyor',
      timestamp: new Date().toISOString(),
      request: {
        method: req.method,
        url: req.url,
        headers: req.headers,
        query: req.query,
        body: req.body
      },
      server: {
        node_version: process.version,
        platform: process.platform,
        arch: process.arch,
        pid: process.pid,
        uptime: process.uptime()
      }
    });
  });
}

// Alt rotaları kaydet
router.use('/products', productsRoutes);
router.use('/transactions', transactionsRoutes);
router.use('/machines', machinesRoutes);
router.use('/plannings', planningsRoutes);

// 404 handler - API rotaları için
router.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'API endpoint bulunamadı',
    requested_url: req.originalUrl,
    method: req.method,
    available_endpoints: {
      health: 'GET /api/health',
      info: 'GET /api/info',
      stats: 'GET /api/stats',
      products: 'GET /api/products',
      transactions: 'GET /api/transactions'
    },
    documentation: 'API dokümantasyonu için /api/info endpoint\'ini ziyaret edin'
  });
});

module.exports = router;