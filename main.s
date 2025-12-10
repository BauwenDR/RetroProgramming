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

ldx #<music_data_untitled
ldy #>music_data_untitled
lda #0 ; NTSC
jsr famistudio_init

lda #0
jsr famistudio_music_play

jsr start_screen_main
jsr render_border
reset_game:
lda #$00
sta RIGHT_SCREEN

;; Wait for first VBLANK to have occured
jsr wait_for_nmi
lda #$00
sta VBLANK_OCCURED

ldy #$00
lda #$00
:
  sta PLAYER_HEAD,y
  iny 
  cpy #$49
  bne :-


jsr init_pickups

jsr wait_for_nmi
lda #$00
sta VBLANK_OCCURED

jsr init_player
jsr init_draw_player

lda #$00
sta VBLANK_TICK_COUNT
jsr delete_press_to_start
start_delay:
  lda VBLANK_TICK_COUNT
  cmp #$64
  bne start_delay

lda #$00
sta VBLANK_OCCURED
vblank_wait_2:
lda VBLANK_OCCURED
cmp #$01
bne vblank_wait_2
lda #$00
sta VBLANK_OCCURED

jsr init_player
jsr init_draw_player

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
    
    cmp #$07
    bne:+

      
      lda PLAYERS_DEAD
      and #%00001111
      cmp #$03
      bcc:+
        jmp end_screen
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
      jsr player_collisions
      jsr read_input
      jsr update_pickups
  :
  
  jmp forever


.endproc

.proc end_screen
    jsr end_screen_main
    jmp reset_game
    rts 
.endproc


.include "nmi.s"
.include "pushBackgroundBuffer.s"

.include "input.s"
.include "border.s"

.include "player.s"
.include "playerInit.s"
.include "playerAddSegment.s"
.include "playerDeleteSnake.s"
.include "playerCollision.s"

.include "pickups.s"
.include "pickupCollision.s"

.include "render_titlescreen.s"

.include "famistudio_ca65.s"
.include "nokiaSong.s"

palettes:
  ; Sprite Palette
  .byte $1B, $18, $29, $38
  .byte $1B, $05, $16, $36
  .byte $1B, $14, $25, $35
  .byte $1B, $2D, $27, $30

  ; Background Palette
  .byte $0B, $11, $21, $31
  .byte $0B, $05, $16, $36
  .byte $0B, $14, $25, $35
  .byte $0B, $2D, $27, $30

; Character memory
.segment "CHARS"
.incbin "tiles.chr"