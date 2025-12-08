
.proc check_body_collitions
    ;make sure that in the x register has the x value of the location that has to be checkt
    ;make sure that in the y register has the y value of the location that has to be checkt
    CHECK_X = $01                   ;the x location to check
    CHECK_Y = $02                   ;the y location to check

    SNAKE_X = $03                   ;the x location of the bodypart to check
    SNAKE_Y = $04                   ;the y location of the bodypart to check

    OFFSET = $05                    ;the offset to see what snake we are checking
    LENGTH = $06                    ;the length of the snake we are checking

    stx CHECK_X                     ;copying the x,y values into the memory
    sty CHECK_Y

    lda #$00
    sta OFFSET                      ;setting the offset to 0
    next_snake:
        ldy OFFSET                  ;load the offset in y
        cpy #$48                    ;check if the offset is 48 (if it is it means that is done with looping)
        bne:+       
            jmp no_collition_found  ;if it is 48 -> end the function
        :
                                   ;else -> continiue
        lda PLAYER_LENGTH,y
        lsr 
        lsr 
        cmp #$00
        bne:+
            jmp prep_next_snake
        :

        lda PLAYER_LENGTH,y         ;getting the player length
        lsr                         ;putting it in the right spot
        lsr                         ;and shifting the bits from the head out
        sta LENGTH                  ;storing the value
        cmp #$00                    ;seing if the length is 0
        bne:+                       ;if it is skip to next player
            tya                     ;get the offset to a
            clc     
            adc #$12                ;add 12 because the size of the player in memory is 12
            sta OFFSET              ;store the offset in OFFSET
            jmp next_snake          ;go to the next snake
        :                       
        


        lda PLAYER_HEAD,y           ;getting the x location from player head
        and #%00011111              ;deleting the bits from the y position
        sta SNAKE_X                 ;storing the start x position into memory

        lda PLAYER_HEAD,y           ;getting the 3 lsb from player head 
        lsr                         ;putting them in the right possition
        lsr 
        lsr 
        lsr 
        lsr 
        sta SNAKE_Y                 ;storing the tempeary value

        lda PLAYER_HEAD + 1,y       ;getting the 2 msb from player head  
        and #%00000011
        asl                         ;putting them in the right possition
        asl 
        asl 

        ora SNAKE_Y                 ;combining the 2 prev opperations
        sta SNAKE_Y                 ;storing the start y position into memory

        collision_loop:
            


            lda LENGTH              ;getting the right byte
            sec 
            sbc #$01
            lsr                     ;the last 2 bits in body offset mean waht instruction we are at
            lsr             
            clc 
            adc OFFSET              ;add it to the offset
            tay         


            ;getting the direction for next location
            ;the last 2 digets of length say what part of the byte gets used 
            ;and we are extracting that first
            lda LENGTH
            and #%00000011
            ;based on the result we need to shift the byte
            cmp #$00                ;0 shifts                    
            bne:+
                lda PLAYER_BODY,y
                tax 
                lda #$04
            :

            cmp #$03                ;2 shifts
            bne:+
                lda PLAYER_BODY,y
                lsr 
                lsr 
                tax 
                lda #$04
            :

            cmp #$02               ;4 shifts
            bne:+
                lda PLAYER_BODY,y
                lsr 
                lsr 
                lsr 
                lsr  
                tax 
                lda #$04
            :

            cmp #$01                ;6 shifts
            bne:+
                lda PLAYER_BODY,y
                lsr 
                lsr 
                lsr 
                lsr 
                lsr 
                lsr 
                tax 

            :
            txa 
            and #%00000011 
            ;setting the next location
           
            cmp #$00                ;left                 
            bne:+
                dec SNAKE_X
                lda #$04
            :

            cmp #$01                ;right                
            bne:+
                inc SNAKE_X
                lda #$04
            :

            cmp #$02                ;up                  
            bne:+
                dec SNAKE_Y
                lda #$04
            :

            cmp #$03                ;down                  
            bne:+
                inc SNAKE_Y
                lda #$04
            :

            lda SNAKE_X
            cmp CHECK_X
            bne:+
                lda SNAKE_Y
                cmp CHECK_Y
                bne:+
                    jmp collision_found
                    
                
            :
        
            dec LENGTH
            lda LENGTH              ;getting the length
            cmp #$01                ;seing if the length is 0
            beq:+           
                jmp collision_loop  ;if it isnt -> loop again 
            :                       ;if it is
            prep_next_snake:
                tya                     ;get the offset to a
                clc     
                adc #$12                ;add 12 because the size of the player in memory is 12
                sta OFFSET              ;store the offset in OFFSET
                jmp next_snake          ;go to the next snake

    collision_found:
        ldy OFFSET              ;load the offset in y so you know what player had the collistion
        lda #$01                ;load 1 in a so you know there has been a collistion
        rts 
    no_collition_found:
        lda #$00                ;load 0 in a so you know there has been a collistion
        rts  
