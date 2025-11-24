; temp location for player offsets
PLAYER_LOC = $0200

lda #$00            ; Set player locations to 0
sta PLAYER_LOC
sta PLAYER_LOC+1

jmp player_skip

move_player:
    ; Remove last tile
    lda #$00
    ldx #$20
    ldy PLAYER_LOC
    jsr push_background_buffer

    inc PLAYER_LOC

    ; Increase high byte on overflow
    ; beq :+ 
    ;     inc PLAYER_LOC+1
    ; :

    ; Render new tiles
    lda #$0A
    ldx #$20
    ldy PLAYER_LOC
    jsr push_background_buffer

    lda #$06
    ldx #$20
    ldy PLAYER_LOC
    iny
    iny
    jsr push_background_buffer

    lda #$04
    ldx #$20
    ldy PLAYER_LOC
    iny
    iny
    iny
    jsr push_background_buffer

    rts

player_skip: