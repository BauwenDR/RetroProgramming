;register layout for pushing

;x = CCNNNNYY
;y = YYYXXXXX
;a = TTTTTTTT

; C = color pallet
; N = nametable
; Y = y location (2msb are in the x register 3lsb are in y register)
; X = x location
; T = tile index

.proc render_border
    ;setting up counters
    COUNTER_Y = $01                             ;counter for the y register
    COUNTER_X = $02                             ;counter for the x register

    lda #$00
    sta VBLANK_TICK_COUNT                       ;reset the vblank tick count
    render_loop:
        lda VBLANK_TICK_COUNT                   
        cmp #$01                                ;if the tick count is 1 (1 because to clear any possible buffer)
        ;top row
        bne :++ 
            lda #%00000010                      ;start y counter
            sta COUNTER_Y                       ;store the counter

            :                                   
            ldx #%00100000                      ;load the x register (color pallet 00 nametable 1000 y location is 00(000))
            ldy COUNTER_Y                       ;load the y register                       
            lda #$11                            ;load the a register (tile index)
            jsr push_background_buffer          ;push all to the buffer
            lda COUNTER_Y                       ;load y counter into a
            inc COUNTER_Y                       ;increase y
            cmp #%00011101                      ;this is the disared endvalue of the y register
            bne :-
        :
        lda VBLANK_TICK_COUNT
        cmp #$04                                ;if the tick count is 4 (4 because it leaves 3 vblanks to clear the buffer)
        bne :++
            lda #%10100010                      ;start y counter
            sta COUNTER_Y                       ;store the counter
    
            :                                   ;bottem row
            ldx #%00100011                      ;color pallet 00 nametable 1000 y location is 11(101)
            ldy COUNTER_Y                       ;load the y register                       
            lda #$11                            ;load tile index
            jsr push_background_buffer          ;push all to the buffer
            lda COUNTER_Y                       ;load y counter into a
            inc COUNTER_Y                       ;increase y
            cmp #%10111101                      ;this is the disared endvalue of the y register
            bne :-
        :

        lda VBLANK_TICK_COUNT
        cmp #$07                                 ;if the tick count is 7 (7 because it leaves 3 vblanks to clear the buffer)
        ;left row
        bne :++
            lda #%00000000                      ;start y counter
            sta COUNTER_Y                       ;store the counter
            lda #%00100000                      ;start x counter 
            sta COUNTER_X                       ;store the counter

            :                                  
            ldx COUNTER_X                       ;load the x register                       
            ldy COUNTER_Y                       ;load the y register                       
            lda #$11                            ;load the a register (tile index)
            jsr push_background_buffer          ;push it to the buffer

            ldy COUNTER_Y                       ;load the y register                       
            ldx COUNTER_X                       ;load the x register                       
            

            lda COUNTER_Y                       
            clc 
            adc #%00100000                      ;adding this to the y register make the y location go up by 1
            sta COUNTER_Y                       ;store the value
            lda COUNTER_X                       
            adc #$00                            ;if there was a carry it has been added to the x counter
            sta COUNTER_X

            tya 
            cmp #%10100000                      ;this is the disared endvalue of the y register
            bne :-
                txa 
                cmp #%00100011                  ;this is the disared endvalue of the x register
                bne :-
        :

        lda VBLANK_TICK_COUNT
        cmp #$0A 
        ;2nd left row
        bne :++
            lda #%00000001                      ;start y counter
            sta COUNTER_Y                       ;store the counter
            lda #%00100000                      ;start x counter 
            sta COUNTER_X                       ;store the counter

            :                                  
            ldx COUNTER_X                       ;load the x register                       
            ldy COUNTER_Y                       ;load the y register                       
            lda #$11                            ;load the a register (tile index)
            jsr push_background_buffer          ;push it to the buffer

            ldy COUNTER_Y                       ;load the y register                       
            ldx COUNTER_X                       ;load the x register                       
            

            lda COUNTER_Y                       
            clc 
            adc #%00100000                      ;adding this to the y register make the y location go up by 1
            sta COUNTER_Y                       ;store the value
            lda COUNTER_X                       
            adc #$00                            ;if there was a carry it has been added to the x counter
            sta COUNTER_X

            tya 
            cmp #%10100001                      ;this is the disared endvalue of the y register
            bne :-
                txa 
                cmp #%00100011                  ;this is the disared endvalue of the x register
                bne :-
        :

        lda VBLANK_TICK_COUNT
        cmp #$0E
        ;right row

        bne :++
            lda #%00011110                      ;start y counter
            sta COUNTER_Y                       ;store the counter
            lda #%00100000                      ;start x counter 
            sta COUNTER_X                       ;store the counter

            :                                  
            ldx COUNTER_X                       ;load the x register                       
            ldy COUNTER_Y                       ;load the y register                       
            lda #$11                            ;load the a register (tile index)
            jsr push_background_buffer          ;push it to the buffer

            ldy COUNTER_Y                       ;load the y register                       
            ldx COUNTER_X                       ;load the x register                       
            

            lda COUNTER_Y                       
            clc 
            adc #%00100000                      ;adding this to the y register make the y location go up by 1
            sta COUNTER_Y                       ;store the value
            lda COUNTER_X                       
            adc #$00                            ;if there was a carry it has been added to the x counter
            sta COUNTER_X

            tya 
            cmp #%10111110                      ;this is the disared endvalue of the y register
            bne :-
                txa 
                cmp #%00100011                  ;this is the disared endvalue of the x register
                bne :-
        :


        lda VBLANK_TICK_COUNT
        cmp #$11 
        ;2nd right row
        bne :++
            lda #%00011111                      ;start y counter
            sta COUNTER_Y                       ;store the counter
            lda #%00100000                      ;start x counter 
            sta COUNTER_X                       ;store the counter

            :                                  
            ldx COUNTER_X                       ;load the x register                       
            ldy COUNTER_Y                       ;load the y register                       
            lda #$11                            ;load the a register (tile index)
            jsr push_background_buffer          ;push it to the buffer

            ldy COUNTER_Y                       ;load the y register                       
            ldx COUNTER_X                       ;load the x register                       
            

            lda COUNTER_Y                       
            clc 
            adc #%00100000                      ;adding this to the y register make the y location go up by 1
            sta COUNTER_Y                       ;store the value
            lda COUNTER_X                       
            adc #$00                            ;if there was a carry it has been added to the x counter
            sta COUNTER_X

            tya 
            cmp #%10111111                      ;this is the disared endvalue of the y register
            bne :-
                txa 
                cmp #%00100011                  ;this is the disared endvalue of the x register
                bne :-
        :


        lda VBLANK_TICK_COUNT
        cmp #$1F 
        bne :+
            rts 
        :
        jmp render_loop

    rts 
