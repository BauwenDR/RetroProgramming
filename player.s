;; Moves all players by 1 tile
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

    ; Reset all "ram" address values to 0
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
        ldx OFFSET ; Loads the right offset into x for the right snake (snakes are stores sequentually, x will be the offset to the first byte of the current snake)
        cpx #$37   ; When the offset is bigger than the total snake lengths, break out of the loop ($3 * $12 + 1)
        bmi :+
            jmp player_loop_end
        :

        ; Store player length (total amount of segments in its body)
        ; Since we store this together with the 2 msb's of the position we need to filter out the position bits
        lda PLAYER_LENGTH,x
        lsr
        lsr
        sta LENGTH
        cmp #$02                    ; Check if the length of the snake is shorter then 2 (snakes start at 2, so if they are shorter that means they have died)
        bpl :+
            jsr next_player
            jmp player_loop             ; Then skip this code and move to the next player
        :

        ; Store amount of bytes the body currently takes in both SHIFT_LENGTH AND BYTE_LENGTH
        ; We store these twice and SHIFT_LENGTH will have its value modified later
        sec 
        sbc #$01
        lsr
        lsr
        sta BYTE_SHIFT_LENGTH
        sta BYTE_LENGTH
        ldx OFFSET

        ; Calculate bit offset in for next position (amount of bits modulo 4)
        ; This will give us the offset of the next movement bits.
        lda LENGTH
        and #$03
        cmp #$00
        bne :+
            lda #$04
        :
        sta LENGTH_MOD

        lda #$04    ; Calcuate amount of times to shift right (to get last movement direction out of the body)
        sec 
        sbc LENGTH_MOD
        sta SHIFT_RIGHT_COUNT
        cmp #$00

        ; After initialising RAM variables, execute the code in the sub player files
        ; We use include here to split up the files for better readability and to avoid merge conflicts.
        .include "playerMovement.s"
        .include "playerDrawHead.s"
        .include "playerDrawTail.s"

    jsr next_player
    jmp player_loop

    player_loop_end:
    rts

    ; Increased OFFSET, SPRITE_OFFSET by #12 and CONTROLLER_OFFSET be one
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
.endproc