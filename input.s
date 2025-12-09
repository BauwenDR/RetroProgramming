INPUT_RAM = $01

.proc read_input
    lda #$01    ; Strobe the controllers, so we have the most recent input values
    sta JOYPAD1 ; We only need to strobe the input once, as enabling the stobe bit strobes all controllers
    lsr a       ; https://www.nesdev.org/wiki/Four_player_adapters#Four_Score
    sta JOYPAD1

    ldx 0
    jsr read_controller_one ; First read controllers 1 and 3
    jsr read_controller_two
    inx
    jsr read_controller_one ; Then read controllers 2 and 4
    jsr read_controller_two
    rts
.endproc

.proc read_controller_one
    lda #$01
    sta INPUT_RAM
    lsr

    :
        lda JOYPAD1,X
        lsr a          ; bit 0 -> Carry
        rol INPUT_RAM  ; Carry -> bit 0; bit 7 -> Carry
        bcc :-

    lda INPUT_RAM
    ora CONTROLLER1,X
    sta CONTROLLER1,X
    rts
.endproc

.proc read_controller_two
    lda #$01
    sta INPUT_RAM
    lsr

    :
        lda JOYPAD1,X
        lsr a          ; bit 0 -> Carry
        rol INPUT_RAM  ; Carry -> bit 0; bit 7 -> Carry
        bcc :-

    lda INPUT_RAM
    ora CONTROLLER3,X
    sta CONTROLLER3,X
    rts
.endproc

.proc reset_input
    lda #$00
    sta CONTROLLER1
    STA CONTROLLER2
    STA CONTROLLER3
    STA CONTROLLER4
    rts
.endproc