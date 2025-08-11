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


; preamble!!

; the zx81 has 32 columns by 24 rows of characters - not pixels
; the pixels can only be plotted using rom characters
; we have to manipulate/recalculate the x y coordinate into a pixel coordinate
; the characters are as follows showing only the ones we need here
; this means we can have horizontally 32 * 2 = 64 pixels 
; and vertically we can have 24 * 2 = 48 pixels

;; symbol   int   
;;===============
;; o-        1       
;; --                     
;;===============
;; -o        2     
;; --                   
;;===============
;; --        4        
;; o-                    
;;===============
;; --      135
;; -o                          

; the people that designed the zx81 character set did a pretty good job. it makes it possible 
; with a couple of bit operations to get both the 32,24 position form the 2*32, 2*24 x,y coordinate
; and also to maintain the current character by or'ing the new with the existing at the character
; position 

; X Y  are consecutive to save time in drawPixel/undrawPixel
X_Plot_Position
    defb 0
Y_Plot_Position
    defb 0
LineLength    
    defb 0



drawPixel 
   
; why using ld hl, (nn) rather than two ld a, (nn) for X/Y positions
; ld a, (nn) is 13 T states, ld hl, (nn) is 16, but we have todo another 
; load from h to a and l to a each 4
; so either (13 * 2) + (2 * 4) = 34, or 16 + 8 = 24 saving 8, so use ld hl, (nn)

; see comments and this code up to findAddress is 69 T states

    ld hl, (X_Plot_Position) ; 16 T states  ; hl now both X_Plot_Position and Y_Plot_Position
                                            ; because they are consecutive in memory
    ld a, l                  ; 4 T states  
    and 1                    ; 4 T states  
    jp nz, X_Is_Odd          ; 10 T states  (34 T states for this block)
    ;; fall through
X_Is_Even
    ld a, h                  ; 4 T states 
    and 1                    ; 4 T states
    jp nz, X_Even_Y_Odd      ; 10 T states
    ;; fall through    
X_Even_Y_Even
    ld a, 1                  ; 7 T states
    jp findAddress           ; 10 T states  (total T states = 69 if end up here))
X_Even_Y_Odd   
    ld a, 4                  ; 7 T states
    jp findAddress           ; 10 T states  (total T states = 69 if end up here))
X_Is_Odd
    ld a, h                  ; 4 T states 
    and 1                    ; 4 T states
    jp nz, X_and_Y_Odd       ; 10 T states
    ;; fall through    
X_Odd_Y_Even
    ld a, 2                  ; 7 T states
    jp findAddress           ; 10 T states  (total 69 T states if end up here)
X_and_Y_Odd
    ld a, $87                ; 7 T states   (total 59 T states if end up here)
    
    
findAddress
    push af
        ld a, (Y_Plot_Position)
        sra a
        ld b, a

        ld   l, b
        ld   h, 0         ; hl = row (16-bit)

        ; multiply hl by 33 (i.e., hl = hl * 33 = hl * 32 + hl)
        push hl           ; save hl = row
            add  hl, hl       ; hl = row * 2
            add  hl, hl       ; hl = row * 4
            add  hl, hl       ; hl = row * 8
            add  hl, hl       ; hl = row * 16
            add  hl, hl       ; hl = row * 32
        pop  de           ; de = row
        add  hl, de       ; hl = row * 33

        ; add column
        ld a, (X_Plot_Position)
        sra a
        ld c, a       
        ld   e, c
        ld   d, 0
        add  hl, de       ; hl = row * 33 + column

        ; add screen base address
        ld   de, Display    
        inc de
        add  hl, de       ; hl = screen address
        ld a, (hl)           
    pop bc    
before_XOR_B
    xor b
    ld (hl), a

    ;call delayTinyAmount
    ret



undrawPixel 
    ld hl, (X_Plot_Position) ; 16 T states  ; hl now both X_Plot_Position and Y_Plot_Position
                                            ; because they are consecutive in memory
    ld a, l                  ; 4 T states  
    and 1                    ; 4 T states  
    jp nz, X_Is_Odd_U          ; 10 T states  (34 T states for this block)
    ;; fall through
X_Is_Even_U
    ld a, h                  ; 4 T states 
    and 1                    ; 4 T states
    jp nz, X_Even_Y_Odd_U      ; 10 T states
    ;; fall through    
