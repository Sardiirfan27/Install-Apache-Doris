# Apache Doris 4.1.3 – Docker Installation Guide

Instalasi **Apache Doris 4.1.3** menggunakan Docker Compose dengan konfigurasi dasar:

- **Frontend (FE):** Apache Doris 4.1.3
- **Backend (BE):** Custom Docker Image Apache Doris dengan Python UDF Support
- **Python:** 3.12.11
- **Python Environment:** Miniforge / Conda
- **Python Dependencies:** pandas, pyarrow, libarrow-flight

---

## 1. Prasyarat Sebelum Instalasi

Pastikan beberapa kebutuhan berikut sudah tersedia:

1. Docker Desktop sudah terinstall.
2. Docker Desktop sudah berjalan.
3. Docker Compose tersedia.
4. Koneksi internet tersedia untuk mengunduh Docker Image dan dependency.

### 1.1. Jalankan Docker Desktop

Buka aplikasi **Docker Desktop** pada Windows.

Tunggu sampai Docker Engine berjalan dan status Docker Desktop menunjukkan bahwa Docker sudah aktif.

### 1.2. Verifikasi Docker

Buka terminal CMD, PowerShell, atau terminal VS Code.

Jalankan:

```bash
docker --version
```

Periksa Docker Compose:

```bash
docker compose version
```

Pastikan kedua perintah berhasil menampilkan versi.

Verifikasi Docker Engine:

```bash
docker info
```

Jika berhasil menampilkan informasi Docker Engine, berarti Docker sudah siap digunakan.

---

## 2. Project Structure

Pastikan struktur project sudah disiapkan seperti berikut:

```text
apache_doris/
│
├── docker-compose-doris.yml
├── Dockerfile.be
├── .env
│
└── data/
```

Keterangan:

| File / Folder | Fungsi |
|---|---|
| docker-compose-doris.yml | Konfigurasi service FE, BE, network, port, dan volume |
| Dockerfile.be | Membuat custom image BE dengan Python UDF support |
| .env | Menyimpan konfigurasi environment variable |
| data/ | Menyimpan data dan log Apache Doris |

Folder `data` dan subfolder yang digunakan pada bind mount akan dibuat otomatis oleh Docker jika belum tersedia.

---

## 3. Proses Instalasi (Build dan Jalankan Apache Doris)

Buka terminal pada direktori project `apache_doris`.

### 3.1. Validasi Docker Compose

Jalankan:

```bash
docker compose -f docker-compose-doris.yml config
```

Tujuan:
- Memastikan konfigurasi YAML valid.
- Memeriksa environment variable.
- Memeriksa konfigurasi service, port, volume, dan network.

Jika tidak ada error, lanjutkan ke tahap berikutnya.

### 3.2. Build dan Start Container

Jalankan:

```bash
docker compose -f docker-compose-doris.yml up -d --build
```

Perintah ini akan:

1. Mengunduh base image Apache Doris jika belum tersedia.
2. Membaca Dockerfile.be.
3. Menginstall Miniforge.
4. Membuat Conda environment `py312`.
5. Menginstall Python 3.12.11.
6. Menginstall dependency pandas, pyarrow, dan libarrow-flight.
7. Membuat custom Docker image untuk BE.
8. Membuat container FE dan BE.
9. Menjalankan kedua container.

**Catatan:** FE menggunakan image `apache/doris:all-in-one-4.1.3`, sedangkan BE menggunakan custom image `apache/doris-be-python:4.1.3`.

Build pertama mungkin membutuhkan waktu lebih lama karena harus mengunduh image dan dependency Python.

---

## 4. Verifikasi Container

Setelah proses selesai, periksa status container:

```bash
docker compose -f docker-compose-doris.yml ps
```

Pastikan kedua container sudah berjalan:

| Container | Service | Status |
|---|---|---|
| doris-fe-1 | FE | Running |
| doris-be-1 | BE | Running |

Untuk melihat seluruh container:

```bash
docker ps
```

Jika container belum berjalan, periksa log masing-masing service.

### 4.1. Periksa Log FE

```bash
docker compose -f docker-compose-doris.yml logs --tail=50 fe-1
```

### 4.2. Periksa Log BE

```bash
docker compose -f docker-compose-doris.yml logs --tail=50 be-1
```

Pastikan tidak ada error startup yang berulang.

---

## 5. Verifikasi Python Environment pada BE

Karena BE menggunakan custom image untuk mendukung Python UDF, pastikan instalasi Python berhasil.

### 5.1. Periksa Conda Environment

Jalankan:

```bash
docker exec -it doris-be-1 bash
```

Kemudian:

```bash
/opt/miniforge3/bin/conda env list
```

Pastikan environment `py312` tersedia.

### 5.2. Periksa Versi Python

```bash
/opt/miniforge3/envs/py312/bin/python --version
```

Hasil yang diharapkan:

