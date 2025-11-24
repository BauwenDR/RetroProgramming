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
.include "player.s"

forever:
  lda VBLANK_OCCURED
  cmp #$01
  bne :++ ; If a VBLANK occured run the code, otherwise skip
    lda #$00
    sta VBLANK_OCCURED

    lda VBLANK_TICK_COUNT
    cmp #$08
    bne :+  ; Only move every 8 frames
      lda #$00  ; Clear VBLANK count
      sta VBLANK_TICK_COUNT
      jsr move_player
    :
  :

  jmp forever

.include "nmi.s"
.include "pushBackgroundBuffer.s"

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