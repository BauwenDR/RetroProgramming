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

;; Wait for first VBLANK to have occured
vblank_wait:
lda VBLANK_OCCURED
cmp #$01
bne vblank_wait
jsr init_player
jsr init_draw_player

jsr init_pickups
jsr render_border

.proc forever
  jsr read_input
  lda VBLANK_OCCURED
  cmp #$01
  bne :+ ; If (VBLANK_OCCURED)
    lda #$00  ; VBLANK_OCCURED = false
    sta VBLANK_OCCURED


    lda VBLANK_TICK_COUNT

    cmp #$06
    bpl :+
      jsr delete_dead
    :

    cmp #$08
    bcc :+  ; IF(VBLANK_TICK_COUNT >= 8)
      lda #$00  ; VBLANK_TICK_COUNT = 0
      sta VBLANK_TICK_COUNT
      jsr read_input
      jsr move_player
      jsr read_input
      jsr reset_input
      jsr read_input
      jsr player_collistions
      jsr read_input
      jsr update_pickups
  :
  
  jmp forever
.endproc

.include "nmi.s"
.include "pushBackgroundBuffer.s"

.include "player.s"
.include "input.s"
.include "delete_dead.s"

.include "pickups.s"
.include "collision.s"
.include "border.s"


palettes:
  ; Background Palette
  .byte $1B, $18, $29, $38
  .byte $1B, $05, $16, $36
  .byte $1B, $14, $25, $35
  .byte $1B, $2D, $27, $30

  ; Sprite Palette
  .byte $0B, $11, $21, $31
  .byte $0B, $05, $16, $36
  .byte $0B, $14, $25, $35
  .byte $0B, $2D, $27, $30

; Character memory
.segment "CHARS"
.incbin "tiles.chr"