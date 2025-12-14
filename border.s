.proc render_border
    COUNTER_Y = $01
    COUNTER_X = $02

    lda #$00
    sta VBLANK_TICK_COUNT
    render_loop:
        lda VBLANK_TICK_COUNT
        cmp #$01
        bne :++ 
            lda #%00000010
            sta COUNTER_Y

            :                                   ;top row
            ldx #%00100000
            ldy COUNTER_Y
            lda #$11
            jsr push_background_buffer
            lda COUNTER_Y
            inc COUNTER_Y
            cmp #%00011101
            bne :-
        :
        lda VBLANK_TICK_COUNT
        cmp #$03 
        bne :++
            lda #%10100010
            sta COUNTER_Y
    
            :                                   ;bottem row
            ldx #%00100011
            ldy COUNTER_Y
            lda #$11
            jsr push_background_buffer
            lda COUNTER_Y
            inc COUNTER_Y
            cmp #%10111101
            bne :-
            lda #$09
        :
        lda VBLANK_TICK_COUNT
        cmp #$05 
        bne :++
            lda #%00000000
            sta COUNTER_Y
            lda #%00100000
            sta COUNTER_X

            :                                   ;left row
            ldx COUNTER_X
            ldy COUNTER_Y
            lda #$11
            jsr push_background_buffer

            lda COUNTER_Y
            tay 

            lda COUNTER_X
            tax 

            lda COUNTER_Y
            clc 
            adc #%00100000
            sta COUNTER_Y
            lda COUNTER_X
            adc #$00
            sta COUNTER_X

            tya 
            cmp #%10100000
            bne :-
                txa 
                cmp #%00100011
                bne :-
        :

        lda VBLANK_TICK_COUNT
        cmp #$07 
        bne :++
            lda #%00000001
            sta COUNTER_Y
            lda #%00100000
            sta COUNTER_X

            :                                   ;2nd left row
            ldx COUNTER_X
            ldy COUNTER_Y
            lda #$11
            jsr push_background_buffer

            lda COUNTER_Y
            tay 

            lda COUNTER_X
            tax 

            lda COUNTER_Y
            clc 
            adc #%00100000
            sta COUNTER_Y
            lda COUNTER_X
            adc #$00
            sta COUNTER_X

            tya 
            cmp #%10100001
            bne :-
                txa 
                cmp #%00100011
                bne :-
        :

        lda VBLANK_TICK_COUNT
        cmp #$09 
        bne :++
            lda #%00011110
            sta COUNTER_Y
            lda #%00100000
            sta COUNTER_X

            :                                   ;right row
            ldx COUNTER_X
            ldy COUNTER_Y
            lda #$11
            jsr push_background_buffer

            lda COUNTER_Y
            tay 

            lda COUNTER_X
            tax 

            lda COUNTER_Y
            clc 
            adc #%00100000
            sta COUNTER_Y
            lda COUNTER_X
            adc #$00
            sta COUNTER_X

            tya 
            cmp #%10111110
            bne :-
                txa 
                cmp #%00100011
                bne :-
        :

        lda VBLANK_TICK_COUNT
        cmp #$0B 
        bne :++
            lda #%00011111
            sta COUNTER_Y
            lda #%00100000
            sta COUNTER_X

            :                                   ;2nd right row
            ldx COUNTER_X
            ldy COUNTER_Y
            lda #$11
            jsr push_background_buffer

            lda COUNTER_Y
            tay 

            lda COUNTER_X
            tax 

            lda COUNTER_Y
            clc 
            adc #%00100000
            sta COUNTER_Y
            lda COUNTER_X
            adc #$00
            sta COUNTER_X

            tya 
            cmp #%10111111
            bne :-
                txa 
                cmp #%00100011
                bne :-
        :




        lda VBLANK_TICK_COUNT
        cmp #$0F 
        bne :+
            rts 
        :
        jmp render_loop

    rts 
.endproc

.proc clean_upcrew
    X_LOCATION = $01
    Y_LOCATION = $02

    lda #$20
    sta X_LOCATION
    lda #$22
    sta Y_LOCATION
    jsr wait_for_nmi


    :
        ldx X_LOCATION
        ldy Y_LOCATION
        lda #$00
        jsr push_background_buffer

        inc Y_LOCATION
        lda Y_LOCATION
        and #%00011111
        cmp #$1E
        bne:-
            jsr wait_for_nmi
            jsr wait_for_nmi

            lda Y_LOCATION
            and #%11100000
            ora #%00000010
            sta Y_LOCATION
            clc 
            adc #$20
            sta Y_LOCATION
            lda X_LOCATION
            adc #$00
            sta X_LOCATION

            lda Y_LOCATION
            and #%11100000
            cmp #%10100000
            bne:-
            lda X_LOCATION
            cmp #$23
            bne:-

	rts 

.endproc

