# 🥗 NutriScan: Functional Safety Engine

**NutriScan**, paketli gıdalardaki potansiyel sağlık risklerini analiz eden, Racket tabanlı fonksiyonel bir güvenlik motorudur. 

Büyük veri setleri (CSV) üzerinde çalışarak, ürün içeriklerini toksikolojik risk veritabanı ile çapraz sorgular ve kullanıcıya detaylı bir **Risk Raporu** sunar.

![Racket](https://img.shields.io/badge/Language-Racket-red)
![License](https://img.shields.io/badge/License-MIT-blue)

## 🚀 Özellikler

- **Veri İşleme:** CSV formatındaki market verilerini (`products.csv`) otomatik işler.
- **Fonksiyonel Motor:** Döngüler yerine `filter`, `map` ve `foldl` algoritmaları kullanır.
- **Risk Analizi:** E-Kodlarını (E621, E250 vb.) tarar ve kümülatif risk puanı hesaplar.
- **ASCII Raporlama:** Sonuçları görsel bir terminal arayüzünde sunar.

## 📂 Proje Yapısı

```text
NutriScan/
├── main.rkt           # Ana Program Kodu (Logic Layer)
├── data/
│   └── products.csv   # Ürün Veri Seti (Data Layer)
└── README.md          # Proje Dokümantasyonu