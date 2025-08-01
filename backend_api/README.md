# Stok Takibi API

Flutter mobil uygulaması için Node.js tabanlı RESTful API servisi.

## 🚀 Özellikler

### Ürün Yönetimi
- ✅ Ürün ekleme, güncelleme, silme (CRUD)
- ✅ Barkod ile ürün arama
- ✅ Kategori bazlı filtreleme
- ✅ Düşük stok uyarıları
- ✅ Ürün istatistikleri
- ✅ Sayfalama ve sıralama

### Stok İşlemleri
- ✅ Stok girişi, çıkışı ve düzeltmesi
- ✅ İşlem geçmişi takibi
- ✅ Tarih aralığı filtreleme
- ✅ İşlem istatistikleri
- ✅ Günlük işlem özetleri

### Güvenlik ve Performans
- ✅ CORS koruması
- ✅ Rate limiting
- ✅ Input validation
- ✅ SQL injection koruması
- ✅ Helmet güvenlik başlıkları
- ✅ Gzip sıkıştırma

## 🛠️ Teknolojiler

- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **PostgreSQL** - Veritabanı
- **Sequelize** - ORM
- **Express Validator** - Veri doğrulama
- **Helmet** - Güvenlik
- **CORS** - Cross-origin resource sharing
- **Morgan** - HTTP request logger
- **Compression** - Gzip sıkıştırma

## 📋 Gereksinimler

- Node.js (v16 veya üzeri)
- PostgreSQL (v12 veya üzeri)
- npm veya yarn

## ⚡ Hızlı Başlangıç

### 1. Projeyi Klonlayın
```bash
git clone <repository-url>
cd backend_api
```

### 2. Bağımlılıkları Yükleyin
```bash
npm install
```

### 3. Çevre Değişkenlerini Ayarlayın
`.env` dosyasını düzenleyin:
```env
# Veritabanı
DB_HOST=localhost
DB_PORT=5432
DB_NAME=stok_takibi
DB_USER=postgres
DB_PASSWORD=your_password

# Sunucu
PORT=3000
NODE_ENV=development
```

### 4. Veritabanını Oluşturun
```sql
CREATE DATABASE stok_takibi;
```

### 5. Sunucuyu Başlatın
```bash
# Development
npm run dev

# Production
npm start
```

## 📚 API Dokümantasyonu

### Base URL
```
http://localhost:3000/api
```

### Sağlık Kontrolü
```http
GET /api/health
```

### Ürün Endpoints

#### Tüm Ürünleri Getir
```http
GET /api/products
```

**Query Parameters:**
- `page` (int): Sayfa numarası (varsayılan: 1)
- `limit` (int): Sayfa başına öğe sayısı (varsayılan: 50)
- `search` (string): Arama terimi
- `category` (string): Kategori filtresi
- `sortBy` (string): Sıralama alanı
- `sortOrder` (string): Sıralama yönü (ASC/DESC)
- `lowStock` (boolean): Düşük stoklu ürünler

#### Ürün Detayı
```http
GET /api/products/:id
```

#### Barkod ile Ürün
```http
GET /api/products/barcode/:barcode
```

#### Yeni Ürün Oluştur
```http
POST /api/products
Content-Type: application/json

{
  "barcode": "1234567890123",
  "name": "Ürün Adı",
  "description": "Ürün açıklaması",
  "category": "Kategori",
  "price": 99.99,
  "current_stock": 100,
  "min_stock_level": 10,
  "unit": "adet"
}
```

#### Ürün Güncelle
```http
PUT /api/products/:id
Content-Type: application/json

{
  "name": "Güncellenmiş Ürün Adı",
  "price": 149.99
}
```

#### Ürün Sil
```http
DELETE /api/products/:id
```

### Stok İşlemi Endpoints

#### Tüm İşlemleri Getir
```http
GET /api/transactions
```

