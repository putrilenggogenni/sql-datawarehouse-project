# SQL Data Warehouse

Proyek pembelajaran mandiri: membangun Data Warehouse dengan **SQL Server** menggunakan **Medallion Architecture (Bronze, Silver, Gold)**, mencakup proses ETL dengan T-SQL, data modeling (Star Schema), dan pemeriksaan kualitas data.

> Proyek ini dibuat berdasarkan materi kursus [DataWithBaraa](https://github.com/DataWithBaraa/sql-data-warehouse-project) (MIT License). Dataset dan konsep arsitektur berasal dari kursus tersebut, sedangkan script ditulis dan dijalankan ulang sebagai bahan belajar.

## Arsitektur

Data dari dua sistem sumber (CRM dan ERP) dimuat ke SQL Server, dibersihkan secara bertahap, lalu dimodelkan menjadi Star Schema yang siap untuk pelaporan.

![High Level Architecture](docs/Data%20Architect.drawio.png)

| Layer | Fungsi | Objek | Cara Load |
|---|---|---|---|
| Bronze | Menyimpan data mentah apa adanya, tanpa transformasi | Tabel | Full load (truncate & insert) dengan `BULK INSERT` |
| Silver | Cleansing, standardisasi, derived column, enrichment | Tabel | Full load (truncate & insert) dari Bronze |
| Gold | Integrasi data dan model siap pakai (Star Schema) | View | Tidak ada proses load |

### Data Flow

Alur dari tiap tabel sumber sampai ke tabel Gold:

![Data Flow](docs/Data%20Flow.drawio.png)

## Dataset

Dataset berisi **6 file CSV** dari dua sistem sumber. Tema datanya adalah toko sepeda (pelanggan, produk, dan transaksi penjualan), mirip AdventureWorks. File ini disimpan di folder `dataset/`.

| Sistem | File | Isi | Kolom utama | Jumlah baris |
|---|---|---|---|---|
| CRM | `cust_info.csv` | Data pelanggan | `cst_id`, `cst_key`, nama, status pernikahan, gender, tanggal dibuat | 18.493 |
| CRM | `prd_info.csv` | Data produk beserta riwayat harga | `prd_id`, `prd_key`, nama, biaya, product line, tanggal mulai dan akhir | 397 |
| CRM | `sales_details.csv` | Detail transaksi penjualan | nomor order, `prd_key`, `cst_id`, tanggal order/kirim/jatuh tempo, sales, quantity, price | 60.398 |
| ERP | `CUST_AZ12.csv` | Tambahan data pelanggan | `CID`, tanggal lahir, gender | 18.483 |
| ERP | `LOC_A101.csv` | Lokasi pelanggan | `CID`, negara | 18.484 |
| ERP | `PX_CAT_G1V2.csv` | Kategori produk | `ID`, kategori, subkategori, maintenance | 35 |

CRM adalah sumber utama untuk pelanggan, produk, dan penjualan. ERP melengkapi informasi yang tidak ada di CRM (tanggal lahir, negara, kategori produk). Tabel-tabel ini dihubungkan lewat kunci pelanggan (`cst_key` ↔ `CID`) dan kunci produk (`prd_key` ↔ `ID` kategori).

### Masalah kualitas data pada data mentah

Data sengaja dibuat kotor supaya proses cleansing di Silver bermakna. Contohnya:

- Spasi berlebih di awal atau akhir teks (misalnya nama pelanggan).
- Nilai berupa kode satu huruf (`M`, `F`, `S`, `R`) yang perlu diubah menjadi nilai deskriptif.
- Tanggal transaksi disimpan sebagai angka 8 digit (`20101229`), bukan tipe tanggal.
- Biaya produk kosong (`NULL`).
- Format kunci berbeda antar sistem: `AW00011000` di CRM, `NASAW00011000` di tabel ERP pelanggan, dan `AW-00011000` di tabel lokasi.

## Struktur Repo

```
.
├── dataset/
│   ├── source_crm/          # cust_info.csv, prd_info.csv, sales_details.csv
│   └── source_erp/          # CUST_AZ12.csv, LOC_A101.csv, PX_CAT_G1V2.csv
├── docs/                    # diagram arsitektur dan data flow
├── scripts/
│   ├── init_database.sql    # membuat database DataWarehouse dan schema bronze/silver/gold
│   ├── bronze/              # ddl_bronze.sql, proc_load_bronze.sql
│   ├── silver/              # ddl_silver.sql, proc_load_silver.sql
│   └── gold/                # ddl_gold.sql
└── tests/                   # quality_checks_silver.sql, quality_checks_gold.sql
```

## Cara Menjalankan

**Prasyarat:** SQL Server dan SQL Server Management Studio (SSMS).

1. Letakkan keenam file CSV di folder `dataset/` sesuai struktur di atas.
2. Buka `scripts/bronze/proc_load_bronze.sql`, lalu **ubah path di setiap `BULK INSERT`** agar menunjuk ke lokasi folder `dataset/` di komputermu. Path harus bisa diakses oleh layanan SQL Server.
3. Jalankan script berikut secara berurutan:

```sql
-- 1. Database dan schema
scripts/init_database.sql

-- 2. Bronze
scripts/bronze/ddl_bronze.sql
scripts/bronze/proc_load_bronze.sql
EXEC load_bronze;

-- 3. Silver
scripts/silver/ddl_silver.sql
scripts/silver/proc_load_silver.sql
EXEC silver.load_silver;

-- 4. Pemeriksaan kualitas Silver
tests/quality_checks_silver.sql

-- 5. Gold
scripts/gold/ddl_gold.sql

-- 6. Pemeriksaan kualitas Gold
tests/quality_checks_gold.sql
```

## Proses ETL

**Bronze** memuat CSV apa adanya ke tabel dengan `BULK INSERT`. Setiap proses memakai `TRUNCATE` sebelum insert, mencatat durasi, dan menangani error dengan `TRY...CATCH`.

**Silver** membersihkan dan menstandarkan data dari Bronze:
- Deduplikasi pelanggan dengan `ROW_NUMBER()`, mengambil catatan terbaru per `cst_id`.
- `TRIM` pada kolom teks.
- Standardisasi kode menjadi nilai deskriptif (gender, status pernikahan, product line).
- Derived column: `cat_id` dan `prd_key` dipecah dari kunci produk, `prd_end_dt` dihitung dengan `LEAD()`.
- Konversi tanggal 8 digit menjadi tipe `DATE` dan perbaikan nilai sales/price yang tidak konsisten.

## Model Data (Gold)

Gold berisi tiga view yang membentuk Star Schema:

| View | Tipe | Isi |
|---|---|---|
| `gold.dim_customers` | Dimensi | Data pelanggan dari CRM digabung dengan tanggal lahir dan negara dari ERP. Gender memakai CRM sebagai acuan utama dan ERP sebagai cadangan. |
| `gold.dim_products` | Dimensi | Data produk dari CRM digabung dengan kategori dari ERP, hanya versi produk yang masih aktif. |
| `gold.fact_sales` | Fakta | Transaksi penjualan yang terhubung ke kedua dimensi lewat surrogate key. |

Surrogate key (`customer_key`, `product_key`) dibuat dengan `ROW_NUMBER()`.

## Pemeriksaan Kualitas Data

Folder `tests/` berisi query validasi yang dijalankan setelah tiap layer selesai dimuat:

- **Silver:** primary key NULL atau duplikat, spasi yang tidak diinginkan, konsistensi nilai standar, urutan tanggal yang valid, dan kesesuaian `sales = quantity × price`.
- **Gold:** keunikan surrogate key, keunikan natural key, integritas relasi antara fact dan dimensi, serta pengecekan bahwa jumlah baris `fact_sales` sama dengan Silver (tidak ada baris yang menggandakan akibat join).

## Teknologi

Microsoft SQL Server, T-SQL (Stored Procedure, window function, CTE), SSMS.

## Lisensi dan Atribusi

Proyek ini memakai lisensi MIT (lihat `LICENSE`). Konsep dan dataset berasal dari materi kursus DataWithBaraa.
