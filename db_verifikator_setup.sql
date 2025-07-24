-- ===== FIX DATABASE SCHEMA ISSUES =====
-- File: database_fix.sql
-- Run: psql -U postgres -d dukcapil_ktp -f sql/database_fix.sql

DROP DATABASE IF EXISTS dukcapil_ktp;
CREATE DATABASE dukcapil_ktp WITH OWNER postgres;

-- 1. Drop problematic view first
DROP VIEW IF EXISTS ktp_summary CASCADE;

-- 2. Drop existing table to recreate fresh
DROP TABLE IF EXISTS ktp_dukcapil CASCADE;

\connect dukcapil_ktp;

-- 3. Create table with correct column types
CREATE TABLE ktp_dukcapil (
    id BIGSERIAL PRIMARY KEY,
    nik VARCHAR(20) NOT NULL UNIQUE,
    nama_lengkap VARCHAR(100) NOT NULL,
    tempat_lahir VARCHAR(50) NOT NULL,
    tanggal_lahir DATE NOT NULL,
    jenis_kelamin VARCHAR(255) NOT NULL CHECK (jenis_kelamin IN ('LAKI_LAKI', 'PEREMPUAN')),
    nama_alamat TEXT NOT NULL,
    kecamatan VARCHAR(50) NOT NULL,
    kelurahan VARCHAR(50) NOT NULL,
    agama VARCHAR(255) NOT NULL CHECK (agama IN ('ISLAM', 'KRISTEN', 'BUDDHA', 'HINDU', 'KONGHUCU', 'LAINNYA')),
    status_perkawinan VARCHAR(20) NOT NULL,
    kewarganegaraan VARCHAR(20) DEFAULT 'WNI' NOT NULL,
    berlaku_hingga VARCHAR(20) DEFAULT 'SEUMUR HIDUP' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create indexes
CREATE INDEX idx_ktp_nik ON ktp_dukcapil(nik);
CREATE INDEX idx_ktp_nama ON ktp_dukcapil(LOWER(nama_lengkap));
CREATE INDEX idx_ktp_nik_nama ON ktp_dukcapil(nik, LOWER(nama_lengkap));

-- 5. Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_ktp_updated_at
    BEFORE UPDATE ON ktp_dukcapil
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 6. Insert sample data
INSERT INTO ktp_dukcapil (
    nik, nama_lengkap, tempat_lahir, tanggal_lahir, jenis_kelamin,
    nama_alamat, kecamatan, kelurahan, agama, status_perkawinan
) VALUES 
('3175031234567890', 'John Doe', 'Jakarta', '1990-05-15', 'LAKI_LAKI',
 'Jl. Sudirman No. 123, RT 001/RW 002', 'Tanah Abang', 'Bendungan Hilir', 'ISLAM', 'BELUM KAWIN'),

('3175032345678901', 'Jane Smith', 'Jakarta', '1995-08-22', 'PEREMPUAN', 
 'Jl. Gatot Subroto No. 456, RT 003/RW 004', 'Setiabudi', 'Kuningan Timur', 'KRISTEN', 'KAWIN'),

('3175033456789012', 'Ahmad Rahman', 'Bogor', '1985-12-10', 'LAKI_LAKI',
 'Jl. Thamrin No. 789, RT 005/RW 006', 'Menteng', 'Gondangdia', 'ISLAM', 'KAWIN'),

('3175034567890123', 'Siti Nurhaliza', 'Depok', '1992-03-18', 'PEREMPUAN',
 'Jl. HR Rasuna Said No. 321, RT 007/RW 008', 'Setiabudi', 'Setiabudi', 'ISLAM', 'BELUM KAWIN'),

('3175035678901234', 'Budi Santoso', 'Jakarta', '1988-11-25', 'LAKI_LAKI',
 'Jl. Kemang Raya No. 654, RT 009/RW 010', 'Mampang Prapatan', 'Kemang', 'BUDDHA', 'KAWIN'),

('1234567890123456', 'Test User One', 'Jakarta', '1995-01-01', 'LAKI_LAKI',
 'Jl. Test No. 123', 'Test Kecamatan', 'Test Kelurahan', 'ISLAM', 'BELUM KAWIN'),

('1234567890123457', 'Test User Two', 'Bandung', '1992-02-02', 'PEREMPUAN',
 'Jl. Test No. 456', 'Test Kecamatan', 'Test Kelurahan', 'KRISTEN', 'KAWIN');

-- 7. Verify data
SELECT 'Database fixed successfully!' as status;
SELECT COUNT(*) as total_records FROM ktp_dukcapil;
SELECT nik, nama_lengkap, jenis_kelamin, agama FROM ktp_dukcapil LIMIT 5;