```text
Python 3.12.11
```

### 5.3. Periksa Python Dependencies

```bash
/opt/miniforge3/envs/py312/bin/python -c "import pandas, pyarrow; print('Python dependencies OK')"
```

Hasil:

```text
Python dependencies OK
```

Jika seluruh pengecekan berhasil, berarti Python environment dan dependency sudah tersedia pada container BE.

Keluar dari container:

```bash
exit
```

---

## 6. Akses Apache Doris

Setelah FE dan BE berjalan, Apache Doris dapat diakses melalui beberapa port.

| Service | Port | Fungsi |
|---|---:|---|
| FE HTTP | 8030 | Web UI dan HTTP API |
| FE MySQL | 9030 | Koneksi SQL |
| BE HTTP | 8040 | HTTP API Backend |

### 6.1. Akses Web UI

Buka browser:

```text
http://localhost:8030
```

### 6.2. Koneksi Menggunakan DBeaver

Buat koneksi baru menggunakan driver MySQL.

Konfigurasi:

| Parameter | Value |
|---|---|
| Host | localhost |
| Port | 9030 |
| Database | default_db |
| Username | root |
| Password | Kosong (default) |

Klik Test Connection.

Jika berhasil, koneksi ke Apache Doris sudah tersedia.

---

## 7. Verifikasi FE dan BE

Setelah berhasil terhubung melalui DBeaver, jalankan SQL berikut:

### 7.1. Periksa Frontend

```sql
SHOW FRONTENDS;
```

Pastikan FE sudah terdaftar dan aktif.

### 7.2. Periksa Backend

```sql
SHOW BACKENDS;
```

Pastikan BE sudah terdaftar dan kolom `Alive` bernilai `true`.

Contoh kondisi yang diharapkan:

| Backend | Alive |
|---|---|
| be-1 | true |

Jika `Alive = true`, berarti BE sudah terhubung dan aktif pada cluster Apache Doris.

---

## 8. Pengujian Python UDF

Setelah FE dan BE berjalan serta Python environment tersedia, lanjutkan dengan pengujian Python UDF.

Pastikan konfigurasi BE berikut aktif:

```properties
enable_python_udf_support = true
python_env_mode = conda
python_conda_root_path = /opt/miniforge3
```

Konfigurasi tersebut sudah disiapkan melalui `BE_CONFIG_EXTRA` pada Docker Compose.

Selanjutnya, lakukan pengujian dengan membuat Python UDF sederhana melalui SQL.

Pastikan fungsi berhasil dibuat dan dapat dieksekusi.

**Catatan:** Python environment yang berhasil diinstall belum otomatis membuktikan Python UDF sudah berfungsi. Pengujian eksekusi UDF tetap diperlukan.

---

## 9. Perintah Operasional Docker

Berikut beberapa perintah yang sering digunakan.

### Melihat Status Container

```bash
docker compose -f docker-compose-doris.yml ps
```

### Melihat Log Semua Service

```bash
docker compose -f docker-compose-doris.yml logs -f
```

### Menghentikan Container

```bash
docker compose -f docker-compose-doris.yml stop
```

### Menjalankan Kembali Container

```bash
docker compose -f docker-compose-doris.yml start
```

### Restart Container

```bash
docker compose -f docker-compose-doris.yml restart
```

### Menghapus Container dan Network

```bash
docker compose -f docker-compose-doris.yml down
```

### Build Ulang Custom Image BE

```bash
docker compose -f docker-compose-doris.yml build --no-cache be-1
```

Kemudian jalankan kembali:

```bash
docker compose -f docker-compose-doris.yml up -d
```

**Penting:** Jangan menggunakan `docker compose down -v` atau menghapus folder `data` jika masih ingin mempertahankan metadata dan data Apache Doris.

---

## 10. Installation Checklist

Gunakan checklist berikut untuk memastikan seluruh proses instalasi berhasil.

- [ ] Docker Desktop sudah berjalan.
- [ ] Docker Engine berhasil diverifikasi.
- [ ] Docker Compose berhasil diverifikasi.
- [ ] Docker Compose configuration valid.
- [ ] Custom BE image berhasil dibangun.
- [ ] Container FE berhasil berjalan.
- [ ] Container BE berhasil berjalan.
- [ ] Python 3.12.11 berhasil diinstall.
- [ ] Conda environment `py312` tersedia.
- [ ] pandas dan pyarrow berhasil diimport.
- [ ] Web UI FE dapat diakses.
- [ ] DBeaver berhasil terhubung.
- [ ] FE terdaftar dan aktif.
- [ ] BE terdaftar dengan `Alive = true`.
- [ ] Python UDF berhasil dibuat dan dieksekusi.

---

**Installation Complete!**

Apache Doris 4.1.3 sudah siap digunakan setelah seluruh pengecekan berhasil, termasuk pengujian Python UDF.

