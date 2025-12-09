ldx OFFSET  ;loads the right offset into x for the right snake 
; Draw body on last head location ---------------------------------------------------------------------------------------------------------------------------------------------------------
ldy PLAYER_HEAD ,x
lda PLAYER_LENGTH,x
and #03
clc 
adc #$20
tax
lda NEW_MOVE_DIR
cmp LAST_MOVE_DIR

bne :+ 
; if LAST_MOVE_DIR == NEW_MOVE_DIR (straight)
    clc 
    and #%00000010
    ror 
    adc #$05
    jmp finish_drawing_body

: ; if LAST_MOVE_DIR != NEW_MOVE_DIR (corner)
    asl 
    asl 
    ora LAST_MOVE_DIR ; merge NEW + LAST
    
    cmp #%00000011
    beq :+
    cmp #%00001001
    beq :+
    jmp :++
    :
        lda #$07
        jmp finish_drawing_body
    : 
    
    cmp #%00000111
    beq :+
    cmp #%00001000
    beq :+
    jmp:++
    :
        lda #$08
        jmp finish_drawing_body
    :

    cmp #%00000010
    beq :+
    cmp #%00001101
    beq :+
    jmp:++
    :
        lda #$09
        jmp finish_drawing_body
    :

    cmp #%00001100
    beq :+
    cmp #%00000110
    beq :+
    jmp:++
    :
        lda #$0A
        jmp finish_drawing_body
    :
    lda #$00

finish_drawing_body:
jsr push_background_buffer

; Move player head -------------------------------------------------------------------------------------------------------------------------------------------------------------
lda NEW_MOVE_DIR
cmp #$00    ; Right
bne :++
    ldx OFFSET ;loads the right offset into x for the right body part ;head
    inc PLAYER_HEAD,x
    bne :+
        ldy OFFSET ;loads the right offset into x for the right body part ;head
        lda PLAYER_LENGTH,y
        and #$03
        clc
        adc #$01
        and #$03
        tax
        lda #$FC
        and PLAYER_LENGTH,y
        sta PLAYER_LENGTH,y
        txa
        ora PLAYER_LENGTH,y
        sta PLAYER_LENGTH,y
    :
    jmp end_move_switch
:

cmp #$01    ; Left
bne :++
    ldx OFFSET ;loads the right offset into x for the right body part ;head
    lda PLAYER_HEAD,x
    sec
    sbc #$01
    sta PLAYER_HEAD,x
    bcs :+
        ldy OFFSET     ;loads the right offset into x for the right snake

        lda PLAYER_LENGTH,y
        and #$03
        sec
        sbc #$01
        and #$03
        tax
        lda #$FC
        and PLAYER_LENGTH,y
        sta PLAYER_LENGTH,y
        txa
        ora PLAYER_LENGTH,y
        sta PLAYER_LENGTH,y
    :
    jmp end_move_switch
:

cmp #$02    ; Down
bne :++
    ldx OFFSET ;loads the right offset into x for the right body part ;head
    lda PLAYER_HEAD,x
    clc
    adc #$20
    sta PLAYER_HEAD,x
    bcc :+
        ldy OFFSET      ;loads the right offset into x for the right snake

        lda PLAYER_LENGTH,y
        and #$03
        clc
        adc #$01
        and #$03
        tax
        lda #$FC
        and PLAYER_LENGTH,y
        sta PLAYER_LENGTH,y
        txa
        ora PLAYER_LENGTH,y
        sta PLAYER_LENGTH,y
    :
    jmp end_move_switch
:

cmp #$03    ; Up
bne :++
    ldx OFFSET ;loads the right offset into x for the right body part ;head
    lda PLAYER_HEAD,x
    sec
    sbc #$20
    sta PLAYER_HEAD,x
    bcs :+
        ldy OFFSET       ;loads the right offset into x for the right snake

        lda PLAYER_LENGTH,y
        and #$03
        sec
        sbc #$01
        and #$03
        tax
        lda #$FC
        and PLAYER_LENGTH,y
        sta PLAYER_LENGTH,y
        txa
        ora PLAYER_LENGTH,y
        sta PLAYER_LENGTH,y
    :
    jmp end_move_switch
:
end_move_switch:

; ; Draw head (as a sprite) in new position -----------------------------------------------------------------------------------------------------------------------------------------
clc 

; calculate y position
ldx OFFSET
lda PLAYER_LENGTH,x ; get first 2 bits
and #%00000011
ror 
sta LENGTH
lda PLAYER_HEAD,x ; get last 3 bits
and #%11100000

ora LENGTH ; merge them
ror 
ror 

; sprites render one pixel below bg tiles at the same location
sbc #$00 ; subtract one (yes, I know it says 0, just trust me bro)
ldy SPRITE_OFFSET
sta PLAYER_HEAD_SPRITE, y ; store y position

; calculate x position
ldx OFFSET
lda PLAYER_HEAD,x
and #%00011111

asl ; multiply by 8
asl 
asl 

sta PLAYER_HEAD_SPRITE + 3, y ; store x position

; set tile index
lda NEW_MOVE_DIR
clc 
adc #$01
sta PLAYER_HEAD_SPRITE + 1,y ; store tile index