X_Even_Y_Even_U
    ld a, 129                  ; 7 T states
    jp findAddress           ; 10 T states  (total T states = 69 if end up here))
X_Even_Y_Odd_U   
    ld a, 132                  ; 7 T states
    jp findAddress           ; 10 T states  (total T states = 69 if end up here))
X_Is_Odd_U
    ld a, h                  ; 4 T states 
    and 1                    ; 4 T states
    jp nz, X_and_Y_Odd_U       ; 10 T states
    ;; fall through    
X_Odd_Y_Even_U
    ld a, 130                  ; 7 T states
    jp findAddress           ; 10 T states  (total 69 T states if end up here)
X_and_Y_Odd_U
    ld a, 7                ; 7 T states   (total 59 T states if end up here)
    jp findAddress         ; 10 T states  (total 69 T states if end up here)
    ret    ;; never gets here, ret is done after findAddress



drawVerticalLine
    ; 8 bit memory locations  X_Plot_Position Y_Plot_Position(start) and LineLength set by Caller

    ld a, (LineLength)
    ld b, a
drawVerticalLine_loop
    push bc
        call drawPixel
        ld a, (Y_Plot_Position)
        inc a
        ld (Y_Plot_Position), a
    pop bc
    djnz drawVerticalLine_loop    
    ret





;;; test code
local_X_Pos
    defb 0
local_Y_Pos
    defb 0
local_LineLength
    defb 0    

TEST_LineDraw
    call CLS
    call delaySome
    ld a, 40
    ld (local_LineLength), a
    ld a, 0
    ld (local_X_Pos), a
    ld (local_Y_Pos), a
    ld b, 16
TEST_LineDrawLoop        
    push bc
        ld a, (local_X_Pos)
        ld (X_Plot_Position), a
        ld a, (local_Y_Pos)
        ld (Y_Plot_Position), a
        ld a, (local_LineLength)
        ld (LineLength), a

        call drawVerticalLine

        ld a, (local_X_Pos)
        inc a
        ld (local_X_Pos), a
        ld a, (local_Y_Pos)
        inc a        
        ld (local_Y_Pos), a
        ld a, (local_LineLength)
        dec a
        dec a
        ld (local_LineLength), a
    pop bc
    djnz TEST_LineDrawLoop
    call delaySome
    jp TEST_LineDraw
    ret

TEST_pixel_64_by_48_char_mapping

;; we run several tests which we draw and then undraw pixels

    ; test 1 vertical bars
	;call CLS

    ld a, 0    
    ld (X_Plot_Position), a
    ld a, 0
	ld (Y_Plot_Position), a
    ld b, 20
loopXY
    push bc     
        ld b, 30
loopXY_inner
        push bc            
            call drawPixel      
            ld a, (X_Plot_Position)
            inc a       
            inc a  
            ld (X_Plot_Position), a        
        pop bc
        djnz loopXY_inner
        ld a, (Y_Plot_Position)
        inc a                               
        ld (Y_Plot_Position), a
        ld a, 0    
        ld (X_Plot_Position), a
    pop bc
    djnz loopXY

    call delayTinyAmount

    ld a, 0    
    ld (X_Plot_Position), a
    ld a, 0
	ld (Y_Plot_Position), a
    ld b, 20
loopXY_U
    push bc     
        ld b, 30
loopXY_inner_U
        push bc            
            call undrawPixel      
            ld a, (X_Plot_Position)
            inc a       
            inc a  
            ld (X_Plot_Position), a        
        pop bc
        djnz loopXY_inner_U
        ld a, (Y_Plot_Position)
        inc a                               
        ld (Y_Plot_Position), a
        ld a, 0    
        ld (X_Plot_Position), a
    pop bc
    djnz loopXY_U

    call delayTinyAmount

    ; test 2 horizontal bars

    ld a, 0    
    ld (X_Plot_Position), a
    ld a, 0
	ld (Y_Plot_Position), a
    ld b, 20
loopXY2
    push bc     
        ld b, 30
