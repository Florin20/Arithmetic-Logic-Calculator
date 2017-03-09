.386

.model flat, stdcall

extern exit:proc
extern printf:proc
extern scanf:proc

.data
	msg DB "Arithmetic Calculator v0.1", 0ah, 0ah,   "Operations:", 0ah, "+ addition", 0ah, "- subtraction", 0ah,
	"* multiplication", 0ah, "/ division", 0ah, "a and", 0ah, "n not", 0ah, 0ah, 
	"Instructions:", 0ah,
	"exit -> close the program", 0ah, "num -> change the numerical system, h for hexa, d for decimal", 0ah, 
	"Press = for printing the result", 0ah, 0ah,  "Enter an expression:", 0ah, 0
	format DB "%d", 0
	formatw DB "The result is: %d",0ah, 0
	formats DB "%s",0ah, 0
	formatc DB "%c", 0
	acceptedChars DB " +-*/1234567890=FanexitnumABCDE", 0
	formath DB "The result is %x", 0ah, 0
	formatr DB "%s\n", 0
	err DB "Invalid input!", 0
	string DB 100 DUP (0),0
	reset DD 0
	operators DB "-+*/an", 0
	num DB "d", 0 ;hex or dec
	var DD 0
	expr1 DD 0
	expr2 DD 0
	indexe DD 0  ;end
	indexs DD 0 ;start
	index DD 0
	flag DD 0
	result DD 0
	op DB "+", 0
	conseq DB 0
	temp DD 0
	equals DB 0
	fop DB "?", 0
	fm DB "%d %d",0

.code

isOp PROC ;EAX is 1 if the character is an operator

	mov EAX, 0
	mov EBX, [ESP+4]
	mov ECX, 7
	isOprpt:cmp BL, [operators+ECX-1]
	je isOptrue
	loop isOprpt
	
	jmp isOpexit
	
	isOptrue:mov EAX, 1
	isOpexit:ret 4
	
isOp ENDP

getrN PROC ;get the number on the right

	mov EAX, 0
	mov EBX, [ESP+4]
	getrNrpt:inc EBX
	
	cmp [string+EBX], '+'
	jne getrNs
	mov indexe, EBX
	jmp getrNexit

	getrNs:cmp[string+EBX], '-'
	jne getrNm
	mov indexe, EBX
	jmp getrNexit
	
	getrNm:cmp[string+EBX], '*'
	jne getrNd
	mov indexe, EBX
	jmp getrNexit
	
	getrNd:cmp[string+EBX], '/'
	jne getrNa
	mov indexe, EBX
	jmp getrNexit
	
	getrNa:cmp[string+EBX], 'a'
	jne getrNn
	mov indexe, EBX
	jmp getrNexit
	
	getrNn:cmp[string+EBX], 'n'
	jne getrN0
	mov indexe, EBX
	jmp getrNexit
	
	getrN0:cmp[string+EBX], 0
	jne getrNnxt
	mov indexe, EBX
	jmp getrNexit
	
	
	
	getrNnxt:cmp num, 'd'
	jne getrNhex
	mov ECX, 10
	mul ECX
	xor ECX, ECX
	mov CL, [string+EBX]
	add EAX, ECX
	sub EAX, '0'
	jmp getrNrpt
	
	
	getrNhex:mov ECX, 16
	mul ECX
	cmp [string+EBX], 65
	jae getrNl
	xor EDX, EDX
	mov DL, [string+EBX]
	add EAX, EDX
	sub EAX, '0'
	jmp getrNrpt
	

	getrNl:xor EDX, EDX
	mov DL, [string+EBX]
	add EAX, EDX
	sub EAX, '0'
	sub EAX, 7
	jmp getrNrpt
	
	getrNexit:
	ret 4
	
getrN ENDP

