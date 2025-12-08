; Draw tale (it's "tail" btw) -------------------------------------------------------------------------------------------------------------------------------------------------------
TAIL_BYTE = $0C
TAIL_POSITION = $0D ; 2 bytes
PREV_TAIL_POSITION = $0F ; 2 bytes
TAIL_SPRITE = $11 ; 1 byte
PREV_TAIL_SPRITE = $12 ; 1 byte


; get position
ldx OFFSET
lda PLAYER_HEAD,x
sta TAIL_POSITION
lda PLAYER_HEAD + 1,x
and #$03
adc #$20
sta TAIL_POSITION + 1

; calculate the offset
clc 
lda OFFSET
adc BYTE_LENGTH
tax 

; get all values for initial the loop
ldy LENGTH_MOD
cpy #$00
bne :+
    ldy #$04
    dex 
:

lda PLAYER_BODY,x
sta TAIL_BYTE

cpy #$00
bne :+
    ldy #$04
:

cpy #$04
beq :+
    lsr TAIL_BYTE
    lsr TAIL_BYTE
    iny 
    jmp :-
:   

ldy LENGTH_MOD
cpy #$00
bne :+
    ldy #$04
    dex 
:

tail_position_loop:
    lda TAIL_BYTE
    and #$03
    sta TAIL_SPRITE
    
    cmp #$00
    bne :++
    lda TAIL_POSITION

    cmp #$00
        bne :+ ; if overflow
            dec TAIL_POSITION + 1
        :
        dec TAIL_POSITION
        jmp end_tail_crumb_check
    :

    cmp #$01
    bne :++
        inc TAIL_POSITION
        bne :+ ; if overflow
            inc TAIL_POSITION + 1
        :
        jmp end_tail_crumb_check
    :

    cmp #$02
    bne :++
        sec 
        lda TAIL_POSITION
        sbc #$20 ; length of 1 line
        bcs :+ ; if overflow
            dec TAIL_POSITION + 1
        :
        sta TAIL_POSITION
        jmp end_tail_crumb_check
    :

    cmp #$03
    bne :++
        clc 
        lda TAIL_POSITION
        adc #$20
        bcc :+ ; if overflow
            inc TAIL_POSITION + 1
        :
        sta TAIL_POSITION
        jmp end_tail_crumb_check
    :

    end_tail_crumb_check: ; crumb = 2 bits
    lsr TAIL_BYTE
    lsr TAIL_BYTE
    dey 

    cpy #$00
    bne :+ ; if y == 0
        ldy #$04
        dex 
        cpx OFFSET
        bmi end_tail_calculations

        lda PLAYER_BODY,x
        sta TAIL_BYTE
    :

    ; store the previous locations
    cpx OFFSET
    bne tail_position_loop ; skip the prev pos saving when not necessary (can save up to 3500 clock cycles)

        lda TAIL_POSITION
        sta PREV_TAIL_POSITION
        lda TAIL_POSITION + 1
        sta PREV_TAIL_POSITION + 1
        lda TAIL_SPRITE
        sta PREV_TAIL_SPRITE
    
        jmp tail_position_loop

end_tail_calculations:

ldx TAIL_POSITION + 1
ldy TAIL_POSITION
lda #$00
jsr push_background_buffer

ldx PREV_TAIL_POSITION + 1
ldy PREV_TAIL_POSITION
lda #$0B
adc PREV_TAIL_SPRITE
jsr push_background_buffer