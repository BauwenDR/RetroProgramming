.segment "ZEROPAGE"
  .res 18 ; make sure the sound doesn't override our own variables

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

; Initialise sounds effects
ldx #<sounds
ldy #>sounds
lda #$00
jsr famistudio_sfx_init

; Show start screen and only continue after a button has been pressed
jsr start_screen_main
jsr render_border

; Wait for two VBLANKs after rendering the border (if we dont do this, some tiles will be missing)
jsr wait_for_nmi
jsr wait_for_nmi

; Resetting the player locations and lengths to predetermined values
reset_game:
lda #$00
sta RIGHT_SCREEN

; Reset player bodies memory
ldy #$00
lda #$00
:
  sta PLAYER_HEAD,y
  iny 
  cpy #$49
  bne :-

; Also spawn the first three pickups
jsr init_pickups

; Wait for another VBLANK just to be sure and then start initialising the menu music
jsr wait_for_nmi
lda #$00
sta VBLANK_OCCURED

jsr famistudio_music_stop
ldx #<music_data_bold
ldy #>music_data_bold
lda #0 ; PAL
jsr famistudio_init

ldx #<music_data_bold
ldy #>music_data_bold
lda #0
jsr famistudio_music_play

; Draw the players in their initial locations
jsr init_player
jsr init_draw_player
jsr wait_for_nmi

; Reset VBLANK tick count to 0 so that our main loop will work properly
lda #$00
sta VBLANK_TICK_COUNT

; Delete text saying press start`
jsr delete_press_to_start
; Wait for 100 VBLANKS (2 seconds) and then start game play
start_delay:
  lda VBLANK_TICK_COUNT
  cmp #$64
  bne start_delay

; Reset VBLANK count once again after the delay, the main loop needs these values between 0 and 8
lda #$00
sta VBLANK_TICK_COUNT

; Main game loop
.proc forever
  jsr read_input
  lda VBLANK_OCCURED
  cmp #$01
  bne no_vblank ; If (VBLANK_OCCURED)
    lda #$00  ; VBLANK_OCCURED = false
    sta VBLANK_OCCURED

    lda VBLANK_TICK_COUNT

    cmp #$06 ; if (VBLANK_TICK_COUNT <= 6)
    bpl :+
      jsr delete_dead
    :
    
    cmp #$07 ; if (VBLANK_TICK_COUNT == 7)
    bne :+
      lda PLAYERS_DEAD
      and #%00001111
      cmp #$03
      bcc:+
        jmp end_screen
    :

    cmp #$08 ; IF(VBLANK_TICK_COUNT >= 8)
    bcc :+  
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
  no_vblank:
  
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

.include "renderTitleScreen.s"

.include "famistudio.s"
.include "songSwimming.s"
.include "songBold.s"
.include "soundEffects.s"

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
