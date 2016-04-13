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

%define PVAI 1
%define PVP 2
%define AIVAI 3

SECTION .bss
	input:		resd 1			; User inputed space
	playSymb:	resd 1			; The Player's symbol
	compSymb:	resd 1			; The Computer's symbol
	mode:		resd 1			; Game mode (PVAI, PVP, or AIVAI)   

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
	norm:		db 27, "(B", 10, 0		; Normal Character Set
	reset:		db 27, "(B", 27, "[40m", 0	; Normal character set and background
	clearScreen:	db 27, "[H", 27, "[2J", 0
	X:		db "X", 0		; X
	O:		db "O", 0		; Y
	E:		db " ", 0		; Space
	a:		db "a", 0
	pName:		db "Dave"		; Player/Player1/Computer1 Name
			times 100-$+pName db 0	; Reserve enough room in pName for 100 characters total
	cName:		db "Hal"		; Computer/Player2/Computer2 Name
			times 100-$+cName db 0	; Reserve enough room in cName for 100 characters total
	m_badSpot:	db "Space already occupied", 10, 0 ; User chose occupied spot in board
	newline:	db 10, 0		; newline character
	m_tieWin:	db "Tie game!", 10, 0	; Tie Game Message
	m_compWin:	db "The Computer Won, of course!", 10, 0 ; Computer Win Message
	m_playWin:	db "Crap, the player won...", 10, 0	; Player win message
	m_here:		db "HERE", 10, 0
	m_currWins:	db "You won ", 0
	m_currLoss:	db "You lost ", 0
	m_currTies:	db "You tied ", 0
	m_totGames:	db " out of ", 0
	m_games:	db " games", 10, 0
	m_playerMove:	db ", please make a move. ", 0	; The player's turn
	m_compMove:	db " is making a move.", 0		; The computer's turn
	m_characterIs:	db " is ", 0
	m_promptName:	db "Please enter your name : ", 0	; Prompt the only player for his name
	m_prompt1stName:db "Please enter player 1's name: ", 0	; Prompt player 1 for his name
	m_prompt2ndName:db "Please enter player 2's name: ", 0	; Prompt player 2 for his name
	m_promptMode:	db "Please select a game mode by entering the corresponing number: ", 10,
			db "1) Play against an AI", 10
			db "2) Play against another player", 10
			db "3) Watch two AI duke it out", 10, 0
	currentSymb:	dd X_VAL		; Current playing symbol
	wins:		dd 0			; Player wins
	loss:		dd 0			; Player loss
	ties:		dd 0			; Ties

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CELL ONE ESCAPES
	cell1Start:	db 27, "[3;2H", 0
	cell1_2:	db 27, "[4;2H", 0
	cell1_3:	db 27, "[5;2H", 0
	cell1_4:	db 27, "[6;2H", 0
	cell1_5:	db 27, "[7;2H", 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CELL TWO ESCAPES
	cell2Start:	db 27, "[3;7H", 0
	cell2_2:	db 27, "[4;7H", 0
	cell2_3:	db 27, "[5;7H", 0
	cell2_4:	db 27, "[6;7H", 0
	cell2_5:	db 27, "[7;7H", 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CELL THREE ESCAPES
	cell3Start:	db 27, "[3;12H", 0
	cell3_2:	db 27, "[4;12H", 0
	cell3_3:	db 27, "[5;12H", 0
	cell3_4:	db 27, "[6;12H", 0
	cell3_5:	db 27, "[7;12H", 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CELL FOUR ESCAPES
	cell4Start:	db 27, "[8;2H", 0
	cell4_2:	db 27, "[9;2H", 0
	cell4_3:	db 27, "[10;2H", 0
	cell4_4:	db 27, "[11;2H", 0
	cell4_5:	db 27, "[12;2H", 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CELL FIVE ESCAPES
	cell5Start:	db 27, "[8;7H", 0
	cell5_2:	db 27, "[9;7H", 0
	cell5_3:	db 27, "[10;7H", 0
	cell5_4:	db 27, "[11;7H", 0
	cell5_5:	db 27, "[12;7H", 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CELL SIX ESCAPES
	cell6Start:	db 27, "[8;12H", 0
	cell6_2:	db 27, "[9;12H", 0
	cell6_3:	db 27, "[10;12H", 0
	cell6_4:	db 27, "[11;12H", 0
	cell6_5:	db 27, "[12;12H", 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CELL SEVEN ESCAPES
	cell7Start:	db 27, "[13;2H", 0
	cell7_2:	db 27, "[14;2H", 0
	cell7_3:	db 27, "[15;2H", 0
	cell7_4:	db 27, "[16;2H", 0
	cell7_5:	db 27, "[17;2H", 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CELL EIGHT ESCAPES
	cell8Start:	db 27, "[13;7H", 0
	cell8_2:	db 27, "[14;7H", 0
	cell8_3:	db 27, "[15;7H", 0
	cell8_4:	db 27, "[16;7H", 0
	cell8_5:	db 27, "[17;7H", 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CELL NINE ESCAPES
	cell9Start:	db 27, "[13;12H", 0
	cell9_2:	db 27, "[14;12H", 0
	cell9_3:	db 27, "[15;12H", 0
	cell9_4:	db 27, "[16;12H", 0
	cell9_5:	db 27, "[17;12H", 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LEFT WALL ESCAPES
	lft1:		db 27, "[3;1H", 0
	lft2:		db 27, "[4;1H", 0
	lft3:		db 27, "[5;1H", 0
	lft4:		db 27, "[6;1H", 0
	lft5:		db 27, "[7;1H", 0
	lft6:		db 27, "[8;1H", 0
	lft7:		db 27, "[9;1H", 0
	lft8:		db 27, "[10;1H", 0
	lft9:		db 27, "[11;1H", 0
	lft10:		db 27, "[12;1H", 0
	lft11:		db 27, "[13;1H", 0
	lft12:		db 27, "[14;1H", 0
	lft13:		db 27, "[15;1H", 0
	lft14:		db 27, "[16;1H", 0
	lft15:		db 27, "[17;1H", 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END CELL ESCAPES
	solidRow:	db "aaaaa", 0
	xRow1:		db "\  /a", 0
	xRow2:		db " \/ a", 0
	xRow3:		db " /\ a", 0
	xRow4:		db "/  \a", 0
	oRow1:		db " ff a", 0
	oRow2:		db "f  fa", 0
	oRow3:		db "f  fa", 0
	oRow4:		db " ff a", 0
	ePrint:		db "    a", 0

