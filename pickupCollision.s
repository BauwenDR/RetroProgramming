.proc pickup_collisions
    COLLISION = $01
    jsr check_head_collisions
    sta COLLISION

    and #%00000001              ;player 1
    cmp #%00000001
    bne :+
        ; Play sound effect
        lda #$00
        ldx FAMISTUDIO_SFX_CH3
        jsr famistudio_sfx_play

        ; Set return status flags
        ldy #$00
        lda #$01
        rts 
    :

    lda COLLISION
    and #%00000010              ;player 2
    cmp #%00000010
    bne :+
        ; Play sound effect
        lda #$00
        ldx FAMISTUDIO_SFX_CH3
        jsr famistudio_sfx_play

        ; Set return status flags
        ldy #$12
        lda #$01
        rts 
    :

    lda COLLISION
    and #%00000100              ;player 3
    cmp #%00000100
    bne :+
        ; Play sound effect
        lda #$00
        ldx FAMISTUDIO_SFX_CH3
        jsr famistudio_sfx_play

        ; Set return status flags
        ldy #$24
        lda #$01
        rts 
    :

    lda COLLISION
    and #%00001000              ;player 4
    cmp #%00001000
    bne :+
        ; Play sound effect
        lda #$00
        ldx FAMISTUDIO_SFX_CH3
        jsr famistudio_sfx_play

        ; Set return status flags
        ldy #$36
        lda #$01
        rts 
    :

    lda #$00
    rts 
.endproc