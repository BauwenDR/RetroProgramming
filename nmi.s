loop_counter = $c1

nmi:
    ; save registers
    php ; SR
    pha ; A
    txa ; X
    pha 
    tya ; Y
    pha 

    ; set vBlank? to 1 (to say a vBlank happened)
    lda #$01 
    sta VBLANK_OCCURED
    inc VBLANK_TICK_COUNT

    ; enable background + sprites, color emphasis normal
    lda #%00011110
    sta $2001

    lda #$00
    sta loop_counter

    draw_tile:
    ; get buffer size
    lda VBLANK_BUFFER_SIZE
    and #$0F ; get last 4 bits

    ; if 0: skip
    cmp #$00
    beq skip_drawing

    sbc #$01 ; decrement A by 1

    ; multiply A by 3
    sta $C0
    clc 
    adc $C0
    adc $C0
    tay 

    ; set ppu address
    lda VBLANK_BACK_BUFFER, y ; address byte 1
    and #$3F
    sta $2006
    lda VBLANK_BACK_BUFFER+1, y ; address byte 2 (made the address one higher to not have to increment Y)
    sta $2006

    ; set tile
    lda VBLANK_BACK_BUFFER+2, y
    sta $2007

    ; something something colors???

    ; decrement buffer size
    dec VBLANK_BUFFER_SIZE

    inc loop_counter
    lda loop_counter
    clc
    cmp #$0F
    bne draw_tile

    skip_drawing:

    ; Set background scroll to (0, 0)
    lda #$00
    sta $2005
    sta $2005

    ; restore registers
    pla ; Y
    tay 
    pla ; X
    tax 
    pla ; A
    plp ; SR
    rti