.proc player_collisions
    PLAYER_X        = $A0           ; Temp storage for current player X
    PLAYER_Y        = $A1           ; Temp storage for current player Y
    OFFSET          = $A2           ; Current player memory offset (0, 18, 36, 54)
    DELETE_PLAYERS  = $A3           ; Bitmask tracking which players died this frame
    
    lda #$00
    sta OFFSET                      ; Reset offset to first player
    sta DELETE_PLAYERS              ; Clear death bitmask

    next_snake:
        ldy OFFSET                  ; Load the offset in y
        cpy #$48                    ; Check if the offset is 48 (4 players * 18 bytes)
        bne :+                      ; If not 48, continue processing
            jmp end_collisions      ; If it is 48 -> end the function
        : 

        ; Skip inactive snakes (length == 0)
        lda PLAYER_LENGTH,y         ; Load length of current snake
        lsr                         ; Shift right to isolate length bits
        lsr 
        cmp #$00                    ; Compare with zero
        bne :+                      ; If length is not 0, snake is active
            jmp prep_next_snake     ; Otherwise, go to next snake
        :

        lda PLAYER_HEAD,y           ; Getting the x location from player head
        and #%00011111              ; Deleting the bits from the y position (masking)
        sta PLAYER_X                ; Storing the start x position into memory 

        lda PLAYER_HEAD,y           ; Getting the 3 lsb from player head for Y
        lsr                         ; Putting them in the right position (bits 5-7 to 0-2)
        lsr 
        lsr 
        lsr 
        lsr 
        sta PLAYER_Y                ; Storing the temporary Y value

        lda PLAYER_HEAD + 1,y       ; Getting the 2 msb from player head (byte 2)
        and #%00000011              ; Masking to keep only the bottom 2 bits
        asl                         ; Putting them in the right position (bits 3-4)
        asl 
        asl 

        ora PLAYER_Y                ; Combining the 2 previous operations
        sta PLAYER_Y                ; Storing the start y position into memory

        ldy PLAYER_Y                ; Pass Y to collision check
        ldx PLAYER_X                ; Pass X to collision check
        jsr check_body_collisions   ; Check if head is inside any snake body

        cmp #$00                    ; Check if collision occurred (A=1 if hit)
        beq skip_delete_player      ; If 0, no body hit
            lda OFFSET              ; Load offset to find which player bit to set
            cmp #$00
            bne :+
                lda #%00000001      ; Set bit 0 for Player 1
                ora DELETE_PLAYERS
                sta DELETE_PLAYERS
                lda #$01
            :
            cmp #$12
            bne :+
                lda #%00000010      ; Set bit 1 for Player 2
                ora DELETE_PLAYERS
                sta DELETE_PLAYERS
                lda #$01
            :
            cmp #$24
            bne :+
                lda #%00000100      ; Set bit 2 for Player 3
                ora DELETE_PLAYERS
                sta DELETE_PLAYERS
                lda #$01
            :
            cmp #$36
            bne :+
                lda #%00001000      ; Set bit 3 for Player 4
                ora DELETE_PLAYERS
                sta DELETE_PLAYERS
                lda #$01
            :
        skip_delete_player:

        ldy PLAYER_Y                ; Set up registers for head check
        ldx PLAYER_X
        lda #$00                    ; Clear A
        jsr check_head_collisions   ; Check for head-on collisions

        ldy OFFSET                  ; Check which snake we are currently processing
        cpy #$00
        bne :+
            and #%00001110          ; Mask out self (Player 1 cannot head-butt self)
            ora DELETE_PLAYERS      ; Merge with existing death mask
            sta DELETE_PLAYERS
            lda #$FF                ; Logic flag
        :
        cpy #$12
        bne :+
            and #%00001101          ; Mask out self (Player 2)
            ora DELETE_PLAYERS
            sta DELETE_PLAYERS
            lda #$FF
        :
        cpy #$24
        bne :+
            and #%00001011          ; Mask out self (Player 3)
            ora DELETE_PLAYERS
            sta DELETE_PLAYERS
            lda #$FF
        :
        cpy #$36
        bne :+
            and #%00000111          ; Mask out self (Player 4)
            ora DELETE_PLAYERS
            sta DELETE_PLAYERS
            lda #$FF
        :

        lda PLAYER_X                ; Boundary Check: Left Wall
        cmp #$01
        bne :+
            jsr dead                ; Trigger death logic
        :

        lda PLAYER_X                ; Boundary Check: Right Wall
        cmp #$1E
        bne :+
            jsr dead
        :

        lda PLAYER_Y                ; Boundary Check: Top Wall
        cmp #$00
        bne :+
            jsr dead
        :

        lda PLAYER_Y                ; Boundary Check: Bottom Wall
        cmp #$1D
        bne :+
            jsr dead
        :

        prep_next_snake:
        lda OFFSET                  ; Get the current offset
        clc     
        adc #$12                    ; Add 18 ($12) bytes for next player data block
        sta OFFSET                  ; Store the updated offset
        jmp next_snake              ; Go to the next snake loop
    end_collisions:

    lda DELETE_PLAYERS              ; Process the death mask
    and #%00000001                  ; Check bit for Player 1
    cmp #%00000001
    bne :+
        ldx #$00                    ; Set index for deletion
        jsr delete_snake            ; Call delete routine
    :

    lda DELETE_PLAYERS
    and #%00000010                  ; Check bit for Player 2
    cmp #%00000010
    bne :+
        ldx #$01
        jsr delete_snake 
    :

    lda DELETE_PLAYERS
    and #%00000100                  ; Check bit for Player 3
    cmp #%00000100
    bne :+
        ldx #$02
        jsr delete_snake
    :

    lda DELETE_PLAYERS
    and #%00001000                  ; Check bit for Player 4
    cmp #%00001000
    bne :+
        ldx #$03
        jsr delete_snake 
    :       
    rts                             ; Return from main collision check

    .proc dead
        lda OFFSET                  ; Identify which player died
        cmp #$00
        bne :+
            lda #%00000001          ; Flag Player 1
            ora DELETE_PLAYERS
            sta DELETE_PLAYERS
            lda #$01
        :
        cmp #$12
        bne :+
            lda #%00000010          ; Flag Player 2
            ora DELETE_PLAYERS
            sta DELETE_PLAYERS
            lda #$01
        :
        cmp #$24
        bne :+
            lda #%00000100          ; Flag Player 3
            ora DELETE_PLAYERS
            sta DELETE_PLAYERS
            lda #$01
        :
        cmp #$36
        bne :+
            lda #%00001000          ; Flag Player 4
            ora DELETE_PLAYERS
            sta DELETE_PLAYERS
            lda #$01
        : 
        rts 
    .endproc
