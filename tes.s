.segment "HEADER"
  .byte "NES", $1A
  .byte 1
  .byte 1
  .byte $01
  .byte $00
  .byte $00,$00,$00,$00,$00,$00,$00,$00

.segment "ZEROPAGE"
  gameisOver: .res 1
xbox: .res 1
ybox: .res 1
xmusuh: .res 1
ymusuh: .res 1
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
  LDA #30
  STA xbox
  LDA #200
  STA ybox
  LDA #250
  STA xmusuh
  LDA #200
  STA ymusuh
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
  LDA xmusuh
  SEC
  SBC #2
  STA xmusuh
  JSR brch2
  JSR brch3
  LDA #$00
  STA $2003
  LDA #$02
  STA $4014
GambarSemua:
  LDA ybox
  STA $0200
  LDA #1
  STA $0201
  LDA #3
  STA $0202
  LDA xbox
  STA $0203
  LDA ymusuh
  STA $0204
  LDA #1
  STA $0205
  LDA #1
  STA $0206
  LDA xmusuh
  STA $0207
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
brch1:
  LDA ybox
  CMP #200
  BCS elseBrch1
  LDA ybox
  CLC
  ADC #2
  STA ybox
  RTS
elseBrch1:
  RTS
brch2:
  LDA xmusuh
  CMP #10
  BCS elseBrch2
  LDA #250
  STA xmusuh
  RTS
elseBrch2:
  RTS
brch3:
  LDA xmusuh
  CMP xbox
  BNE elseBrch3
  JSR brch4
  RTS
elseBrch3:
  RTS
brch4:
  LDA ybox
  CMP #190
  BCC elseBrch4
  JSR brch5
  RTS
elseBrch4:
  RTS
brch5:
  LDA ybox
  CMP #210
  BCS elseBrch5
  LDA #1
  STA gameisOver
  RTS
elseBrch5:
  RTS
ReadController1:
  LDA #1
  STA $4016
  LDA #0
  STA $4016

kontrol1:
  LDA $4016
kontrol2:
  LDA $4016
kontrol3:
  LDA $4016
kontrol4:
  LDA $4016
kontrol5:
  LDA $4016
  AND #1
  BEQ notkontrol5
  LDA ybox
  SEC
  SBC #3
  STA ybox
  JMP kontrol6
notkontrol5:
  JSR brch1
kontrol6:
  LDA $4016
kontrol7:
  LDA $4016
kontrol8:
  LDA $4016
  RTS

.segment "VECTORS"
  .word NMI
  .word RESET
  .word 0

.segment "CHARS"
  .byte $00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
  .byte $00,$00,$00,$00,$00,$00,$00,$00
