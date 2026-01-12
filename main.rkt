#lang racket

;; =================================================================
;; GIDA ANALİZ MOTORU (FULL RAPOR + SENSÖR SİMÜLASYONU)
;; =================================================================

;; --- YAPI TANIMLARI ---
(struct ingredient (code name category score) #:transparent)

;; DOSYA YOLLARI
(define DICT-PATH "data/icerik_sozlugu.csv")
(define PROD-PATH "data/urunler.csv")

;; =================================================================
;; BÖLÜM 1: VERİ YÜKLEME
;; =================================================================

(define (load-dictionary path)
  (if (file-exists? path)
      (let ([lines (file->lines path)])
        (for/hash ([line lines]
                   #:unless (or (string=? (string-trim line) "")
                                (string-prefix? line "Kod")))
          (define parts (string-split line ","))
          (if (>= (length parts) 4)
              (let ([code (string->symbol (first parts))]
                    [name (second parts)]
                    [cat  (third parts)]
                    [score (string->number (string-trim (fourth parts)))])
                (values code (ingredient code name cat score)))
              (values 'ERR #f))))
      (begin (printf "[!] HATA: '~a' bulunamadı!\n" path) (hash))))

(define (load-products path)
  (if (file-exists? path)
      (let ([lines (file->lines path)])
        (for/hash ([line lines]
                   #:unless (string=? (string-trim line) ""))
          (define parts (string-split line ","))
          (define p-name (string->symbol (string-downcase (string-trim (first parts)))))
          (define p-codes (map string->symbol (map string-trim (rest parts))))
          (values p-name p-codes)))
      (begin (printf "[!] HATA: '~a' bulunamadı!\n" path) (hash))))

(displayln ">> Sistem Başlatılıyor...")
(define INGREDIENT-DB (load-dictionary DICT-PATH))
(define PRODUCT-DB (load-products PROD-PATH))
(printf ">> Veritabanı: ~a ürün ve ~a içerik maddesi yüklendi.\n" 
        (hash-count PRODUCT-DB) (hash-count INGREDIENT-DB))

;; =================================================================
;; BÖLÜM 2: ANALİZ VE ÖNERİ MANTIĞI
;; =================================================================

(define (analyze-product product-key)
  (define codes (hash-ref PRODUCT-DB product-key '()))
  
  (define details 
    (filter-map (lambda (code) 
                  (if (hash-has-key? INGREDIENT-DB code)
                      (hash-ref INGREDIENT-DB code)
                      #f)) 
                codes))
  
  (define total-score
    (foldl (lambda (ing sum) (+ sum (ingredient-score ing))) 0 details))
  
  (define risky-items
    (filter (lambda (ing) (> (ingredient-score ing) 3)) details))
  
  (values total-score details risky-items))

(define (get-recommendation score risky-count)
  (cond
    [(> score 45) 
     "KRİTİK UYARI: Bu ürün çok fazla katkı maddesi veya şeker içeriyor. \n    Sağlığınız için tüketmemenizi veya doğal bir alternatif bulmanızı öneririm."]
    [(> score 25) 
     "DİKKATLİ TÜKETİN: İçeriğinde riskli bileşenler var. \n    Sık tüketimden kaçının ve porsiyonu küçültün."]
    [(and (> score 10) (> risky-count 0))
     "ORTA SEVİYE: Çok zararlı değil ancak en temiz seçenek de sayılmaz. \n    Arada sırada tüketilebilir."]
    [else 
     "TEMİZ İÇERİK: Bu ürün güvenli görünüyor. \n    Gönül rahatlığıyla tüketebilirsiniz. Afiyet olsun!"]))

;; =================================================================
;; BÖLÜM 3: GELİŞMİŞ RAPORLAMA
;; =================================================================

(define (print-report p-name score all-items risky-items)
  (newline)
  (displayln "================================================")
  (printf    " ÜRÜN ANALİZ RAPORU: ~a\n" (string-upcase p-name))
  (displayln "================================================")
  
  (displayln " [1] İÇİNDEKİLER:")
  (display   "     ")
  (displayln (string-join (map ingredient-name all-items) ", "))
  (newline)

  (displayln " [2] RİSK DURUMU:")
  (printf    "     Toplam Puan: ~a / 100\n" score)
  (display   "     Risk Barı  : [")
  (cond
    [(> score 40) (display "█████████████████!!")] 
    [(> score 20) (display "██████████░░░░░░░░░")] 
    [(> score 10) (display "█████░░░░░░░░░░░░░░")] 
    [else         (display "░░░░░░░░░░░░░░░░░░░")]) 
  (displayln "]")
  
  (unless (null? risky-items)
    (newline)
    (displayln " [3] TESPİT EDİLEN RİSKLİ MADDELER:")
    (for ([item risky-items])
      (printf "     Make: ~a | Puan: ~a -> ~a (~a)\n" 
              (ingredient-code item)
              (ingredient-score item)
              (ingredient-name item)
              (ingredient-category item))))
  
  (displayln "------------------------------------------------")
  
  (displayln " [4] SİSTEM ÖNERİSİ:")
  (printf    "    % ~a\n" (get-recommendation score (length risky-items)))
  
  (displayln "================================================\n"))

;; =================================================================
;; BÖLÜM 4: SENSÖR SİMÜLASYON MODÜLÜ (YENİ EKLENDİ)
;; =================================================================
;; Bu bölüm fiziksel sensörden gelen verileri taklit eder.

(define (simulate-sensor-scan)
  (newline)
  (displayln ">>> SENSÖR MODU AKTİF: Lütfen test çubuğunu gıdaya batırın...")
  (sleep 2) ;; Kullanıcıya zaman tanı
  (displayln ">>> Numune algılandı. Analiz başlatılıyor...")
  (sleep 1)
  
  ;; Simülasyon Efektleri (Gerçekçilik için)
  (display ">>> Spektral Tarama: ")
  (for ([i (in-range 10)]) (display "█") (flush-output) (sleep 0.2))
  (newline)
  
  (display ">>> pH Seviyesi Ölçülüyor... ")
  (sleep 1)
  (printf "~a (Asidik)\n" (+ 2 (random 4))) ;; Rastgele asidik değer üret
  
  (display ">>> Glikoz Yoğunluğu Hesaplanıyor... ")
  (sleep 1)
  (printf "%~a\n" (+ 10 (random 50)))
  
  (displayln ">>> VERİTABANI EŞLEŞTİRMESİ YAPILIYOR...")
  (sleep 1)
  
  ;; HİLE KISMI: Veritabanından rastgele bir ürün seçiyoruz
  ;; Sanki sensör o ürünü tanımış gibi davranacak.
  (define all-products (hash-keys PRODUCT-DB))
  (if (null? all-products)
      (displayln "[!] Veritabanı boş, analiz yapılamadı.")
      (let* ([random-idx (random (length all-products))]
             [detected-product (list-ref all-products random-idx)])
        
        (printf "\n[OK] TESPİT EDİLEN ÜRÜN İMZASI: ~a\n" (string-upcase (symbol->string detected-product)))
        (sleep 1)
        ;; Raporu bas
        (let-values ([(score all risky) (analyze-product detected-product)])
          (print-report (symbol->string detected-product) score all risky)))))

;; =================================================================
;; BÖLÜM 5: ANA MENÜ DÖNGÜSÜ
;; =================================================================

(define (main-menu)
  (newline)
  (displayln "/// NUTRISCAN PRO ANA MENÜ ///")
  (displayln "1. İsim ile Arama (Manuel)")
  (displayln "2. Sensör ile Tarama (Otomatik)")
  (displayln "3. Çıkış")
  (display ">> Seçiminiz (1/2/3): ")
  (flush-output)
  
  (define choice (read-line))
  
  (cond
    [(string=? choice "1")
     (display ">> Ürün Adı Girin: ")
     (flush-output)
     (define raw-input (read-line))
     (define search-key (string->symbol (string-downcase (string-trim raw-input))))
     
     (if (hash-has-key? PRODUCT-DB search-key)
         (let-values ([(score all risky) (analyze-product search-key)])
           (print-report (symbol->string search-key) score all risky))
         (displayln "\n[X] Ürün bulunamadı!"))
     (main-menu)]
    
    [(string=? choice "2")
     (simulate-sensor-scan)
     (main-menu)]
    
    [(string=? choice "3")
     (displayln "Güle güle homie!")]
    
    [else
     (displayln "[!] Geçersiz seçim.")
     (main-menu)]))

;; Programı başlat
(main-menu)