SECTION .text
	global main
	extern scanf
	extern printf
	extern time
	extern rand
	extern srand

main:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN main
	push white		; Set the foreground to white
	call printf
	add ESP, 4

	push black		; Set text to black
	call printf
	add ESP, 4

	call choosePlayers	; choose which player goes first (also sets random seed for program)

	call getMode

	mov EAX, [mode]

	cmp EAX, PVAI
	je pvaiInit
	cmp EAX, PVP
	je pvpInit
	cmp EAX, AIVAI
	je aivailoop
	;jmp to get mode again

pvaiInit:			; Initialize pvai cycle
	call getName
pvailoop:			; Player versus AI loop

	call prettyPrint		; print original empty board

.gameloop:
	mov EAX, [currentSymb]	;put current symbol in EAX
	mov EBX, [playSymb]	;put player's symbol in EBX
	cmp EAX, EBX		;check if player's turn or computer's turn
	je  .player
	jmp .computer

.player:
	call getInput		; get user input for move placement
	jmp .bottom

.computer:
	;currently the same as .player since no placement algorithm
	call getInput		; get user input for move placement
	jmp .bottom
	
.bottom:
	call switchTurn		; switch who's turn it is
	call prettyPrint
	call calcWin		; returns 0 if game is still going; 1,2,or 3 if ended
	cmp EAX, 0		; if game is still going, 
	je .gameloop		; continue game loop
	jmp exit		; For now, exit	

	call endgame		; something to update scores, reset board, etc.
	;call playAgain		; maybe? return value of 0 to continue? else to quit?
	call switchPlayers	; switch players' symbols
	jmp pvailoop		; start new game

.exit:
	;call printScores	; a method to print final scores before exiting entirely
	jmp exit		; exit program