.endproc

.proc clean_upcrew
;cleans up the screen after the game
    X_LOCATION = $01                                
    Y_LOCATION = $02                                

    lda #%00100000                                  ;load  X_LOCATION (color pallet 00 nametable 1000 y location is 00(000))
    sta X_LOCATION
    lda #%00100010                                  ;load  Y_LOCATION (y location 001 x location 00010)
    sta Y_LOCATION
    jsr wait_for_nmi                                ;clear buffer


    :                                               
        ldx X_LOCATION                              ;load the x register 
        ldy Y_LOCATION                              ;load the y register 
        lda #$00                                    ;load the a register
        jsr push_background_buffer                  ;sent to buffer

        inc Y_LOCATION                              ;move to next tile horizontal
        lda Y_LOCATION                              ;load for check
        and #%00011111                              ;mask out the X coordinate bits
        cmp #$1E                                    ;check if we reached the end of the line
        bne:-
            jsr wait_for_nmi                        ;clear buffer
            jsr wait_for_nmi                        ;clear buffer twice buffer safety

            lda Y_LOCATION                          ;load current position
            and #%11100000                          ;clear the X bits
            ora #%00000010                          ;reset to the left margin
            sta Y_LOCATION
            clc 
            adc #%00100000                          ;increment Y coordinate by 1 tile
            sta Y_LOCATION
            lda X_LOCATION                          ;handle overflow into X layout register
            adc #$00
            sta X_LOCATION

            lda Y_LOCATION                          ;check total progress
            and #%11100000                          ;mask high bits
            cmp #%10100000                          ;check if we reached bottom of cleanup area
            bne:-
            lda X_LOCATION                          ;final check on X register layout
            cmp #$23
            bne:-

    rts
.endproc
