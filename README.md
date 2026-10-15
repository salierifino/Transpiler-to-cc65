# Transpiler-to-cc65

Transpiler atau Translater bahasa pemrograman custom, dari bahasa Indonesia ke cc65. Yang dapat digunakan untuk membuat game NES (Nintendo Entertainment System). 

File-file :  
indo.sh : File utama untuk transpilasi  
setup.sh : File untuk menaruh file utama ke ~/../usr/bin  
metagame.indo : File .indo contoh/demo  
tes.s : Hasil transpilasi ke ASM cc65  

## 1. Cara menggunakan
Ada beberapa cara menggunakan bahasa pemrograman ini.
**Cara yang pertama** adalah dengan meletakkan file *indo.sh* di folder yang sama dengan file pemograman bahasa .indo yang ingin dikompilasi. Contoh nama file .indo anda adalah *gameSaya.indo*.
Kemudian, ketikkan perintah Bash berikut setiap anda ingin mengkompilasi.
```bash
bash indo.sh gameSaya.indo
```
**Cara yang kedua** adalah dengan meletakkan file *indo.sh* ke directory *home* atau ~. Kemudian tambahkan izin execute menggunakan perintah Bash :
```bash
chmod +x indo.sh
```
Kemudian ganti namanya dengan tanpa .sh
```
mv indo.sh indo
```
Kemudian pindahkan ke *~/../usr/bin/*
Setelah itu, panggil setiap anda ingin kompilasi file .indo di mana saja hanya dengan perintah :
```bash
indo gameSaya.indo
```
**Cara yang ketiga** adalah dengan meletakkan file *indo.sh* dan *setup.sh* di folder yang sama, kemudian menjalankan setup.sh.
```bash
bash setup.sh
```
Kemudian, anda bisa menggunakannya hanya dengan perintah:
```bash
indo gameSaya.indo
```

## 2. Sintaksis
*metagame.sh* adalah contoh sintaksis pemograman bahasa .indo yang cukup lengkap, karena memang pemograman ini belum mencakup banyak hal karena ditranslasi langsung ke bahasa cc65.
**1. Deklarasi dan definisi variabel**
```indo
ingat namaVariabel bernilai 10
namaVariabel bernilai 7
namaVariabel bertambah 8
namaVariabel berkurang
```
Deklarasi menggunakan kata "**ingat**" di depannya, diikuti kata "**bernilai**" dan juga nilainya. 
Kemudian perubahan nilai variabel dapat menggunakan kata "**bernilai**", "**bertambah**", dan "**berkurang**".
Jika bertambah dan berkurang tidak mencantumkan angka, berarti bertambah atau berkurang sebanyak satu.

**2. Perulangan game**
Menggunakan kata "**perulangan**" untuk memulai perulangan dan kata "**tutup**" untuk menutup perulangan. Hanya ada satu perulangan dan itu berjalan selamanya.
Ada juga fungsi "**berakhir**" untuk keluar dari perulangan dan game over.

**3. Percabangan kondisi**
Menggabungkan sintaksis :
```
jika .... maka #... diisi kondisi
.... #jika kondisi benar
lain
... #jika kondisi salah
tutup
```
Hanya memuat satu kondisi saja, tidak ada 'dan', 'atau' atau juga 'else if'.

**4. Menggambar kotak**
```indo
gambar koorX koorY merah
```
Warna hanya ada RGB(Red Green Blue)

**5. Tombol**
Ada 8 tombol.
A, B, Select, Start, Atas, Bawah, Kiri, dan Kanan.
```
tombol Atas ditekan
... #jika tombol ditekan
tutup

tombol Atas dilepas
... #jika tidak ditekan
tutup
```

## 3. Cara menjalankan 
Setelah proses mengkompilasi, maka akan muncul file .nes hasil kompilasi dengan nama yang sama dengan angka waktu kompilasi di belakangnya.

File .s hasil translasi telah terhapus pada proses, dan jika tidak terdapat cc65, maka akan otomatis terunduh. Khusus android atau termux, menggunakan pkg.

File .nes ini hanya dapat dijalankan menggunakan emulator seperti RetroArch dan semacamnya yang bisa diunduh lewat play store.

## 4. Target
1. Mengubah sintaksis dan kosakata menjadi lebih mudah dan terbaca bagi awam
2. Menambahkan banyak fitur seperti else if, random number, dan semacamnya
3. Menambahkan fungsi dan impor, agar bisa mengambil kode dari sumber kode indo lain
4. Dapat dijalankan diberbagai OS
5. Rewrite dari Bash ke C atau semacamnya