.endproc


.proc check_body_collisions
    ; INPUT: X register = target X, Y register = target Y
    CHECK_X = $01                   ; The x location to check
    CHECK_Y = $02                   ; The y location to check

    SNAKE_X = $03                   ; Moving pointer for body reconstruction (X)
    SNAKE_Y = $04                   ; Moving pointer for body reconstruction (Y)

    OFFSET = $05                    ; Offset to current snake being checked
    LENGTH = $06                    ; Current length of snake being checked

    stx CHECK_X                     ; Copy target coordinates to local memory
    sty CHECK_Y

    lda #$00
    sta OFFSET                      ; Start with the first snake
    next_snake:
        ldy OFFSET                  ; Load offset into Y
        cpy #$48                    ; Check if we finished all snakes
        bne :+       
            jmp no_collision_found  ; No hits found after full loop
        :
        
        lda PLAYER_LENGTH,y         ; Check if this snake is alive
        lsr 
        lsr 
        cmp #$00
        bne :+
            jmp prep_next_snake     ; Skip if dead
        :

        lda PLAYER_LENGTH,y         ; Getting the player length
        lsr                         ; Shift out the head data bits
        lsr 
        sta LENGTH                  ; Store actual length
        cmp #$00                    ; Check for 0 length
        bne :+                      ; If length exists, proceed
            tya                     ; Else prepare next snake
            clc     
            adc #$12                
            sta OFFSET              
            jmp next_snake          
        :                       

        lda PLAYER_HEAD,y           ; Get head X for current snake
        and #%00011111              
        sta SNAKE_X                 

        lda PLAYER_HEAD,y           ; Get head Y part 1
        lsr 
        lsr 
        lsr 
        lsr 
        lsr 
        sta SNAKE_Y                 

        lda PLAYER_HEAD + 1,y       ; Get head Y part 2
        and #%00000011
        asl 
        asl 
        asl 
        ora SNAKE_Y                 ; Combine Y bits
        sta SNAKE_Y                 ; Body pointer starts at the head

        collision_loop:
            lda LENGTH              ; Getting the right byte index for body direction
            sec 
            sbc #$01
            lsr                     ; 2 bits per direction means 4 directions per byte
            lsr             
            clc 
            adc OFFSET              ; Offset relative to player data
            tay         

            ; Extract 2 bits from the body byte based on remainder of length
            lda LENGTH
            and #%00000011
            
            cmp #$00                ; No shifts needed
            bne :+
                lda PLAYER_BODY,y
                tax 
                lda #$04
            :

            cmp #$03                ; 2 bit shifts
            bne :+
                lda PLAYER_BODY,y
                lsr 
                lsr 
                tax 
                lda #$04
            :

            cmp #$02                ; 4 bit shifts
            bne :+
                lda PLAYER_BODY,y
                lsr 
                lsr 
                lsr 
                lsr  
                tax 
                lda #$04
            :

            cmp #$01                ; 6 bit shifts
            bne :+
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
            and #%00000011          ; Final 2-bit direction (0=L, 1=R, 2=U, 3=D)
            
            ; Update virtual pointer based on movement history
            cmp #$00                ; Left                 
            bne :+
                dec SNAKE_X
                lda #$04
            :

            cmp #$01                ; Right                
            bne :+
                inc SNAKE_X
                lda #$04
            :

            cmp #$02                ; Up                   
            bne :+
                dec SNAKE_Y
                lda #$04
            :

            cmp #$03                ; Down                   
            bne :+
                inc SNAKE_Y
                lda #$04
            :

            lda SNAKE_X             ; Check if virtual body segment matches target X
            cmp CHECK_X
            bne :+
                lda SNAKE_Y         ; Check if virtual body segment matches target Y
                cmp CHECK_Y
                bne :+
                    jmp collision_found ; Match found!
            :
        
            dec LENGTH              ; Move to next body segment
            lda LENGTH
            cmp #$01                ; Length 1 is the head, which we've checked
            beq :+           
                jmp collision_loop  ; Continue checking body
            :                       
            
            prep_next_snake:
                tya                 ; Move to next player index
                clc     
                adc #$12                
                sta OFFSET              
                jmp next_snake          

    collision_found:
        ldy OFFSET                  ; Set Y to the snake that was hit
        lda #$01                    ; Set collision flag
        rts 
    no_collision_found:
        lda #$00                    ; Clear collision flag
        rts  
