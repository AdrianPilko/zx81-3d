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

X_Plot_Position
    defb 0
Y_Plot_Position
    defb 0

drawPixel 
    ld a, (X_Plot_Position)
    and 1
    jr nz, X_Is_Odd
    ;; fall through
X_Is_Even
    ld a, (Y_Plot_Position)
    and 1
    jr nz, X_Even_Y_Odd     
    ;; fall through    
X_Even_Y_Even
    ld a, 1
    jr plotCharacter
X_Even_Y_Odd   
    ld a, $4
    jr plotCharacter
X_Is_Odd
    ld a, (Y_Plot_Position)
    and 1
    jr nz, X_and_Y_Odd     
    ;; fall through    
X_Odd_Y_Even
    ld a, 2
    jr plotCharacter
X_and_Y_Odd
    ld a, $87
    


plotCharacter
    push af        
        ld a, (X_Plot_Position)
        sra a   ; divide a by 2 giving proper character position
        ld hl, Display
        inc hl
        ld de, 0
        ld e, a        
        add hl, de
        ld a, (Y_Plot_Position)
        sra a ; divide a by 2 giving proper y position
        ld b, a
        inc b ; (just in case it's zero - we correct address after by -33)
        ld de, 33
secondPixelLoop        
        add hl, de
        djnz secondPixelLoop
        ld de, -33
        add hl, de
        ld a, (hl)   
    pop bc
    xor b
    ld (hl), a
	ret


;;; test code

TEST_pixel_64_by_48_char_mapping

    ; test 1 vertical bars
	call CLS
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

    call delaySome



    ; test 2 horizontal bars
	call CLS
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

    call delaySome

	
    ;; Test 3 diagonal line left to right
    call CLS
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

    call delaySome

    ;; Test 4 diagonal line right to left
    call CLS
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
END_TEST    
    jr END_TEST
    ret


TEST_PIX_text_1
	defb _P,_I,_X,_E,_L,0,_P,_O,_S,_I,_T,_I,_O,_N,$ff
TEST_PIX_text_2
	defb _C,_H,_A,_R,0,_R,_E,_S,_U,_L,_T,$ff