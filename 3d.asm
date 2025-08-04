; Copyright (c) 2025 Adrian Pilkington

; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:

; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

;; KNOWN BUGS
;; ==========
;;
;; TODO 
;; ====
;;

;;; 3d game renderer
;;;
;;; https://youtube.com/@byteforever7829

;;; Known bug(s)
;;; - randomness isn't too good
;;; - player only dies if lined up exactly with asteroid

;;  TODO
;;  - put in power-up bonus like "deflector" sheilds
;;  - add levels and bigger score if hit UFO
;;  - add multiple missiles

CLS EQU $0A2A


TOTAL_NUMBER_OF_ASTEROIDS  EQU 4     ; self explanatory, but max of 8 allowed with current memory "allocation"
VSYNCLOOP                  EQU 1     ; this essentially controls how fast the game runs, the lower the number (down to 1 min) the faster it is
LEVEL_COUNT_DOWN_INIT      EQU 3    ; this is how fast the asteroids come down the screen, higher number the slower they move

KEYBOARD_READ_PORT_P_TO_Y	EQU $DF
; for start key
KEYBOARD_READ_PORT_A_TO_G	EQU $FD
; keyboard port for shift key to v
KEYBOARD_READ_PORT_SHIFT_TO_V EQU $FE
; keyboard space to b
KEYBOARD_READ_PORT_SPACE_TO_B EQU $7F
; keyboard q to t
KEYBOARD_READ_PORT_Q_TO_T EQU $FB



; starting port numbner for keyboard, is same as first port for shift to v
KEYBOARD_READ_PORT EQU $FE
SCREEN_WIDTH EQU 32
SCREEN_HEIGHT EQU 23   ; we can use the full screen becuase we're not using PRINT or PRINT AT ROM subroutines
MISSILE_COUNTDOWN_INIT EQU 18
PLAYER_START_POS EQU 637
PLAYER_X_START_POS EQU 10
PLAYER_LIVES EQU 3
ASTEROID_START_POS EQU 55
LEV_COUNTDOWN_TO_INVOKE_BOSS EQU 2


;;;; this is the whole ZX81 runtime system and gets assembled and
;;;; loads as it would if we just powered/booted into basic

           ORG  $4009             ; assemble to this address

VERSN
    DB 0
E_PPC:
    DW 2
D_FILE:
    DW Display
DF_CC:
    DW Display+1                  ; First character of display
VARS:
    DW Variables
DEST:           DW 0
E_LINE:         DW BasicEnd
CH_ADD:         DW BasicEnd+4                 ; Simulate SAVE "X"
X_PTR:          DW 0
STKBOT:         DW BasicEnd+5
STKEND:         DW BasicEnd+5                 ; Empty stack
BREG:           DB 0
MEM:            DW MEMBOT
UNUSED1:        DB 0
DF_SZ:          DB 2
S_TOP:          DW $0002                      ; Top program line number
LAST_K:         DW $fdbf
DEBOUN:         DB 15
MARGIN:         DB 55
NXTLIN:         DW Line2                      ; Next line address
OLDPPC:         DW 0
FLAGX:          DB 0
STRLEN:         DW 0
T_ADDR:         DW $0c8d
SEED:           DW 0
FRAMES:         DW $f5a3
COORDS:         DW 0
PR_CC:          DB $bc
S_POSN:         DW $1821
CDFLAG:         DB $40
MEMBOT:         DB 0,0 ;  zeros
UNUNSED2:       DW 0

            ORG 16509       ;; we have to push the place in memory for this here becuase basic has
                    ;; to start at 16514 if memory was tight we could use the space between UNUSED2
                    ;; and Line1 for variables

Line1:          DB $00,$0a                    ; Line 10
                DW Line1End-Line1Text         ; Line 10 length
Line1Text:      DB $ea                        ; REM

;; in test mode comment out jp intro_title and comment in the test calls

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	jp intro_title		; main entry point
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; end of test modes    
    call TEST_pixel_64_by_48_char_mapping
    ret

include math.asm
include draw.asm
include keyboardequ.asm
include utility.asm

    ret

                DB $76                        ; Newline
Line1End
Line2			DB $00,$14
                DW Line2End-Line2Text
Line2Text     	DB $F9,$D4                    ; RAND USR
				DB $1D,$22,$21,$1D,$20        ; 16514
                DB $7E                        ; Number
                DB $8F,$01,$04,$00,$00        ; Numeric encoding
                DB $76                        ; Newline
Line2End
endBasic

Display        	DB $76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
                DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$76
Variables

VariablesEnd:   DB $80
BasicEnd:


