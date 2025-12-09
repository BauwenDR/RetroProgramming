.proc pickup_collisions
    COLLISION = $01
    jsr check_head_collisions
    sta COLLISION

    and #%00000001              ;player 1
    cmp #%00000001
    bne :+
        ldy #$00
        lda #$01
        rts 
    :

    lda COLLISION
    and #%00000010              ;player 2
    cmp #%00000010
    bne :+
        ldy #$12
        lda #$01
        rts 
    :

    lda COLLISION
    and #%00000100              ;player 3
    cmp #%00000100
    bne :+
        ldy #$24
        lda #$01
        rts 
    :

    lda COLLISION
    and #%00001000              ;player 4
    cmp #%00001000
    bne :+
        ldy #$36
        lda #$01
        rts 
    :

    lda #$00
    rts 
.endproc