aivailoop:			; AI versus AI game
	call prettyPrint		; print original empty board

.gameloop:
	mov EAX, [currentSymb]	;put current symbol in EAX
	mov EBX, [playSymb]	;put player's symbol in EBX
	cmp EAX, EBX		;check if player's turn or computer's turn
	je  .player
	jmp .computer

.player:
	call getInput		; get user input for move placement
	jmp .bottom

.computer:
	;currently the same as .player since no placement algorithm
	call getInput		; get user input for move placement
	jmp .bottom
	
.bottom:
	call switchTurn		; Switch who's turn it is
	call prettyPrint
	call calcWin		; returns 0 if game is still going; 1,2,or 3 if ended
	cmp EAX, 0		; if game is still going, 
	je .gameloop		; continue game loop
	jmp exit		; For now, exit	

	call endgame		; something to update scores, reset board, etc.
	;call playAgain		; maybe? return value of 0 to continue? else to quit?
	call switchPlayers	; switch players' symbols
	jmp aivailoop		; start new game

.exit:
	;call printScores	; a method to print final scores before exiting entirely
	jmp exit		; exit program

pvpInit:
	call getName
	call getOtherName
pvploop:			; Player versus player game
	call prettyPrint	; print original empty board

.gameloop:
	mov EAX, [currentSymb]	;put current symbol in EAX
	mov EBX, [playSymb]	;put player's symbol in EBX
	cmp EAX, EBX		;check if player's turn or computer's turn
	je  .player
	jmp .computer

.player:
	call getInput		; get user input for move placement
	jmp .bottom

.computer:
	;currently the same as .player since no placement algorithm
	call getInput		; get user input for move placement
	jmp .bottom
	
.bottom:
	call switchTurn		; Switch who's turn it is
	call prettyPrint
	call calcWin		; returns 0 if game is still going; 1,2,or 3 if ended
	cmp EAX, 0		; if game is still going, 
	je .gameloop		; continue game loop

	call endgame		; something to update scores, reset board, etc.
	;call playAgain		; maybe? return value of 0 to continue? else to quit?
	;call switchPlayers	; switch players' symbols
	;jmp pvploop		; start new game
	jmp .exit
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
	jl	.fail		; if not, print m_badBounds
	cmp EAX, 9		; make sure user's input is less than or equal to 9
	jg	.fail		; if not, print m_badBounds

	call setSpot		; if input is within bounds, attempt to set space

	jmp .end		; return
.fail:
	call prettyPrint

	push m_badBounds	; push out of bounds warning string to stack
	call printf		; print warning to user
	add ESP, 4		; adjust stack pointer
	
	jmp getInput		; Go to top of function

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
	call prettyPrint

	push m_badSpot		; move warning string that space is occupied to stack
	call printf		; print warning to user
	add ESP, 4		; adjust stack pointer

	call getInput		; Get input again

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
	cmp EAX, 1		; If O won, EAX will be 1
	je .OWin

	call checkTie
	cmp EAX, 1		; If there are no empty space, EAX will be 1
	je .tie
	jmp .noWin		; Else there's no endgame yet
	 
.XWin:				; If X won
	mov EAX, [playSymb]	; Put the player's symbol in EAX
	cmp EAX, X_VAL		; See if the player won
	je .playWin		; If so, go to player win
	jmp .compWin		; Else go to computer win

.OWin:				; If O won
	mov EAX, [playSymb]	; Put the player's symbol in EAX
	cmp EAX, O_VAL		; See if the player won
	je .playWin		; if so, go to player win
	jmp .compWin		; Else go to computer win

.compWin:			; if the computer won
	push m_compWin		; Say it
	call printf
	add ESP, 4

	mov EAX, 1		; Return 1
	jmp .end

.playWin:			; if the player won
	push m_playWin		; Print player message
	call printf	
	add ESP, 4
	
	mov EAX, 2		; Return 2
	jmp .end

.tie:
	push m_tieWin		; If it is a tie game
	call printf		; Print tie message
	add ESP, 4
	
	mov EAX, 3		; Return 3
	jmp .end

