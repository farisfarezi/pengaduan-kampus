# Pengaduan Fasilitas Kampus (Flutter)

## Cara menjalankan
1. Install Flutter, cek dengan `flutter doctor`.
2. `flutter create pengaduan_kampus`, lalu timpa folder `lib/` dan `pubspec.yaml` dengan isi dari sini.
3. `flutter pub get`
4. Tambahkan izin di `android/app/src/main/AndroidManifest.xml` (dalam `<manifest>`, sebelum `<application>`):

       <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
       <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
       <uses-permission android:name="android.permission.CAMERA"/>

5. `flutter run`

## Akun
- Mahasiswa: daftar sendiri lewat tombol "Belum punya akun? Daftar".
- Admin bawaan: `admin@kampus.id` / `admin123`

## Database (SQLite)
users   : id, name, email (unik), password (SHA-256), role (mahasiswa/admin)
reports : id, user_id (FK ke users), title, description, category, photo_path,
          latitude, longitude, location_note, status, created_at

## Fitur
- Daftar akun, login, logout (login tersimpan)
- Dashboard ringkasan (Total, Menunggu, Diproses, Selesai)
- Mahasiswa: kirim laporan (foto, GPS, lokasi), lihat laporan sendiri + statusnya
- Admin: lihat semua laporan beserta pelapor, ubah status, hapus laporan
