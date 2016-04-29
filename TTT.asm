; Jeremy Greenburg and Cody Robertson
; Tic Tac Toe
; Plays ye old guessing game with the user
; nasm -f elf32 TTT.asm && gcc -m32 TTT.o -o TTT
; DEBUG:
; nasm -f elf32 -l TTT.lst TTT.asm && gcc -m32 -o TTT TTT.o
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
	winner:		resd 1			; 1 If player won, 0 if Comp won
	mode:		resd 1			; Game mode (PVAI, PVP, or AIVAI)   

SECTION .data
	m_badBounds:	db "ERROR: Invalid space", 10, 0 ;user chose a space that is not 1-9
	board:		times 9 dd 0	;legit board
	f_int: 		db "%d", 0 		; Integer format
	f_strn:		db "%s", 10, 0 		; String format w newline
	f_str:		db "%s", 0		; String format
	f_char:		db "%c", 0		; Character format
	white:		db 27, "[47m", 0	; White background
	red:		db 27, "[31m", 0	; Red foreground
	blue:		db 27, "[34m", 0	; Blue foreground
	black:		db 27, "[30m", 0	; Black foreground
	alt:		db 27, "(0", 0		; Alternate character set
	norm:		db 27, "(B", 0		; Normal Character Set
	reset:		db 27, "(B", 27, "[40m", 0	; Normal character set and background
	clearScreen:	db 27, "[H", 27, "[2J", 0
	X:		db "X", 0		; X
	O:		db "O", 0		; Y
	E:		db " ", 0		; Space
	a:		db "a", 0		; a
	pName:		db "Dave", 0		; Player/Player1/Computer1 Name
			times 100-$+pName db 0	; Reserve enough room in pName for 100 characters total
	cName:		db "Hal", 0		; Computer/Player2/Computer2 Name
			times 100-$+cName db 0	; Reserve enough room in cName for 100 characters total
	m_badSpot:	db "Space already occupied", 10, 0 ; User chose occupied spot in board
	newline:	db 10, 0		; newline character
	m_tieWin:	db "Tie game!", 10, 0	; Tie Game Message
	m_winner:	db " is the winner!", 10, 0		; Is the winner message
	m_anyKey:	db "Press enter to continue. ", 0	; Press enter to continue
	m_currWins:	db " won ", 0				; x Won y games
	m_currTies:	db "Games tied: ", 0			; Games tied message
	m_totGames:	db " out of ", 0			; y games out of total games
	m_games:	db " games", 10, 0			; Games
	m_playerMove:	db ", please make a move. ", 0		; The player's turn
	m_compMove:	db " is making a move. ", 0		; The computer's turn
	m_characterIs:	db " is ", 0				; is
	m_promptName:	db "Please enter your name: ", 0	; Prompt the only player for his name
	m_prompt1stName:db "Please enter player 1's name: ", 0	; Prompt player 1 for his name
	m_prompt2ndName:db "Please enter player 2's name: ", 0	; Prompt player 2 for his name
	m_promptMode:	db "Please select a game mode by entering the corresponing number: ", 10
			db "1) Play against an AI", 10
			db "2) Play against another player", 10
			db "3) Watch two AI duke it out", 10
			db ": ", 0 
	m_playAgain:	db "Would you like to play again? ", 10
			db "1 - Yes", 10
			db "2 - No", 10, 0
	currentSymb:	dd X_VAL		; Current playing symbol
	wins:		dd 0			; Player wins
	loss:		dd 0			; Player loss
	ties:		dd 0			; Ties
	debug:		db "Not Found", 10, 0
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
	solidRow:	db "aaaaa", 0		; A solid row
	xRow1:		db "\  /a", 0		; First x row
	xRow2:		db " \/ a", 0		; Second x row
	xRow3:		db " /\ a", 0		; Third x row
	xRow4:		db "/  \a", 0		; Fourth x row
	oRow1:		db " ff a", 0		; First circle row
	oRow2:		db "f  fa", 0		; Second circle row
	oRow3:		db "f  fa", 0		; Third circle row
	oRow4:		db " ff a", 0		; Fourth circle row
	ePrint:		db "    a", 0		; Printing for empty cell
	enemySymb:	dd O_VAL		; Not playing symbol
	firstTurn:	dd 0			; 0 if first turn, 1 if not

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

	push norm		; Normal Character set (just in case)
	call printf
	add ESP, 4

	call choosePlayers	; choose which player goes first (also sets random seed for program)

	call getMode		; Prompts the player for game type

	mov EAX, [mode]		; Move the answer into EAX

	cmp EAX, PVAI		; See if they chose pvai
	je pvaiInit		; Start pvai game
	cmp EAX, PVP		; See if they cose pvp
	je pvpInit		; Start pvp game
	cmp EAX, AIVAI		; See if they chose aivai game
	je aivailoop		; Start aivai game
	;jmp to get mode again

pvaiInit:			; Initialize pvai cycle
	call getName		; Get the player's anme
