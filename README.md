# TripSplit — Chia tiền chuyến đi

App Flutter chia tiền nhóm bạn đi chơi. Tính toán offline, ai trả gì, ai nợ ai bao nhiêu.

## Tính năng

- Tạo chuyến đi, thêm thành viên & khoản chi
- Tính quyết toán offline (tối giản số lần chuyển tiền)
- Shop coin: theme, nền thẻ, bỏ quảng cáo, tính năng premium
- Google Play Billing: 10 gói coin `ts_pack_1` → `ts_pack_10`
- Remote IAP config: `https://api2.blwsmartware.net/T106.json`
- Song ngữ EN / VI

## Google Play — Checklist

### 1. Package & ký

- Package: `com.tripsplit.tripsplit`
- Tạo `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

### 2. In-App Products (Play Console → Monetize → Products)

Tạo **10 sản phẩm consumable**:

| Product ID | Coins |
|------------|-------|
| ts_pack_1  | 50    |
| ts_pack_2  | 100   |
| ts_pack_3  | 200   |
| ts_pack_4  | 350   |
| ts_pack_5  | 500   |
| ts_pack_6  | 750   |
| ts_pack_7  | 1000  |
| ts_pack_8  | 1500  |
| ts_pack_9  | 2200  |
| ts_pack_10 | 3000  |

### 3. Remote IAP JSON

Host file `T106.json` tại: `https://api2.blwsmartware.net/T106.json`

Mẫu: `docs/T106.json`

- `disable: 0` → hiện popup mua coin qua Google Billing
- `disable: 1` → ẩn Google Billing, shop coin vẫn hoạt động (cày điểm)

### 4. Build release

```bash
flutter pub get
dart run flutter_launcher_icons
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 5. Privacy policy

Host `docs/privacy_policy.html` và thêm URL vào Play Console.

## Cấu trúc IAP

```
ShopProvider
  ├── IapConfigService  → GET T106.json (timeout 10s, cache offline)
  ├── BillingService    → in_app_purchase (Google Billing)
  └── SharedPreferences → coins, owned items, themes
```

## Shop items (mua bằng coin)

| ID | Loại | Giá |
|----|------|-----|
| remove_ads | Một lần | 500 |
| theme_sunset/midnight/tropical/sakura | Theme | 200-250 |
| bg_ticket/ocean/mountain | Nền thẻ | 150-200 |
| feat_unlimited_trips | Tính năng | 300 |
| feat_export_backup | Tính năng | 200 |
| feat_share_settlement | Tính năng | 150 |
| feat_custom_split | Tính năng | 250 |
| feat_multi_currency | Tính năng | 200 |
| feat_expense_note | Tính năng | 150 |

Tất cả tính năng đã mua được **áp dụng ngay** trong app. Theme/nền có thể **reset về mặc định**.

## Cày coin miễn phí

- Đăng nhập hàng ngày: +10 coin
- Xem quyết toán: +8 coin (tối đa 3 lần/ngày)

## Dev

```bash
flutter pub get
flutter run
```
