#!/data/data/com.termux/files/usr/bin/bash

if ! command -v cc65 &> /dev/null; then
	echo Install cc65
	if command -v pkg &> /dev/null; then
		pkg update && pkg install -y cc65
	fi
fi

nama_file=$1
if [[ "$nama_file" != *.indo ]]; then
        echo "Ini bukan file pemograman indo!"
        exit 1
fi

isi_file=$(<$nama_file)

posisisekarang=$(pwd)

mkdir -p $HOME/nes_tes
cd $HOME/nes_tes


cat > tes.s << 'EOF'
.segment "HEADER"
  .byte "NES", $1A
  .byte 1
  .byte 1
  .byte $01
  .byte $00
  .byte $00,$00,$00,$00,$00,$00,$00,$00

.segment "ZEROPAGE"
  gameisOver: .res 1
EOF

memory=0

lokasi_parent=""
lokasi=setup

if_count=1
fungsi_kosong=""
nest_count=""


#Jika debugging, tidak menghapus folder nes_tes
> zeropage.tmp
> setup.tmp
> loop.tmp
> fungsi.tmp
> gambar.tmp
cat > kontrol.tmp << 'EOF'
ReadController1:
  LDA #1
  STA $4016
  LDA #0
  STA $4016

EOF

for i in {1..8}; do
	echo "kontrol${i}:" > kontrol${i}.tmp
	echo "  LDA \$4016" >> kontrol${i}.tmp
done

