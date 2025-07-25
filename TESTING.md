# Testing

## Register

**Langkah 1** : Masuk ke pods backend

```bash
minikube kubectl -- exec -it <<nama_deployment_backend>> -- /bin/bash
```

**Langkah 2** : Uji Register

```bash
curl -X POST "http://localhost:8080/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "namaLengkap": "John Doe",
    "nik": "3175031234567890",
    "namaIbuKandung": "Mary Doe",
    "nomorTelepon": "081234567890",
    "email": "john.doe@example.com",
    "password": "JohnDoe123!",
    "tipeAkun": "BNI Taplus",
    "jenisKartu": "Gold",
    "tempatLahir": "Jakarta",
    "tanggalLahir": "1990-05-15",
    "jenisKelamin": "Laki-laki",
    "agama": "Islam",
    "statusPernikahan": "Belum Kawin",
    "pekerjaan": "Software Engineer",
    "sumberPenghasilan": "Gaji",
    "rentangGaji": "5-10 juta",
    "tujuanPembuatanRekening": "Tabungan",
    "alamat": {
      "namaAlamat": "Jl. Sudirman No. 123, RT 001/RW 002",
      "provinsi": "DKI Jakarta",
      "kota": "Jakarta Pusat",
      "kecamatan": "Tanah Abang",
      "kelurahan": "Bendungan Hilir",
      "kodePos": "10210"
    },
    "wali": {
      "jenisWali": "Ayah",
      "namaLengkapWali": "Robert Doe",
      "pekerjaanWali": "Pensiunan",
      "alamatWali": "Jl. Sudirman No. 123, RT 001/RW 002",
      "nomorTeleponWali": "081298765432"
    }
  }'
```

```bash
curl -X POST "http://localhost:8080/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "namaLengkap": "Jane Smith",
    "nik": "3175032345678901",
    "namaIbuKandung": "Anna Smith",
    "nomorTelepon": "081234567891",
    "email": "jane.smith@example.com",
    "password": "JaneSmith123!",
    "tipeAkun": "BNI Taplus",
    "jenisKartu": "Gold",
    "tempatLahir": "Jakarta",
    "tanggalLahir": "1995-08-22",
    "jenisKelamin": "Perempuan",
    "agama": "Kristen",
    "statusPernikahan": "Kawin",
    "pekerjaan": "Marketing Manager",
    "sumberPenghasilan": "Gaji",
    "rentangGaji": "10-15 juta",
    "tujuanPembuatanRekening": "Investasi",
    "alamat": {
      "namaAlamat": "Jl. Gatot Subroto No. 456, RT 003/RW 004",
      "provinsi": "DKI Jakarta",
      "kota": "Jakarta Selatan",
      "kecamatan": "Setiabudi",
      "kelurahan": "Kuningan Timur",
      "kodePos": "12950"
    },
    "wali": {
      "jenisWali": "Suami",
      "namaLengkapWali": "Michael Smith",
      "pekerjaanWali": "Konsultan",
      "alamatWali": "Jl. Gatot Subroto No. 456, RT 003/RW 004",
      "nomorTeleponWali": "081298765433"
    }
  }'
```
