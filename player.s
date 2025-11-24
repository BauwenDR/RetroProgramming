init_player:
    lda #$01
    ldx #$00
    ldy #$00
    jsr push_background_buffer

    lda #$02
    ldx #$01
    ldy #$00
    jsr push_background_buffer

    lda #$03
    ldx #$02
    ldy #$00
    jsr push_background_buffer

    rts