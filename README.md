# Stok Takibi Uygulaması

Bu proje Flutter, ObjectBox ve PostgreSQL + Node.js API kullanarak geliştirilmiş bir stok takibi uygulamasıdır.

## Özellikler

- ✅ Cross-platform (Android & iOS)
- ✅ Yerel veri depolama (ObjectBox)
- ✅ Uzak sunucu senkronizasyonu (PostgreSQL + Node.js API)
- ✅ Ürün ekleme/düzenleme/silme
- ✅ Stok giriş/çıkış işlemleri
- ✅ Stok seviyesi takibi
- ✅ Raporlama

## Proje Yapısı

```
stok-takibi/
├── flutter_app/          # Flutter mobil uygulama
├── backend_api/           # Node.js API sunucusu
└── README.md
```

## Kurulum

### Flutter Uygulaması
```bash
cd flutter_app
flutter pub get
flutter run
```

### Backend API
```bash
cd backend_api
npm install
npm start
```

## Teknolojiler

- **Frontend**: Flutter, ObjectBox
- **Backend**: Node.js, Express.js, PostgreSQL
- **Database**: PostgreSQL (uzak), ObjectBox (yerel)