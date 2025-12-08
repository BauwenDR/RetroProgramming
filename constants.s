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

CONTROLLER = $0400

CONTROLLER1 = $0400
CONTROLLER2 = $0401
CONTROLLER3 = $0402
CONTROLLER4 = $0403


;; Players
PLAYER_HEAD = $0200
PLAYER_LENGTH = $0201 ; Split 6 msb lengh, 2 lsb part of head
PLAYER_BODY = $0202   ; Length of body max 16 bytes

PLAYER_HEAD_2 = $0212
PLAYER_LENGTH_2 = $0213 ; Split 6 msb lengh, 2 lsb part of head
PLAYER_BODY_2 = $0214   ; Length of body max 16 bytes

PLAYER_HEAD_3 = $0224
PLAYER_LENGTH_3 = $0225 ; Split 6 msb lengh, 2 lsb part of head
PLAYER_BODY_3 = $0226   ; Length of body max 16 bytes

PLAYER_HEAD_4 = $0236
PLAYER_LENGTH_4 = $0237 ; Split 6 msb lengh, 2 lsb part of head
PLAYER_BODY_4 = $0238   ; Length of body max 16 bytes

PICKUP_1_X = $0680      ;msb byte oif the x says if it is alive 
PICKUP_1_Y = $0681
PICKUP_2_X = $0682
PICKUP_2_Y = $0683
PICKUP_3_X = $0684
PICKUP_3_Y = $0685


;; Random Numbers
RANDOM_SEED = $BE  ; Set memory address for rng to $2 and #3 (as it used 16 bits)

;; Sprites
PLAYER_HEAD_SPRITE = $0500

PLAYER_HEAD_SPRITE_1 = $0500
PLAYER_HEAD_SPRITE_2 = $0500 + 4
PLAYER_HEAD_SPRITE_3 = $0500 + 8
PLAYER_HEAD_SPRITE_4 = $0500 + 12

PLAYER_TAIL_SPRITE_1 = $0500 + 16
PLAYER_TAIL_SPRITE_2 = $0500 + 20
PLAYER_TAIL_SPRITE_3 = $0500 + 24
PLAYER_TAIL_SPRITE_4 = $0500 + 28

PICKUPS_SPRITE_1     = $0510
PICKUPS_SPRITE_2     = $0514
PICKUPS_SPRITE_3     = $0518