.noWin:
	push newline		; Print empty newline
	call printf		
	add ESP, 4	

	xor EAX, EAX		; Return 0	
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
	jne .rlDi

	mov EAX, [board + 32]	; Middle right cell
	cmp EAX, EBX
	jne .rlDi
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
	xor ECX, ECX		; Zero out ECX

.top:
	cmp ECX, 9
	je .end
	
	mov EAX, ECX		; Put ECX in EAX
	xor EDX, EDX		; Zero out EDX
	imul EAX, 4		; Multiply by size of DWORD

	mov EBX, [board + EAX]	; Put spot in array into EBX
	
	cmp EBX, 0		; Check if that space is empty
	je .empty		; If so, jump to that exit
	jmp .bottom		; Else continue on with the loop

.bottom:
	inc ECX			; Increment ECX
	jmp .top		; Jump to the top of the loop

.empty:				; If there's an esmpty space
	xor EAX, EAX		; Return 0
	ret
.end:				; There is no moer empty space
	mov EAX, 1		; Return 1
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END checkTie

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

endgame:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; START endgame

	cmp EAX, 1		; See if the computer won
	je .playerLost		
	cmp EAX, 2		; See if the player won
	je .playerWon
	jmp .tie		; Otherwise there was a tie

.playerWon:			; If the player won
	mov EAX, [wins]		; Move wins into EAX
	inc EAX			; Increment EAX
	mov [wins], EAX		; Store the wins
	jmp .out		; Jump out of if's

.playerLost:			; If the player lost
	mov EAX, [loss]		; Move loss into EAX
	inc EAX			; Increment losses
	mov [loss], EAX		; Store the loss
	jmp .out		; Jump out of if's

.tie:				; If there was a tie
	mov EAX, [ties]		; Move ties into EAX
	inc EAX			; Increment EAX
	mov [ties], EAX		; Store ties
	jmp .out		; Jump out of loop

.out:				; Outside of if's
	call reportStatistics	; Report statistics

	xor ECX, ECX		; Clear out ECX
.top:				; Top of loop
	cmp ECX, 9		; If ECX is < 8
	je .end			; Exit function
	
	mov EAX, ECX		; Stic ECX into EAX
	xor EDX, EDX		; Clear out EDX

	imul EAX, 4		; Multiply by the size of DWORD
	mov [board + EAX], DWORD 0	; Clear out that spot in the board

	inc ECX			; Increment ECX
	jmp .top		; Jump to top of loop

.end: ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END endgame

reportStatistics:;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN reportStatistics
	;;;;;;;;;;;;;;;;;;;;;;;;; Print wins
	push m_currWins		; Push message to stack
	call printf		; Call printf
	add ESP, 4		; Adjust stack pointer
	
	mov EAX, [wins]		; Stick num of wins in EAX
	push EAX		; Push EAX to stack
	push f_int		; Push integer format
	call printf		; Call printf
	add ESP, 8		; Adjust stack pointer

	call totalGames		; totalGames prints rest of message

	;;;;;;;;;;;;;;;;;;;;;;;;; Print loss
	push m_currLoss		; Push current loss message
	call printf		; Call printf
	add ESP, 4		; Adjust stack pointer

	mov EAX, [loss]		; Stick loss number in EAX
	push EAX		; Push EAX to stack
	push f_int		; Push integer format
	call printf		; Print it all out
	add ESP, 8		; Adjust stack pointer

	call totalGames		; Print rest of message

	;;;;;;;;;;;;;;;;;;;;;;;;; Print ties
	push m_currTies		; Push tie message
	call printf		; Print it out
	add ESP, 4		; Adjust stack pointer

	mov EAX, [ties]		; Move ties into EAX
	push EAX		; Push EAX to stack
	push f_int		; Push integer format
	call printf		; Print it out
	add ESP, 8		; Adjust stack pointer
	
	call totalGames		; Print the rest of message

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END reportStatistics

