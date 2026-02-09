
.proc init_pickups
    jsr new_pickup_location         ; Randomly place the pickups on start
    
    ; --- Pickup 1 Sprite Config ---
    lda #$0F
    sta PICKUPS_SPRITE_1 + 1        ; Set Tile Index (Graphic)
    lda #$03
    sta PICKUPS_SPRITE_1 + 2        ; Set Attributes (Color/Palette)

    ; --- Pickup 2 Sprite Config ---
    lda #$0F
    sta PICKUPS_SPRITE_2 + 1        ; Set Tile Index
    lda #$03
    sta PICKUPS_SPRITE_2 + 2        ; Set Attributes

    ; --- Pickup 3 Sprite Config ---
    lda #$0F
    sta PICKUPS_SPRITE_3 + 1        ; Set Tile Index
    lda #$03
    sta PICKUPS_SPRITE_3 + 2        ; Set Attributes
    rts 
.endproc


.proc update_pickups
    ; --- Handle Pickup 1 ---
    lda #%00011111                  ; Mask out the "existence bit" (Bit 7)
    and PICKUP_1_X                  ; Extract just the 5-bit X coordinate
    tax 
    ldy PICKUP_1_Y
    jsr pickup_collisions           ; Check for player collision at (X, Y)
    cmp #$01
    bne :+
        jsr add_segment             ; Collision! Grow the snake
        lda #$00
        sta PICKUP_1_X              ; Clear existence bit (mark as collected)
        jsr new_pickup_location     ; Request respawn
    :

    ; --- Visibility Logic: Hide sprites based on player deaths ---
    lda PLAYERS_DEAD
    and #%00001111
    cmp #$02                        ; If 2+ players dead, hide pickups 2 & 3
    bcc:+
        lda #$00 
        sta PICKUPS_SPRITE_2 + 1    ; Remove tile index (effectively hides it)
        sta PICKUPS_SPRITE_3 + 1
        jmp end_pickup              ; Optimization: exit early
    :

    ; --- Handle Pickup 2 ---
    lda #%00011111                  
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

    lda PLAYERS_DEAD
    and #%00001111
    cmp #$01                        ; If 1+ players dead, hide pickup 3
    bcc:+
        lda #$00 
        sta PICKUPS_SPRITE_3 + 1
        jmp end_pickup
    :

    ; --- Handle Pickup 3 ---
    lda #%00011111                  
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

    end_pickup:
    rts 
.endproc


.proc new_pickup_location
    TEMP_X = $07
    TEMP_Y = $08
    NEW_LOCATIONS = $09             ; Bitmask for which pickup slot to fill
    
    start:
        lda #$00
        sta NEW_LOCATIONS           ; Clear the update flags

        ; Check existence of all 3 pickups (Bit 7 = 1 means it exists)
        lda #%10000000
        and PICKUP_1_X      
        cmp #$80
        bne :+                      ; Found a slot to fill (Pickup 1)

        lda #%10000000
        and PICKUP_2_X      
        cmp #$80
        bne :+                      ; Found a slot to fill (Pickup 2)

        lda #%10000000
        and PICKUP_3_X      
        cmp #$80
        bne :+                      ; Found a slot to fill (Pickup 3)

        rts                         ; All pickups already exist, exit
        
        :
        ; --- Random Generation Stage ---
        jsr galois16                ; Call RNG
        clc 
        adc #$02                    ; X Offset: Keep away from left border
        tax 
        stx TEMP_X
        
        jsr galois16                ; Call RNG again
        clc 
        adc #$01                    ; Y Offset: Keep away from top border
        tay 
        sty TEMP_Y

        jsr check_body_collisions   ; Validate: Did we spawn inside a snake?
        cmp #$00
        beq :+
            jmp start               ; Invalid location, try again
        :

        ; --- Overlap Check: Don't spawn on top of existing pickups ---
        ; Check Pickup 1
        lda #%10000000                  
        and PICKUP_1_X
        cmp #$80                    ; If Pickup 1 exists...
        bne :+
            lda #%00011111
            and PICKUP_1_X
            cmp TEMP_X              ; Is new X same as Pickup 1 X?
            bne :++
                lda PICKUP_1_Y
                cmp TEMP_Y          ; Is new Y same as Pickup 1 Y?
                bne :++
                jmp start           ; Overlap! Restart RNG.
        :
            lda #$01                ; Mark Pickup 1 as the slot to update
            ora NEW_LOCATIONS
            sta NEW_LOCATIONS
        :

        ; Check Pickup 2
        lda #%10000000
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
            lda #$02                ; Mark Pickup 2 as the slot to update
            ora NEW_LOCATIONS
            sta NEW_LOCATIONS
        :

        ; Check Pickup 3
        lda #%10000000
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
            lda #$04                ; Mark Pickup 3 as the slot to update
            ora NEW_LOCATIONS
            sta NEW_LOCATIONS
        :

        ; --- Finalization Stage: Write data to memory and OAM ---
        
        ; Slot 1 Update
        lda #$01
        and NEW_LOCATIONS
        cmp #$01
        bne :+
            lda TEMP_X
            ora #%10000000          ; Save X coordinate with existence bit (7)
            sta PICKUP_1_X

            lda TEMP_X
            asl 
            asl 
            asl         ; Convert Tile X to Pixel X (Multiply by 8)
            sta PICKUPS_SPRITE_1 + 3

            lda TEMP_Y
            sta PICKUP_1_Y

            asl 
            asl 
            asl         ; Convert Tile Y to Pixel Y (Multiply by 8)
            sta PICKUPS_SPRITE_1    ; Write to Sprite Y
            dec PICKUPS_SPRITE_1    ; NES Sprite Y-offset fix (-1 scanline)

            jmp start               ; Re-loop to see if other slots need filling
        :
        
        ; Slot 2 Update
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
            sta PICKUPS_SPRITE_2 + 3

            lda TEMP_Y
            sta PICKUP_2_Y

            asl 
            asl 
            asl 
            sta PICKUPS_SPRITE_2
            dec PICKUPS_SPRITE_2

            jmp start
        :

        ; Slot 3 Update
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
            sta PICKUPS_SPRITE_3 + 3

            lda TEMP_Y
            sta PICKUP_3_Y

            asl 
            asl 
            asl 
            sta PICKUPS_SPRITE_3 
            dec PICKUPS_SPRITE_3
            
            jmp start
        :
        jmp start
.endproc