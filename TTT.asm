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
	badBounds:	db "ERROR: Invalid space", 10, 0
	;board:		times 9 dd 0
	board: 		dd 0, 1, 2, 0, 1, 2, 0, 1, 2
	f_int: 		db "%d", 0 		; Integer format
	f_strn:		db "%s", 10, 0 		; String format w newline
	f_str:		db "%s", 0		; String format
	white:		db 27, "[47m", 0	; White background
	red:		db 27, "[31m", 0	; Red foreground
	blue:		db 27, "[34m", 0	; Blue foreground
	black:		db 27, "[30m", 0	; Black foreground
	alt:		db 27, "(0", 0		; Alternate character set
	norm:		db 27, "(B", 0		; Normal Character Set
	reset:		db 27, "(B", 27, "[40m", 0		; Normal character set and background
	X:		db "X", 0		; X
	O:		db "O", 0		; Y
	E:		db " ", 0		; Space
	badSpot:	db "Space already occupied", 10, 0

SECTION .text
	global main
	extern scanf
	extern printf
	extern rand
	extern srand

main:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN main
	;jmp exit
	
	push white
	push f_str
	call printf
	add ESP, 8

	push black
	push f_str
	call printf
	add ESP, 8 	

	
	call printBoard
	call getInput
	call printBoard

	jmp exit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END main

getInput:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN getInput
	push input
	push f_int
	call scanf
	add ESP, 8

	mov EAX, [input]

	cmp EAX, 1
	jl	.fail1
	cmp EAX, 9
	jg	.fail1

	call setSpot

	jmp .end
.fail1:
	push badBounds
	push f_str
	call printf
	add ESP, 8
	jmp .end	

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END getInput

setSpot:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN setSpot
	dec EAX
	xor EDX, EDX
	imul EAX, 4

	mov EBX, [board + EAX]

	cmp EBX, 0
	jne .bad
	
	mov EBX, 1
	mov [board + EAX], EBX
	jmp .end
.bad:
	push badSpot
	call printf
	add ESP, 4

	jmp .end

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END setSpot

printBoard:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN printBoard

	xor ECX, ECX
.top:	
	cmp ECX, 10
	je .end

	push ECX

	mov EAX, ECX
	xor EDX, EDX
	imul EAX, 4
	mov EAX, [board + EAX]
	cmp EAX, X_VAL
	je .printX

	cmp EAX, O_VAL
	je .printO

	push E
	call printf
	add ESP, 4
	jmp .bottom

.printX:
	push X
	call printf
	add ESP, 4
	jmp .bottom

.printO:
	push O
	call printf
	add ESP, 4
	jmp .bottom
	
.bottom:
	pop ECX
	inc ECX
	jmp .top

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END printBoard

exit:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN exit
	push norm
	push f_str
	call printf
	add ESP, 8

	ret		; Get outta harlem
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END exit