totalGames:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN totalGames
	push m_totGames		; Push total games messaage onto stack
	call printf		; Print it
	add ESP, 4		; Adjust stack pointer

	mov EAX, [wins]		; EAX = player wins
	mov EBX, [loss]		; EBX = player loss
	mov ECX, [ties]		; ECX = ties

	add EAX, EBX		; EAX += EBX
	add EAX, ECX		; EAX += ECX

	push EAX		; Push EAX
	push f_int		; Push integer format
	call printf		; Call printf
	add ESP, 8		; Clear off stack

	push m_games		; Push the games message
	call printf		; Print it
	add ESP, 4		; Clear out stack

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END totalGames

prettyPrint:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN prettyPrint
	push clearScreen
	call printf
	add ESP, 4

	call gameInfo

	push alt
	call printf
	add ESP, 4

	call drawCell1
	call drawCell2
	call drawCell3
	call drawCell4
	call drawCell5
	call drawCell6
	call drawCell7
	call drawCell8
	call drawCell9

	call drawBorders

	push norm
	call printf
	add ESP, 4

	call turnInfo

.exit:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END prettyPrint

drawCell1:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN drawCell1
	mov EAX, [board]
	cmp EAX, X_VAL
	je .Xprint
	cmp EAX, O_VAL
	je .Oprint
	jmp .EPrint

.Xprint:
	push cell1Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell1_2
	call printf
	add ESP, 4

	push xRow1
	call printf
	add ESP, 4

	push cell1_3
	call printf
	add ESP, 4

	push xRow2
	call printf
	add ESP, 4

	push cell1_4
	call printf
	add ESP, 4

	push xRow3
	call printf
	add ESP, 4

	push cell1_5
	call printf
	add ESP, 4

	push xRow4
	call printf
	add ESP, 4

	ret
.Oprint:
	push cell1Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell1_2
	call printf
	add ESP, 4

	push oRow1
	call printf
	add ESP, 4

	push cell1_3
	call printf
	add ESP, 4

	push oRow2
	call printf
	add ESP, 4

	push cell1_4
	call printf
	add ESP, 4

	push oRow3
	call printf
	add ESP, 4

	push cell1_5
	call printf
	add ESP, 4

	push oRow4
	call printf
	add ESP, 4

	ret
.EPrint:
	push cell1Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell1_2
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell1_3
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell1_4
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell1_5
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END drawCell1

drawCell2:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN drawCell2
	mov EAX, [board + 4]
	cmp EAX, X_VAL
	je .Xprint
	cmp EAX, O_VAL
	je .Oprint
	jmp .EPrint

.Xprint:
	push cell2Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell2_2
	call printf
	add ESP, 4

	push xRow1
	call printf
	add ESP, 4

	push cell2_3
	call printf
	add ESP, 4

	push xRow2
	call printf
	add ESP, 4

	push cell2_4
	call printf
	add ESP, 4

	push xRow3
	call printf
	add ESP, 4

	push cell2_5
	call printf
	add ESP, 4

	push xRow4
	call printf
	add ESP, 4

	ret
.Oprint:
	push cell2Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell2_2
	call printf
	add ESP, 4

	push oRow1
	call printf
	add ESP, 4

	push cell2_3
	call printf
	add ESP, 4

	push oRow2
	call printf
	add ESP, 4

	push cell2_4
	call printf
	add ESP, 4

	push oRow3
	call printf
	add ESP, 4

	push cell2_5
	call printf
	add ESP, 4

	push oRow4
	call printf
	add ESP, 4

	ret
.EPrint:
	push cell2Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell2_2
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell2_3
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell2_4
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell2_5
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END drawCell2

drawCell3:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN drawCell3
	mov EAX, [board + 8]
	cmp EAX, X_VAL
	je .Xprint
	cmp EAX, O_VAL
	je .Oprint
	jmp .EPrint

.Xprint:
	push cell3Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell3_2
	call printf
	add ESP, 4

	push xRow1
	call printf
	add ESP, 4

	push cell3_3
	call printf
	add ESP, 4

	push xRow2
	call printf
	add ESP, 4

	push cell3_4
	call printf
	add ESP, 4

	push xRow3
	call printf
	add ESP, 4

	push cell3_5
	call printf
	add ESP, 4

	push xRow4
	call printf
	add ESP, 4

	ret
