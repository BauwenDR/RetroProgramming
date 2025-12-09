.proc delete_snake
    COUNTER = $01
    SNAKE_NR = $02
    OFFSET = $03

    ; when calling this function have the number of the snake you want in x (0,1,2,3)
    lda #$00
    sta COUNTER
    sta OFFSET

    txa
    sta SNAKE_NR            ;loads the correct values into the zeropage

    :
    lda COUNTER
    cmp SNAKE_NR
    bcs :+                   ;check if the counter lines up the number that has been in x before this function

    clc
    lda OFFSET
    adc #$12                ;$12 to jump to next snake
    sta OFFSET
    inc COUNTER

    bcc :-                   ;jump back to previus branch
    :

    ldx OFFSET
    lda #$00
    sta PLAYER_HEAD,x         ;1
    inx
    sta PLAYER_HEAD,x         ;2
    inx
    sta PLAYER_HEAD,x         ;3
    inx
    sta PLAYER_HEAD,x         ;4
    inx
    sta PLAYER_HEAD,x         ;5
    inx
    sta PLAYER_HEAD,x         ;6
    inx 
    sta PLAYER_HEAD,x         ;7
    inx 
    sta PLAYER_HEAD,x         ;8
    inx
    sta PLAYER_HEAD,x         ;9
    inx
    sta PLAYER_HEAD,x         ;10
    inx
    sta PLAYER_HEAD,x         ;11
    inx

    rts
.endproc