.endproc 

.proc check_head_collitions
    ;make sure that in the x register has the x value of the location that has to be checkt
    ;make sure that in the y register has the y value of the location that has to be checkt
    CHECK_X = $01                   ;the x location to check
    CHECK_Y = $02                   ;the y location to check

    SNAKE_X = $03                   ;the x location of the bodypart to check
    SNAKE_Y = $04                   ;the y location of the bodypart to check

    OFFSET = $05                    ;the offset to see what snake we are checking
    COLLISION = $06


    stx CHECK_X                     ;copying the x,y values into the memory
    sty CHECK_Y

    lda #$00
    sta COLLISION
    sta OFFSET

    next_snake:
        ldy OFFSET                  ;load the offset in y
        cpy #$48                    ;check if the offset is 48 (if it is it means that is done with looping)
        bne:+       
            lda COLLISION
            rts                     ;if it is 48 -> end the function
        :

        lda PLAYER_LENGTH,y
        lsr 
        lsr 
        cmp #$00
        bne:+
            jmp prep_next_snake
        :

        lda PLAYER_HEAD,y           ;getting the x location from player head
        and #%00011111              ;deleting the bits from the y position
        sta SNAKE_X                 ;storing the start x position into memory

        lda PLAYER_HEAD,y           ;getting the 3 lsb from player head 
        lsr                         ;putting them in the right possition
        lsr 
        lsr 
        lsr 
        lsr 
        sta SNAKE_Y                 ;storing the tempeary value

        lda PLAYER_HEAD + 1,y       ;getting the 2 msb from player head  
        and #%00000011
        asl                         ;putting them in the right possition
        asl 
        asl 

        ora SNAKE_Y                 ;combining the 2 prev opperations
        sta SNAKE_Y                 ;storing the start y position into memory



        lda SNAKE_X
            cmp CHECK_X
            bne:++++
                lda SNAKE_Y
                cmp CHECK_Y
                bne:++++
                    lda OFFSET
                    cmp #$00
                    bne:+
                        lda #%00000001
                        ora COLLISION
                        sta COLLISION

                        lda #$01
                    :
                    cmp #$12
                    bne:+
                        lda #%00000010
                        ora COLLISION
                        sta COLLISION

                        lda #$01
                    :
                    cmp #$24
                    bne:+
                        lda #%00000100
                        ora COLLISION
                        sta COLLISION

                        lda #$01
                    :
                    cmp #$36
                    bne:+
                        lda #%00001000
                        ora COLLISION
                        sta COLLISION

                        lda #$01
                    :



        prep_next_snake:
    

        tya                     ;get the offset to a
        clc     
        adc #$12                ;add 12 because the size of the player in memory is 12
        sta OFFSET              ;store the offset in OFFSET
        jmp next_snake          ;go to the next snake
.endproc

.proc pickup_collitions
    COLLISION = $01
    jsr check_head_collitions
    sta COLLISION

    and #%00000001              ;player 1
    cmp #%00000001
    bne:+
        ldy #$00
        lda #$01
        rts 
    :

    lda COLLISION
    and #%00000010              ;player 2
    cmp #%00000010
    bne:+
        ldy #$12
        lda #$01
        rts 
    :

    lda COLLISION
    and #%00000100              ;player 3
    cmp #%00000100
    bne:+
        ldy #$24
        lda #$01
        rts 
    :

    lda COLLISION
    and #%00001000              ;player 4
    cmp #%00001000
    bne:+
        ldy #$36
        lda #$01
        rts 
    :


    lda #$00
    rts 
.endproc

