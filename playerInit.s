;; Initialises player memory (hardcoded values)
.proc init_player
    
    ; Set attributes (no flipping x 2, in front of background, unimplemented x 3, palette x 2)
    lda #%00000000
    sta PLAYER_HEAD_SPRITE_1 + 2 ; Store attributes

    lda #%00000001
    sta PLAYER_HEAD_SPRITE_2 + 2 ; Store attributes

    lda #%00000010
    sta PLAYER_HEAD_SPRITE_3 + 2 ; Store attributes

    lda #%00000011
    sta PLAYER_HEAD_SPRITE_4 + 2 ; Store attributes

    ; Player 1
    lda #$24                     ; x = 4, y = 1
    sta PLAYER_HEAD

    lda #%00001100               ; Length = 3, y = 1
    sta PLAYER_LENGTH

    lda #%00000000               ; First 3 body bits moving right
    sta PLAYER_BODY

    ; Player 2
    lda #$7D                     ; x = 29, y = 3
    sta PLAYER_HEAD_2

    lda #%00001100               ; Length = 3, y = 3
    sta PLAYER_LENGTH_2

    lda #%10101000
    sta PLAYER_BODY_2            ; First 3 body bits moving down

    ; Player 3
    lda #$9B                     ; x = 27, y = 28
    sta PLAYER_HEAD_3

    lda #%00001111               ; Length = 3, y = 28
    sta PLAYER_LENGTH_3

    lda #%01010100               ; First 3 body bits moving left
    sta PLAYER_BODY_3


    ;player 4
    lda #$42                     ; x = 2, y = 26
    sta PLAYER_HEAD_4

    lda #%00001111               ; Length = 3, y = 26
    sta PLAYER_LENGTH_4

    lda #%11111100               ; First 3 body bits moving up
    sta PLAYER_BODY_4

    rts 
.endproc

;; Draws initial player locations
.proc init_draw_player
    ;; Player 1
    lda #$0B
    ldx #$20
    ldy #$22
    jsr push_background_buffer

    lda #$05
    ldx #$20
    ldy #$23
    jsr push_background_buffer

    lda #$07
    sta PLAYER_HEAD_SPRITE_1
    lda #$20
    sta PLAYER_HEAD_SPRITE_1 + 3
    lda #$01
    sta PLAYER_HEAD_SPRITE_1 + 1

    ;; Player 2
    lda #$0D
    ldx #$20
    ldy #$3D
    jsr push_background_buffer

    lda #$06
    ldx #$20
    ldy #$5D
    jsr push_background_buffer

    lda #$17
    sta PLAYER_HEAD_SPRITE_2
    lda #$E8
    sta PLAYER_HEAD_SPRITE_2 + 3
    lda #$03
    sta PLAYER_HEAD_SPRITE_2 + 1

    ;; Player 3
    lda #$0C
    ldx #$23
    ldy #$9D
    jsr push_background_buffer

    lda #$05
    ldx #$23
    ldy #$9C
    jsr push_background_buffer

    lda #$DF
    sta PLAYER_HEAD_SPRITE_3
    lda #$D8
    sta PLAYER_HEAD_SPRITE_3 + 3
    lda #$02
    sta PLAYER_HEAD_SPRITE_3 + 1

    ;; Player 4
    lda #$0E
    ldx #$23
    ldy #$82
    jsr push_background_buffer

    lda #$06
    ldx #$23
    ldy #$62
    jsr push_background_buffer

    lda #$CF
    sta PLAYER_HEAD_SPRITE_4
    lda #$10
    sta PLAYER_HEAD_SPRITE_4 + 3
    lda #$04
    sta PLAYER_HEAD_SPRITE_4 + 1

    rts
.endproc