.proc delete_snake
    COUNTER = $01
    SNAKE_NR = $02
    OFFSET = $03

    ; when calling this function have the number of the snake you want in x (0,1,2,3)
    lda #$00
    sta COUNTER
    sta OFFSET
    stx SNAKE_NR            ;loads the correct values into the zeropage

    ; storing what player is ded
    lda PLAYERS_DEAD
    cpx #$00
    bne:+
        ora #%10000000
    :
    cpx #$01
    bne:+
        ora #%01000000
    :
    cpx #$02
    bne:+
        ora #%00100000
    :
    cpx #$03
    bne:+
        ora #%00010000
    :
    
    sta PLAYERS_DEAD

    rts
.endproc

.proc delete_dead
    COUNTER = $01
    SNAKE_NR = $02
    OFFSET = $03
    TAIL_BYTE = $04
    TAIL_POSITION = $05 ; 2 bytes
    LENGTH = $07
    LENGTH_MOD = $08
    TAIL_BYTE_INDEX = $09
    TAIL_CRUMB_INDEX = $0A
    BYTE_LENGTH = $0B

    ; clear previous values
    lda #$00
    sta COUNTER
    sta SNAKE_NR
    sta OFFSET

    delete_dead_loop:

        ; check if current SNAKE_NR is dead
        ldx SNAKE_NR
        cpx #$00
        bne :+
            lda PLAYERS_DEAD
            and #%10000000
            beq :+
                jmp snake_is_dead
        :
        cpx #$01
        bne :+
            lda PLAYERS_DEAD
            and #%01000000
            beq :+
                jmp snake_is_dead
        :
        cpx #$02
        bne :+
            lda PLAYERS_DEAD
            and #%00100000
            beq :+
                jmp snake_is_dead
        :
        cpx #$03
        bne :+
            lda PLAYERS_DEAD
            and #%00010000
            beq :+
                jmp snake_is_dead
        :

        ; if the current snake is not dead yet, skip
        jmp continue

        snake_is_dead:
        ; multiply SNAKE_NR by #$12 for offset
        lda SNAKE_NR
        asl 
        asl 
        asl 
        clc 
        adc SNAKE_NR
        asl 
        sta OFFSET

        ; place head off-screen
        lda SNAKE_NR
        asl ; multiply by 4
        asl 
        tax 
        lda #$FF
        sta PLAYER_HEAD_SPRITE, x ; y location
        sta PLAYER_HEAD_SPRITE + 3, x ; x location

        ; get length
        ldx OFFSET
        lda PLAYER_LENGTH, x
        lsr 
        lsr 
        sta LENGTH
        and #%00000011
        sta LENGTH_MOD

        ; skip if length = 0
        lda LENGTH
        cmp #$00
        bne :+
            jmp continue
        :

        ; get size of player body bytes
        lda LENGTH
        sec 
        sbc #$01
        lsr 
        lsr 
        sta BYTE_LENGTH

        ; get position
        ldx OFFSET
        lda PLAYER_HEAD,x
        sta TAIL_POSITION
        lda PLAYER_HEAD + 1,x
        and #$03
        clc 
        adc #$20
        sta TAIL_POSITION + 1
        
        lda OFFSET
        clc 
        adc BYTE_LENGTH
        tax 

        ; calculate tail byte index
        lda OFFSET
        clc 
        adc BYTE_LENGTH
        tax 
        stx TAIL_BYTE_INDEX

        ; get all values for the initial loop 
        ldy LENGTH_MOD
        cpy #$00
        bne :+
            ldy #$04
            ;dex 
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

        sty TAIL_CRUMB_INDEX

        ; set counter to 0
        lda #$00
        sta COUNTER

        tail_position_loop:
            ; get the current crumb
            lda TAIL_BYTE
            and #$03
            
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
                lda TAIL_POSITION
                sec 
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

            ; get loop values
            ldx TAIL_BYTE_INDEX
            ldy TAIL_CRUMB_INDEX

            ; check if it completeed the entire snake
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

            ; store loop values
            stx TAIL_BYTE_INDEX
            sty TAIL_CRUMB_INDEX

            ; delete snake part
            ldx TAIL_POSITION + 1
            ldy TAIL_POSITION
            lda #$00
            jsr push_background_buffer

            ; check if we have reached the maximum amount of snake deletions per frame (12)
            inc COUNTER
            lda COUNTER
            cmp #12 ; decimal
            bne :+
                ; store current location and length to continue from next frame
                ; location
                ldx OFFSET
                lda TAIL_POSITION
                sta PLAYER_HEAD, x
                lda TAIL_POSITION + 1
                and #$03
                sta PLAYER_HEAD + 1, x
                
                ; length
                lda LENGTH
                sec 
                sbc #12 ; decimal
                asl 
                asl 
                ora PLAYER_LENGTH, x ; combine with the 2 bits from position
                sta PLAYER_LENGTH, x

                jmp continue
            :

            jmp tail_position_loop

        end_tail_calculations:

        ; set length to 0
        ldx OFFSET
        lda #$00
        sta PLAYER_LENGTH, x

    continue: 

    lda SNAKE_NR
    cmp #$04
    bpl :+
        inc SNAKE_NR
        jmp delete_dead_loop
    :
        
    rts 
.endproc