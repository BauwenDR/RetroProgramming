;; PPU


;; VBlank
VBLANK_OCCURED = $0700
VBLANK_TICK_COUNT = $0701
VBLANK_BUFFER_SIZE = $0600
VBLANK_BACK_BUFFER = $0601
VBLANK_FRONT_BUFFER = $0680


;; Input
JOYPAD1 = $4016 ; Address for controller one, using x register to read controller 2
JOYPAD2 = $4017 ; Address for controller one, using x register to read controller 2

CONTROLLER1 = $0400
CONTROLLER2 = $0401
CONTROLLER3 = $0402
CONTROLLER4 = $0403


;; Players
PLAYER_HEAD_1 = $0200
PLAYER_LENGTH_1 = $0201 ; Split 6 msb lengh, 2 lsb part of head
PLAYER_BODY_1 = $0202   ; Length of body max 16 bytes

PLAYER_HEAD_2 = $0212
PLAYER_LENGTH_2 = $0213 ; Split 6 msb lengh, 2 lsb part of head
PLAYER_BODY_2 = $0214   ; Length of body max 16 bytes

PLAYER_HEAD_3 = $0224
PLAYER_LENGTH_3 = $0225 ; Split 6 msb lengh, 2 lsb part of head
PLAYER_BODY_3 = $0226   ; Length of body max 16 bytes

PLAYER_HEAD_4 = $0236
PLAYER_LENGTH_4 = $0237 ; Split 6 msb lengh, 2 lsb part of head
PLAYER_BODY_4 = $0238   ; Length of body max 16 bytes


;; Random Numbers
RANDOM_SEED = $BE  ; Set memory address for rng to $2 and #3 (as it used 16 bits)

;; Sprites
PLAYER_HEAD_SPRITE_1 = $0500
PLAYER_HEAD_SPRITE_2 = $0500 + 4
PLAYER_HEAD_SPRITE_3 = $0500 + 8
PLAYER_HEAD_SPRITE_4 = $0500 + 12