**Query Parameters:**
- `page`, `limit`: Sayfalama
- `product_id` (int): Ürün filtresi
- `transaction_type` (string): İşlem türü (stock_in, stock_out, adjustment)
- `start_date`, `end_date` (ISO date): Tarih aralığı

#### Yeni Stok İşlemi
```http
POST /api/transactions
Content-Type: application/json

{
  "product_id": 1,
  "quantity": 50,
  "transaction_type": "stock_in",
  "reason": "Yeni sevkiyat",
  "notes": "Tedarikçiden gelen ürünler",
  "created_by": "admin"
}
```

**İşlem Türleri:**
- `stock_in`: Stok girişi
- `stock_out`: Stok çıkışı
- `adjustment`: Stok düzeltmesi

#### Ürüne Göre İşlemler
```http
GET /api/transactions/product/:product_id
```

#### İşlem İstatistikleri
```http
GET /api/transactions/statistics
```

#### Günlük Özet
```http
GET /api/transactions/daily-summary?date=2024-01-15
```

## 🗄️ Veritabanı Şeması

### Products Tablosu
```sql
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  barcode VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  current_stock INTEGER DEFAULT 0,
  min_stock_level INTEGER DEFAULT 0,
  unit VARCHAR(20) DEFAULT 'adet',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Stock_Transactions Tablosu
```sql
CREATE TABLE stock_transactions (
  id SERIAL PRIMARY KEY,
  product_id INTEGER REFERENCES products(id),
  quantity INTEGER NOT NULL,
  transaction_type VARCHAR(20) NOT NULL,
  reason VARCHAR(255),
  notes TEXT,
  previous_stock INTEGER NOT NULL,
  new_stock INTEGER NOT NULL,
  transaction_date TIMESTAMP NOT NULL,
  created_by VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## 🧪 Test

```bash
# Tüm testleri çalıştır
npm test

# Test coverage
npm run test:coverage
```

## 📝 Scripts

```bash
# Geliştirme sunucusu (nodemon ile)
npm run dev

# Production sunucusu
npm start

# Veritabanı migration
npm run migrate

# Test verisi oluştur
npm run seed

# Testleri çalıştır
npm test
```

## 🔧 Konfigürasyon

### Çevre Değişkenleri

| Değişken | Açıklama | Varsayılan |
|----------|----------|------------|
| `NODE_ENV` | Ortam (development/production) | development |
| `PORT` | Sunucu portu | 3000 |
| `DB_HOST` | Veritabanı host | localhost |
| `DB_PORT` | Veritabanı port | 5432 |
| `DB_NAME` | Veritabanı adı | stok_takibi |
| `DB_USER` | Veritabanı kullanıcısı | postgres |
| `DB_PASSWORD` | Veritabanı şifresi | - |
| `ALLOWED_ORIGINS` | CORS izinli origin'ler | localhost:3000 |
| `RATE_LIMIT_MAX_REQUESTS` | Rate limit maksimum istek | 100 |

## 🚀 Deployment

### Docker ile

```dockerfile
# Dockerfile örneği
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### PM2 ile

```bash
# PM2 kurulumu
npm install -g pm2

# Uygulamayı başlat
pm2 start server.js --name "stok-api"

# Durumu kontrol et
pm2 status

# Logları görüntüle
pm2 logs stok-api
```

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 📞 İletişim

- **Proje Sahibi:** Stok Takibi Ekibi
- **Email:** info@stoktakibi.com
- **GitHub:** [github.com/stoktakibi/api](https://github.com/stoktakibi/api)

## 🔄 Changelog

### v1.0.0 (2024-01-15)
- ✅ İlk sürüm
- ✅ Ürün CRUD işlemleri
- ✅ Stok işlemleri
- ✅ Barkod desteği
- ✅ İstatistikler
- ✅ API dokümantasyonu

---

**Not:** Bu API, Flutter mobil uygulaması ile birlikte çalışacak şekilde tasarlanmıştır. Mobil uygulama için [flutter_app](../flutter_app) klasörüne bakınız.