.proc start_screen_main
	jsr famistudio_music_stop
	ldx #<music_data_swimming
	ldy #>music_data_swimming
	lda #0 ; PAL
	jsr famistudio_init

	ldx #<music_data_swimming
	ldy #>music_data_swimming
	lda #0
	jsr famistudio_music_play

    lda #$01
    sta RIGHT_SCREEN

    jsr draw_names
    jsr draw_4_player_snake
    jsr draw_press_to_start

    forever:
        jsr galois16
        jsr read_input
        ldx #$00
        :
            lda CONTROLLER1,x
            and #%10000000
            cmp #%10000000
            bne:+
                rts 
            :
            inx
            cpx #$04
        bne:-- 
        jsr reset_input
    jmp forever
    rts 
.endproc



.proc end_screen_main
	jsr famistudio_music_stop
	ldx #<music_data_swimming
	ldy #>music_data_swimming
	lda #0 ; PAL
	jsr famistudio_init

	ldx #<music_data_swimming
	ldy #>music_data_swimming
	lda #0
	jsr famistudio_music_play

    lda #$01
    sta RIGHT_SCREEN
    jsr clean_sprites

    jsr draw_names
    jsr draw_4_player_snake
    jsr draw_play_again

    jsr draw_is_the_winner
    jsr wait_for_nmi
    lda PLAYERS_DEAD
    and #%11110000
    cmp #%11100000              ;player 4
    bne:+
        ldx #$25
        ldy #$CC
        lda #$B4
        jsr push_background_buffer

        jmp end_choise_winner
    :
    cmp #%11010000              ;player 3
    bne:+
        ldx #$25
        ldy #$CC
        lda #$B3
        jsr push_background_buffer

        jmp end_choise_winner
    :
    cmp #%10110000              ;player 2
    bne:+
        ldx #$25
        ldy #$CC
        lda #$B2
        jsr push_background_buffer

        jmp end_choise_winner
    :
    cmp #%01110000              ;player 1
    bne:+
        ldx #$25
        ldy #$CC
        lda #$B1
        jsr push_background_buffer

        jmp end_choise_winner
    :

    jsr draw_no_winner

    end_choise_winner:

    jsr clean_upcrew
    forever:
        jsr read_input
        ldx #$00
        :
            lda CONTROLLER1,x
            and #%10000000
            cmp #%10000000
            bne:+
                rts 
            :
            inx
            cpx #$04
        bne:-- 
        jsr reset_input
    jmp forever

    rts 
.endproc


.proc clean_sprites
    lda #$00
    ldx #$00

    :
    sta PLAYER_HEAD_SPRITE + 1 ,x
    inx 
    inx 
    inx 
    inx 
    cpx #$20
    bne :-


    rts 
.endproc

.proc draw_is_the_winner
    jsr wait_for_nmi
	; 
	ldx #$25
	ldy #$C0
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C1
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C2
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C3
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C4
	lda #$A0
	jsr push_background_buffer

	;P
	ldx #$25
	ldy #$C5
	lda #$D0
	jsr push_background_buffer

	;L
	ldx #$25
	ldy #$C6
	lda #$CC
	jsr push_background_buffer

	;A
	ldx #$25
	ldy #$C7
	lda #$C1
	jsr push_background_buffer

	;Y
	ldx #$25
	ldy #$C8
	lda #$D9
	jsr push_background_buffer

	;E
	ldx #$25
	ldy #$C9
	lda #$C5
	jsr push_background_buffer

	;R
	ldx #$25
	ldy #$CA
	lda #$D2
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$CB
	lda #$A0
	jsr push_background_buffer

	;X
	ldx #$25
	ldy #$CC
	lda #$D8
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$CD
	lda #$A0
	jsr push_background_buffer

	;I
	ldx #$25
	ldy #$CE
	lda #$C9
	jsr push_background_buffer

	;S
	ldx #$25
	ldy #$CF
	lda #$D3
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$D0
	lda #$A0
	jsr push_background_buffer

	;T
	ldx #$25
	ldy #$D1
	lda #$D4
	jsr push_background_buffer

	;H
	ldx #$25
	ldy #$D2
	lda #$C8
	jsr push_background_buffer

	;E
	ldx #$25
	ldy #$D3
	lda #$C5
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$D4
	lda #$A0
	jsr push_background_buffer

	;W
	ldx #$25
	ldy #$D5
	lda #$D7
	jsr push_background_buffer

	;I
	ldx #$25
	ldy #$D6
	lda #$C9
	jsr push_background_buffer

	;N
	ldx #$25
	ldy #$D7
	lda #$CE
	jsr push_background_buffer

	;N
	ldx #$25
	ldy #$D8
	lda #$CE
	jsr push_background_buffer

	;E
	ldx #$25
	ldy #$D9
	lda #$C5
	jsr push_background_buffer

	;R
	ldx #$25
	ldy #$DA
	lda #$D2
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$DB
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$DC
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$DD
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$DE
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$DF
	lda #$A0
	jsr push_background_buffer



    rts 
.endproc