.Oprint:
	push cell3Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell3_2
	call printf
	add ESP, 4

	push oRow1
	call printf
	add ESP, 4

	push cell3_3
	call printf
	add ESP, 4

	push oRow2
	call printf
	add ESP, 4

	push cell3_4
	call printf
	add ESP, 4

	push oRow3
	call printf
	add ESP, 4

	push cell3_5
	call printf
	add ESP, 4

	push oRow4
	call printf
	add ESP, 4

	ret
.EPrint:
	push cell3Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell3_2
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell3_3
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell3_4
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell3_5
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END drawCell3

drawCell4:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN drawCell4
	mov EAX, [board + 12]
	cmp EAX, X_VAL
	je .Xprint
	cmp EAX, O_VAL
	je .Oprint
	jmp .EPrint

.Xprint:
	push cell4Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell4_2
	call printf
	add ESP, 4

	push xRow1
	call printf
	add ESP, 4

	push cell4_3
	call printf
	add ESP, 4

	push xRow2
	call printf
	add ESP, 4

	push cell4_4
	call printf
	add ESP, 4

	push xRow3
	call printf
	add ESP, 4

	push cell4_5
	call printf
	add ESP, 4

	push xRow4
	call printf
	add ESP, 4

	ret
.Oprint:
	push cell4Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell4_2
	call printf
	add ESP, 4

	push oRow1
	call printf
	add ESP, 4

	push cell4_3
	call printf
	add ESP, 4

	push oRow2
	call printf
	add ESP, 4

	push cell4_4
	call printf
	add ESP, 4

	push oRow3
	call printf
	add ESP, 4

	push cell4_5
	call printf
	add ESP, 4

	push oRow4
	call printf
	add ESP, 4

	ret
.EPrint:
	push cell4Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell4_2
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell4_3
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell4_4
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell4_5
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END drawCell4

drawCell5:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN drawCell5
	mov EAX, [board + 16]
	cmp EAX, X_VAL
	je .Xprint
	cmp EAX, O_VAL
	je .Oprint
	jmp .EPrint

.Xprint:
	push cell5Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell5_2
	call printf
	add ESP, 4

	push xRow1
	call printf
	add ESP, 4

	push cell5_3
	call printf
	add ESP, 4

	push xRow2
	call printf
	add ESP, 4

	push cell5_4
	call printf
	add ESP, 4

	push xRow3
	call printf
	add ESP, 4

	push cell5_5
	call printf
	add ESP, 4

	push xRow4
	call printf
	add ESP, 4

	ret
.Oprint:
	push cell5Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell5_2
	call printf
	add ESP, 4

	push oRow1
	call printf
	add ESP, 4

	push cell5_3
	call printf
	add ESP, 4

	push oRow2
	call printf
	add ESP, 4

	push cell5_4
	call printf
	add ESP, 4

	push oRow3
	call printf
	add ESP, 4

	push cell5_5
	call printf
	add ESP, 4

	push oRow4
	call printf
	add ESP, 4

	ret
.EPrint:
	push cell5Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell5_2
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell5_3
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell5_4
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell5_5
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END drawCell3

drawCell6:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN drawCell6
	mov EAX, [board + 20]
	cmp EAX, X_VAL
	je .Xprint
	cmp EAX, O_VAL
	je .Oprint
	jmp .EPrint

.Xprint:
	push cell6Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell6_2
	call printf
	add ESP, 4

	push xRow1
	call printf
	add ESP, 4

	push cell6_3
	call printf
	add ESP, 4

	push xRow2
	call printf
	add ESP, 4

	push cell6_4
	call printf
	add ESP, 4

	push xRow3
	call printf
	add ESP, 4

	push cell6_5
	call printf
	add ESP, 4

	push xRow4
	call printf
	add ESP, 4

	ret
.Oprint:
	push cell6Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell6_2
	call printf
	add ESP, 4

	push oRow1
	call printf
	add ESP, 4

	push cell6_3
	call printf
	add ESP, 4

	push oRow2
	call printf
	add ESP, 4

	push cell6_4
	call printf
	add ESP, 4

	push oRow3
	call printf
	add ESP, 4

	push cell6_5
	call printf
	add ESP, 4

	push oRow4
	call printf
	add ESP, 4

	ret
