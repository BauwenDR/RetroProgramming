; Initialise rng
ldx #$14
lda #$15 
sta RANDOM_SEED
jsr galois16

jmp skip_random	; We de no want to run this code twice on init

galois16:
	ldy #8
	lda RANDOM_SEED+0
:
	asl        ; shift the register
	rol RANDOM_SEED+1
	bcc :+
	eor #$39   ; apply XOR feedback whenever a 1 bit is shifted out
:
	dey
	bne :--
	sta RANDOM_SEED+0
	cmp #0     ; reload flags
	rts

skip_random: