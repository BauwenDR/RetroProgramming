loop_counter = $c1

.proc nmi
    ; save registers
    php ; SR
    pha ; A
    txa ; X
    pha 
    tya ; Y
    pha 

    ; enable background + sprites, color emphasis normal
    lda #%00011110
    sta $2001

    ; update sprites
    lda #$05 ; first byte of sprite location
    sta $4014 ; OAMDMA location, read: https://www.nesdev.org/wiki/PPU_registers#OAMDMA

    lda #$00
    sta loop_counter

   

    draw_tile:
        ; get buffer size
        lda $0600

        ; if 0: skip
        cmp #$00
        beq skip_tile_drawing

        sbc #$01 ; decrement A by 1

        ; multiply A by 3
        sta $C0
        clc 
        adc $C0
        adc $C0
        tay 

        ; set ppu address
        lda $0601, y ; address byte 1
        and #$3F
        sta $2006
        lda $0602, y ; address byte 2 (made the address one higher to not have to increment Y)
        sta $2006

        ; set tile
        lda $0603, y
        sta $2007

        ; decrement buffer size
        dec $0600

        ; check if we have reached the limit of background tile updates
        inc loop_counter
        lda loop_counter
        cmp #25 ; (this is in decimal) max amount of of tiles updated per frame is 19 due to limited clock cycles
        bne draw_tile

    skip_tile_drawing:

    ; Set background scroll to (0, 0)
    lda $2002 ; reset toggle
    lda #$00 
    sta $2006
    sta $2006

    lda RIGHT_SCREEN
    cmp #$01
    bne:+
        lda #%10010001   ; enable NMI, select $2400 as base nametable
        sta $2000
        jmp:++
    :
        lda #%10000000  ; enable NMI, select $2400 as base nametable
        sta $2000
    :
    lda #$00
    sta $2005
    sta $2005

    ; set vBlank? to 1 (to say a vBlank happened)
    lda #$01 
    sta VBLANK_OCCURED
    inc VBLANK_TICK_COUNT

    jsr famistudio_update

    ; restore registers
    pla ; Y
    tay 
    pla ; X
    tax 
    pla ; A
    plp ; SR
    rti
.endproc

.proc wait_for_nmi
    lda #$00
    sta VBLANK_OCCURED
    vblank_wait:
    lda VBLANK_OCCURED
    cmp #$01
    bne vblank_wait
    lda #$00
    sta VBLANK_OCCURED
    rts 
.endproc