pvailoop:			; Player versus AI loop
	
	call gameInfo		; Print who is who
	call prettyPrint	; print original empty board

.gameloop:			; Start of the game loop
	mov EAX, [currentSymb]	;put current symbol in EAX
	mov EBX, [playSymb]	;put player's symbol in EBX
	cmp EAX, EBX		;check if player's turn or computer's turn
	je  .player		
	jmp .computer

.player:			; player's turn
	call getInput		; get user input for move placement
	jmp .bottom

.computer:
	call computer		; get user input for move placement
	jmp .bottom
	
.bottom:
	call switchTurn		; switch who's turn it is
	call prettyPrint	; Print board again
	call calcWin		; returns 0 if game is still going; 1,2,or 3 if ended
	cmp EAX, 0		; if game is still going, 
	je .gameloop		; continue game loop

	call endgame		; something to update scores, reset board, etc.
	cmp EAX, 0		; See if player chose not to continue
	je exit			; If so, exit
	
	call switchPlayers	; switch players' symbols
	jmp pvailoop		; start new game
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END PVAI LOOP

aivailoop:			; AI versus AI game
	call prettyPrint	; print original empty board

.gameloop:
	mov EAX, [currentSymb]	;put current symbol in EAX
	mov EBX, [playSymb]	;put player's symbol in EBX
	cmp EAX, EBX		;check if player's turn or computer's turn
	je  .player
	jmp .computer

.player:
	call computer		; get user input for move placement
	jmp .bottom

.computer:
	call computer		; get user input for move placement
	jmp .bottom
	
.bottom:
	call switchTurn		; Switch who's turn it is
	call gameInfo		; Print who is who
	call prettyPrint	; Print the board
	call calcWin		; returns 0 if game is still going; 1,2,or 3 if ended
	cmp EAX, 0		; if game is still going, 
	je .gameloop		; continue game loop

	call endgame		; something to update scores, reset board, etc.
	cmp EAX, 0
	je exit

	call switchPlayers	; switch players' symbols
	jmp aivailoop		; start new game
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END AIVAI LOOP

pvpInit:
	call getName		; Get player 1's name
	call getOtherName	; Get player 2's name
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
	call getInput		; get user input for move placement
	jmp .bottom
	
.bottom:
	call switchTurn		; Switch who's turn it is
	call prettyPrint
	call calcWin		; returns 0 if game is still going; 1,2,or 3 if ended
	cmp EAX, 0		; if game is still going, 
	je .gameloop		; continue game loop

	call endgame		; something to update scores, reset board, etc.
	cmp EAX, 0
	je exit

	call switchPlayers	; switch players' symbols
	jmp pvploop		; start new game
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END main

getInput:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN getInput
	call turnInfo

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

	push red		; Make foreground red
	call printf
	add ESP, 4

	push m_badBounds	; push out of bounds warning string to stack
	call printf		; print warning to user
	add ESP, 4		; adjust stack pointer

	push black		; Make foreground black
	call printf
	add ESP, 4

	jmp getInput		; Go to top of function

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END getInput

;;Takes EAX as parameter;;
setSpot:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN setSpot
	mov [input], EAX

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

	push red		; Make foreground red
	call printf
	add ESP, 4

	push m_badSpot		; move warning string that space is occupied to stack
	call printf		; print warning to user
	add ESP, 4		; adjust stack pointer

	push black		; Make foreground black
	call printf
	add ESP, 4

	call getInput		; Get input again

.end:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END setSpot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN computer
computer:
	call turnInfo

	xor ECX, ECX
.wait:
	NOP
	inc ECX
	cmp ECX, 1000000000
	jne .wait

.checkFirst:
	mov EAX, [currentSymb]
	cmp EAX, O_VAL
	je  .checkWins	

	mov EAX, [firstTurn]	;check if first turn
	cmp EAX, 0		;if equal, first turn
	je  .first		;calculate random spot to move and go there
	
;if not the first move, check if winning moves exist for computer or player
.checkWins:
	mov EBX, [currentSymb]
	call calcWinMove	;check if computer has winning move	
	cmp EAX, 0		;if 0, no move was found
	jne .makeMove		;if not 0, make the move found

	mov EBX, [enemySymb]
	call calcWinMove	;check if player has winning move
	cmp EAX, 0		;if 0, no move was found
	jne .makeMove		;if not 0, make the move found

;if no winning moves, continue to main algorithm to 
.findMove:
	;main algorithm should go here
	call defend ;protects against adjacent sides
	cmp EAX, 0
	jne .makeMove

	call cornerSide ;protects against corner and opposite sides
	cmp EAX, 0
	jne .makeMove	

	mov EAX, [input]
	cmp EAX, 1
	je .counterCorner
	cmp EAX, 3
	je .counterCorner
	cmp EAX, 7
	je .counterCorner
	cmp EAX, 9
	je .counterCorner
	cmp EAX, 5
	je .counterCenter
	jmp .counterSide