.proc player_collistions
    PLAYER_X        = $A0
    PLAYER_Y        = $A1
    OFFSET          = $A2
    DELETE_PLAYERS  = $A3   
    
    lda #$00
    sta OFFSET
    sta DELETE_PLAYERS

    next_snake:
        ldy OFFSET                      ;load the offset in y
        cpy #$48                        ;check if the offset is 48 (if it is it means that is done with looping)
        bne:+       
            jmp end_collisions                         ;if it is 48 -> end the function
        : 

        lda PLAYER_LENGTH,y
        lsr 
        lsr 
        cmp #$00
        bne:+
            jmp prep_next_snake
        :

        lda PLAYER_HEAD,y               ;getting the x location from player head
        and #%00011111                  ;deleting the bits from the y position
        sta PLAYER_X                    ;storing the start x position into memory 

        lda PLAYER_HEAD,y               ;getting the 3 lsb from player head 
        lsr                             ;putting them in the right possition
        lsr 
        lsr 
        lsr 
        lsr 
        sta PLAYER_Y                    ;storing the tempeary value

        lda PLAYER_HEAD + 1,y           ;getting the 2 msb from player head  
        and #%00000011
        asl                             ;putting them in the right possition
        asl 
        asl 

        ora PLAYER_Y                    ;combining the 2 prev opperations
        sta PLAYER_Y                    ;storing the start y position into memory

        ldy PLAYER_Y
        ldx PLAYER_X
        jsr check_body_collitions

        cmp #$00
        beq:++++
            lda OFFSET
                    cmp #$00
                    bne:+
                        lda #%00000001
                        ora DELETE_PLAYERS
                        sta DELETE_PLAYERS

                        lda #$01
                    :
                    cmp #$12
                    bne:+
                        lda #%00000010
                        ora DELETE_PLAYERS
                        sta DELETE_PLAYERS

                        lda #$01
                    :
                    cmp #$24
                    bne:+
                        lda #%00000100
                        ora DELETE_PLAYERS
                        sta DELETE_PLAYERS

                        lda #$01
                    :
                    cmp #$36
                    bne:+
                        lda #%00001000
                        ora DELETE_PLAYERS
                        sta DELETE_PLAYERS

                        lda #$01
                    :

        ldy PLAYER_Y
        ldx PLAYER_X
        lda #$00
        jsr check_head_collitions

        ldy OFFSET
        cpy #$00
        bne:+
            and #%00001110
            ora DELETE_PLAYERS
            sta DELETE_PLAYERS

            lda #$FF
        :
        cpy #$12
        bne:+
            and #%00001101
            ora DELETE_PLAYERS
            sta DELETE_PLAYERS

            lda #$FF
        :
        cpy #$24
        bne:+
            and #%00001011
            ora DELETE_PLAYERS
            sta DELETE_PLAYERS

            lda #$FF
        :
        cpy #$36
        bne:+
            and #%00000111
            ora DELETE_PLAYERS
            sta DELETE_PLAYERS

            lda #$FF
        :

    


        lda PLAYER_X
        cmp #$02
        bcs:+
            jsr dead
        :

        lda PLAYER_X
        cmp #$1E
        bcc:+
            jsr dead
        :

        lda PLAYER_Y
        cmp #$00
        bcs:+
            jsr dead
        :

        lda PLAYER_Y
        cmp #$1D
        bcc:+
            jsr dead
        :
        jmp prep_next_snake

        dead:
            lda OFFSET
            cmp #$00
            bne:+
                lda #%00000001
                ora DELETE_PLAYERS
                sta DELETE_PLAYERS

                lda #$01
            :
            cmp #$12
            bne:+
                lda #%00000010
                ora DELETE_PLAYERS
                sta DELETE_PLAYERS

                lda #$01
            :
            cmp #$24
            bne:+
                lda #%00000100
                ora DELETE_PLAYERS
                sta DELETE_PLAYERS

                lda #$01
            :
            cmp #$36
            bne:+
                lda #%00001000
                ora DELETE_PLAYERS
                sta DELETE_PLAYERS

                lda #$01
            : 
            rts 


        prep_next_snake:

            lda OFFSET              ;get the offset to a
            clc     
            adc #$12                ;add 12 because the size of the player in memory is 12
            sta OFFSET              ;store the offset in OFFSET
            jmp next_snake          ;go to the next snake


    end_collisions:
    lda DELETE_PLAYERS
    and #%00000001              ;player 1
    cmp #%00000001
    bne:+
        ldx #$00
        jsr delete_snake 
    :

    lda DELETE_PLAYERS
    and #%00000010              ;player 2
    cmp #%00000010
    bne:+
        ldx #$01
        jsr delete_snake 
    :

    lda DELETE_PLAYERS
    and #%00000100              ;player 3
    cmp #%00000100
    bne:+
        ldx #$02
        jsr delete_snake
    :

    lda DELETE_PLAYERS
    and #%00001000              ;player 4
    cmp #%00001000
    bne:+
        ldx #$03
        jsr delete_snake 
    :       
    rts
.endproc