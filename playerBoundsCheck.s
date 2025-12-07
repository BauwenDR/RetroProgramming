;; Load player position into A and Y registers
ldx OFFSET
ldy PLAYER_LENGTH,x
tya         ; Only the 2 position bits are needed
and #$03
tay
lda PLAYER_HEAD,x


;; Do top/ bottom collision first as they are non-destructive to the A register
; Top wall
cpy #$00
bne :++
    cmp #$84
    bpl :+
        nop
    :
:

; Bottom wall
cpy #$03
bne :++
    cmp #$7C    ; Last possible position (plus 1 to avoid triggering when we hit that exact tile)
    bmi :+
        nop
    :
:

AND #$1F  ; Only last 5 bits of head are needed to check for left/ right collision (right wall will always be 1C and left wall 03)
        ; This is only true when we do only account for the 5 lsb's

; Left wall
cmp #$03
bne :+  ; Left wall hit
    nop
:

; Right wall
cmp #$1C
bne :+  ; Right wall hit
    nop
:
