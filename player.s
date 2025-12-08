;; Initialises player memory (hardcoded values)
.proc init_player
    
    ; Set attributes (no flipping x 2, in front of background, unimplemented x 3, palette x 2)
    lda #%00000000
    sta PLAYER_HEAD_SPRITE_1 + 2 ; Store attributes

    lda #%00000001
    sta PLAYER_HEAD_SPRITE_2 + 2 ; Store attributes

    lda #%00000010
    sta PLAYER_HEAD_SPRITE_3 + 2 ; Store attributes

    lda #%00000011
    sta PLAYER_HEAD_SPRITE_4 + 2 ; Store attributes

    ; Player 1
    lda #$24                    ; x = 4, y = 1
    sta PLAYER_HEAD

    lda #%00001100              ; Length = 3, y = 1
    sta PLAYER_LENGTH

    lda #%00000000              ; First 3 body bits moving right
    sta PLAYER_BODY

    ; Player 2
    lda #$7D                    ; x = 29, y = 3
    sta PLAYER_HEAD_2

    lda #%00001100              ; Length = 3, y = 3
    sta PLAYER_LENGTH_2

    lda #%10101000
    sta PLAYER_BODY_2           ; First 3 body bits moving down

    ; Player 3
    lda #$9B                    ; x = 27, y = 28
    sta PLAYER_HEAD_3

    lda #%00001111              ; Length = 3, y = 28
    sta PLAYER_LENGTH_3

    lda #%01010100              ; First 3 body bits moving left
    sta PLAYER_BODY_3


    ;player 4
    lda #$42                    ; x = 2, y = 26
    sta PLAYER_HEAD_4

    lda #%00001111              ; Length = 3, y = 26
    sta PLAYER_LENGTH_4

    lda #%11111100              ; First 3 body bits moving up
    sta PLAYER_BODY_4

    rts 
.endproc

;; Draws initial player locations
.proc init_draw_player
    ;; Player 1
    lda #$0B
    ldx #$20
    ldy #$22
    jsr push_background_buffer

    lda #$05
    ldx #$20
    ldy #$23
    jsr push_background_buffer

    lda #$08
    sta PLAYER_HEAD_SPRITE_1
    lda #$20
    sta PLAYER_HEAD_SPRITE_1 + 3
    lda #$01
    sta PLAYER_HEAD_SPRITE_1 + 1

    ;; Player 2
    lda #$0D
    ldx #$20
    ldy #$3D
    jsr push_background_buffer

    lda #$06
    ldx #$20
    ldy #$5D
    jsr push_background_buffer

    lda #$08
    sta PLAYER_HEAD_SPRITE_2
    lda #$E8
    sta PLAYER_HEAD_SPRITE_2 + 3
    lda #$03
    sta PLAYER_HEAD_SPRITE_2 + 1

    ;; Player 3
    lda #$0C
    ldx #$23
    ldy #$9D
    jsr push_background_buffer

    lda #$05
    ldx #$23
    ldy #$9C
    jsr push_background_buffer

    lda #$E0
    sta PLAYER_HEAD_SPRITE_3
    lda #$E8
    sta PLAYER_HEAD_SPRITE_3 + 3
    lda #$02
    sta PLAYER_HEAD_SPRITE_3 + 1

    ;; Player 4
    lda #$0E
    ldx #$23
    ldy #$82
    jsr push_background_buffer

    lda #$06
    ldx #$23
    ldy #$62
    jsr push_background_buffer

    lda #$D0
    sta PLAYER_HEAD_SPRITE_4
    lda #$10
    sta PLAYER_HEAD_SPRITE_4 + 3
    lda #$04
    sta PLAYER_HEAD_SPRITE_4 + 1

    rts
.endproc

