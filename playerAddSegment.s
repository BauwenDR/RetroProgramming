.proc add_segment
    LENGTH = $01                    ; Temporary storage for calculated length
    OFFSET = $02                    ; Storage for player offset (0 for P1, 16 for P2, etc.)
    
    ; The Y register must contain the player offset when calling this
    sty OFFSET

    ; --- LENGTH CHECK ---
    lda PLAYER_LENGTH,y             ; Load current player length (bit-packed value)
    lsr                             ; Shift right twice to isolate length bits 
    lsr                             
    cmp #$3e                        ; Check if length is at the maximum (62 segments)
    bne :+
        rts                         ; If snake is max length, exit without growing
    :                        

    ; --- PREPARE FOR SHIFT ---
    lsr                             ; Continue shifting to prepare the value
    lsr                             
    sta LENGTH                      ; Store current base length
   
    ldx OFFSET                      ; Load player offset into X for indexed addressing
    clc 
    adc OFFSET                      ; Calculate actual memory index
    sta LENGTH
    clc 

    ; --- SHIFTING THE BODY DATA ---
    ; This block uses ROR (Rotate Right) to shift the direction data of the 
    ; entire snake body. This effectively "moves" every segment back one slot.
    ; It does this twice to move 2-bit direction data through the 16-byte buffer.
    
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
    
    clc                             ; Clear carry before second shift pass
    
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

    ; --- INITIALIZE NEW SEGMENT ---
    ldy OFFSET
    lda PLAYER_BODY, y              ; Get the head's current data
    and #%00110000                  ; Mask to get the direction bits
    asl                             ; Shift bits to align with the new segment slot
    asl 
    ora PLAYER_BODY, y              ; Combine back with existing body data
    sta PLAYER_BODY, y              ; Store the updated first byte

    ; --- UPDATE LENGTH VARIABLE ---
    ldy OFFSET        
    lda PLAYER_LENGTH,y             ; Load packed length variable
    clc 
    adc #$04                        ; Increase length by 1 (represented as 4 due to bit packing)
    sta PLAYER_LENGTH,y             ; Save the new length
    rts 
.endproc