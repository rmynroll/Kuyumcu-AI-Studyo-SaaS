# Kuyumcu AI Stüdyo — Flutter Klasör Yapısı (features/ bazlı)

```
kuyumcu_flutter/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   │
│   ├── app/                              # Uygulama iskeleti (tema, router, root widget)
│   │   ├── app.dart
│   │   ├── router.dart                   # go_router tanımları + route guard
│   │   └── theme/
│   │       ├── app_colors.dart           # Altın/siyah lüks palet
│   │       └── app_theme.dart            # ThemeData (light/dark)
│   │
│   ├── core/                             # Feature'lar arası paylaşılan altyapı
│   │   ├── network/
│   │   │   ├── api_client.dart           # Dio kurulumu (bu teslimatın ana dosyası)
│   │   │   ├── api_exception.dart        # Sade, kuyumcu-dostu hata mesajları
│   │   │   └── interceptors/
│   │   │       ├── auth_interceptor.dart
│   │   │       ├── error_interceptor.dart
│   │   │       └── logging_interceptor.dart
│   │   ├── storage/
│   │   │   └── secure_storage_service.dart   # JWT/refresh token saklama
│   │   ├── constants/
│   │   │   └── api_constants.dart        # Base URL, endpoint path'leri, timeout'lar
│   │   ├── errors/
│   │   │   └── failure.dart              # Domain seviyesi hata tipi
│   │   └── widgets/
│   │       ├── app_primary_button.dart   # Büyük, dokunma dostu ana buton
│   │       └── app_loading_view.dart
│   │
│   └── features/
│       ├── auth/
│       │   ├── data/                     # AuthRepository, DTO'lar
│       │   ├── domain/                   # Entity'ler, use-case'ler
│       │   └── presentation/             # Login/Register ekranları, riverpod provider'lar
│       │
│       ├── home/
│       │   └── presentation/
│       │       ├── dashboard_screen.dart # ← bu teslimatın ana ekranı (3 büyük buton)
│       │       └── widgets/
│       │           └── dashboard_action_card.dart
│       │
│       ├── products/
│       │   ├── data/                     # ProductRepository, ProductDto
│       │   ├── domain/                   # Product entity, enum'lar (tür/metal/taş)
│       │   └── presentation/             # Ürün Yükle, Ürün Kütüphanesi ekranları
│       │
│       ├── generation/                   # "Görsel Oluştur" akışının tamamı
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── generation.dart   # freezed model (Generation, GenerationStatus)
│       │   │   └── generation_repository.dart  # Dio ile /generations çağrıları
│       │   ├── application/
│       │   │   ├── generation_providers.dart      # Riverpod provider'ları
│       │   │   └── generation_polling_service.dart # ← 3-5 sn polling servisi
│       │   └── presentation/
│       │       ├── generation_mode_selection_screen.dart  # Hazır Şablon / Referans Görsel
│       │       ├── generation_progress_screen.dart
│       │       └── widgets/
│       │           └── mode_selection_card.dart
│       │
│       ├── results/
│       │   └── presentation/             # "Sonuçlarım" grid ekranı
│       │
│       ├── billing/
│       │   └── presentation/             # Kredi/paket ekranları
│       │
│       └── settings/
│           └── presentation/             # Firma/hesap ayarları
```

## Mimari prensipler

- **Feature-first + katmanlı**: Her feature kendi `data / domain / presentation` katmanını taşır
  (basit feature'larda — ör. `home` — sadece `presentation` yeterlidir).
- **State management**: `flutter_riverpod`. Her feature kendi provider'larını
  `application/` veya `presentation/` altında tutar; global olanlar (auth durumu, dio client)
  `core/` seviyesinde `Provider`/`AsyncNotifierProvider` olarak tanımlanır.
- **Network**: Tüm HTTP çağrıları `core/network/api_client.dart` üzerinden geçen tek bir
  `Dio` instance'ı kullanır; her feature'ın repository'si bu client'ı enjekte alır, kendi
  base URL/interceptor mantığını tekrar kurmaz.
- **Modeller**: `freezed` + `json_serializable`. Bu paket kurulumundan sonra
  `dart run build_runner build --delete-conflicting-outputs` çalıştırılmalı; `*.freezed.dart`
  ve `*.g.dart` dosyaları bu komutla otomatik üretilir (elle yazılmaz, repoya committed
  edilebilir ama bu teslimatta üretilmedi çünkü ortamda Flutter SDK yok).
- **Navigation**: `go_router`, tüm route'lar `app/router.dart` içinde tek yerden tanımlanır;
  auth durumu bir `redirect` guard'ı ile kontrol edilir.