.EPrint:
	push cell6Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell6_2
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell6_3
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell6_4
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell6_5
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END drawCell6

drawCell7:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN drawCell7
	mov EAX, [board + 24]
	cmp EAX, X_VAL
	je .Xprint
	cmp EAX, O_VAL
	je .Oprint
	jmp .EPrint

.Xprint:
	push cell7Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell7_2
	call printf
	add ESP, 4

	push xRow1
	call printf
	add ESP, 4

	push cell7_3
	call printf
	add ESP, 4

	push xRow2
	call printf
	add ESP, 4

	push cell7_4
	call printf
	add ESP, 4

	push xRow3
	call printf
	add ESP, 4

	push cell7_5
	call printf
	add ESP, 4

	push xRow4
	call printf
	add ESP, 4

	ret
.Oprint:
	push cell7Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell7_2
	call printf
	add ESP, 4

	push oRow1
	call printf
	add ESP, 4

	push cell7_3
	call printf
	add ESP, 4

	push oRow2
	call printf
	add ESP, 4

	push cell7_4
	call printf
	add ESP, 4

	push oRow3
	call printf
	add ESP, 4

	push cell7_5
	call printf
	add ESP, 4

	push oRow4
	call printf
	add ESP, 4

	ret
.EPrint:
	push cell7Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell7_2
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell7_3
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell7_4
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell7_5
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END drawCell7

drawCell8:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN drawCell8
	mov EAX, [board + 28]
	cmp EAX, X_VAL
	je .Xprint
	cmp EAX, O_VAL
	je .Oprint
	jmp .EPrint

.Xprint:
	push cell8Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell8_2
	call printf
	add ESP, 4

	push xRow1
	call printf
	add ESP, 4

	push cell8_3
	call printf
	add ESP, 4

	push xRow2
	call printf
	add ESP, 4

	push cell8_4
	call printf
	add ESP, 4

	push xRow3
	call printf
	add ESP, 4

	push cell8_5
	call printf
	add ESP, 4

	push xRow4
	call printf
	add ESP, 4

	ret
.Oprint:
	push cell8Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell8_2
	call printf
	add ESP, 4

	push oRow1
	call printf
	add ESP, 4

	push cell8_3
	call printf
	add ESP, 4

	push oRow2
	call printf
	add ESP, 4

	push cell8_4
	call printf
	add ESP, 4

	push oRow3
	call printf
	add ESP, 4

	push cell8_5
	call printf
	add ESP, 4

	push oRow4
	call printf
	add ESP, 4

	ret
.EPrint:
	push cell8Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell8_2
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell8_3
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell8_4
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell8_5
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END drawCell8

drawCell9:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN drawCell9
	mov EAX, [board + 32]
	cmp EAX, X_VAL
	je .Xprint
	cmp EAX, O_VAL
	je .Oprint
	jmp .EPrint

.Xprint:
	push cell9Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell9_2
	call printf
	add ESP, 4

	push xRow1
	call printf
	add ESP, 4

	push cell9_3
	call printf
	add ESP, 4

	push xRow2
	call printf
	add ESP, 4

	push cell9_4
	call printf
	add ESP, 4

	push xRow3
	call printf
	add ESP, 4

	push cell9_5
	call printf
	add ESP, 4

	push xRow4
	call printf
	add ESP, 4

	ret
.Oprint:
	push cell9Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell9_2
	call printf
	add ESP, 4

	push oRow1
	call printf
	add ESP, 4

	push cell9_3
	call printf
	add ESP, 4

	push oRow2
	call printf
	add ESP, 4

	push cell9_4
	call printf
	add ESP, 4

	push oRow3
	call printf
	add ESP, 4

	push cell9_5
	call printf
	add ESP, 4

	push oRow4
	call printf
	add ESP, 4

	ret
.EPrint:
	push cell9Start
	call printf
	add ESP, 4

	push solidRow
	call printf
	add ESP, 4

	push cell9_2
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell9_3
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell9_4
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	push cell9_5
	call printf
	add ESP, 4

	push ePrint
	call printf
	add ESP, 4

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END drawCell9