.counterCorner:
	call tryCenter
	cmp EAX, 0
	jne .makeMove

	call tryCorner
	cmp EAX, 0
	jne .makeMove

	call trySide
	jmp .makeMove

.counterCenter:
	call tryCorner
	cmp EAX, 0
	jne .makeMove	
	
	call trySide
	jmp .makeMove

.counterSide:
	mov EAX, [firstTurn]
	cmp EAX, 1
	je .specialSide

	call trySide
	cmp EAX, 0
	jne .makeMove

	call tryCenter
	cmp EAX, 0
	jne .makeMove

	call tryCorner
	jmp .makeMove

.specialSide:
	call tryCenter
	cmp EAX, 0
	jne .makeMove

	call trySide
	cmp EAX, 0
	jne .makeMove

	call tryCorner
	jmp .makeMove

.makeMove:
	call setSpot		;set spot (takes EAX as parameter)
	jmp  .exit
.first:
	call rand		;store random value in EAX
	xor EDX, EDX		;set EDX to 0 to prepare for division
	mov EBX, 9		;willl divide by 9
	div EBX
	mov EAX, EDX		;copy EDX remainder into EAX
	inc EAX			;format EAX for setSpot function
	call setSpot		;sets spot (takes EAX as parameter)

.exit:  
	ret			;exit function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END computer

;;Takes EBX as input.  EBX holds current symbol being checked;;
;;Returns location 1-9 for placement or 0 if no spot found in EDX;;
calcWinMove:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN checkWin

;;;;;;;;;;;;;;;;;BEGIN AREA CHECK;;;;;;;;;;;;;;;;;;
.topRow:
	xor ECX, ECX		; Set spaces counter to 0

.tr1:
	mov EAX, [board]	; Top left cell
	cmp EAX, EBX		; If equal to selected symbol,
	je  .tr2		; move to next

	cmp EAX, 0		; if not 0 either, must be other symbol
	jne .centRow		; begin next area check
	
	mov EDX, 1		; store location of empty space
	inc ECX			; increment space counter

.tr2:	
	mov EAX, [board + 4]	; Top center cell
	cmp EAX, EBX		; If equal to selected symbol,
	je  .tr3		; move to next	

	cmp EAX, 0		; if not 0 either, must be other symbol
	jne .centRow		; begin next area check

	cmp ECX, 0		; find value of space counter
	jg  .centRow		; if greater than 0, move to next check (multiple spaces found)

	mov EDX, 2		; store location of empty space
	inc ECX			; increment space counter

.tr3:
	mov EAX, [board + 8]	; Top right cell
	cmp EAX, EBX		; If equal to selected symbol,
	je  .found		; space has been found previously
	
	cmp EAX, 0		; if not 0 either, must be other symbol
	jne .centRow		; begin next area check

	cmp ECX, 0		; find value of space counter
	jg  .centRow		; if greater than 0, move to next check (multiple spaces found)
	
	mov EDX, 3		; store location of empty space
	inc ECX			; increment space counter

	jmp .found		; space has been found
	
;;;;;;;;;;;;;;;;;;BEGIN NEXT AREA CHECK;;;;;;;;;;;;;;;;;;;;
.centRow:
	xor ECX, ECX		; Set space counter to 0
.cr1:
	mov EAX, [board + 12]	; Middle left cell
	cmp EAX, EBX		; If equal to selected symbol,
	je .cr2			; move to next

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .botRow		; begin next area check

	mov EDX, 4		; store location of empty space
	inc ECX			; increment space counter

.cr2:
	mov EAX, [board + 16]	; Middle center cell
	cmp EAX, EBX		; If equal to selected symbol
	je .cr3			; move to next

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .botRow		; begin next area check
	
	cmp ECX, 0		; find value of space counter
	jg  .botRow		; if greater than 0, move to next cehck (multiple spaces found)

	mov EDX, 5		; store location of empty space
	inc ECX			; increment space counter

.cr3:
	mov EAX, [board + 20]	; Middle right cell
	cmp EAX, EBX		; If equal to selected symbol,
	je .found		; move to area check
	
	cmp EAX, 0		; if not 0 either, must be other symbol
	jne .botRow		; begin next area check

	cmp ECX, 0		; find value of space counter
	jg  .botRow		; if greater than 0, move to next check (multiple spaces found)
	
	mov EDX, 6		; store location of empty space
	inc ECX			; increment space counter

	jmp .found

;;;;;;;;;;;;;;;BEGIN NEXT AREA CHECK;;;;;;;;;;;;;;;;;
.botRow:
	xor ECX, ECX		; set space counter back to 0
.br1:
	mov EAX, [board + 24]	; Bottom left cell
	cmp EAX, EBX		; If equal to selected symbol,
	je .br2			; move to next

	cmp EAX, 0		; if not 0 either, must be other symbol
	jne .leftCol		; begin next area check
	
	mov EDX, 7		; store location of empty space
	inc ECX			; increment space counter
