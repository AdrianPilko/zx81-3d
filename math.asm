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



; in an attempt to make this run fast we're doing all the math in 8bits and integer
; not floating point.

; these were pre calculated using the C program calcSineCos.cpp

mathPrecalcd_SIN 
	defb 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 26
	defb 27, 28, 29, 30, 31, 32, 32, 33, 34, 35, 36, 36, 37, 38, 39, 39, 40, 41, 41, 42, 43, 43, 44, 45, 45, 46
	defb 46, 47, 48, 48, 49, 49, 50, 50, 51, 51, 51, 52, 52, 53, 53, 53, 54, 54, 54, 55, 55, 55, 55, 56, 56, 56
	defb 56, 56, 56, 56, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 56, 56, 56, 56, 56, 56, 56, 55, 55, 55, 55
	defb 54, 54, 54, 53, 53, 53, 52, 52, 51, 51, 51, 50, 50, 49, 49, 48, 48, 47, 46, 46, 45, 45, 44, 43, 43 
	defb 42, 41, 41, 40, 39, 39, 38, 37, 36, 36, 35, 34, 33, 32, 32, 31, 30, 29, 28, 27, 26, 26, 25, 24, 23 
	defb 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 0, 0, -1, -2, -3
	defb -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24, -25
	defb -26, -26, -27, -28, -29, -30, -31, -32, -32, -33, -34, -35, -36, -36, -37, -38, -39, -39, -40, -41, -41
	defb -42, -43, -43, -44, -45, -45, -46, -46, -47, -48, -48, -49, -49, -50, -50, -51, -51, -51, -52, -52, -53
	defb -53, -53, -54, -54, -54, -55, -55, -55, -55, -56, -56, -56, -56, -56, -56, -56, -57, -57, -57, -57, -57
	defb -57, -57, -57, -57, -57, -57, -56, -56, -56, -56, -56, -56, -56, -55, -55, -55, -55, -54, -54, -54, -53
	defb -53, -53, -52, -52, -51, -51, -51, -50, -50, -49, -49, -48, -48, -47, -46, -46, -45, -45, -44, -43, -43
	defb -42, -41, -41, -40, -39, -39, -38, -37, -36, -36, -35, -34, -33, -32, -32, -31, -30, -29, -28, -27, -26
	defb -26, -25, -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5
	defb -4, -3, -2, -1, 0

mathPrecalcd_COS
	defb 57, 57, 57, 57, 57, 57, 56, 56, 56, 56, 56, 56, 56, 55, 55, 55, 55, 54, 54, 54, 53, 53, 53, 52, 52, 51 
	defb 51, 51, 50, 50, 49, 49, 48, 48, 47, 46, 46, 45, 45, 44, 43, 43, 42, 41, 41, 40, 39, 39, 38, 37, 36, 36 
	defb 35, 34, 33, 32, 32, 31, 30, 29, 28, 27, 26, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12
	defb 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 0, 0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14
	defb -15, -16, -17, -18, -19, -20, -21, -22, -23, -24, -25, -26, -26, -27, -28, -29, -30, -31, -32, -32, -33
	defb -34, -35, -36, -36, -37, -38, -39, -39, -40, -41, -41, -42, -43, -43, -44, -45, -45, -46, -46, -47, -48
	defb -48, -49, -49, -50, -50, -51, -51, -51, -52, -52, -53, -53, -53, -54, -54, -54, -55, -55, -55, -55, -56
	defb -56, -56, -56, -56, -56, -56, -57, -57, -57, -57, -57, -57, -57, -57, -57, -57, -57, -56, -56, -56
	defb -56, -56, -56, -56, -55, -55, -55, -55, -54, -54, -54, -53, -53, -53, -52, -52, -51, -51, -51, -50
	defb -50, -49, -49, -48, -48, -47, -46, -46, -45, -45, -44, -43, -43, -42, -41, -41, -40, -39, -39, -38
	defb -37, -36, -36, -35, -34, -33, -32, -32, -31, -30, -29, -28, -27, -26, -26, -25, -24, -23, -22, -21
	defb -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 0, 0
	defb 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 26, 27
	defb 28, 29, 30, 31, 32, 32, 33, 34, 35, 36, 36, 37, 38, 39, 39, 40, 41, 41, 42, 43, 43, 44, 45, 45, 46
	defb 46, 47, 48, 48, 49, 49, 50, 50, 51, 51, 51, 52, 52, 53, 53, 53, 54, 54, 54, 55, 55, 55, 55, 56, 56
	defb 56, 56, 56, 56, 56, 57, 57, 57, 57, 57