getlN PROC ;get the number on the left
	
	mov EAX, 0
	mov EBX, [ESP+4]
	getlNrpt:dec EBX
	
	cmp [string+EBX], '+'
	jne getlNs
	mov indexs, EBX
	jmp getlNnxt

	getlNs:cmp[string+EBX], '-'
	jne getlNm
	mov indexs, EBX
	jmp getlNnxt
	
	getlNm:cmp[string+EBX], '*'
	jne getlNd
	mov indexs, EBX
	jmp getlNnxt
	
	getlNd:cmp[string+EBX], '/'
	jne getlNa
	mov indexs, EBX
	jmp getlNnxt
	
	getlNa:cmp[string+EBX], 'a'
	jne getlNn
	mov indexs, EBX
	jmp getlNnxt
	
	getlNn:cmp[string+EBX], 'n'
	jne getlN0
	mov indexs, EBX
	jmp getlNnxt
	
	getlN0:cmp[string+EBX], 0
	jne getlNrpt
	mov indexs, EBX
	jmp getlNnxt
	
	getlNnxt:mov EBX, indexs
	cmp num, 'h'
	je getlNhex
	
	mov ECX, [esp+4]
	sub ECX, indexs
	dec ECX
	zecrpt:inc EBX
	mov EDX, 10
	mul EDX
	xor EDX, EDX
	mov DL, [string+EBX]
	add EAX, EDX
	sub EAX, '0'
	loop zecrpt
	
	jmp getlNexit
	
	getlNhex:mov ECX, [esp+4]
	sub ECX, indexs
	dec ECX
	
	hexrpt:inc EBX
	mov EDX, 16
	mul EDX
	cmp[string+EBX], 65
	jae getlNl
	
	xor EDX, EDX
	mov DL, [string+EBX]
	add EAX, EDX
	sub EAX, '0'
	loop hexrpt
	jmp getlNexit
	
	getlNl:xor EDX, EDX
	mov DL, [string+EBX]
	add EAX, EDX
	sub EAX, '0'
	sub EAX, 7
	loop hexrpt
	
	getlNexit:ret 4
	
getlN ENDP

parseString PROC

	comment @ mov ECX, indexe
	mov EBX, 0
	
	psrpt:cmp [string+ECX], 0
	je psout
	mov DL, [string+ECX]
	mov [substring+EBX], DL
	inc EBX
	inc ECX
	jmp psrpt
	

	psout:mov ECX, indexs
	mov EBX, 0
	psrpt2:mov DL, [substring+EBX]
	mov [string+ECX], DL
	cmp [string+ECX], 0
	je psret
	inc EBX
	inc ECX
	jmp psrpt2
	
	psret:mov [string+ECX], 0
	ret
	@
	mov ECX, 0
	bucla:
	mov EAX, indexe
	mov DL, [string+ecx+eax]
	mov EAX, indexs
	mov[string+ECX+EAX], DL
	INC ecx
	cmp [string+ECX+EAX], 0
	jne bucla
	
	ret
	
parseString ENDP


sum PROC
	add result, EAX
	ret
sum ENDP

dif PROC
	sbb result, EAX
	ret
dif ENDP

multiplication PROC
	mov EBX, EAX
	mov EAX, temp
	mul EBX
	mov temp, EAX
	ret
multiplication ENDP
	
division PROC
	xor EBX, EBX
	mov EBX, EAX
	mov EAX, temp
	cdq
	idiv EBX
	mov temp, EAX
	ret
division ENDP

aop PROC
	and result, EAX
	ret
aop ENDP

nope PROC
	not result
	ret
nope ENDP