.br2:
	mov EAX, [board + 28]	; Bottom center cell
	cmp EAX, EBX		; If equal to selected symbol,
	je .br3			; move to next

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .leftCol		; begin next area check

	cmp ECX, 0		; find value of space counter
	jg .leftCol		; if greater than 0, move to next check (multiple spaces found)

	mov EDX, 8		; store location of empty space
	inc ECX			; increment space counter
.br3:
	mov EAX, [board + 32]	; Bottom right cell
	cmp EAX, EBX		; If equal to selected symbol,
	je .found		; move to area check
	
	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .leftCol		; begin next area check

	cmp ECX, 0		; Find value of space counter
	jg  .leftCol		; if greater than 0, move to next check (multiple spaces found)

	mov EDX, 9		; store location of empty space
	inc ECX			; increment space counter

	jmp .found

;;;;;;;;;;;;;;;;BEGIN NEXT AREA CHECK;;;;;;;;;;;;;;;
.leftCol:
	xor ECX, ECX		; set space counter back to 0
.lc1:
	mov EAX, [board]	; Top left cell
	cmp EAX, EBX		; If equal to selected symbol,
	je  .lc2		; move to next
	
	cmp EAX, 0		; if not 0 either, must be other symbol
	jne .centCol		; begin next area check

	mov EDX, 1		; store location of empty space
	inc ECX			; increment space counter
.lc2:
	mov EAX, [board + 12]	; Middle left cell
	cmp EAX, EBX		; If equal to selected symbol,
	je  .lc3		; move to next

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .centCol		; begin next area check

	cmp ECX, 0		; find value of space counter
	jg .centCol		; if greater than 0, move to next check (multiple spaces found)

	mov EDX, 4		; store location of empty space
	inc ECX			; increment space counter
.lc3:
	mov EAX, [board + 24]	; Bottom left cell
	cmp EAX, EBX		; If equal to selected symbol
	je .found		; free space has been found

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .centCol		; begin next area check
	
	cmp ECX, 0		; Find value of space counter
	jg  .centCol		; if greater than 0, move to next check (multiple spaces found)
	
	mov EDX, 7		; store location of empty space
	inc ECX			; increment space counter

	jmp .found
	
;;;;;;;;;;;;;;;BEGIN NEXT AREA CHECK;;;;;;;;;;;;;;;;;;
.centCol:
	xor ECX, ECX		; reset space counter
.cc1:
	mov EAX, [board + 4]	; Top Middle cell
	cmp EAX, EBX		; If equal to selected symbol,
	je  .cc2		; move to next

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .rightCol		; begin next area check

	mov EDX, 2		; store location of empty space
	inc ECX
.cc2:
	mov EAX, [board + 16]	; Middle Center cell
	cmp EAX, EBX		; If equal to selected symbol,
	je  .cc3		; move to next

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .rightCol		; begin next area check

	cmp ECX, 0		; Find value of space counter
	jg  .rightCol		; if greater than 0, move to next check (multiple spaces found)

	mov EDX, 5		; store location of empty space
	inc ECX			; increment space counter
.cc3:
	mov EAX, [board + 28]	; Bottom Middle cell
	cmp EAX, EBX		; If equal to selected symbol,
	je  .found		; free space has been found previously

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .rightCol		; begin next area check

	cmp ECX, 0		; Find value of space counter
	jg  .rightCol		; if greater than 0, move to next check (multiple spaces found)
	
	mov EDX, 8		; store location of empty space
	inc ECX			; increment space counter
	
	jmp .found		; return location found

;;;;;;;;;;;;;;;;BEGIN NEXT AREA CHECK;;;;;;;;;;;;;;;;;
.rightCol:
	xor ECX, ECX		; reset space counter
.rc1:
	mov EAX, [board + 8]	; Top Right cell
	cmp EAX, EBX		; If equal to selected symbol,
	je  .rc2		; move to next

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .lrDi		; begin next area check

	mov EDX, 3		; store location of empty space
	inc ECX			; increment space counter
.rc2:
	mov EAX, [board + 20]	; Middle Right cell
	cmp EAX, EBX		; If equal to selected symbol,
	je .rc3			; move to next

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .lrDi		; begin next area check
	
	cmp ECX, 0		; Find value of space counter
	jg  .lrDi		; if greater than 0, move to next check (multiple spaces found)

	mov EDX, 6		; store location of empty space
	inc ECX			; increment space counter

.rc3:
	mov EAX, [board + 32]	; Bottom right cell
	cmp EAX, EBX		; If equal to selected symbol,
	je .found		; space has been found previously

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .lrDi		; begin next area check

	cmp ECX, 0		; find value of space counter
	jg  .lrDi		; if greater than 0, move to next check (multiple spaces found)

	mov EDX, 9		; store location of empty space
	inc ECX			; increment space counter

	jmp .found		; return location found

;;;;;;;;;;;;;;;;BEGIN NEXT AREA CHECK;;;;;;;;;;;;;;;;;
.lrDi:
	xor ECX, ECX		; reset space counter
