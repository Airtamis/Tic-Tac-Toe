; Jeremy Greenburg and Cody Robertson
; Tic Tac Toe
; Plays ye old guessing game with the user
; nasm -f elf32 TTT.asm && gcc -m32 TTT.o -o TTT

; comment

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
	board:		times 9 dd 0	;legit board
	;board: 		dd 0, 1, 2, 0, 1, 2, 0, 1, 2	; test board
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
	currentSymb:	dd X_VAL

	m_computer:	db "Computer's Turn", 0	; test message
	m_player:	db "Player's Turn", 0	; test message

SECTION .text
	global main
	extern scanf
	extern printf
	extern time
	extern rand
	extern srand

main:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN main
	;jmp exit
	
	push white		; push white background escape character to stack
	push f_str		; push string format for printf to stack
	call printf		; change background to white color
	add ESP, 8		; adjust stack pointer

	push black		; push black foreground escape character to stack
	push f_str		; push string format for printf to stack
	call printf		; change foreground to black color
	add ESP, 8 		; adjust stack pointer

	call choosePlayers	; choose which player goes first (also sets random seed for program)

mainloop:
	call printBoard		; print original empty board

.gameloop:
	mov EAX, [currentSymb]	;put current symbol in EAX
	mov EBX, [playSymb]	;put player's symbol in EBX
	cmp EAX, EBX		;check if player's turn or computer's turn
	je  .player
	jmp .computer

.player:
	push m_player
	call printf
	add ESP, 4

	call getInput		; get user input for move placement
	jmp .bottom

.computer:
	push m_computer
	call printf
	add ESP, 4

	;currently the same as .player since no placement algorithm
	call getInput		; get user input for move placement
	jmp .bottom
	
.bottom:
	call printBoard
	call switchTurn		; switch currentSymb to O's
	;call calcWin		; returns 0 if game is still going; 1,2,or 3 if ended
	;cmp EAX, 0		; if game is still going, 
	;(not sure if Jeremy has already implemented a system for catching return value)
	jmp .gameloop		; continue game loop
	
	;call endgame		; something to update scores, reset board, etc.
	;call playAgain		; maybe? return value of 0 to continue? else to quit?
	call switchPlayers	; switch players' symbols
	jmp mainloop		; start new game

.exit:
	;call printScores	; a method to print final scores before exiting entirely
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
	
	mov EBX, [currentSymb]	; mov the player's symbol into EBX
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
	jmp .top		; loop to top

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END printBoard

choosePlayers:;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN choosePlayers
;; choose a random number (0-computer or 1-player) that will determine which player is X (who goes first) ;;
;; set random seed (can be done here because function should only be called once) ;;
	push	0		; push null character to stack
	call	time		; returns time_t value in EAX
	add	ESP, 4		; adjust stack pointer
	push	EAX		; mov time return value to stack
	call	srand		; set random seed (time value is seed value for rand)
	add	ESP, 4		; adjust stack pointer
	
	call	rand		; call rand for random value, returned in EAX
	xor	EDX, EDX	; set EDX to 0 to prepare for division
	mov	EBX, 2		; we will divide by 2 since we want 2 possibilities
	div	EBX		; divide random number in EAX by 2, we will get remainder from EDX
	
	cmp	EDX, 0		; if remainder is 0,
	je	.computerFirst	; computer goes first
	
.humanFirst:
	mov	EAX, X_VAL	
	mov	[playSymb], EAX	; set human as X
	mov	EAX, O_VAL
	mov	[compSymb], EAX	; set computer as O
	jmp	.end		; return

.computerFirst:
	mov	EAX, X_VAL
	mov	[compSymb], EAX	; set computer as X
	mov	EAX, O_VAL
	mov	[playSymb], EAX	; set human as O
	
.end:
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END choosePlayers

switchTurn:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN switchTurn
;; This function takes no input and switches the value in currentSymb ;; 
	mov	EAX, [currentSymb]	;load current symbol into EAX
	cmp	EAX, X_VAL		;if current symbol is x,
	je	.switchx		;go to switch that X to an O

	mov	EAX, X_VAL		;else, load X value into EAX
	mov	[currentSymb], EAX	;set current symbol to X
	jmp	.end			;return

.switchx:
	mov	EAX, O_VAL		;if current symbol is X, load O value into EAX
	mov	[currentSymb], EAX	;set current symbol to O
	
.end:
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END switchTurn

switchPlayers:;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN switchPlayers
;; This function takes no input and switches the values in playSymb and compSymb ;;
;; Also updates currentSymb in preparation for new game ;;
	mov	EAX, [playSymb]	; store player's symbol
	mov	EBX, [compSymb]	; store computer's symbol
	mov	[playSymb], EBX	; store computer's symbol as new human symbol
	mov	[compSymb], EAX	; store player's symbol as new computer symbol
	
	mov	EAX, X_VAL		;store X value in EAX
	mov	[currentSymb], EAX	;update currentSymb to be X for new game
	
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END switchPlayers

exit:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN exit
	push norm		; push normal character set escape character to stack
	push f_str		; push format string for printing a string
	call printf		; no more demon symbols
	add ESP, 8		; adjust stack pointer

	ret			; Get outta harlem
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END exit
