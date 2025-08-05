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

    ld b, 1
    and b
    cp 1
    jr nz, X_Is_Even
    ;; fall through
X_Is_Odd
    ; if x coord is x and y coord odd then character = $87
    ld a, (Y_Plot_Position)
    ; mask the lower 4 bits - this gives the character
    ld b, 1
    and b
    cp 1
    jr z, X_and_Y_Odd     
    ;; fall through    
X_Odd_Y_Even
    ld a, 2
    jr plotCharacter
X_and_Y_Odd
    ld a, $87
    jr plotCharacter

X_Is_Even
    ld a, (Y_Plot_Position)
    ; mask the lower 4 bits - this gives the character
    ld b, 1
    and b
    cp 1
    jr z, X_Even_Y_Odd     
    ;; fall through    
X_Even_Y_Even
    ld a, 1
    jr plotCharacter
X_Even_Y_Odd   
    ld a, 4


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
    or b
    ld (hl), a
	ret


;;; test code

TEST_pixel_64_by_48_char_mapping
	call CLS

    ld a, 1
	ld (X_Plot_Position), a
    ld a, 1
	ld (Y_Plot_Position), a     
	call drawPixel    

    ld a, 4
	ld (X_Plot_Position), a
    ld a, 4
	ld (Y_Plot_Position), a     
	call drawPixel    

    ld a, 8
	ld (X_Plot_Position), a
    ld a, 8
	ld (Y_Plot_Position), a     
	call drawPixel    

    ld a, 16
	ld (X_Plot_Position), a
    ld a, 16
	ld (Y_Plot_Position), a     
	call drawPixel        



	ret


TEST_PIX_text_1
	defb _P,_I,_X,_E,_L,0,_P,_O,_S,_I,_T,_I,_O,_N,$ff
TEST_PIX_text_2
	defb _C,_H,_A,_R,0,_R,_E,_S,_U,_L,_T,$ff