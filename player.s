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

        .include "playerMovement.s"
        .include "playerDrawHead.s"
        .include "playerDrawTail.s"

    jsr next_player
    jmp player_loop

    player_loop_end:
    rts

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