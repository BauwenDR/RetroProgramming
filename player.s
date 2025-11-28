;; Initialises player memory (hardcoded values)
.proc init_player
    lda #$02            ; (2, 0)
    sta PLAYER_HEAD_1   
    lda #$0C            ; Length of 3, plus 2 0 bits for player head location
    sta PLAYER_LENGTH_1

    ; Load in body
    lda #$00           ; All 3 facing richt
    sta PLAYER_BODY_1

    rts
.endproc


;; Draws initial location of player (hardcoded values)
.proc init_draw_player
    lda #$00
    ldx #$20
    ldy #$02
    jsr push_background_buffer

    lda #$06
    ldx #$20
    ldy #$01
    jsr push_background_buffer

    lda #$0A
    ldx #$20
    ldy #$00
    jsr push_background_buffer

    rts
.endproc


;; Moves player by 1 tile
.proc move_player
    ; These addresses may be overriden outside of this function
    LENGH = $01
    BYTE_SHIFT_LENGTH = $02
    LENGTH_MOD = $03
    BYTE_LENGTH = $04
    SHIFT_RIGHT_COUNT = $05
    LAST_MOVE_DIR = $06
    NEW_MOVE_DIR = $07
    CONTROLLER_FAST = $08


    ; Store player length in $01
    lda PLAYER_LENGTH_1
    lsr
    lsr
    sta LENGH

    ; Store amount of bytes the body currently takes in $02 and $03
    lsr
    lsr
    sta BYTE_SHIFT_LENGTH
    sta BYTE_LENGTH
    ldx #$00

    ; Shifting player body
    asl PLAYER_BODY_1   ; Discard the first 2 bytes (last location)
    asl PLAYER_BODY_1

    lda #$00    ; Skip loop if amount of bytes is 1 ($02 == 0)
    bit BYTE_SHIFT_LENGTH
    beq shirt_loop_end

    shift_loop:
       lda PLAYER_BODY_1-1,X    ; Load previous byte into A

        asl PLAYER_BODY_1,X     ; Shift first bit out
        bcc :+                  ; If bit was one set it for last byte
            ora #$02
        :                       
        asl PLAYER_BODY_1,X     ; Shift out second bit and set for last byte 
        bcc :+
            ora #$01
        :

        sta PLAYER_BODY_1-1,X

        inx
        dec BYTE_SHIFT_LENGTH
        bne shift_loop
    shirt_loop_end:

    ; Calculate bit offset for next position and store in $02
	lda LENGH
	sec
    bit_offset_modulus: ; Player length % 4
        sbc #$04
		bcs bit_offset_modulus
		adc #$04
    sta LENGTH_MOD

    lda #$04    ; Calcuate amount of times to shift right (and store in $04)
    sbc LENGTH_MOD
    sta SHIFT_RIGHT_COUNT

    ; Calculate last move dir
    ldx BYTE_LENGTH
    lda PLAYER_BODY_1,X ; Load last byte of body into A

    ldy SHIFT_RIGHT_COUNT
    :   ; Shift right untill the 2 lsb's are last direction
        lsr
        lsr
        dey
        beq :-

    and #$03    ; Extract last 2 bits
    sta LAST_MOVE_DIR

    ; Moving the head
    lda CONTROLLER1
    cmp #$00
    beq no_input        ; Button has been pressed, move to other direction
        sta CONTROLLER_FAST ; Store in 0 page for fast access (2 cycles saved per bit operation)

        ; Calculate new movement direction
        lda #$01    ; Right
        bit CONTROLLER_FAST
        beq :+
            lda #$00
            sta NEW_MOVE_DIR
            jmp end_input_switch
        :
        lda #$02    ; Left
        bit CONTROLLER_FAST
        beq :+
            lda #$01
            sta NEW_MOVE_DIR
            jmp end_input_switch
        :
        lda #$04    ; Down
        bit CONTROLLER_FAST
        beq :+
            lda #$02
            sta NEW_MOVE_DIR
            jmp end_input_switch
        :
        lda #$08    ; Up
        bit CONTROLLER_FAST

        beq :+
            lda #$03
            sta NEW_MOVE_DIR
            jmp end_input_switch
        :
        end_input_switch:

        ; When new input is opposide of old input go to_input
        ; TODO

        lda NEW_MOVE_DIR
        ldy SHIFT_RIGHT_COUNT     ; Shift back n-1 times
        dey
        :
            asl
            asl
            dey
            beq :-
        dey

        ora PLAYER_BODY_1,X
        sta PLAYER_BODY_1,X

        jmp input_end
    no_input:           ; No Button was pressed, continue in same direction
        ; If modulo was 0
        ; TODO

        ; else
        lda LAST_MOVE_DIR
        sta NEW_MOVE_DIR
        ldy SHIFT_RIGHT_COUNT     ; Shift back n-1 times
        dey
        :
            asl
            asl
            dey
            beq :-
        dey

        ora PLAYER_BODY_1,X
        sta PLAYER_BODY_1,X
    input_end:

    ; ; Clear last head position
    ; ldy PLAYER_HEAD_1
    ; lda PLAYER_LENGTH_1
    ; and #03
    ; clc
    ; adc #$20
    ; tax
    ; lda #$00; Draw tile for head
    ; jsr push_background_buffer

    ; Move player head
    lda NEW_MOVE_DIR
    cmp #$00    ; Right
    bne :++
        inc PLAYER_HEAD_1
        bne :+
            lda PLAYER_LENGTH_1
            and #$03
            clc
            adc #$01
            and #$03
            tax
            lda #$FC
            and PLAYER_LENGTH_1
            sta PLAYER_LENGTH_1
            txa
            ora PLAYER_LENGTH_1
            sta PLAYER_LENGTH_1
        :
        jmp end_move_switch
    :

    cmp #$01    ; Left
    bne :++
        lda PLAYER_HEAD_1
        sec
        sbc #$01
        sta PLAYER_HEAD_1
        bcs :+
            lda PLAYER_LENGTH_1
            and #$03
            sec
            sbc #$01
            and #$03
            tax
            lda #$FC
            and PLAYER_LENGTH_1
            sta PLAYER_LENGTH_1
            txa
            ora PLAYER_LENGTH_1
            sta PLAYER_LENGTH_1
        :
        jmp end_move_switch
    :

    cmp #$02    ; Down
    bne :++
        lda PLAYER_HEAD_1
        clc
        adc #$20
        sta PLAYER_HEAD_1
        bcc :+
            lda PLAYER_LENGTH_1
            and #$03
            clc
            adc #$01
            and #$03
            tax
            lda #$FC
            and PLAYER_LENGTH_1
            sta PLAYER_LENGTH_1
            txa
            ora PLAYER_LENGTH_1
            sta PLAYER_LENGTH_1
        :
        jmp end_move_switch
    :

    cmp #$03    ; Up
    bne :++
        lda PLAYER_HEAD_1
        sec
        sbc #$20
        sta PLAYER_HEAD_1
        bcs :+
            lda PLAYER_LENGTH_1
            and #$03
            sec
            sbc #$01
            and #$03
            tax
            lda #$FC
            and PLAYER_LENGTH_1
            sta PLAYER_LENGTH_1
            txa
            ora PLAYER_LENGTH_1
            sta PLAYER_LENGTH_1
        :
        jmp end_move_switch
    :
    end_move_switch:

    ; ; Draw head in new position
    ; ldy PLAYER_HEAD_1
    ; lda PLAYER_LENGTH_1
    ; and #03
    ; clc
    ; adc #$20
    ; tax
    ; lda #$04; Draw tile for head
    ; jsr push_background_buffer

    clc 

    ; calculate y position
    lda PLAYER_LENGTH_1 ; get first 2 bits
    and #%00000011
    ror 
    sta $01

    lda PLAYER_HEAD_1 ; get last 3 bits
    and #%11100000
    
    ora $01 ; merge them
    ror 
    ror 

    sta PLAYER_HEAD_SPRITE_1 ; store y position

    clc 

    ; calculate x position
    lda PLAYER_HEAD_1
    and #%00011111

    sta $0A ; debug store

    rol ; multiply by 8
    rol 
    rol 

    sta PLAYER_HEAD_SPRITE_1 + 3 ; store x position

    ; set tile index
    lda #$04 ; default for now
    sta PLAYER_HEAD_SPRITE_1 + 1 ; store tile index

    ; set attributes (no flipping x 2, in front of background, unimplemented x 3, palette x 2)
    lda #%00000000
    sta PLAYER_HEAD_SPRITE_1 + 2 ; store attributes


    ; Draw tale (it's "tail" btw)

    ; Remove after tale


    ; Move player head

    ; ; Remove last tile
    ; lda #$00
    ; ldx #$23
    ; ldy PLAYER_HEAD_1
    ; jsr push_background_buffer

    ; inc PLAYER_HEAD_1

    ; ; Increase high byte on overflow
    ; ; beq :+ 
    ; ;     inc PLAYER_LOC+1
    ; ; :

    ; ; Render new tiles
    ; lda #$0A
    ; ldx #$23
    ; ldy PLAYER_HEAD_1
    ; jsr push_background_buffer

    ; lda #$06
    ; ldx #$23
    ; ldy PLAYER_HEAD_1
    ; iny
    ; iny
    ; jsr push_background_buffer

    ; lda #$04
    ; ldx #$23
    ; ldy PLAYER_HEAD_1
    ; iny
    ; iny
    ; iny
    ; jsr push_background_buffer

    rts
.endproc
