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
	m_badBounds:	db "ERROR: Invalid space", 10, 0 ;user chose a space that is not 1-9
	board:		times 9 dd 0	;legit board
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
	m_badSpot:	db "Space already occupied", 10, 0 ; User chose occupied spot in board
	newline:	db 10, 0		; newline character
	m_tieWin:	db "Tie game!", 10, 0	; Tie Game Message
	m_compWin:	db "The Computer Won, of course!", 10, 0 ; Computer Win Message
	m_playWin:	db "Crap, the player won...", 10, 0	; Player win message
	m_here:		db "HERE\n", 0
SECTION .text
	global main
	extern scanf
	extern printf
	extern rand
	extern srand

main:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN main
	;jmp exit

	push white
	call printf
	add ESP, 4

	push black
	call printf
	add ESP, 4

	mov [playSymb], DWORD X_VAL

.top:
	call printBoard 	; print original empty board
	call getInput
	call calcWin

	cmp EAX, 0
	je .top

	jmp exit		; exit program
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END main

getInput:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN getInput
	push input		; push variable to store input to stack
	push f_int		; push format string for getting integer input
	call scanf		; get user's inputted move
	add ESP, 8		; adjust stack pointer

	mov EAX, [input]	; move user's inputted number into EAX

	cmp EAX, 1		; make sure user's input is greater or equal to 1
	jl	.fail1		; if not, print m_badBounds
	cmp EAX, 9		; make sure user's input is less than or equal to 9
	jg	.fail1		; if not, print m_badBounds

	call setSpot		; if input is within bounds, attempt to set space

	jmp .end		; return
.fail1:
	push m_badBounds		; push out of bounds warning string to stack
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
	push m_badSpot		; move warning string that space is occupied to stack
	call printf		; print warning to user
	add ESP, 4		; adjust stack pointer

	jmp .end		; ret

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END setSpot

printBoard:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN printBoard

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
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END printBoard

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EAX = 0 if no win, 1 if computer win, 2 if player win, 3 if tie
calcWin:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Begin calcWin
	mov EBX, X_VAL
	call checkWin
	cmp EAX, 1		; If X won, EAX will be 1
	je .XWin

	mov EBX, O_VAL
	call checkWin
	cmp EAX, 1		; If O won, EAX will be 2
	je .OWin
	call checkTie
	cmp EAX, 1
	je .tie
	jmp .noWin
	 
.XWin:
	mov EAX, [playSymb]
	cmp EAX, X_VAL
	je .playWin
	jmp .compWin

.OWin:
	mov EAX, [playSymb]
	cmp EAX, O_VAL
	je .playWin
	jmp .compWin

.compWin:
	push m_compWin
	call printf
	add ESP, 4

	mov EAX, 1
	jmp .end

.playWin:
	push m_playWin
	call printf
	add ESP, 4
	
	mov EAX, 2
	jmp .end

.tie:
	push m_tieWin
	call printf
	add ESP, 4
	
	mov EAX, 3		; Return 3
	jmp .end

.noWin:
	push newline
	call printf
	add ESP, 4

	xor EAX, EAX
	jmp .end

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END calcWin

checkWin:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN checkWin

.topRow:
	mov EAX, [board]	; Top left cell
	cmp EAX, EBX
	jne .centRow

	mov EAX, [board + 4]	; Top center cell
	cmp EAX, EBX
	jne .centRow

	mov EAX, [board + 8]	; Top right cell
	cmp EAX, EBX
	jne .centRow
	jmp .win

.centRow:
	mov EAX, [board + 12]	; Middle left cell
	cmp EAX, EBX
	jne .botRow

	mov EAX, [board + 16]	; Middle center cell
	cmp EAX, EBX
	jne .botRow

	mov EAX, [board + 20]	; Middle right cell
	cmp EAX, EBX
	jne .botRow
	jmp .win

.botRow:
	mov EAX, [board + 24]	; Middle left cell
	cmp EAX, EBX
	jne .leftCol

	mov EAX, [board + 28]	; Middle center cell
	cmp EAX, EBX
	jne .leftCol

	mov EAX, [board + 32]	; Middle right cell
	cmp EAX, EBX
	jne .leftCol
	jmp .win


.leftCol:
	mov EAX, [board]	; Middle left cell
	cmp EAX, EBX
	jne .centCol

	mov EAX, [board + 12]	; Middle center cell
	cmp EAX, EBX
	jne .centCol

	mov EAX, [board + 24]	; Middle right cell
	cmp EAX, EBX
	jne .centCol
	jmp .win

.centCol:
	mov EAX, [board + 4]	; Middle left cell
	cmp EAX, EBX
	jne .rightCol

	mov EAX, [board + 16]	; Middle center cell
	cmp EAX, EBX
	jne .rightCol

	mov EAX, [board + 28]	; Middle right cell
	cmp EAX, EBX
	jne .rightCol
	jmp .win


.rightCol:
	mov EAX, [board + 8]	; Middle left cell
	cmp EAX, EBX
	jne .lrDi

	mov EAX, [board + 20]	; Middle center cell
	cmp EAX, EBX
	jne .lrDi

	mov EAX, [board + 32]	; Middle right cell
	cmp EAX, EBX
	jne .lrDi
	jmp .win

.lrDi:
	mov EAX, [board]	; Middle left cell
	cmp EAX, EBX
	jne .rlDi

	mov EAX, [board + 16]	; Middle center cell
	cmp EAX, EBX
	jne .lrDi

	mov EAX, [board + 32]	; Middle right cell
	cmp EAX, EBX
	jne .lrDi
	jmp .win


.rlDi:
	mov EAX, [board + 8]	; Middle left cell
	cmp EAX, EBX
	jne .fail

	mov EAX, [board + 16]	; Middle center cell
	cmp EAX, EBX
	jne .fail

	mov EAX, [board + 24]	; Middle right cell
	cmp EAX, EBX
	jne .fail
	jmp .win


.fail:
	xor EAX, EAX
	jmp .end
.win:
	mov EAX, 1
	jmp .end
	
.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END checkWin

checkTie:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN checkTie
	xor ECX, ECX

.top:
	cmp ECX, 9
	je .end
	
	mov EAX, ECX		; Put ECX in EAX
	xor EDX, EDX		; Zero out EDX
	imul EAX, 4		; Multiply by size of DWORD

	mov EBX, [board + EAX]	; Put spot in array into EBX
	
	cmp EBX, 0
	je .empty
	jmp .bottom

.bottom:
	inc ECX
	jmp .top

.empty:				; If there's an esmpty space
	xor EAX, EAX
	ret
.end:	
	mov EAX, 1
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END checkTie

exit:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN exit
	push norm		; push normal character set escape character to stack
	push f_str		; push format string for printing a string
	call printf		; no more demon symbols
	add ESP, 8		; adjust stack pointer

	ret		; Get outta harlem
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END exit