.lr1:
	mov EAX, [board]	; Top left cell
	cmp EAX, EBX		; If equal to selected symbol,
	je  .lr2		; move to next

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .rlDi		; begin next area check

	mov EDX, 1		; store location of empty space
	inc ECX			; increment space counter
.lr2:
	mov EAX, [board + 16]	; Middle center cell
	cmp EAX, EBX		; If equal to selected symbol,
	je  .lr3		; move to next

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .rlDi		; begin next area check

	cmp ECX, 0		; Find value of space counter
	jg  .rlDi		; if greater than 0, move to next check (multiple spaces found)

	mov EDX, 5		; store location of empty space
	inc ECX			; increment space counter
.lr3:
	mov EAX, [board + 32]	; Bottom right cell
	cmp EAX, EBX		; If equal to selected symbol,
	je  .found		; space has been found previously

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .rlDi		; begin next area check

	cmp ECX, 0		; find value of space counter
	jg  .rlDi		; if greater than 0, move to next check (multiple spaces found)

	mov EDX, 9		; store location of empty space
	inc ECX			; increment space counter
	
	jmp .found		; return location found

;;;;;;;;;;;;;;;;;BEGIN NEXT AREA CHECK;;;;;;;;;;;;;;;;
.rlDi:
	xor ECX, ECX		; reset space counter
.rl1:
	mov EAX, [board + 8]	; Top right cell
	cmp EAX, EBX		; If equal to selected symbol
	je  .rl2		; move to next

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .notFound		; no winning move found

	mov EDX, 3		; store location of empty space
	inc ECX			; increment space counter
