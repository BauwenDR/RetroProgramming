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

;load the startscreen on the second NameTable and wait for the first input
jsr start_screen_main
jsr render_border


reset_game:
;set the variable of RIGHT_SCREEN to #$00 
;so the ppu knows it has to render the left nametable 
lda #$00
sta RIGHT_SCREEN

;; Wait for first VBLANK to have occured
jsr wait_for_nmi
lda #$00
sta VBLANK_OCCURED

;reset the a and y registers 
ldy #$00
lda #$00

;clean the memory of the player data so no random garbage is leftover
:
  sta PLAYER_HEAD,y         ;location of PLAYER_HEAD offset by y
  iny 
  cpy #$49                  ;#$49 because all the data of the snakes are #$48 long
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

;reset vblack tick count
lda #$00
sta VBLANK_TICK_COUNT
;the text "Press a to start" wil never be used agains so we remove it here
jsr delete_press_to_start

; this delay is so the game doesnt start instanly and player have time to prepere
start_delay:
  lda VBLANK_TICK_COUNT
  cmp #$64
  bne start_delay

; Reset VBLANK count once again after the delay, the main loop needs these values between 0 and 8
lda #$00
sta VBLANK_TICK_COUNT

;main loop
.proc forever
  jsr read_input 
  lda VBLANK_OCCURED
  cmp #$01
  bne no_vblank ; If (VBLANK_OCCURED)
    lda #$00  ; VBLANK_OCCURED = false
    sta VBLANK_OCCURED

    lda VBLANK_TICK_COUNT

    cmp #$06 
    bpl :+                    ;if the VBlank tick count is 5 or less 
      jsr delete_dead         ;clean up the bodies
    :
    
    cmp #$07                  ;if the VBlank tick count is 7
    bne:+
      lda PLAYERS_DEAD        ;load the player dead data
      ;the 4 MSB are data for individual players and the 4 LSB are a count of the dead players
      and #%00001111          ;we need the count of dead players          
      cmp #$03                
      bcc:+                   ;if there are 3 players dead
        jmp end_screen        ;go to endscreen
    :

    cmp #$08                  ;if the VBlank tick count is 7
    bcc :+                    ; IF(VBLANK_TICK_COUNT >= 8)
      lda #$00                
      sta VBLANK_TICK_COUNT   ; reset the VBLANK_TICK_COUNT cause we work in cycles of 8 vblanks
      jsr read_input          ;we jump to read input every other time to make sure we dont mis an input
      jsr move_player         ;if we dont do this the game feels unresponsif
      jsr read_input
      jsr reset_input
      jsr read_input
      jsr player_collisions
      jsr read_input
      jsr update_pickups
    :
  no_vblank:
  
  jmp forever                 ;go back to start of the loop
.endproc

.proc end_screen              ;the game is over 
    jsr end_screen_main       ;jump to the main function of the endscreen
    jmp reset_game            ;reset the game

.endproc

; include all files
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