loopXY_inner2
        push bc            
            call drawPixel      
            ld a, (X_Plot_Position)
            inc a       
            ld (X_Plot_Position), a        
        pop bc
        djnz loopXY_inner2
        ld a, (Y_Plot_Position)
        inc a                               
        inc a         
        ld (Y_Plot_Position), a
        ld a, 0    
        ld (X_Plot_Position), a
    pop bc
    djnz loopXY2  

    call delayTinyAmount



    ld a, 0    
    ld (X_Plot_Position), a
    ld a, 0
	ld (Y_Plot_Position), a
    ld b, 20
loopXY2_U
    push bc     
        ld b, 30
loopXY_inner2_U
        push bc            
            call drawPixel      
            ld a, (X_Plot_Position)
            inc a       
            ld (X_Plot_Position), a        
        pop bc
        djnz loopXY_inner2_U
        ld a, (Y_Plot_Position)
        inc a                               
        inc a         
        ld (Y_Plot_Position), a
        ld a, 0    
        ld (X_Plot_Position), a
    pop bc
    djnz loopXY2_U

    call delayTinyAmount

	
    ;; Test 3 diagonal line left to right
    ld a, 0
    ld (X_Plot_Position), a
    ld a, 0
	ld (Y_Plot_Position), a
    ld b, 20
loopXY3
    push bc     
        call drawPixel      
        ld a, (X_Plot_Position)
        inc a       
        ld (X_Plot_Position), a        
        ld a, (Y_Plot_Position)
        inc a       
        ld (Y_Plot_Position), a                        
    pop bc
    djnz loopXY3

    call delayTinyAmount

    ld a, 0
    ld (X_Plot_Position), a
    ld a, 0
	ld (Y_Plot_Position), a
    ld b, 20
loopXY3_U
    push bc     
        call drawPixel      
        ld a, (X_Plot_Position)
        inc a       
        ld (X_Plot_Position), a        
        ld a, (Y_Plot_Position)
        inc a       
        ld (Y_Plot_Position), a                        
    pop bc
    djnz loopXY3_U

    call delayTinyAmount


    ;; Test 4 diagonal line right to left

    ld a, 20
    ld (X_Plot_Position), a
    ld a, 0
	ld (Y_Plot_Position), a
    ld b, 20
loopXY4
    push bc     
        call drawPixel      
        ld a, (X_Plot_Position)
        dec a       
        ld (X_Plot_Position), a        
        ld a, (Y_Plot_Position)
        inc a       
        ld (Y_Plot_Position), a                        
    pop bc
    djnz loopXY4

    call delayTinyAmount

    ld a, 20
    ld (X_Plot_Position), a
    ld a, 0
	ld (Y_Plot_Position), a
    ld b, 20
loopXY4_U
    push bc     
        call drawPixel      
        ld a, (X_Plot_Position)
        dec a       
        ld (X_Plot_Position), a        
        ld a, (Y_Plot_Position)
        inc a       
        ld (Y_Plot_Position), a                        
    pop bc
    djnz loopXY4_U

    call delayTinyAmount

    ; test 5 solid block draw and undraw
	call CLS
    ld a, 0    
    ld (X_Plot_Position), a
    ld a, 0
	ld (Y_Plot_Position), a
    ld b, 40
loopXY5
    push bc     
        ld b, 40
loopXY_inner5
        ld a, (X_Plot_Position)
        push bc           
            call drawPixel      
            ld a, (X_Plot_Position)
            inc a       
            ld (X_Plot_Position), a        
        pop bc
        ld (X_Plot_Position), a        
        djnz loopXY_inner5
        ld a, (Y_Plot_Position)
        inc a                                
        ld (Y_Plot_Position), a
        ld a, 0    
        ld (X_Plot_Position), a
    pop bc
    djnz loopXY5

    call delayTinyAmount
	
    ld a, 0    
    ld (X_Plot_Position), a
    ld a, 0
	ld (Y_Plot_Position), a
    ld b, 40
loopXY6
    push bc     
        ld b, 40
loopXY_inner6
        ld a, (X_Plot_Position)
        push bc           
            call undrawPixel      
            ld a, (X_Plot_Position)
            inc a       
            ld (X_Plot_Position), a        
        pop bc
        ld (X_Plot_Position), a        
        djnz loopXY_inner6
        ld a, (Y_Plot_Position)
        inc a                                
        ld (Y_Plot_Position), a
        ld a, 0    
        ld (X_Plot_Position), a
    pop bc
    djnz loopXY6

    call delayTinyAmount
    ret