#pecah perbaris
while IFS= read -r baris; do
	# pecah perkata
	read -r kata1 kata2 kata3 kata4 kata5 sisa <<< "$baris"

	if [[ "$kata1" == \#* || "$kata1" == "" ]]; then
		continue

	#jika mengandung kata ingat, deklarasi variabel
	elif [[ "$kata1" == "ingat" ]]; then
		#jika diawali angka
		if [[ "$kata2" =~ ^[0-9] ]]; then
			echo "Error: nama variabel '$kata2' tidak boleh diawali angka" >&2
			exit 1
		fi

		#jika tidak ada di zeropage, tambahkan ke zeropage, kalau ada, ngga usah
		if grep -q "^$kata2:" zeropage.tmp; then	
			echo "Warning: variabel '$kata2' sudah didefinisikan" >&2
		else 
			echo "$kata2: .res 1" >> zeropage.tmp
		fi
		if [[ "$kata3" == "bernilai" && -n "$kata4" ]]; then
			if [[ "$kata4" =~ ^[0-9] ]]; then
				echo "  LDA #$kata4" >> $lokasi.tmp
			else 
				echo "  LDA $kata4" >> $lokasi.tmp
			fi
			echo "  STA $kata2" >> $lokasi.tmp
		fi

	# definisi dan perubahan variabel
	elif grep -q "^$kata1:" zeropage.tmp; then
		if [[ "$kata2" == "bernilai" && -n "$kata3" ]]; then
			if [[ "$kata3" =~ ^[0-9] ]]; then
                                echo "  LDA #$kata3" >> $lokasi.tmp
                        else
                                echo "  LDA $kata3" >> $lokasi.tmp
                        fi
        		echo "  STA $kata1" >> $lokasi.tmp

		#penjumlahan
		elif [[ "$kata2" == "bertambah" ]]; then
			if [[ -z "$kata3" || "$kata3" == "1" ]]; then
				echo "  INC $kata1" >> $lokasi.tmp
			else
				echo "  LDA $kata1" >> $lokasi.tmp
				echo "  CLC" >> $lokasi.tmp
				if [[ "$kata3" =~ ^[0-9] ]]; then
                                	echo "  ADC #$kata3" >> $lokasi.tmp
                        	else
                                	echo "  ADC $kata3" >> $lokasi.tmp
                        	fi
        			echo "  STA $kata1" >> $lokasi.tmp
			fi

		#pengurangan
        	elif [[ "$kata2" == "berkurang" ]]; then
        		if [[ -z "$kata3" || "$kata3" == "1" ]]; then
        			echo "  DEC $kata1" >> $lokasi.tmp
        		else
				echo "  LDA $kata1" >> $lokasi.tmp
                                echo "  SEC" >> $lokasi.tmp
				if [[ "$kata3" =~ ^[0-9] ]]; then
                                        echo "  SBC #$kata3" >> $lokasi.tmp
                                else
                                        echo "  SBC $kata3" >> $lokasi.tmp
                                fi
        			echo "  STA $kata1" >> $lokasi.tmp
			fi
		fi
	# percabangan kondisi
	elif [[ "$kata1" == "jika" ]]; then
		echo "  JSR brch$if_count" >> $lokasi.tmp
		echo "brch$if_count:" >> fungsi${nest_count}.tmp
		echo "  LDA $kata2" >> fungsi${nest_count}.tmp
		if [[ "$kata4" =~ ^[0-9] ]]; then
                        echo "  CMP #$kata4" >> fungsi${nest_count}.tmp
                else
                        echo "  CMP $kata4" >> fungsi${nest_count}.tmp
                fi
		#macam2 perbandingan, tapi untuk kebalikan/ elsenya
		if [[ "$kata3" == "=" ]];then #jika =, elsenya jadi ≠
			echo "  BNE elseBrch${if_count}" >> fungsi${nest_count}.tmp
		elif [[ "$kata3" == "!" ]];then # jika ≠, elsenya jadi =
                        echo "  BNE elseBrch${if_count}" >> fungsi${nest_count}.tmp
		elif [[ "$kata3" == "<" ]];then # jika <, elsenya jadi >
                        echo "  BCS elseBrch${if_count}" >> fungsi${nest_count}.tmp
		elif [[ "$kata3" == ">" ]];then # jika >, elsenya jadi <
                        echo "  BCC elseBrch${if_count}" >> fungsi${nest_count}.tmp
		fi
		lokasi_parent="$lokasi_parent $lokasi"
		lokasi=fungsi$nest_count
		if [[ "$nest_count" == "" ]]; then
			nest_count=1
		else
			((nest_count++))
		fi
		# simpan Fungsi yang belum terdefinisi
		fungsi_kosong="$fungsi_kosong elseBrch${if_count}:"

		((if_count++))



	elif [[ "$kata1" == "lain" ]]; then
                ((nest_count--))
                if [[ "$nest_count" == 0 ]]; then
                        nest_count=""
                fi
                echo "  RTS" >> $lokasi.tmp
                #definisikan fungsi else yang tadi kosong
                temp_func=${fungsi_kosong##* } #ambil kata paling terakhir
                echo "${temp_func}" >> fungsi${nest_count}.tmp
                fungsi_kosong=${fungsi_kosong% *}

		if [[ "$nest_count" == "" ]]; then
                        nest_count=1
                else
                        ((nest_count++))
                fi

	elif [[ "$kata1" == "tutup" ]]; then
		if [[ $lokasi == fungsi* ]]; then
			((nest_count--))
			temp_func=${fungsi_kosong##* }
			echo "  RTS" >> $lokasi.tmp
			if [[ -n $temp_func ]]; then
				echo "${temp_func}" >> fungsi${nest_count}.tmp 
				echo "  RTS" >> fungsi${nest_count}.tmp
	                	fungsi_kosong=${fungsi_kosong% *}
			fi
	
			lokasi=${lokasi_parent##* } #ambil kata paling terakhir
			lokasi_parent=${lokasi_parent% *}
			if [[ "$nest_count" == 0 ]]; then
	                        nest_count=""
				cat fungsi?.tmp >> fungsi.tmp
				rm fungsi?.tmp
	                fi
		elif [[ $lokasi == kontrol* ]]; then
			if [[ $lokasi == kontrol? ]]; then
				num=${lokasi#kontrol}
				echo "  JMP kontrol$((num+1))" >> ${lokasi}.tmp
			fi
			
			lokasi=${lokasi_parent##* } #ambil kata paling terakhir
			lokasi_parent=${lokasi_parent% *}
		elif [[ $lokasi == loop ]]; then
			lokasi=setup
		fi
	
	elif [[ "$kata1" == perulangan* ]]; then
                lokasi=loop

	elif [[ "$kata1" == "gambar" ]]; then
		if [[ "$kata3" =~ ^[0-9] ]]; then
			echo "  LDA #$kata3" >> gambar.tmp
		else
			echo "  LDA $kata3" >> gambar.tmp
		fi
		echo "  STA \$020$memory" >> gambar.tmp && ((memory++))
		echo "  LDA #1" >> gambar.tmp
		echo "  STA \$020$memory" >> gambar.tmp && ((memory++))
		if [[ "$kata4" == "merah" ]]; then
			echo "  LDA #1" >> gambar.tmp
		elif [[ "$kata4" == "biru" ]]; then
                        echo "  LDA #2" >> gambar.tmp
		elif [[ "$kata4" == "hijau" ]]; then
                        echo "  LDA #3" >> gambar.tmp
		elif [[ "$kata4" == "putih" || -z "$kata4" ]]; then
                        echo "  LDA #0" >> gambar.tmp
		fi
		echo "  STA \$020$memory" >> gambar.tmp && ((memory++))
		if [[ "$kata2" =~ ^[0-9] ]]; then
                        echo "  LDA #$kata2" >> gambar.tmp               
		else
                        echo "  LDA $kata2" >> gambar.tmp
                fi
		echo "  STA \$020$memory" >> gambar.tmp && ((memory++))

	elif [[ "$kata1" == "tombol" ]]; then
		if [[ "$kata2" == "A" ]]; then
			lokasi_parent="$lokasi_parent $lokasi"
			lokasi=kontrol1
		elif [[ "$kata2" == "B" ]]; then
                        lokasi_parent="$lokasi_parent $lokasi"
                        lokasi=kontrol2
		elif [[ "$kata2" == "Select" ]]; then
                        lokasi_parent="$lokasi_parent $lokasi"
                        lokasi=kontrol3
		elif [[ "$kata2" == "Start" ]]; then
                        lokasi_parent="$lokasi_parent $lokasi"
                        lokasi=kontrol4
		elif [[ "$kata2" == "Atas" ]]; then
                        lokasi_parent="$lokasi_parent $lokasi"
                        lokasi=kontrol5
		elif [[ "$kata2" == "Bawah" ]]; then
                        lokasi_parent="$lokasi_parent $lokasi"
                        lokasi=kontrol6
		elif [[ "$kata2" == "Kiri" ]]; then
                        lokasi_parent="$lokasi_parent $lokasi"
                        lokasi=kontrol7
		elif [[ "$kata2" == "Kanan" ]]; then
                        lokasi_parent="$lokasi_parent $lokasi"
                        lokasi=kontrol8
		fi
		if [[ ! -s "${lokasi}1.tmp" ]]; then
			echo "$lokasi:" > $lokasi.tmp
			echo "  LDA \$4016" >> $lokasi.tmp
			echo "  AND #1" >> $lokasi.tmp
			echo "  BEQ not${lokasi}" >> $lokasi.tmp
			echo "not${lokasi}:" > ${lokasi}1.tmp
		fi
		if [[ "$kata3" == "dilepas" ]]; then
			echo "not${lokasi}:" > ${lokasi}1.tmp
			lokasi="${lokasi}1"
		elif [[ "$kata3" == "ditekan" ]]; then
			echo "$lokasi:" > $lokasi.tmp
			echo "  LDA \$4016" >> $lokasi.tmp
                        echo "  AND #1" >> $lokasi.tmp
                        echo "  BEQ not${lokasi}" >> $lokasi.tmp
		elif [[ "$kata3" != "ditekan" ]]; then
			echo "Error: Event '$kata3' tidak dikenali" >&2   
			exit 1
		fi

	elif [[ "$kata1" == "berakhir" ]]; then
		echo "  LDA #1" >> $lokasi.tmp
		echo "  STA gameisOver" >> $lokasi.tmp

	else 
		echo "\'$kata1\' tidak terdefinisi" >&2
	fi

done <<< "$isi_file"

cat zeropage.tmp >> tes.s

cat >> tes.s << 'EOF'
.segment "CODE"
RESET:
  SEI
  CLD
  LDX #$FF
  TXS
  INX
  STX $2000
  STX $2001

VBlank2:
  BIT $2002
  BPL VBlank2

  LDA $2002
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006
  LDX #$00
LoadPalette:
  LDA MyPalette, X
  STA $2007
  INX
  CPX #32
  BNE LoadPalette
  
  LDA #0
  STA gameisOver
EOF

cat setup.tmp >> tes.s

cat >> tes.s << 'EOF'
  LDA #%10000000
  STA $2000
  LDA #%00010000
  STA $2001

Forever:
  JMP Forever

NMI:
  PHA
  TXA
  PHA
  TYA
  PHA

  JSR ReadController1

  LDA gameisOver
  CMP #1
  BEQ GambarSemua
EOF

cat loop.tmp >> tes.s

cat >> tes.s << 'EOF'
  LDA #$00
  STA $2003
  LDA #$02
  STA $4014
EOF

echo "GambarSemua:" >> tes.s

cat gambar.tmp >> tes.s

cat >> tes.s << 'EOF'
  PLA
  TAY
  PLA
  TAX
  PLA
  RTI


MyPalette:
  ; Background
  .byte $0F,$00,$10,$30, $0F,$06,$16,$26, $0F,$02,$12,$22, $0F,$09,$19,$29
  ; Sprite
  .byte $0F,$30,$10,$00  ; 0 = putih
  .byte $0F,$16,$16,$16  ; 1 = MERAH
  .byte $0F,$02,$02,$02  ; 2 = BIRU
  .byte $0F,$1A,$1A,$1A  ; 3 = HIJAU
EOF

cat fungsi.tmp >> tes.s

cat kontrol?*.tmp >> kontrol.tmp
echo "  RTS" >> kontrol.tmp
rm kontrol?.tmp
cat kontrol.tmp >> tes.s

cat >> tes.s << 'EOF'

.segment "VECTORS"
  .word NMI
  .word RESET
  .word 0

.segment "CHARS"
  .byte $00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
  .byte $00,$00,$00,$00,$00,$00,$00,$00
EOF

cat > nes.cfg << 'EOF'
MEMORY {
    ZP:     start = $0000, size = $0100, type = rw;
    HEADER: start = $0000, size = $0010, file = %O, fill = yes;
    PRG:    start = $C000, size = $4000, file = %O, fill = yes;
    CHR:    start = $0000, size = $2000, file = %O, fill = yes;
}

SEGMENTS {
    ZEROPAGE: load = ZP,     type = zp;
    HEADER:   load = HEADER, type = ro;
    CODE:     load = PRG,    type = ro, start = $C000;
    VECTORS:  load = PRG,    type = ro, start = $FFFA;
    CHARS:    load = CHR,    type = ro;
}
EOF

ca65 tes.s -o tes.o
ld65 -C nes.cfg -m map.txt tes.o -o ${nama_file%.*}$(date +%s).nes

mkdir -p /sdcard/Download/NESGame
cp ${nama_file%.*}$(date +%s).nes $posisisekarang

cd ~
rm -rf nes_tes
