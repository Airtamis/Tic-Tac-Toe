; Jeremy Greenburg and Cody Robertson
; Tic Tac Toe
; Plays ye old guessing game with the user
; nasm -f elf32 TTT.asm && gcc -m32 TTT.o -o TTT

%define SYS_EXIT 1
%define SYS_READ 3
%define SYS_WRITE 4
%define STDIN 0
%define STDOUT 1
%define STDERR 2

%define EMPTY_VAL 0
%define X_VAL 1
%define O_VAL 2

SECTION .bss
	input:		resd 1
	playSymb:	resd 1
	compSymb:	resd 1

SECTION .data
	badBounds:	db "ERROR: Invalid space", 10, 0 ;user chose a space that is not 1-9
	;board:		times 9 dd 0	;legit board
	board: 		dd 0, 1, 2, 0, 1, 2, 0, 1, 2	; test board
	f_int: 		db "%d", 0 		; Integer format
	f_strn:		db "%s", 10, 0 		; String format w newline
	f_str:		db "%s", 0		; String format
	white:		db 27, "[47m", 0	; White background
	red:		db 27, "[31m", 0	; Red foreground
	blue:		db 27, "[34m", 0	; Blue foreground
	black:		db 27, "[30m", 0	; Black foreground
	alt:		db 27, "(0", 0		; Alternate character set
	norm:		db 27, "(B", 0		; Normal Character Set
	reset:		db 27, "(B", 27, "[40m", 0	; Normal character set and background
	X:		db "X", 0		; X
	O:		db "O", 0		; Y
	E:		db " ", 0		; Space
	badSpot:	db "Space already occupied", 10, 0 ; User chose occupied spot in board
	newline:	db 10, 0		; newline character
	tieWin:		db "Tie game!", 10, 0	; Tie Game Message
	compWin:	db "The Computer Won, of course!", 10, 0 ; Computer Win Message
	playWin:	db "Crap, the player won...", 10, 0	; Player win message

SECTION .text
	global main
	extern scanf
	extern printf
	extern rand
	extern srand

main:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN main
	;jmp exit
	
	call printBoard 	; print original empty board
	call getInput		; get user input for move placement
	call printBoard		; print updated board after first move

	jmp exit		; exit program
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END main

getInput:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN getInput
	push input		; push variable to store input to stack
	push f_int		; push format string for getting integer input
	call scanf		; get user's inputted move
	add ESP, 8		; adjust stack pointer

	mov EAX, [input]	; move user's inputted number into EAX

	cmp EAX, 1		; make sure user's input is greater or equal to 1
	jl	.fail1		; if not, print badBounds
	cmp EAX, 9		; make sure user's input is less than or equal to 9
	jg	.fail1		; if not, print badBounds

	call setSpot		; if input is within bounds, attempt to set space

	jmp .end		; return
.fail1:
	push badBounds		; push out of bounds warning string to stack
	push f_str		; push string format string to stack
	call printf		; print warning to user
	add ESP, 8		; adjust stack pointer
	jmp .end		; return

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END getInput

setSpot:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN setSpot
	dec EAX			; adjust input for array indexing
	xor EDX, EDX		; set EDX to 0 before multiplication
	imul EAX, 4		; multiply EAX by 4 due to 4-byte blocks of integers in array

	mov EBX, [board + EAX]  ; retrieve current value at position in board

	cmp EBX, 0		; if board position is not empty, print warning
	jne .bad		
	
	mov EBX, X_VAL		; mov the player's symbol into EBX
	mov [board + EAX], EBX  ; set board spot to player's symbol
	jmp .end		; ret
.bad:
	push badSpot		; move warning string that space is occupied to stack
	call printf		; print warning to user
	add ESP, 4		; adjust stack pointer

	jmp .end		; ret

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END setSpot

printBoard:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN printBoard

	push white
	call printf
	add ESP, 4

	push black
	call printf
	add ESP, 4	

	xor ECX, ECX		; set ECX to 0
.top:	
	cmp ECX, 10		; check if ECX is finished iterating over array
	je .end			; if so, return

	push ECX		; push 0 to stack to retain current iteration number

	mov EAX, ECX		; mov 0 into EAX
	xor EDX, EDX		; set EDX to 0
	imul EAX, 4		; multiply EAX by for for array offset
	mov EAX, [board + EAX]	; access current element in array
	cmp EAX, X_VAL		; if there is an X in the space,
	je .printX		; print X not 1

	cmp EAX, O_VAL		; if there is an O in the space,
	je .printO		; print O not 1

	push E			; otherwise, print an empty space; push space string to stack
	call printf		; print space for current board space
	add ESP, 4		; adjust stack pointer
	jmp .bottom		; prepare for next iteration of loop

.printX:
	push X			; push X character string to stack
	call printf		; print X for space in board
	add ESP, 4		; adjust stack pointer
	jmp .bottom		; prepare for next iteration of loop

.printO:
	push O			; push O character string to stack
	call printf		; pirnt O for space in board
	add ESP, 4		; adjust stack pointer
	jmp .bottom		; prepare for next iteration of loop
	
.bottom:
	pop ECX			; retrieve current iteration counter from stack
	inc ECX			; increment counter
	
	cmp ECX, 3		; If ECX is 3
	je .new			; Print a newline
	cmp ECX, 6		; If ECX is 6
	je .new			; print a newline
	cmp ECX, 9		; IF ECX is 9
	je .new			; Print a newline

	jmp .top		; loop to top
.new:
	push ECX		; Save ECX

	push newline		; Push newline charater
	call printf		; Call printf
	add ESP, 4		; Adjust stack

	pop ECX			; Get ECX back
	jmp .top

.end:
	push reset		; Return keyboard to normal
	call printf		; Call printf
	add ESP, 4		; Adjust stack pointer

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END printBoard

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EAX = 0 if no win, 1 if computer win, 2 if player win, 3 if tie
calcWin:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Begin calcWin
	;; Board looks like:
	;; 0, 1, 2
	;; 3, 4, 5
	;; 6, 7, 8

	call checkXWin
	cmp EAX, 1		; If X won, EAX will be 1
	je .XWin
	call checkOWin
	cmp EAX, 1		; If O won, EAX will be 2
	je .OWin
	call checkTie
	cmp EAX, 1
	je .tie
	jmp .noWin
	 
.XWin:

.OWin:
	mov playSmb

.tie:
	push tie
	call printf
	add ESP, 4
	
	mov EAX, 3		; Return 3
	jmp .end

.noWin:
	xor EAX, EAX
	jmp .end

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END calcWin

checkXWin:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN checkXWin

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END checkXWin

checkOWin:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN checkOWin

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END checkOWin

checkTie:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN checkTie

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END checkTie

exit:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN exit
	push norm		; push normal character set escape character to stack
	push f_str		; push format string for printing a string
	call printf		; no more demon symbols
	add ESP, 8		; adjust stack pointer

	ret		; Get outta harlem
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END exit
