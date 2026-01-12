# Skema Pendaftaran & Link Akun (Parent-First Strategy)

Dokumen ini menjelaskan alur "Orang Tua Mendaftarkan Anak" yang digunakan dalam aplikasi Ruang Les.

## Konsep Utama
1.  **Orang Tua adalah Admin Keluarga**: Akun utama adalah milik Orang Tua.
2.  **Anak Tidak Register Sendiri**: Akun anak dibuatkan melalui dashboard Orang Tua.
3.  **Automatic Linking**: Karena dibuat dari akun orang tua, sistem langsung menghubungkan (link) data anak ke orang tua tersebut.

---

## Alur Pendaftaran (Step-by-Step)

### 1. Orang Tua Mendaftar (Register)
*   **Aktor**: Orang Tua (Baru)
*   **Lokasi**: Halaman Register
*   **Input**: Nama Lengkap, Email, Password, No. HP.
*   **Proses**:
    *   Sistem membuat akun di `users` (Role: 'parent').
    *   Sistem membuat dokumen kosong di `parents` dengan `studentIds: []`.
*   **Hasil**: Orang tua bisa login dan masuk ke Dashboard.

### 2. Orang Tua Menambahkan Anak
*   **Aktor**: Orang Tua (Sudah Login)
*   **Lokasi**: Parent Dashboard -> Tombol "+ Tambah Anak"
*   **Input**:
    *   Nama Lengkap Anak
    *   Nama Panggilan
    *   Tingkat Kelas (SD 1-3, SD 4-6, SMP, dll)
    *   Pilih Kelas (Opsional/Dropdown)
*   **Proses**:
    1.  **Create Student User**: Sistem membuat akun Auth untuk siswa (bisa auto-generate email/pass sementara).
    2.  **Create Data**:
        *   Buat dokumen di `users` (Role: 'student').
        *   Buat dokumen di `students` dengan data:
            *   `parentId`: ID Orang Tua yang sedang login.
            *   `classId`: ID Kelas yang dipilih.
            *   `gradeLevel`: Tingkat kelas.
    3.  **Link to Parent**:
        *   Update dokumen `parents` milik orang tua: tambahkan ID Anak baru ke array `studentIds`.
*   **Hasil**: Data anak langsung muncul di Dashboard Orang Tua (Progress & Tagihan).

---

## Struktur Data & Relasi

### Users Collection
*   **Parent User**:
    ```json
    { "uid": "parent_001", "role": "parent", "email": "ibu@test.com" }
    ```
*   **Student User** (Dibuat Otomatis):
    ```json
    { "uid": "student_999", "role": "student", "email": "student_999@ruangles.id" }
    ```

### Parent & Student Collections
*   **Parent Doc** (`parents/parent_001`):
    ```json
    {
      "userId": "parent_001",
      "studentIds": ["student_999"] // <-- Array ID Anak
    }
    ```
*   **Student Doc** (`students/student_999`):
    ```json
    {
      "userId": "student_999",
      "fullName": "Budi Santoso",
      "parentId": "parent_001", // <-- Reference balik ke Orang Tua
      "classId": "class_math_01"
    }
    ```

---

## Kelebihan Metode Ini
1.  **Data Terjamin**: Tidak ada akun siswa "yatim piatu" (tanpa orang tua).
2.  **Pembayaran Valid**: Tagihan siswa otomatis tersambung ke orang tua yang tepat.
3.  **Simpel untuk Anak**: Anak tinggal login pakai username/password yang diberikan orang tua, tidak perlu pusing verifikasi email.