.proc draw_no_winner
    jsr wait_for_nmi
		; 
	ldx #$25
	ldy #$C0
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C1
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C2
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C3
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C4
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C5
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C6
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C7
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C8
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$C9
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$CA
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$CB
	lda #$A0
	jsr push_background_buffer

	;N
	ldx #$25
	ldy #$CC
	lda #$CE
	jsr push_background_buffer

	;O
	ldx #$25
	ldy #$CD
	lda #$CF
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$CE
	lda #$A0
	jsr push_background_buffer

	;W
	ldx #$25
	ldy #$CF
	lda #$D7
	jsr push_background_buffer

	;I
	ldx #$25
	ldy #$D0
	lda #$C9
	jsr push_background_buffer

	;N
	ldx #$25
	ldy #$D1
	lda #$CE
	jsr push_background_buffer

	;N
	ldx #$25
	ldy #$D2
	lda #$CE
	jsr push_background_buffer

	;E
	ldx #$25
	ldy #$D3
	lda #$C5
	jsr push_background_buffer

	;R
	ldx #$25
	ldy #$D4
	lda #$D2
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$D5
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$D6
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$D7
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$D8
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$D9
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$DA
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$DB
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$DC
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$DD
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$DE
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$25
	ldy #$DF
	lda #$A0
	jsr push_background_buffer

    rts 
.endproc

.proc draw_press_to_start
    jsr wait_for_nmi
	;P
	ldx #$26
	ldy #$C8
	lda #$D0
	jsr push_background_buffer

	;R
	ldx #$26
	ldy #$C9
	lda #$D2
	jsr push_background_buffer

	;E
	ldx #$26
	ldy #$CA
	lda #$C5
	jsr push_background_buffer

	;S
	ldx #$26
	ldy #$CB
	lda #$D3
	jsr push_background_buffer

	;S
	ldx #$26
	ldy #$CC
	lda #$D3
	jsr push_background_buffer

	;A
	ldx #$26
	ldy #$CE
	lda #$C1
	jsr push_background_buffer

	;T
	ldx #$26
	ldy #$D0
	lda #$D4
	jsr push_background_buffer

	;O
	ldx #$26
	ldy #$D1
	lda #$CF
	jsr push_background_buffer

	;S
	ldx #$26
	ldy #$D3
	lda #$D3
	jsr push_background_buffer

	;T
	ldx #$26
	ldy #$D4
	lda #$D4
	jsr push_background_buffer

	;A
	ldx #$26
	ldy #$D5
	lda #$C1
	jsr push_background_buffer

	;R
	ldx #$26
	ldy #$D6
	lda #$D2
	jsr push_background_buffer

	;T
	ldx #$26
	ldy #$D7
	lda #$D4
	jsr push_background_buffer



    rts 
.endproc
    
.proc delete_press_to_start
    	; 
	ldx #$26
	ldy #$C8
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$C9
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$CA
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$CB
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$CC
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$CD
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$CE
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$CF
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$D0
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$D1
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$D2
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$D3
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$D4
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$D5
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$D6
	lda #$A0
	jsr push_background_buffer

	; 
	ldx #$26
	ldy #$D7
	lda #$A0
	jsr push_background_buffer
    rts 

.endproc

.proc draw_play_again
    jsr wait_for_nmi

	;P
	ldx #$26
	ldy #$C5
	lda #$D0
	jsr push_background_buffer

	;R
	ldx #$26
	ldy #$C6
	lda #$D2
	jsr push_background_buffer

	;E
	ldx #$26
	ldy #$C7
	lda #$C5
	jsr push_background_buffer

	;S
	ldx #$26
	ldy #$C8
	lda #$D3
	jsr push_background_buffer

	;S
	ldx #$26
	ldy #$C9
	lda #$D3
	jsr push_background_buffer

	;A
	ldx #$26
	ldy #$CB
	lda #$C1
	jsr push_background_buffer

	;T
	ldx #$26
	ldy #$CD
	lda #$D4
	jsr push_background_buffer

	;O
	ldx #$26
	ldy #$CE
	lda #$CF
	jsr push_background_buffer

	;P
	ldx #$26
	ldy #$D0
	lda #$D0
	jsr push_background_buffer

	;L
	ldx #$26
	ldy #$D1
	lda #$CC
	jsr push_background_buffer

	;A
	ldx #$26
	ldy #$D2
	lda #$C1
	jsr push_background_buffer

	;Y
	ldx #$26
	ldy #$D3
	lda #$D9
	jsr push_background_buffer

	;A
	ldx #$26
	ldy #$D5
	lda #$C1
	jsr push_background_buffer

	;G
	ldx #$26
	ldy #$D6
	lda #$C7
	jsr push_background_buffer

	;A
	ldx #$26
	ldy #$D7
	lda #$C1
	jsr push_background_buffer

	;I
	ldx #$26
	ldy #$D8
	lda #$C9
	jsr push_background_buffer

	;N
	ldx #$26
	ldy #$D9
	lda #$CE
	jsr push_background_buffer

    rts 
.endproc