getNumber PROC

    xor EAX, EAX
	mov EBX, index
	rpt:xor ECX, ECX
	inc EBX
	mov CL, [string+EBX]
	cmp CL, '+'
	jne checkSub
	jmp fin
	checkSub: cmp CL, '-'
	jne checkMul
	jmp fin
	checkMul: cmp CL, '*'
	jne checkDiv
	jmp fin
	checkDiv: cmp CL, '/'
	jne checkA
	jmp fin
	checkA:   cmp CL, 'a'
	jne checkNot
	jmp fin
	checkNot:  cmp CL, 'n'
	jne e
	jmp fin
	e: cmp CL, 0
	je en
	
	cmp num, 'd'
	je zec
	
	mov EDX, 16
	mul EDX
	cmp CL, 65
	jb n
	sub CL, '0'
	sub CL, 7
	jmp nx
	n:sub CL, '0'
	nx:add EAX, ECX
	jmp rpt
	
	zec:
	mov EDX, 10
	mul EDX
	sub CL, '0'
	add EAX, ECX
	jmp rpt
	en:mov flag, 0
	fin:mov index, EBX
	ret
	
getNumber ENDP

checkString PROC ;check if the string contains accepted characters
	mov EAX, 1
	mov EBX, -1

    t:inc EBX ;check every character from the string
	cmp [string+EBX], 0
	je x
	mov DL, [string+EBX]
	mov ECX, 28
	
	t2:cmp DL, [acceptedChars+ECX];check with every character from the accepted ones
	je t
	loop t2
	
    mov EAX, 0
	
	x:ret 
	
checkString ENDP

start:

et0:

	push offset msg
	call printf
	add esp, 4


