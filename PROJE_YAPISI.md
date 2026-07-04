# Kuyumcu AI Stüdyo SaaS — Backend Klasör Yapısı

```
kuyumcu-backend/
├── go.mod
├── cmd/
│   ├── api/
│   │   └── main.go          # HTTP API giriş noktası
│   └── worker/
│       └── main.go          # Redis/Asynq worker giriş noktası
│
├── internal/
│   ├── auth/                # Kayıt, giriş, JWT, refresh token
│   ├── users/                # Kullanıcı profil ve rol yönetimi
│   ├── companies/            # Firma/mağaza servis katmanı
│   ├── products/             # Ürün CRUD, görsel yükleme, metadata
│   ├── templates/            # Hazır şablon ve prompt template yönetimi
│   ├── reference_analyses/   # Referans görsel analiz servisi
│   ├── generations/          # AI üretim işi oluşturma ve durum takibi
│   ├── credits/              # Kredi düşme/iade/bakiye
│   ├── payments/             # Paket, checkout, webhook
│   │
│   ├── storage/              # S3/R2 uyumlu dosya yükleme, signed URL
│   ├── ai/                   # Prompt üretimi, AI provider istemcisi
│   ├── notifications/        # Bildirimler
│   ├── admin/                # Admin panel servisleri
│   ├── queue/                # Redis + Asynq kuyruk soyutlaması
│   │
│   ├── database/
│   │   ├── migrations/
│   │   │   └── schema.sql    # ← bu teslimatın SQL şeması
│   │   └── db.go             # PostgreSQL bağlantı havuzu
│   │
│   ├── middleware/            # Auth, logging, rate limit middleware'leri
│   │
│   └── models/                # ← bu teslimatın Go struct'ları
│       ├── user.go
│       ├── company.go
│       ├── product.go
│       ├── reference_analysis.go
│       └── generation.go
│
└── pkg/
    ├── logger/                # Yapılandırılmış loglama
    ├── validator/             # Request validasyon yardımcıları
    ├── response/               # Standart API response zarfları
    └── errors/                  # Ortak hata tipleri
```

## Notlar
- `internal/` paketleri yalnızca bu modül içinden import edilebilir (Go standardı).
- `cmd/api` ve `cmd/worker` aynı `internal/` katmanlarını paylaşır; API yalnızca iş
  oluşturur, ağır AI işlemlerini `cmd/worker` yürütür (bkz. teknik doküman, Redis+Asynq kararı).
- `models` paketindeki struct'lar hem `database/sql` / `sqlx` ile hem de doğrudan
  JSON serialize/deserialize için kullanılabilecek şekilde `db` ve `json` tag'leriyle yazıldı.