.endproc

.proc check_head_collisions
    ; INPUT: X = target X, Y = target Y
    CHECK_X = $01                   ; X to check
    CHECK_Y = $02                   ; Y to check

    SNAKE_X = $03                   ; Current snake head X
    SNAKE_Y = $04                   ; Current snake head Y

    OFFSET = $05                    ; Memory offset
    COLLISION = $06                 ; Collision bitmask result


    stx CHECK_X                     ; Initialize variables
    sty CHECK_Y

    lda #$00
    sta COLLISION
    sta OFFSET

    next_snake:
        ldy OFFSET
        cpy #$48                    ; Check if we checked all 4 snakes
        bne :+
            jmp end
        :

        lda PLAYER_LENGTH,y         ; Check if player exists
        lsr 
        lsr 
        cmp #$00
        bne :+
            jmp prep_next_snake
        :

        lda PLAYER_HEAD,y           ; Extract current head X
        and #%00011111              
        sta SNAKE_X                 

        lda PLAYER_HEAD,y           ; Extract current head Y (bits 0-2)
        lsr 
        lsr 
        lsr 
        lsr 
        lsr 
        sta SNAKE_Y                 

        lda PLAYER_HEAD + 1,y       ; Extract current head Y (bits 3-4)
        and #%00000011
        asl 
        asl 
        asl 
        ora SNAKE_Y                 
        sta SNAKE_Y                 

        lda SNAKE_X                 ; Compare head X to check X
        cmp CHECK_X
        bne prep_next_snake
        lda SNAKE_Y                 ; Compare head Y to check Y
        cmp CHECK_Y
        bne prep_next_snake
            
            lda OFFSET              ; If both match, record which player was hit
            cmp #$00
            bne :+
                lda #%00000001
                ora COLLISION
                sta COLLISION
                lda #$01
            :

            cmp #$12
            bne :+
                lda #%00000010
                ora COLLISION
                sta COLLISION
                lda #$01
            :

            cmp #$24
            bne :+
                lda #%00000100
                ora COLLISION
                sta COLLISION
                lda #$01
            :

            cmp #$36
            bne :+
                lda #%00001000
                ora COLLISION
                sta COLLISION
                lda #$01
            :
        prep_next_snake:
            tya 
            clc 
            adc #$12
            sta OFFSET
            jmp next_snake

    end:
        lda COLLISION               ; Return the mask of snakes involved in head collision
        rts
.endproc