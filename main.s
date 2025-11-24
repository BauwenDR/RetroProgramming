.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0


.segment "STARTUP"
.segment "CODE"

.include "constants.s"

.include "start.s"
.include "random.s"
.include "input.s"

forever:
  jsr galois16
  ldx RANDOM_SEED+0
  ldy RANDOM_SEED+1

  lda $0700
  cmp #$01
  bne :+

  ; set vBlank? to 0
  lda #$00
  sta $0700
  
  lda #$01
  jsr push_background_buffer

  :

  jmp forever

.include "nmi.s"
.include "pushBackgroundBuffer.s"

hello:
  .byte $04 ;h
  .byte $05 ;e
  .byte $06 ;l
  .byte $06 ;l
  .byte $02 ;o
  .byte $00 ;
  .byte $01 ;t
  .byte $02 ;o
  .byte $03 ;m

palettes:
  ; Background Palette
  .byte $1B, $18, $29, $38
  .byte $1B, $05, $16, $36
  .byte $1B, $14, $25, $35
  .byte $1B, $0C, $11, $3C

  ; Sprite Palette
  .byte $0f, $20, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

; Character memory
.segment "CHARS"
.incbin "tiles.chr"