drawBorders:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN drawBorders
	push cell1Start
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft1
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft2
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft3
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft4
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft5
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft6
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft7
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft8
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft9
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft10
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft11
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft12
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft13
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft14
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push lft15
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push newline
	call printf
	add ESP, 4

	push a
	call printf
	add ESP, 4

	push solidRow
	call printf
	call printf
	call printf
	add ESP, 4

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END drawBorders 

turnInfo:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN pvaiTurnInfo

	mov EAX, [currentSymb]
	cmp EAX, [playSymb]
	je .playerTurn
	jmp .compTurn

.playerTurn:			; It is the player's turn to make a move
	push pName
	call printf
	add ESP, 4
	jmp .pmodePrint

.compTurn:			; It is the computers turn to make a move
	push cName
	call printf
	add ESP, 4
	jmp .cmodePrint	

.pmodePrint:			; First player's prompt
	mov EAX, [mode]
	cmp EAX, AIVAI		; The only wat this is computer is if mode is AIVAI
	je .comp
	jmp .prompt		; Else it's human

.cmodePrint:			; Second player's promp
	mov EAX, [mode]
	cmp EAX, PVP		; The only way this is a human is if mode is PVP
	je .prompt
	jmp .comp		; Otherwise it's AI

.prompt:
	push m_playerMove
	call printf
	add ESP, 4

	jmp .exit

.comp:
	push m_compMove
	call printf
	add ESP, 4
	jmp .exit

.exit:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END turnInfo

gameInfo:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN gameInfo
	mov EAX, [playSymb]
	cmp EAX, X_VAL
	je .p1isX
	jmp .p1isO

.p1isX:
	push pName
	call printf
	add ESP, 4

	push m_characterIs
	call printf
	add ESP, 4

	push X
	call printf
	add ESP, 4

	push newline
	call printf
	add ESP, 4

	push cName
	call printf
	add ESP, 4

	push m_characterIs
	call printf
	add ESP, 4

	push O
	call printf
	add ESP, 4

	push newline
	call printf
	add ESP, 4

	ret
.p1isO:
	push pName
	call printf
	add ESP, 4

	push m_characterIs
	call printf
	add ESP, 4

	push O
	call printf
	add ESP, 4

	push newline
	call printf
	add ESP, 4

	push cName
	call printf
	add ESP, 4

	push m_characterIs
	call printf
	add ESP, 4

	push X
	call printf
	add ESP, 4

	push newline
	call printf
	add ESP, 4

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END gameInfo

getName:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN getName
	push clearScreen
	call printf
	add ESP, 4

	mov EAX, [mode]
	cmp EAX, PVP
	je .2ps

.1p:
	push m_promptName
	call printf
	add ESP, 4
	jmp .getTheName

.2ps:
	push m_prompt1stName
	call printf
	add ESP, 4
	jmp .getTheName

.getTheName:
	push pName
	push f_str
	call scanf
	add ESP, 8

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END getName

getOtherName:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN getOtherName
	push clearScreen
	call printf
	add ESP, 4

	push m_prompt2ndName
	call printf
	add ESP, 4

	push cName
	push f_str
	call scanf
	add ESP, 8

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END getOtherName

getMode:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN getMode
	push clearScreen
	call printf
	add ESP, 4

	push m_promptMode
	call printf
	add ESP, 4

	push mode
	push f_int
	call scanf
	add ESP, 8

	mov EAX, [mode]
	cmp EAX, PVAI
	jl .fail
	cmp EAX, AIVAI
	jg .fail
	jmp .exit

.fail:
	call getMode

.exit	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END getMode

debugHERE:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN Debug here
	pushad			; Store all registers
	push m_here		; Push message onto stack
	call printf		; Print here
	add ESP, 4		; Adjust stack pointer
	popad			; Restore all registers
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END debugHERE

exit:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN exit
	push norm		; push normal character set escape character to stack
	push f_str		; push format string for printing a string
	call printf		; no more demon symbols
	add ESP, 8		; adjust stack pointer

	ret			; Get outta harlem
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END exit
