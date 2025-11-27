reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  .
  inx		; now X = 0
  stx $2000	; disable NMI
  stx $2001 	; disable rendering
  stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
vblankwait1:
  bit $2002
  bpl vblankwait1

clear_memory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne clear_memory

;; second wait for vblank, PPU is ready after this
vblankwait2:
  bit $2002
  bpl vblankwait2

clear_ppu_memory:
  ldx #$20
  ldy #$00
  sty $2001 ; disable rendering
  stx $2006 ; set address to $2000
  sty $2006

  lda #$00 ; A is counter 2
  ldx #$00 ; X is counter 1
  ldy #$00 ; Y is 0
  :
  sty $2007
  inx 
  bne :+
    adc #$01 ; if X == 256 increment A
  :
  cmp #$09
  bne :-- ; if (A != 9) do it again

main:
load_palettes:
  lda $2002
  lda #$3f
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
:
  lda palettes, x
  sta $2007
  inx
  cpx #$20
  bne :-

enable_rendering:
  lda #%10000000	; Enable NMI
  sta $2000
  lda #%00010000	; Enable Sprites
  sta $2001

; something to do with the drawing
  ldy #$20
  sty $0011
  ldy #$00
