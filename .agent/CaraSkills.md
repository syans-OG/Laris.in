# CaraSkills.md

Panduan teknis penggunaan *Antigravity Skills* untuk proyek Fashion 3D Website. Dokumen ini menjelaskan cara instalasi, sintaks pemanggilan, dan alur kerja (workflow) terbaik.




## 1. Persiapan & Instalasi
Agar Agen AI (Cursor/Claude/Antigravity) bisa membaca skill yang sudah Anda pilih, Anda harus menempatkannya di struktur folder yang benar.

**Langkah-langkah:**
1.  Di dalam folder utama proyek Anda (root folder), buat folder baru bernama `.agent` (titik agent).
2.  Di dalam folder `.agent`, buat folder lagi bernama `skills`.
3.  Salin folder-folder skill yang sudah Anda pilih (seperti `3d-web-experience`, `frontend-design`, dll) ke dalam folder `.agent/skills/`.

**Struktur Folder Akhir:**
```text
Proyek-Fashion-3D/
├── .agent/
│   └── skills/
│       ├── 3d-web-experience/
│       ├── behavioral-modes/
│       ├── systematic-debugging/
│       └── ... (skill lainnya)
├── src/
└── package.json
```
*Catatan: Agen AI akan otomatis memindai folder ini untuk memahami instruksi baru.*





## 2. Cara Memanggil Skill (Invocation)
Ada dua cara utama untuk mengaktifkan skill saat Anda *chatting* dengan AI:

**A. Panggilan Eksplisit (Wajib untuk Skill Penting)**
Gunakan simbol `@` atau sebutkan nama skill secara spesifik di awal *prompt* untuk memastikan AI menggunakannya.
*   **Contoh:** *"@3d-web-experience tolong buatkan scene Three.js dasar untuk menampilkan model baju."*
*   **Contoh:** *"Use `ui-ux-pro-max` to design a luxury navbar for this fashion brand."*

**B. Panggilan Otomatis (Kontekstual)**
Beberapa skill seperti `clean-code` atau `lint-and-validate` biasanya berjalan otomatis jika Anda meminta AI menulis kode, tetapi sebaiknya diingatkan sesekali.
*   **Contoh:** *"Refactor this code. Remember to follow `clean-code` principles."*





## 3. Alur Kerja (Workflow) Pembuatan Website 3D
Gunakan urutan pemanggilan skill ini agar pengembangan website Anda efisien dan tidak *error* di tengah jalan.

### Tahap 1: Inisialisasi Otak Agen
*Sebelum mulai kerja, atur pola pikir agen.*
> **Prompt:** "Active `@using-superpowers` and `@behavioral-modes`. Switch to **Architect Mode**. I want to build a 3D fashion website using Next.js and Three.js."

### Tahap 2: Perencanaan & Desain
*Jangan langsung koding. Matangkan visual dulu.*
> **Prompt:** "Use `@brainstorming` to help me define the user flow for a scrollytelling experience. Then, use `@ui-ux-pro-max` to suggest a color palette and layout that looks like a high-end fashion brand (e.g., Balenciaga style)."

### Tahap 3: Implementasi Fitur 3D (Inti Proyek)
*Ini adalah tahap terberat. Gunakan skill spesialis.*
> **Prompt:** "Switch to **Implement Mode**. Use `@3d-web-experience` and `@frontend-dev-guidelines`. Create a React Three Fiber component to load a GLB model of a hoodie. Ensure lighting is cinematic."





### Tahap 4: Animasi Scroll
*Menambahkan interaksi.*
> **Prompt:** "Now use `@scroll-experience`. I want the hoodie to rotate 360 degrees as the user scrolls down the page. Help me configure the scroll controls."





### Tahap 5: Debugging & Finishing
*Jika ada error atau website terasa berat.*
> **Prompt:** "The animation feels laggy. Use `@web-performance-optimization` to analyze why. Also, run `@systematic-debugging` on the `ModelViewer.tsx` file to fix the hydration error."

## 4. Tips & Trik Penggunaan

**1. Screenshot Feedback Loop**
AI visual (seperti Gemini 3 Pro/Claude 3.5 Sonnet) bekerja sangat baik dengan gambar.
*   **Cara:** Ambil screenshot tampilan website Anda yang masih berantakan.
*   **Prompt:** *"Look at this screenshot. Use `@frontend-design` to fix the alignment and make it look exactly like the design reference I gave you earlier."*

**2. Jangan Campur Aduk Mode**
Jika agen mulai berhalusinasi atau memberikan jawaban aneh, kemungkinan dia bingung mode.
*   **Solusi:** Ketik *"Stop. Reset context. Switch to `@systematic-debugging` mode only."*

**3. Gunakan "Planning with Files" untuk Proyek Besar**
Karena website 3D kompleks, minta agen mencatat progresnya.
*   **Prompt:** *"Use `@planning-with-files`. Create a `todo.md` file and check off the items as we build the 3D viewer."*

## 5. Cheat Sheet Perintah Cepat

| Tujuan | Perintah / Prompt |
| :--- | :--- |
| **Mulai Proyek** | "Setup project structure using `@nextjs-best-practices` and `@file-organizer`." |
| **Bikin 3D** | "Create 3D scene using `@3d-web-experience`." |
| **Bikin Cantik** | "Style this component using `@ui-ux-pro-max` and `@tailwind-patterns`." |
| **Cek Error** | "Fix this error using `@systematic-debugging`." |
| **Cek Speed** | "Audit performance using `@web-performance-optimization`." |
| **Mau Deploy** | "Prepare for production using `@vercel-deployment`." |