.proc add_segment
    LENGTH = $01
    OFFSET = $02
    ;y has to be the offset
    sty OFFSET


    lda PLAYER_LENGTH,y         ;getting the player length
    lsr                         ;putting it in the right spot
    lsr                         ;and shifting the bits from the head out
    cmp #$3e                    ;if the length is 62 we dont increase it more
    bne :+
        rts 
    :                         
    lsr                         
    lsr                         
    sta LENGTH
   
    ldx OFFSET
    clc 
    adc OFFSET 
    sta LENGTH
    clc 

    ror PLAYER_BODY,x
    ror PLAYER_BODY + 1,x
    ror PLAYER_BODY + 2,x
    ror PLAYER_BODY + 3,x
    ror PLAYER_BODY + 4,x
    ror PLAYER_BODY + 5,x
    ror PLAYER_BODY + 6,x
    ror PLAYER_BODY + 7,x
    ror PLAYER_BODY + 8,x
    ror PLAYER_BODY + 9,x
    ror PLAYER_BODY + $0A,x
    ror PLAYER_BODY + $0B,x
    ror PLAYER_BODY + $0C,x
    ror PLAYER_BODY + $0D,x
    ror PLAYER_BODY + $0E,x
    ror PLAYER_BODY + $0F,x
    clc 
    ror PLAYER_BODY,x
    ror PLAYER_BODY + 1,x
    ror PLAYER_BODY + 2,x
    ror PLAYER_BODY + 3,x
    ror PLAYER_BODY + 4,x
    ror PLAYER_BODY + 5,x
    ror PLAYER_BODY + 6,x
    ror PLAYER_BODY + 7,x
    ror PLAYER_BODY + 8,x
    ror PLAYER_BODY + 9,x
    ror PLAYER_BODY + $0A,x
    ror PLAYER_BODY + $0B,x
    ror PLAYER_BODY + $0C,x
    ror PLAYER_BODY + $0D,x
    ror PLAYER_BODY + $0E,x
    ror PLAYER_BODY + $0F,x

    
    ldy OFFSET
    lda PLAYER_BODY, y
    and #%00110000
    asl 
    asl 
    ora PLAYER_BODY, y
    sta PLAYER_BODY, y

    ldy OFFSET        
    lda PLAYER_LENGTH,y
    clc 
    adc #$04
    sta PLAYER_LENGTH,y
    rts 
.endproc