main:
	;push offset string
	;push offset formats
	;call printf
	;add esp, 8
	
	mov index, 0
	mov flag, 1
	
	; xor EBX, EBX
	; mov BL, fop
	; push EBX
	; push offset formatc
	; call printf
	; add esp, 8
	
	; push expr1
	; push expr2
	; push offset fm
	; call printf
	; add esp, 12
	
	
	cmp fop, '+'
	jne opm
	mov fop, '?'
	mov EBX, expr1
	add result, EBX
	mov EBX, expr2
	add result, EBX
	jmp lfn
	
	opm:cmp fop, '-'
	jne opml
	
	cmp expr2, 0
	jge et99
	
	mov EBX, expr1
	add EBX, expr2
	add result, EBX
	mov fop, '?'
	jmp lfn
	
	et99:cmp fop, '-'
	jne et155
	
	mov EBX, expr1
	add EBX, expr2
	add result, EBX
	mov fop, '?'
	jmp lfn
	
	et155:mov EBX, expr1
	add EBX, expr2
	sbb result, EBX
	mov fop, '?'
	jmp lfn
	
	
	
	opml:cmp fop, '*'
	jne opdv
	mov fop, '?'
	
	; push result
	; push offset formatw
	; call printf
	; add esp, 8
	
	; push expr2
	; push offset formatw
	; call printf
	; add esp, 8
	
	mov EBX, expr1
	add EBX, expr2
	mov EAX, result
	mul EBX
	mov result, EAX
	jmp lfn
	
	opdv:cmp fop, '/'
	jne opa
	mov fop, '?'
	cdq
	mov EBX, expr1
	add EBX, expr2
	mov EAX, result
	idiv EBX
	mov result, EAX
	jmp lfn
	
	opa:cmp fop, 'a'
	jne opn
	mov fop, '?'
	mov EBX, expr1
	add EBX, expr2
	and result, EBX
	jmp lfn
	
	opn:cmp fop, 'n'
	jne rst1
	mov fop, '?'
	not expr2
	mov EBX, expr2
	mov result, EBX
	jmp lfn
	
	rst1:mov result, 0
	mov EBX, expr1
	add result, EBX
	mov EBX, expr2
	add result, EBX

	
	lfn:mov expr1, 0
	mov expr2, 0
	
    scnf:push offset(string)
	push offset(formatr)
	call scanf
	add ESP, 8
	
	call checkString ;EAX is 1 if string is a valid input
	
	cmp EAX, 1
	je ot2
	
	inv:push offset(err) ;print error if the input is not valid
	call printf
	add ESP, 4
	
	;jmp scnf
	
	ot2:
	; xor EBX, EBX
	; mov BL, string ;copiaza primul caracter
	; push EBX
	; call isOp
	; cmp EAX, 1
	; jne v
	; mov fop, BL
	mov BL, string
	mov op, BL
	
	
	cmp[string], '='
	jne y
	
	cmp num, 'h'
	je hex
	
	push result
	push offset formatw
	call printf
	add esp, 8
	mov op, '?'
	jmp scnf
	
	hex:
	push result
	push offset(formath)
	call printf
	add ESP, 12
	mov op, '?'
	jmp scnf
	
   
	
	y:cmp [string], 'e' ;check for 'exit'
	je chx
	jmp ns
	chx:cmp [string+1], 'x'
	je chi
	jmp inv
	chi:cmp[string+2], 'i'
	je cht
	jmp inv
	cht:cmp[string+3], 't'
	je ext
	jmp inv
	
	ns:cmp [string], 'n' ;change the numeration system
	jne srch
	jmp chu
	chu:cmp [string+1], 'u'
	je chm
	jmp srch
	chm: cmp [string+2], 'm'
	je numsys
	jmp inv
	
	numsys:lea EBX, num
	push EBX
	push offset(formatr)
	call scanf
	add esp, 8
	
	jmp scnf
	
	srch:
	
	call getNumber
	mov EBX, index
	
	cmp[string+EBX], 0
	je bo
	cmp[string+EBX], '*'
	jne d
	
	push index
	call getlN
	mov EDX, indexs
	
	cmp[string+EDX], '-'
	jne pm
	sub temp, EAX
	jmp nm
	
	pm:mov temp, EAX
	
	nm:push index
	call getrN
	
	call multiplication
	
	mov EDX, temp
	add expr1, EDX
	mov temp, 0
	
	mov EDX, indexe
	mov index, EDX
	nxtcopm:
	mov EDX, index
	cmp[string+EDX], '*'
	jne opd
	
	call getNumber
	mov EDX, EAX
	mov EAX, expr1
	mul EDX
	mov expr1, EAX
	mov EDX, index
	mov indexe, EDX
	jmp nxtcopm
	
	opd:
	mov EDX, index
	cmp[string+EDX], '/'
	jne cont
	call getNumber
	cdq
	mov ECX, EAX
	mov EAX, expr1
	idiv ECX
	mov expr1, EAX
	mov ECX, index
	mov indexe, ECX
	jmp opd
	
	cont:
	;push expr1
	;push offset formatw
	;call printf
	;add esp, 8
	
	call parseString
	
	mov index, 0
	jmp srch
	
	d: cmp[string+EBX], '/'
	jne ii
	
	mov temp, 0
	push index
	call getlN
	mov EDX, indexs
	
	cmp[string+EDX], '-'
	jne pd
	sub temp, EAX
	jmp nd
	
	pd:mov temp, EAX
	nd:push index
	call getrN

    call division
	
	mov EDX, temp
	add expr1, EDX
	mov temp, 0
	
	
    mov EDX, indexe
	mov index, EDX
	nxtcopm2:
	mov EDX, index
	cmp[string+EDX], '*'
	jne opd2
	
	call getNumber
	mov EDX, EAX
	mov EAX, expr1
	mul EDX
	mov expr1, EAX
	mov EDX, index
	mov indexe, EDX
	jmp nxtcopm2
	
	opd2:
	mov EDX, index
	cmp[string+EDX], '/'
	jne cont2
	
	call getNumber
	cdq
	mov ECX, EAX
	mov EAX, expr1
	idiv ECX
	mov expr1, EAX
	mov ECX, index
	mov indexe, ECX
	jmp opd2 
	
	cont2: 
	call parseString
	
	mov index, 0
	jmp srch
	
	ii:inc index
	jmp srch
	
	bo:
	mov flag, 1
	mov expr2, 0
	mov index, 0
	;xor EBX, EBX
	;mov BL, [string+ECX]
	;push EBX
	;call isOp
	;cmp EAX, 1
	;jne nxt2
	;mov result, 0
	
	nxt2:
	; push offset string
	; push offset formats
	; call printf
	; add esp, 8
	
	mov index, 0
	cmp string, 0
	je main
	
	xor EDX, EDX
	mov DL, string
	push EDX
	call isOp
	cmp EAX, 1
	jne k
	
	mov op, DL
	mov index, 0
	jmp z
	k:mov index, -1
	z:call getNumber
	mov EDX, index
	cmp[string+EDX], 0
	jne p
	
	mov BL, op
	cmp BL, '-'
	jne et78
	mov expr2, 0
	sbb expr2, EAX
	mov fop, BL
	jmp main
	
	et78:mov expr2, EAX
	mov BL, op
	mov fop, BL
	; push expr2
	; push offset formatw
	; call printf
	; add esp, 8
	jmp main
	; push offset string
	; push offset formats
	; call printf
	; add esp, 8
	
	p:
	mov index, 0
	xor EDX, EDX 
	mov DL, string
	push EDX
	call isOp
	cmp EAX, 1 
	je q
	mov result, 0
	jmp ex
	
	
	
	q:mov DL, string
	mov fop, DL
	r:mov EDX, index
	mov var, EDX
	mov DL, [string+EDX]
	mov op, DL ;copy the operation sign to op
	mov BL, op
	xor EBX, EBX
	mov EDX, var
	mov BL, [string+EDX+1]
	cmp BL, 'n'
	jne et55
	inc index
	call getNumber  ;convert the ASCII representation to an integer, store it inside EAX
	not EAX
	
	; push EAX
	; push offset formatw
	; call printf
	; add esp, 8
	
	mov BL, op
	jmp et56
	
	et55:call getNumber
	mov BL, op
	
	et56:
	
	cmp BL, '+'
	jne subt
	add expr2, EAX
	cmp flag, 0
	je main
	jmp r
	
	subt: cmp BL, '-'
	jne mult
	sbb expr2, EAX
	cmp flag, 0
	je main
	jmp r
	
	mult: cmp BL, '*'
	jne divi
	mov fop, '+'
	mov EBX, EAX
	mov EAX, result
	mul EBX
	mov result, EAX
	cmp flag, 0
	je main
	jmp r
	
	divi: cmp BL, '/'
	jne a
	mov fop, '+'
	cdq
	mov EBX, EAX
	mov EAX, expr2
	idiv EBX
    mov expr2, EAX
	cmp flag, 0
	je main
	jmp r
	
	a:cmp BL, 'a'
	jne inv
	mov fop, '+'
	and expr2, EAX
	add esp, 8
	cmp flag, 0
	je main
	jmp r
	
	
	ex:dec index
	call getNumber
	mov expr2, EAX
	jmp r
	
	
	; mov ECX, index
	; call getNumber
	
	; cmp [string+ECX], '+'
	; jne csb
	; add expr2, EAX
	; cmp flag, 0
	; je main
	; jmp nxt2
	
	; csb:cmp[string+ECX], '-'
	; jne cml
	; sbb expr2, EAX
	; cmp flag, 0
	; je main
	; jmp nxt2
	
	; cml:cmp[string+ECX], '*'
	; jne cdv
	; mov EBX, EAX
	; mov EAX, expr2
	; mul EBX
	; mov expr2, EAX
	; cmp flag, 0
	; je main
	; jmp nxt2
	
	; cdv:cmp[string+ECX], '/'
	; jne ca
	; cdq
	; mov EBX, EAX
	; mov EAX, expr2
	; idiv EBX
	; mov expr2, EAX
	; cmp flag, 0
	; je main
	; jmp nxt2
	
	; ca:cmp[string+ECX], 'a'
	; jne cn
	; and expr2, EAX
	; cmp flag, 0
	; je main
	; jmp nxt2
	
	; cn:cmp[string+ECX], 'n'
	; jne inv
	; not expr2
	; cmp flag, 0
	; je main
	; jmp nxt2
	
	ext:push 0
	call exit
	
end start

	
	
