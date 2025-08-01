const { sequelize } = require('../config/database');
const Product = require('./Product');
const StockTransaction = require('./StockTransaction');
const Machine = require('./Machine');
const Planning = require('./Planning');

// Model ilişkilerini tanımla

// Product - StockTransaction ilişkisi (One-to-Many)
Product.hasMany(StockTransaction, {
  foreignKey: 'product_id',
  as: 'transactions',
  onDelete: 'CASCADE',
  onUpdate: 'CASCADE'
});

StockTransaction.belongsTo(Product, {
  foreignKey: 'product_id',
  as: 'product',
  onDelete: 'CASCADE',
  onUpdate: 'CASCADE'
});

// Model senkronizasyonu için yardımcı fonksiyon
const syncModels = async (options = {}) => {
  try {
    // Modelleri sırayla senkronize et
    await Product.sync(options);
    await StockTransaction.sync(options);
    await Machine.sync(options);
    await Planning.sync(options);
    
    console.log('✅ Tüm modeller başarıyla senkronize edildi.');
    return true;
  } catch (error) {
    console.error('❌ Model senkronizasyonu başarısız:', error.message);
    throw error;
  }
};

// Veritabanını sıfırlama fonksiyonu (sadece development)
const resetDatabase = async () => {
  if (process.env.NODE_ENV === 'production') {
    throw new Error('Production ortamında veritabanı sıfırlanamaz!');
  }
  
  try {
    await sequelize.drop();
    console.log('🗑️ Tüm tablolar silindi.');
    
    await syncModels({ force: true });
    console.log('✅ Veritabanı sıfırlandı ve yeniden oluşturuldu.');
    
    return true;
  } catch (error) {
    console.error('❌ Veritabanı sıfırlama başarısız:', error.message);
    throw error;
  }
};

// Test verisi oluşturma fonksiyonu
const seedDatabase = async () => {
  try {
    // Örnek kategoriler
    const categories = ['Elektronik', 'Gıda', 'Giyim', 'Ev & Yaşam', 'Kitap', 'Oyuncak'];
    
    // Örnek ürünler
    const sampleProducts = [
      {
        barcode: '1234567890123',
        name: 'Samsung Galaxy S23',
        description: 'Flagship Android telefon',
        category: 'Elektronik',
        price: 25999.99,
        current_stock: 15,
        min_stock_level: 5,
        unit: 'adet'
      },
      {
        barcode: '2345678901234',
        name: 'iPhone 15',
        description: 'Apple iPhone 15 128GB',
        category: 'Elektronik',
        price: 35999.99,
        current_stock: 8,
        min_stock_level: 3,
        unit: 'adet'
      },
      {
        barcode: '3456789012345',
        name: 'Laptop Asus',
        description: 'Asus VivoBook 15 i5 8GB 256GB SSD',
        category: 'Elektronik',
        price: 15999.99,
        current_stock: 12,
        min_stock_level: 4,
        unit: 'adet'
      },
      {
        barcode: '4567890123456',
        name: 'Çay Bardağı Seti',
        description: '6 parça cam çay bardağı seti',
        category: 'Ev & Yaşam',
        price: 89.99,
        current_stock: 25,
        min_stock_level: 10,
        unit: 'set'
      },
      {
        barcode: '5678901234567',
        name: 'Türk Kahvesi',
        description: 'Geleneksel Türk kahvesi 100gr',
        category: 'Gıda',
        price: 45.50,
        current_stock: 50,
        min_stock_level: 20,
        unit: 'paket'
      },
      {
        barcode: '6789012345678',
        name: 'Spor Ayakkabı',
        description: 'Nike Air Max 270 Erkek Spor Ayakkabı',
        category: 'Giyim',
        price: 899.99,
        current_stock: 3,
        min_stock_level: 5,
        unit: 'çift'
      },
      {
        barcode: '7890123456789',
        name: 'Python Programlama',
        description: 'Python ile Programlamaya Giriş Kitabı',
        category: 'Kitap',
        price: 75.00,
        current_stock: 18,
        min_stock_level: 8,
        unit: 'adet'
      },
      {
        barcode: '8901234567890',
        name: 'Lego Classic Set',
        description: 'Lego Classic Yaratıcı Yapı Taşları Seti',
        category: 'Oyuncak',
        price: 299.99,
        current_stock: 7,
        min_stock_level: 3,
        unit: 'kutu'
      }
    ];
    
    // Ürünleri oluştur
    const createdProducts = await Product.bulkCreate(sampleProducts);
    console.log(`✅ ${createdProducts.length} örnek ürün oluşturuldu.`);
    
    // Örnek stok işlemleri
    const sampleTransactions = [];
    
    for (let i = 0; i < createdProducts.length; i++) {
      const product = createdProducts[i];
      
      // Her ürün için birkaç örnek işlem
      sampleTransactions.push({
        product_id: product.id,
        quantity: Math.floor(Math.random() * 20) + 10,
        transaction_type: StockTransaction.TRANSACTION_TYPES.STOCK_IN,
        reason: 'İlk stok girişi',
        notes: 'Sistem kurulumu sırasında eklenen başlangıç stoğu',
        previous_stock: 0,
        new_stock: product.current_stock,
        transaction_date: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000), // Son 30 gün içinde
        created_by: 'system'
      });
      
      // Bazı ürünler için stok çıkışı
      if (Math.random() > 0.5) {
        const outQuantity = Math.floor(Math.random() * 5) + 1;
        sampleTransactions.push({
          product_id: product.id,
          quantity: outQuantity,
          transaction_type: StockTransaction.TRANSACTION_TYPES.STOCK_OUT,
          reason: 'Satış',
          notes: 'Müşteri satışı',
          previous_stock: product.current_stock,
          new_stock: product.current_stock - outQuantity,
          transaction_date: new Date(Date.now() - Math.random() * 15 * 24 * 60 * 60 * 1000), // Son 15 gün içinde
          created_by: 'system'
        });
      }
    }
    
    // İşlemleri oluştur
    const createdTransactions = await StockTransaction.bulkCreate(sampleTransactions);
    console.log(`✅ ${createdTransactions.length} örnek stok işlemi oluşturuldu.`);
    
    console.log('🌱 Test verisi başarıyla oluşturuldu.');
    return true;
    
  } catch (error) {
    console.error('❌ Test verisi oluşturma başarısız:', error.message);
    throw error;
  }
};

module.exports = {
  sequelize,
  Product,
  StockTransaction,
  Machine,
  Planning,
  syncModels,
  resetDatabase,
  seedDatabase
};