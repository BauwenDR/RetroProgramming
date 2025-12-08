.proc init_pickups
    jsr new_pickup_location
    lda #$0F
    sta PICKUPS_SPRITE_1 + 1

    lda #$03
    sta PICKUPS_SPRITE_1 + 2

    lda #$0F
    sta PICKUPS_SPRITE_2 + 1

    lda #$03
    sta PICKUPS_SPRITE_2 + 2

    lda #$0F
    sta PICKUPS_SPRITE_3 + 1

    lda #$03
    sta PICKUPS_SPRITE_3 + 2
    rts 
.endproc

.proc update_pickups
    lda #%00011111                  ;lose the bit that says if it exist
    and PICKUP_1_X
    tax 
    ldy PICKUP_1_Y
    jsr pickup_collisions
    cmp #$01
    bne :+
        jsr add_segment
        lda #$00
        sta PICKUP_1_X
        jsr new_pickup_location
    :

    lda #%00011111                  ;lose the bit that says if it exist
    and PICKUP_2_X
    tax 
    ldy PICKUP_2_Y
    jsr pickup_collisions
    cmp #$01
    bne :+
        jsr add_segment
        lda #$00
        sta PICKUP_2_X
        jsr new_pickup_location
    :

    lda #%00011111                  ;lose the bit that says if it exist
    and PICKUP_3_X
    tax 
    ldy PICKUP_3_Y
    jsr pickup_collisions
    cmp #$01
    bne :+
        jsr add_segment
        lda #$00
        sta PICKUP_3_X
        jsr new_pickup_location
    :

    rts 
.endproc

.proc new_pickup_location
    TEMP_X = $07
    TEMP_Y = $08
    NEW_LOCATIONS = $09
    start:
        lda #$00
        sta NEW_LOCATIONS 

        lda #%10000000
        and PICKUP_1_X      ;player1
        cmp #$80
        bne :+

        lda #%10000000
        and PICKUP_2_X      ;player2
        cmp #$80
        bne :+

        lda #%10000000
        and PICKUP_3_X      ;player3
        cmp #$80
        bne :+


        rts 
        :
        jsr galois16
        clc 
        adc #$02
        tax 
        stx TEMP_X
        

        jsr galois16
        clc 
        adc #$01
        tay 
        sty TEMP_Y

        jsr check_body_collisions        ;do the collistions checking with snakes

        cmp #$00
        beq :+
            jmp start
        :

        ;check if there already is a pickup on the spot
        lda #%10000000                  
        and PICKUP_1_X
        cmp #$80                            ;check if pickup1 is on the map
        bne :+
            lda #%00011111                  ;lose the bit that says if it exist
            and PICKUP_1_X
            cmp TEMP_X                      ;check if x location is on the same place
            bne :++
                lda PICKUP_1_Y
                cmp TEMP_Y
                bne :++                      ;check if y location is on the same place
                jmp start                   ;if yes then we go again
        :
            lda #$01                        ;set the first bit in new locations
            ora NEW_LOCATIONS               ;to show that this location has to be set
            sta NEW_LOCATIONS
        :

        lda #%10000000                      ;read for player 1 its exact the same here
        and PICKUP_2_X
        cmp #$80
        bne :+
            lda #%00011111
            and PICKUP_2_X
            cmp TEMP_X
            bne :++
                lda PICKUP_2_Y
                cmp TEMP_Y
                bne :+
                jmp start
        :
            lda #$02
            ora NEW_LOCATIONS
            sta NEW_LOCATIONS
        :

        lda #%10000000                      ;read for player 1 its exact the same here
        and PICKUP_3_X
        cmp #$80
        bne :+
            lda #%00011111
            and PICKUP_3_X
            cmp TEMP_X
            bne :++
                lda PICKUP_3_Y
                cmp TEMP_Y
                bne :++
                jmp start
        :
            lda #$04
            ora NEW_LOCATIONS
            sta NEW_LOCATIONS
        :

        lda #$01
        and NEW_LOCATIONS
        cmp #$01
        bne :+
            lda TEMP_X
            ora #%10000000
            sta PICKUP_1_X

            lda TEMP_X
            asl 
            asl 
            asl 
            sta PICKUPS_SPRITE_1 + 3    ;x

            lda TEMP_Y
            sta PICKUP_1_Y

            asl 
            asl 
            asl 
            sta PICKUPS_SPRITE_1        ;y
            dec PICKUPS_SPRITE_1

            jmp start  
        :
        
        lda #$02
        and NEW_LOCATIONS
        cmp #$02
        bne :+
            lda TEMP_X
            ora #%10000000
            sta PICKUP_2_X

            lda TEMP_X
            asl 
            asl 
            asl 
            sta PICKUPS_SPRITE_2 + 3    ;x

            lda TEMP_Y
            sta PICKUP_2_Y

            asl 
            asl 
            asl 
            sta PICKUPS_SPRITE_2        ;y
            dec PICKUPS_SPRITE_2

            jmp start


        :

        lda #$04
        and NEW_LOCATIONS
        cmp #$04
        bne :+
            lda TEMP_X
            ora #%10000000
            sta PICKUP_3_X

            lda TEMP_X
            asl 
            asl 
            asl 
            sta PICKUPS_SPRITE_3 + 3    ;x

            lda TEMP_Y
            sta PICKUP_3_Y

            asl 
            asl 
            asl 
            sta PICKUPS_SPRITE_3        ;y
            dec PICKUPS_SPRITE_3
            
            jmp start
        :
        jmp start
.endproc
