; push a background tile to the buffer to move to VRAM the next vBlank
; X and Y registers are memory location, first 2 bits of X are color palette
; A is tile index
; destroys all register data

.proc push_background_buffer
    pha ; push a to stack (free a register)
    tya ; push y to stack
    pha  
    lda VBLANK_BUFFER_SIZE
    cmp #$2A ; check if full (42 tiles)
    beq :+

    ; multiply A by 3
    sta $C0
    asl 
    adc $C0

    tay 
    txa 
    sta VBLANK_BACK_BUFFER, y ; save x
    iny 
    pla 
    sta VBLANK_BACK_BUFFER, y ; save y
    iny 
    pla 
    sta VBLANK_BACK_BUFFER, y ; save A

    inc VBLANK_BUFFER_SIZE
    jmp :++

    :
    ; pop stack if we skip
    pla 
    pla 

    :
    rts
.endproc

;register layout for pushing

;x = CCNNNNYY
;y = YYYXXXXX
;a = TTTTTTTT

; C = color pallet
; N = nametable
; Y = y location (2msb are in the x register 3lsb are in y register)
; X = x location
; T = tile index