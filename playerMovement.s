; Modify value of X register to OFFSET + BYTE_LENGTH and then load last the last byte of the players body into register A
lda BYTE_LENGTH
clc 
adc OFFSET
tax 
lda PLAYER_BODY,x ; Load last byte of body into A

; Calculate amount of times to shift right for last player location and extract LAST_MOVE_DIR
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

; Shifting player body (move all movement directions by two bits)
ldx OFFSET
asl PLAYER_BODY,x   ; Discard the first 2 bytes (last location)
asl PLAYER_BODY,x
inx 

lda BYTE_SHIFT_LENGTH     ; Skip loop if amount of bytes is 1 ($02 == 0)
cmp #$00
beq shift_loop_end

shift_loop:
    ldy OFFSET
    lda PLAYER_BODY-1,x   ; Load previous byte into A

    asl PLAYER_BODY,x     ; Shift first bit out
    bcc :+                ; If bit was one set it for last byte
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

    jmp input_end
no_input:           ; No Button was pressed, continue in same direction
    lda BYTE_LENGTH
    clc
    adc OFFSET
    tax

    lda LAST_MOVE_DIR
    sta NEW_MOVE_DIR
input_end:

; Once again we set X register equal to the last byte in the player body
lda BYTE_LENGTH
clc
adc OFFSET
tax

; Put the value of NEW_MOVE_DIR in the corrent location
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