.rl2:
	mov EAX, [board + 16]	; Middle center cell
	cmp EAX, EBX		; if equal to selected symbol
	je  .rl3		; move ot next

	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .notFound		; no winning move found

	cmp ECX, 0		; Find value of space counter
	jg  .notFound		; If greater than 0, move to next check (multiple spaces found

	mov EDX, 5		; store location of empty space
	inc ECX			; increment space counter
.rl3:
	mov EAX, [board + 24]	; Bottom left cell
	cmp EAX, EBX		; If equal to selected symbol
	je .found		; free space found previously
	
	cmp EAX, 0		; If not 0 either, must be other symbol
	jne .notFound		; no winning move found

	cmp ECX, 0		; Find value of space counter
	jg  .notFound		; no winning move found (multiple spaces found)

	mov EDX, 7		; store location of empty space
	inc ECX			; increment space counter

	jmp .found		; return free space

;;;;;;;;;;;;;;;;;END CONDITIONS;;;;;;;;;;;;;;;;
.notFound:
	xor EAX, EAX		;return 0 in EAX
	jmp .end
.found:
	mov EAX, EDX		;put return value in EAX
	jmp .end
	
.end:	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END checkWin



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
	mov [winner], DWORD 1

	mov EAX, 1		; Return 1
	jmp .end

.playWin:			; if the player won
	mov [winner], DWORD 2
	
	mov EAX, 2		; Return 2
	jmp .end

.tie:
	mov [winner], DWORD 3	

	mov EAX, 3		; Return 3
	jmp .end

.noWin:
	xor EAX, EAX		; Return 0	
	jmp .end

.end:	
	ret
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
	mov	EBX, [enemySymb]	;load not playing symbol into EBX
	mov	[currentSymb], EBX	;load new playing symbol into currentSymb
	mov	[enemySymb], EAX	;load old playing symbol into enemySymb

	mov	EAX, [firstTurn]	;set firstTurn to 1, since no longer first
	inc	EAX
	mov	[firstTurn], EAX


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
	
	mov	EAX, 0			;set first turn to 0 since it's true now
	mov	[firstTurn], EAX

	mov	EAX, O_VAL		;reset enemy symbol
	mov	[enemySymb], EAX

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END switchPlayers

endgame:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; START endgame

	mov EAX, [winner]

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
	call playAgain		; Decide if we play again
	pushad			; Store result of that
	
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

.end: 
	popad			; Retrieve EAX
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END endgame

reportStatistics:;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN reportStatistics
	push clearScreen
	call printf
	add ESP, 4

	call prettyPrint

	mov EAX, [winner]
	cmp EAX, 1
	je .compWin
	cmp EAX, 2
	je .playerWin
	jmp .tieWin

.playerWin:
	push pName
	call printf
	add ESP, 4

	push m_winner
	call printf
	add ESP, 4
	
	jmp .stats

.compWin:
	push cName
	call printf
	add ESP, 4

	push m_winner
	call printf
	add ESP, 4

	jmp .stats

.tieWin:
	push m_tieWin
	call printf
	add ESP, 4

.stats:

	;;;;;;;;;;;;;;;;;;;;;;;;; Print wins
	push pName
	call printf
	add ESP, 4

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
	push cName
	call printf
	add ESP, 4	

	push m_currWins		; Push current win message
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
;; Takes no arguments and has no return value
;; Uses escape strings to do some schnazzy printing
	push clearScreen	; Push clear screen esacpe string
	call printf		; Call printf
	add ESP, 4		; Adjust stack pointer

	call gameInfo
	
	push alt		; Switch to alternate character set
	call printf
	add ESP, 4

	call drawCell1		; Draw cell 1
	call drawCell2		; Draw cell 2
	call drawCell3		; Draw cell 3
	call drawCell4		; Draw cell 4
	call drawCell5		; Draw cell 5
	call drawCell6		; Draw cell 6
	call drawCell7		; Draw cell 7
	call drawCell8		; Draw cell 8
	call drawCell9		; Draw cell 9

	call drawBorders	; Draw left and bottom border

	push norm		; Switch to normal character set
	call printf
	add ESP, 4

	push newline		; Print a newline
	call printf
	add ESP, 4

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
	cmp EAX, [compSymb]
	je .compTurn
	jmp .playerTurn

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

	push newline		; Force buffer flush by printing newline
	call printf
	add ESP, 4
	
	jmp .exit

.exit:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END turnInfo

gameInfo:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN gameInfo
;; Takes no input and returns nothing
;; Prints basic game info (which player is which symbol)

	mov EAX, [playSymb]	; Mov player's symbol in EAX
	cmp EAX, X_VAL		; Check if player is X
	je .p1isX		; If so, jump here
	jmp .p1isO		; Else jump there

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

playAgain:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN playAgain

	call reportStatistics

	push m_playAgain
	call printf
	add ESP, 4

	xor ECX, ECX

; Let AI play against itself forever
;.loop:	
;	inc ECX
;	cmp ECX, 2000000000
;	jne .loop
;	jmp .exit
		
	push input
	push f_int
	call scanf
	add ESP, 8

	mov EAX, [input]
	cmp EAX, 1
	je .exit
	cmp EAX, 2
	je .xorEAX
	call playAgain

.xorEAX:
	xor EAX, EAX
.exit: ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END playAgain

tryCorner:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN tryCorner
;; Takes no input
;; WIll return 0 if no move possible, or 1, 3, 7, or 9 for the move to make
	xor ECX, ECX		; ECX will count empty spaces
	xor EDX, EDX		; EBX will store index of non-empty space

.countFirstC:			; Count first corner
	mov EAX, [board]	; Move top-left corner into EAX
	cmp EAX, 0		; Check if EAX is empty
	jne .countSecondC	; If not, go count second corner

	inc ECX			; Increment counter
	mov EDX, 1		; Store top-left corner in EDX

.countSecondC:			; Count second corner
	mov EAX, [board + 8]	; Move top-right corner into EAX
	cmp EAX, 0		; Check if EAX is empty
	jne .countThirdC	; If not, go count third corner

	inc ECX			; Increment counter
	mov EDX, 3		; Store top-right corner in EDX

.countThirdC:			; Count third corner
	mov EAX, [board + 24]	; Move bottom-left corner into EAX
	cmp EAX, 0		; Check if EAX is empty
	jne .countFourthC	; If not, go count third corner

	inc ECX			; Increment counter
	mov EDX, 7		; Store bottom-left corner in EDX

.countFourthC:			; Count fourth corner
	mov EAX, [board + 32]	; Move bottom-right corner into EAX
	cmp EAX, 0		; Check if EAX is empty
	jne .decision		; If not, go make decision

	inc ECX			; Increment counter
	mov EDX, 9		; Store top-left corner in EDX

.decision:			; Make decision based upon number of empty spaces
	cmp ECX, 0		; Check if there are no empty spaces
	je .fail		; if there are, fail

	cmp ECX, 2		; If ECX to 2
	je .defense		; We need to be sure that the opponent doesn't have 2 corners
	jmp .edx		; Otherwise go to a known empty corner

.defense:
	xor ECX, ECX		; ECX will keep track of how many corners the enemy has

	mov EAX, [board]
	cmp EAX, [enemySymb]
	jne .d2
	inc ECX
.d2:				; Defense 2
	mov EAX, [board + 8]
	cmp EAX, [enemySymb]
	jne .d3
	inc ECX
.d3:				; Defense 3
	mov EAX, [board + 24]
	cmp EAX, [enemySymb]
	jne .d4
	inc ECX
.d4:				; Defense Four
	mov EAX, [board + 32]
	cmp EAX, [enemySymb]
	jne .df
	inc ECX
.df:				; Defense Final
	cmp ECX, 2		; See if the opponent had 2 
	jne .edx		; if they didn't take EDX
	push EDX		; Save EDX
	call trySide		; Try a side defensively
	pop EDX			; Restore edx
	cmp EAX, 0		; See if side returned 0
	jne .exit		; If it didn't, return that
	jmp .edx		; Else return EDX
	

.fail:				; No empty spaces, fail
	xor EAX, EAX		; Return a 0
	jmp .exit

.edx:				; Return EDX
	mov EAX, EDX		; move EDX into EAX
	jmp .exit

.exit: ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END tryCorner

cornerSide:
	xor EDX, EDX
;check sides
.2:
	;check top
	mov EAX, [board+4]
	cmp EAX, [enemySymb]
	je .27			;check to see if opponent has close corner and side
.4:
	;check left
	mov EAX, [board+12]
	cmp EAX, [enemySymb]	
	je .43			;check to see if opponent has close corner and side
.6:
	;check right
	mov EAX, [board+20]
	cmp EAX, [enemySymb]
	je .61
.8:	
	;check bottom
	mov EAX, [board+28]
	cmp EAX, [enemySymb]
	je .81

	jmp .fail

.27:
	;is bottom left also taken?
	mov EAX, [board+24]
	cmp EAX, [enemySymb]
	jne .29			;if not, next check
	mov EAX, [board]	;check if empty spaces between
	cmp EAX, 0
	jne .29
	mov EAX, [board+12]
	cmp EAX, 0
	jne .29
	mov EDX, 4		;choose side between them
	jmp .success
.29:
	;is bottom right also taken?
	mov EAX, [board+32]
	cmp EAX, [enemySymb]
	jne .4			
	mov EAX, [board+20]	;check if empty spaces between
	cmp EAX, 0
	jne .4
	mov EAX, [board+8]
	cmp EAX, 0
	jne .4
	mov EDX, 6		;choose side between them
	jmp .success
.43:
	;is top right also taken?
	mov EAX, [board+8]
	cmp EAX, [enemySymb]
	jne .49
	mov EAX, [board]
	cmp EAX, 0
	jne .49
	mov EAX, [board+4]
	cmp EAX, 0
	jne .49
	mov EDX, 2
	jmp .success	
.49:	;is bottom right also taken?
	mov EAX, [board+32]
	cmp EAX, [enemySymb]
	jne .6
	mov EAX, [board+24]
	cmp EAX, 0
	jne .6
	mov EAX, [board+28]
	cmp EAX, 0
	jne .6
	mov EDX, 8
	jmp .success
.61:	;is top left also taken?
	mov EAX, [board]
	cmp EAX, [enemySymb]
	jne .67
	mov EAX, [board+4]
	cmp EAX, 0
	jne .67
	mov EAX, [board+8]
	cmp EAX, 0
	jne .67
	mov EDX, 2
	jmp .success
.67:	;is bottom left also taken?
	mov EAX, [board+24]
	cmp EAX, [enemySymb]
	jne .8
	mov EAX, [board+28]
	cmp EAX, 0
	jne .8
	mov EAX, [board+32]
	cmp EAX, 0
	jne .8
	mov EDX, 8
	jmp .success
.81:	;is top left also taken?
	mov EAX, [board]
	cmp EAX, [enemySymb]
	jne .83
	mov EAX, [board+12]
	cmp EAX, 0
	jne .83
	mov EAX, [board+24]
	cmp EAX, 0
	jne .83
	mov EDX, 4
	jmp .success
.83:	;is top right also taken?
	mov EAX, [board+8]
	cmp EAX, [enemySymb]
	jne .fail
	mov EAX, [board+20]
	cmp EAX, 0
	jne .fail
	mov EAX, [board+32]
	cmp EAX, 0
	jne .fail
	mov EDX, 6
	jmp .success
.fail:
	xor EAX, EAX	;return 0
	jmp .exit
.success:
	mov EAX, EDX	;return move
	jmp .exit
.exit:
	ret

tryCenter:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN tryCenter

	mov EAX, [board + 16]	; Move the center cell into EAX
	cmp EAX, 0		; Check and see if the center cell is empty
	jne .fail		; If not, fail

	mov EAX, 5		; If it is empty, move cell number into EAX
	jmp .exit		; Exit

.fail:	xor EAX, EAX		; Zero out EAX
	jmp .exit		; Exit

.exit:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END tryCenter

trySide:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN trySide
	xor EDX, EDX		;holds found move location
	mov ECX, [input]	;holds last move
	

	;Find last move made
	cmp ECX, 1
	je  .1
	cmp ECX, 2
	je  .2
	cmp ECX, 3
	je  .3
	cmp ECX, 4
	je  .4
	cmp ECX, 5
	je  .5
	cmp ECX, 6
	je  .6
	cmp ECX, 7
	je  .7
	cmp ECX, 8
	jne .9
	jmp .8

.1:	;check in order 2,4,6,8
	call .top
	cmp  EDX, 0
	jne  .decision

	call .left
	cmp  EDX, 0
	jne  .decision	

	call .right
	cmp  EDX, 0
	jne  .decision

	call .bottom
	cmp  EDX, 0
	jne  .decision

	jmp  .fail

.2:	;check in order 4,6,8
	call .left
	cmp EDX, 0
	jne .decision

	call .right
	cmp EDX, 0
	jne .decision

	call .bottom
	cmp EDX, 0
	jne .decision

	jmp .fail

.3:	;check in order 2,6,4,8
	call .top
	cmp EDX, 0
	jne .decision

	call .right
	cmp EDX, 0
	jne .decision	;if spot stored, return it
	
	call .left	
	cmp EDX, 0
	jne .decision	;if spot stored, return it

	call .bottom
	cmp EDX, 0
	jne .decision	;if spot stored, return it

	jmp .fail

.4:	;check in order 2,8,6
	call .top
	cmp EDX, 0
	jne .decision

	call .bottom
	cmp EDX, 0
	jne .decision

	call .right
	cmp EDX, 0
	jne .decision

	jmp .fail

.5:	;check in order 2,4,6,8
	call .top
	cmp EDX, 0
	jne .decision

	call .left
	cmp EDX, 0
	jne .decision
	
	call .right
	cmp EDX, 0
	jne .decision

	call .bottom
	cmp EDX, 0
	jne .decision

	jmp .fail

.6:	;check in order 2,8,4
	call .top
	cmp EDX, 0
	jne .decision

	call .bottom
	cmp EDX, 0
	jne .decision

	call .left
	cmp EDX, 0
	jne .decision

	jmp .fail

.7:	;check in order 4,8,2,6
	call .left
	cmp EDX, 0
	jne .decision

	call .bottom
	cmp EDX, 0
	jne .decision

	call .top
	cmp EDX, 0
	jne .decision

	call .right
	cmp EDX, 0
	jne .decision

	jmp .fail

.8:	;check in order 4,6, 2
	call .left
	cmp EDX, 0
	jne .decision

	call .right
	cmp EDX, 0
	jne .decision
	
	call .top
	cmp EDX, 0
	jne .decision

	jmp .fail

.9:	;check in order 6,8,2,4
	call .right
	cmp EDX, 0
	jne .decision

	call .bottom
	cmp EDX, 0
	jne .decision

	call .top
	cmp EDX, 0
	jne .decision

	call .left
	cmp EDX, 0
	jne .decision

	jmp .fail

.top:	;check if top side is free
	mov EAX, [board+4]	
	cmp EAX, 0
	jne .exit
	
	mov EDX, 2
	ret
.left:	;check if left side is free
	mov EAX, [board+12]
	cmp EAX, 0
	jne .exit

	mov EDX, 4
	ret
.right:	;check if right side is free
	mov EAX, [board+20]
	cmp EAX, 0
	jne .exit

	mov EDX, 6
	ret
.bottom:;check if bottom side is free
	mov EAX, [board+28]
	cmp EAX, 0
	jne .exit

	mov EDX, 8
	ret

.decision:
	mov EAX, EDX	;put found move in EAX
	jmp .exit	;return move in EAX

.fail:
	xor EAX, EAX	;return 0
	jmp .exit

.exit:
	ret

defend:
.defend2:
	;test to see if 2 is taken
	mov EAX, [board+4]
	cmp EAX, [enemySymb]	;if it is taken by enemy,
	je .defend24		;check to see if adjacent is taken

.defend8:	
	;test to see if 8 is taken
	mov EAX, [board+28]	
	cmp EAX, [enemySymb]	;if it is taken by enemy,
	je .defend84		;check to see if adjacent is taken
	
	jmp .fail		;if 2 and 8 are not taken, player cannot have adjacent sides 
	
.defend24:
	;test to see if 4 is also taken
	mov EAX, [board+12]
	cmp EAX, [enemySymb]	;does the enemy have the spot?
	jne .defend26		;if not, check other adjacent side
	mov EAX, [board]	;is corresponding corner free?
	cmp EAX, 0
	jne .defend26		;if not free, next check
	mov EDX, 1
	jmp .decision

.defend26:
	;test if 6 is alse taken
	mov EAX, [board+20]
	cmp EAX, [enemySymb]	;does enemy have the spot?
	jne .fail		;if not, no way we can have adjacent side
	mov EAX, [board+8]
	cmp EAX, 0		;is corner free?
	jne .fail		;if not free, no way we can have adjacent side still; exit
	mov EDX, 3		;if free, store spot
	jmp .decision

.defend84:
	mov EAX, [board+12]	
	cmp EAX, [enemySymb]	;does enemy have spot?
	jne .defend86		;if not, check other adjacent side
	mov EAX, [board+24]
	cmp EAX, 0
	jne .fail
	mov EDX, 7		;if free, store spot
	jmp .decision

.defend86:
	;test if 6 is also taken
	mov EAX, [board+20]
	cmp EAX, [enemySymb]	;does enemy have spot?
	jne .fail		;if not, no way we can have adjacent side
	mov EAX, [board+32]
	cmp EAX, 0		;is corner free?
	jne .fail		;if not free, still no way to have adjacent side; exit
	mov EDX, 9
	jmp .decision
	
.decision:
	mov EAX, EDX
	jmp .exit

.fail:
	xor EAX, EAX
	jmp .exit

.exit: ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END trySide


exit:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN exit
	push norm		; push normal character set escape character to stack
	push f_str		; push format string for printing a string
	call printf		; no more demon symbols
	add ESP, 8		; adjust stack pointer

	ret			; Get outta harlem
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END exit