.proc draw_4_player_snake

    jsr wait_for_nmi
	;4
	ldx #$24
	ldy #$C9
	lda #$60
	jsr push_background_buffer
    ;4
	ldx #$24
	ldy #$E9
	lda #$70
	jsr push_background_buffer

	;P
	ldx #$24
	ldy #$CB
	lda #$80
	jsr push_background_buffer
	;P
	ldx #$24
	ldy #$EB
	lda #$90
	jsr push_background_buffer


	;L
	ldx #$24
	ldy #$CC
	lda #$6C
	jsr push_background_buffer
    ;L
	ldx #$24
	ldy #$EC
	lda #$7C
	jsr push_background_buffer

	;A
	ldx #$24
	ldy #$CD
	lda #$61
	jsr push_background_buffer
    ;A
	ldx #$24
	ldy #$ED
	lda #$71
	jsr push_background_buffer

	;Y
	ldx #$24
	ldy #$CE
	lda #$89
	jsr push_background_buffer
	;Y
	ldx #$24
	ldy #$EE
	lda #$99
	jsr push_background_buffer

	;E
	ldx #$24
	ldy #$CF
	lda #$65
	jsr push_background_buffer
    ;E
	ldx #$24
	ldy #$EF
	lda #$75
	jsr push_background_buffer

	;R
	ldx #$24
	ldy #$D0
	lda #$82
	jsr push_background_buffer
	;R
	ldx #$24
	ldy #$F0
	lda #$92
	jsr push_background_buffer

	;S
	ldx #$24
	ldy #$D2
	lda #$83
	jsr push_background_buffer
	;S
	ldx #$24
	ldy #$F2
	lda #$93
	jsr push_background_buffer


	;N
	ldx #$24
	ldy #$D3
	lda #$6E
	jsr push_background_buffer
    ;N
	ldx #$24
	ldy #$F3
	lda #$7E
	jsr push_background_buffer

	;A
	ldx #$24
	ldy #$D4
	lda #$61
	jsr push_background_buffer
	;A
	ldx #$24
	ldy #$F4
	lda #$71
	jsr push_background_buffer

	;K
	ldx #$24
	ldy #$D5
	lda #$6B
	jsr push_background_buffer
	;K
	ldx #$24
	ldy #$F5
	lda #$7B
	jsr push_background_buffer

	;E
	ldx #$24
	ldy #$D6
	lda #$65
	jsr push_background_buffer
	;E
	ldx #$24
	ldy #$F6
	lda #$75
	jsr push_background_buffer
    





.endproc

.proc draw_names
    jsr wait_for_nmi
    ;M
	ldx #$27
	ldy #$8C
	lda #$CD
	jsr push_background_buffer

	;A
	ldx #$27
	ldy #$8D
	lda #$C1
	jsr push_background_buffer

	;D
	ldx #$27
	ldy #$8E
	lda #$C4
	jsr push_background_buffer

	;E
	ldx #$27
	ldy #$8F
	lda #$C5
	jsr push_background_buffer



	;B
	ldx #$27
	ldy #$91
	lda #$C2
	jsr push_background_buffer

	;Y
	ldx #$27
	ldy #$92
	lda #$D9
	jsr push_background_buffer

	
	;B
	ldx #$27
	ldy #$A6
	lda #$C2
	jsr push_background_buffer

	;A
	ldx #$27
	ldy #$A7
	lda #$C1
	jsr push_background_buffer

	;U
	ldx #$27
	ldy #$A8
	lda #$D5
	jsr push_background_buffer

	;W
	ldx #$27
	ldy #$A9
	lda #$D7
	jsr push_background_buffer

	;E
	ldx #$27
	ldy #$AA
	lda #$C5
	jsr push_background_buffer

	;N
	ldx #$27
	ldy #$AB
	lda #$CE
	jsr push_background_buffer

	;,
	ldx #$27
	ldy #$AC
	lda #$AC
	jsr push_background_buffer

	;T
	ldx #$27
	ldy #$AD
	lda #$D4
	jsr push_background_buffer

	;E
	ldx #$27
	ldy #$AE
	lda #$C5
	jsr push_background_buffer

	;U
	ldx #$27
	ldy #$AF
	lda #$D5
	jsr push_background_buffer

	;N
	ldx #$27
	ldy #$B0
	lda #$CE
	jsr push_background_buffer

	;,
	ldx #$27
	ldy #$B1
	lda #$AC
	jsr push_background_buffer

	;M
	ldx #$27
	ldy #$B2
	lda #$CD
	jsr push_background_buffer

	;A
	ldx #$27
	ldy #$B3
	lda #$C1
	jsr push_background_buffer

	;T
	ldx #$27
	ldy #$B4
	lda #$D4
	jsr push_background_buffer

	;T
	ldx #$27
	ldy #$B5
	lda #$D4
	jsr push_background_buffer

	;I
	ldx #$27
	ldy #$B6
	lda #$C9
	jsr push_background_buffer

	;A
	ldx #$27
	ldy #$B7
	lda #$C1
	jsr push_background_buffer

	;S
	ldx #$27
	ldy #$B8
	lda #$D3
	jsr push_background_buffer



    rts 
.endproc
