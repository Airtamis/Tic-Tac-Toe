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

SECTION .bss
	input:		resd 1

SECTION .data
	badBounds:	db "ERROR: Invalid space", 10, 0
	row1:		db "1|2|3", 0
	row2:		db "4|5|6", 0
	row3:		db "7|8|9", 0
	line:		db "-----", 0
	f_int: 		db "%d", 0 		; Integer format
	f_strn:		db "%s", 10, 0 		; String format w newline
	f_str:		db "%s", 0		; String format
	white:		db 27, "[47m", 0	; White background
	red:		db 27, "[31m", 0	; Red foreground
	blue:		db 27, "[34m", 0	; Blue foreground
	black:		db 27, "[30m", 0	; Black foreground
	alt:		db 27, "(0", 0		; Alternate character set
	norm:		db 27, "(B", 27, "[40m", 0		; Normal character set and background

SECTION .text
	global main
	extern scanf
	extern printf
	extern rand
	extern srand

main:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN main

	push alt
	push f_str
	call printf
	add ESP, 8
	
	push white
	push f_str
	call printf
	add ESP, 8

	push black
	push f_str
	call printf
	add ESP, 8 	

.top:
	call getInput
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

	jmp .end
.fail1:
	push badBounds
	push f_str
	call printf
	add ESP, 8
	jmp .end	

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END getInput

exit:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN exit
	push norm
	push f_str
	call printf
	add ESP, 8

	ret		; Get outta harlem
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END exit
