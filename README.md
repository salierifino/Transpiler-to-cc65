# Transpiler-to-cc65

Transpiler atau Translater bahasa pemrograman custom, dari bahasa Indonesia ke cc65. Yang dapat digunakan untuk membuat game NES (Nintendo Entertainment System).

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