;; Moves player by 1 tile
.proc move_player
    ; These addresses may be overriden outside of this function
    LENGTH = $01
    BYTE_SHIFT_LENGTH = $02
    LENGTH_MOD = $03
    BYTE_LENGTH = $04
    SHIFT_RIGHT_COUNT = $05
    LAST_MOVE_DIR = $06
    NEW_MOVE_DIR = $07
    CONTROLLER_FAST = $08

    OFFSET = $09
    CONTROLLER_OFFSET = $0A
    SPRITE_OFFSET = $0B


    lda #$00
    sta OFFSET
    sta CONTROLLER_OFFSET
    sta SPRITE_OFFSET

    sta LENGTH
    sta BYTE_SHIFT_LENGTH
    sta LENGTH_MOD
    sta BYTE_LENGTH
    sta SHIFT_RIGHT_COUNT
    sta LAST_MOVE_DIR
    sta NEW_MOVE_DIR
    sta CONTROLLER_FAST

    player_loop:
        ldx OFFSET ; Loads the right offset into x for the right snake
        cpx #$38
        bmi :+
            jmp player_loop_end
        :

        ; Store player length in $01
        lda PLAYER_LENGTH,x
        lsr
        lsr
        sta LENGTH
        cmp #$02                    ; Check if the length of the snake is shorter then 2
        bpl :+
            jsr next_player
            jmp player_loop             ; Then skip this code and move to the next player
        :

        ; Store amount of bytes the body currently takes in $02 and $03
        sec 
        sbc #$01
        lsr
        lsr
        sta BYTE_SHIFT_LENGTH
        sta BYTE_LENGTH
        ldx OFFSET

        ; Calculate bit offset for next position and store in $02
        lda LENGTH
        and #$03
        cmp #$00
        bne :+
            lda #$04
        :
        sta LENGTH_MOD

        lda #$04    ; Calcuate amount of times to shift right (and store in $04)
        sec 
        sbc LENGTH_MOD
        sta SHIFT_RIGHT_COUNT
        cmp #$00

        ; Calculate last move dir
        lda BYTE_LENGTH
        clc 
        adc OFFSET
        tax 
        lda PLAYER_BODY,x ; Load last byte of body into A

        ldy SHIFT_RIGHT_COUNT
        cpy #$00
        beq :++
        :   ; Shift right untill the 2 lsb's are last direction
            lsr
            lsr
            dey
            bne :-
        :
        and #$03    ; Extract last 2 bits
        sta LAST_MOVE_DIR

        txa 

        ; Shifting player body
        ldx OFFSET
        asl PLAYER_BODY,x   ; Discard the first 2 bytes (last location)
        asl PLAYER_BODY,x
        inx 

        ; lda #$00    ; Skip loop if amount of bytes is 1 ($02 == 0)
        ; bit BYTE_SHIFT_LENGTH
        lda BYTE_SHIFT_LENGTH
        cmp #$00
        beq shift_loop_end

        shift_loop:
            ldy OFFSET
            lda PLAYER_BODY-1,x   ; Load previous byte into A

            asl PLAYER_BODY,x     ; Shift first bit out
            bcc :+                  ; If bit was one set it for last byte
                ora #$02
            :                       
            asl PLAYER_BODY,x     ; Shift out second bit and set for last byte 
            bcc :+
                ora #$01
            :

            sta PLAYER_BODY-1,x

            inx
            dec BYTE_SHIFT_LENGTH
            bne shift_loop
        shift_loop_end:

        ; Moving the head
        ldx CONTROLLER_OFFSET
        lda CONTROLLER,x
        cmp #$00

        bne input        ; Button has been pressed, move to other direction
        jmp no_input     ; Inverted because beq could only jump 128 instructions

        input:
            sta CONTROLLER_FAST ; Store in 0 page for fast access (2 cycles saved per bit operation)
            
            lda #$ff        ; Default out of range value (in case of no valid input)
            sta NEW_MOVE_DIR

            ; Calculate new movement direction
            lda #$01    ; Right
            bit CONTROLLER_FAST
            beq :+
                lda LAST_MOVE_DIR   ; If last move dir was left, skip this input
                cmp #$01
                beq :+

                lda #$00
                cmp LAST_MOVE_DIR   ; If new dir == last dir, skip (let other inputs take priority)
                beq :+

                sta NEW_MOVE_DIR
                jmp end_input_switch
            :
            lda #$02    ; Left
            bit CONTROLLER_FAST
            beq :+
                lda LAST_MOVE_DIR   ; If last move dir was right, skip this input
                cmp #$00
                beq :+

                lda #$01
                cmp LAST_MOVE_DIR   ; If new dir == last dir, skip (let other inputs take priority)
                beq :+

                sta NEW_MOVE_DIR
                jmp end_input_switch
            :
            lda #$04    ; Down
            bit CONTROLLER_FAST
            beq :+
                lda LAST_MOVE_DIR   ; If last move dir was up, skip this input
                cmp #$03
                beq :+

                lda #$02
                cmp LAST_MOVE_DIR   ; If new dir == last dir, skip (let other inputs take priority)
                beq :+

                sta NEW_MOVE_DIR
                jmp end_input_switch
            :
            lda #$08    ; Up
            bit CONTROLLER_FAST

            beq :+
                lda LAST_MOVE_DIR   ; If last move dir was down, skip this input
                cmp #$02
                beq :+

                lda #$03
                cmp LAST_MOVE_DIR   ; If new dir == last dir, skip (let other inputs take priority)
                beq :+

                sta NEW_MOVE_DIR
                jmp end_input_switch
            :
            end_input_switch:

            lda NEW_MOVE_DIR
            cmp #$FF                ; Test if input was valid
            beq no_input

            lda BYTE_LENGTH
            clc
            adc OFFSET
            tax

            lda NEW_MOVE_DIR
            ldy SHIFT_RIGHT_COUNT    ; Shift back n-1 times
            cpy #$00
            beq :++
            :
                asl
                asl
                dey
                bne :-
            :
            ora PLAYER_BODY,x
            sta PLAYER_BODY,x

            jmp input_end
        no_input:           ; No Button was pressed, continue in same direction
            lda BYTE_LENGTH
            clc
            adc OFFSET
            tax

            lda LAST_MOVE_DIR
            sta NEW_MOVE_DIR
            ldy SHIFT_RIGHT_COUNT     ; Shift back n-1 times
            cpy #$00
            beq :++
            :
                asl
                asl
                dey
                bne :-
            :
            ora PLAYER_BODY,x
            sta PLAYER_BODY,x
        input_end:
        
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

        .include "draw_tail.s"

    jmp next_player_skip
    .proc next_player
        lda OFFSET
        clc
        adc #$12
        sta OFFSET

        inc CONTROLLER_OFFSET
    
        lda SPRITE_OFFSET
        clc
        adc #$04
        sta SPRITE_OFFSET

        rts
    .endproc

    next_player_skip:
    jsr next_player
    jmp player_loop
    player_loop_end:
    rts
.endproc

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