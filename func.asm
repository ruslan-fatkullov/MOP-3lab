MODEL SMALL
.CODE
.386
INCLUDE macros.mac
	
 LOCALS
 
;==============================================
; Подпрограмма ввода символа в AL с терминала
;==============================================
GETCH	PROC	NEAR
        MOV	AH,   8
        INT	21h
        RET
GETCH	ENDP
;=====================================================
; Подпрограмма вывода на экран строки, адресуемой SI, 
; с задержкой времени между символами в <CX,DX> mcs.
; Завершителями строки являеются байты 0 или 0FFh.
; ЕСЛИ строка заканчивается байтом 0,
;   ТО добавляется переход в начало новой строки
; 
;=====================================================
PUTSS   PROC	NEAR
@@L:    MOV	AL,	[SI]
        CMP	AL,	0FFH
        JE	@@R
        CMP	AL,	0
        JZ	@@E
        CALL	PUTC
        INC	SI
        JMP	SHORT @@L
        ; Переход на следующую строку
@@E:    MOV	AL, 13
        CALL	PUTC
        MOV	AL, 10
        CALL	PUTC
@@R:    RET
PUTSS	ENDP

;==============================================
; Подпрограмма вывода AL на терминал
;==============================================
PUTC	PROC	NEAR
        PUSH	DX
        MOV	DL,   AL
        MOV	AH,   2
        INT	21h
        POP	DX
        RET
PUTC	ENDP



;==============================================
; Подпрограмма вывода числа на экран в 
; в десятичном виде из регистра AX
;==============================================
BINtoDEC	PROC	NEAR
	push cx
	push dx
	push ax
	
    xor cx, cx  
	decr:               
    inc cx          
    xor dx, dx
    mov bx, 10
    div bx
    push dx
    cmp ax, 0
    jne decr
    
	print:         
    mov ah, 02h    
    xor dx, dx
    pop dx
    add dx, '0'
    int 21h
    loop print
	
	pop ax
	pop dx
	pop cx
		ret
BINtoDEC	ENDP
;==============================================
; Подпрограмма проверки строки на содержание одной точки
; input - esi - адресс строки
;==============================================
checkOnDot	PROC	NEAR
	push esi
	
	xor eax, eax
	add esi, 2
	startCheck:
	cmp byte ptr[esi], 0
	je endCheck
	cmp byte ptr[esi], '.'
	jne middleCheck1
	inc eax
	inc esi
	jmp startCheck
	middleCheck1:
	inc esi
	jmp startCheck
	
	endCheck:
	pop esi 
	ret
checkOnDot	ENDP
;==============================================
; Подпрограмма проверки строки на непереполненность
; input - esi - адресс строки
;==============================================
checkOnSize	PROC	NEAR
	push esi
	
	xor eax, eax
	add esi, 2
	;проверка на минус
	cmp byte ptr[esi], '-'
	jne CheckInteger
	inc esi	
	
	CheckInteger:
	cmp byte ptr[esi], '.'
	je CheckReal
	inc eax
	inc esi
	jmp CheckInteger
	
	CheckReal:
	inc esi
	cmp eax, 10
	jg errorSize
	
	xor eax, eax
	CheckReal1:
	cmp byte ptr[esi], 0
	je endCheckReal
	inc eax
	inc esi
	jmp CheckReal1
	
	endCheckReal:
	cmp eax, 7
	jle endCheckSize
	
	errorSize:
	mov eax, -1
	
	endCheckSize:
	pop esi 
	ret
checkOnSize	ENDP
;==============================================
; Подпрограмма проверки строки ввод цифр
; input - esi - адресс строки
;==============================================
checkOnNumber	PROC	NEAR
	push esi
	xor eax, eax
	add esi, 2
	;проверка на минус
	cmp byte ptr[esi], '-'
	jne CheckNumber
	inc esi	
	CheckNumber:
	cmp byte ptr[esi], 0
	je endCheckNumber
	cmp byte ptr[esi], '.'
	je incrementESI
	cmp byte ptr[esi], '0'
	jl errorNumber
	cmp byte ptr[esi], '9'
	jg errorNumber
	
	incrementESI:
	inc esi
	jmp CheckNumber
	
	errorNumber:
	mov eax, -1
	
	endCheckNumber:
	pop esi 
	ret
checkOnNumber	ENDP
;==============================================
; Подпрограмма записи из буферной строки
; в массив структур  
; input - esi - адрес строки
;		  edi - адрес структуры
;==============================================
bufferToStruct	PROC	NEAR
    push esi
	push edi
	push edx
	push eax
	
	mov eax, edi
	xor edx, edx
	add esi, 2
	
	sign:
	cmp byte ptr[esi], '-'
	jne integer
	mov dl, byte ptr[esi]
	mov byte ptr[edi], dl
	inc esi
	
	integer:
	inc edi
	integer1:
	cmp byte ptr[esi], '.'
	je real
	
	mov dl, byte ptr[esi]
	mov byte ptr[edi], dl
	inc esi
	inc edi
	jmp integer1
	
	real:
	inc esi
	mov edi, eax
	add edi, 11
	real1:
	cmp byte ptr[esi], 0
	je endCycle
	
	mov dl, byte ptr[esi]
	mov byte ptr[edi], dl
	inc esi
	inc edi
	jmp real1
	
	
	endCycle:
	pop eax
	pop edx
	pop edi
	pop esi
		ret
bufferToStruct	ENDP
;==============================================
; Подпрограмма очистки массива
; input esi - адрес массива
;==============================================
clearMassive	PROC	NEAR
	startClear:
	cmp byte ptr[esi+2], 0
	je exitClear
	mov byte ptr[esi+2], 0
	inc esi
	jmp startClear
	
	exitClear:
	ret
clearMassive	ENDP


;==============================================
; Подпрограмма вывода массива 
;==============================================
OutMassive	PROC	NEAR
    M01:
	cmp byte ptr[si+2], '$'
	je endOf
	mov ah, 02h
	mov dl, byte ptr[si+2]
	int 21h
	inc SI
	jmp M01
	endOf:
	ret
OutMassive	ENDP

;=================================================
; Процедура для перевода строки в десятичное число
;
; Входные данные: SI - адрес строки
; Выходные данные: AX - десятеричное число
;=================================================
ATOI	PROC	NEAR
	PUSH	BX
	PUSH si
	XOR	BX,	BX
	XOR	AX,	AX

	@@CONVERT:
		MOV	BL,	[SI + 2]
		CMP	BL,	0
		JZ	@@EXIT

		CMP	BL,	'0'
		JL	@@ERROR
		CMP	BL,	'9'
		JG	@@ERROR

		SUB	BL,	'0'
		IMUL	AX,	10
		ADD	AX, BX

		INC	SI
		JMP	@@CONVERT

	@@ERROR:
		MOV	AX, -1
	@@EXIT:
		POP si
		POP	BX
		RET
ATOI	ENDP

;=================================================
; Процедура умножения на 5
; input - edi - адрес массива
;=================================================
MulFive	PROC	NEAR
	push edi
	push ecx
	push ebx 
	push eax
	push edx
	
	mov ecx, edi
	add edi, 17
	mov al, 0
	startMulFive:
	cmp edi, ecx
	je endMulFive
	
	
	cmp byte ptr[edi], '0'
	jl YUI
	cmp byte ptr[edi], '9'
	jg YUI
	
	mov dl, byte ptr[edi]
	call calcFive
	
	mov byte ptr[edi] , dl
	
	YUI:
	dec edi
	jmp startMulFive
	endMulFive:
	
	cmp al, 0
	je endMulFive1
	add ecx, 10
	add al, '0'
	wqer:
	cmp edi, ecx
	je endMulFive1
	
	mov bl, byte ptr[edi+1]
	mov byte ptr[edi+1] , al
	mov al, bl
	
	inc edi
	jmp wqer
	endMulFive1:
	
	pop edx
	pop eax
	pop ebx
	pop ecx
	pop edi
		RET
MulFive	ENDP
;=================================================
; умножение на 5 символа
; input - dl - цифра
;=================================================
calcFive	PROC	NEAR
	push ax
	sub dl, '0'
	mov al, dl
	mov bl, 5
	mul bl
	add dl, al
	pop bx
	add al, bl
	mov bl, 10
	div bl
	mov dl, ah
	add dl, '0'
	
		RET
calcFive	ENDP
;=================================================
; Процедура сложения двух операндов
; к большему - меньший
; input - edi и esi - элементы массива
;=================================================
sumOperand	PROC	NEAR
	push eax
	push edi
	push esi
	
	mov ecx, edi
	add edi, 17
	add esi, 17
	mov dl, 0
	mov ah, 0
	mov bh, 0
	jmp startSum
	
	decrementSum:
	dec edi
	dec esi
	startSum:
	
	cmp edi, ecx
	je endSumOperation
	
	cmp byte ptr[edi], '9'
	jg firstSign
	cmp byte ptr[esi], '9'
	jg decrementSum
	jmp calc
	
	firstSign:
	cmp byte ptr[esi], '9'
	jle calc
	temp:
	cmp byte ptr[edi], '|'
	jne notEnd
	cmp dl,0
	je notEnd
	mov byte ptr[edi], '1'
	mov dl, 0
	notEnd:
	jmp decrementSum
	
	calc:
	call sumNumbers
	jmp decrementSum
	;;;;;;;;;;;;;;;;;;;;;
	endSumOperation:

	
	pop esi
	pop edi
	pop eax
		RET
sumOperand	ENDP
;=================================================
; Процедура сложения двух цифр
;
; input - edi - цифра
; output bx - флаг переполнения
;=================================================
sumNumbers	PROC	NEAR
	mov al, byte ptr[edi]
	mov bl, byte ptr[esi]
	cmp al, '9'
	jg aNul
	cmp bl, '9'
	jg bNul
	jmp startCulc
	aNul:
	mov al, '0'
	jmp startCulc
	bNul:
	mov bl, '0'
	startCulc:
	sub al, '0'
	sub bl, '0'
	add al, bl
	;;;;;;;;;;;
	add al, dl
	mov dl, 0
	;;;;;;;;;;;;
	cmp al, 10
	jl endCalc
	mov dl, 1
	sub al, 10
	endCalc:
	add al, '0'
	mov byte ptr[edi], al
	
		RET
sumNumbers	ENDP
;=================================================
; Процедура вычитания двух операндов
; из большего меньший
; input - edi и esi - элементы массива
;=================================================
subtraction	PROC	NEAR
	push eax
	push edi
	push esi
	
	mov ecx, edi
	add edi, 17
	add esi, 17
	mov dl, 0
	jmp startSub
	
	decrement:
	dec edi
	dec esi
	
	startSub:
	mov al, byte ptr[edi]
	sub al,dl
	mov byte ptr[edi], al
	mov dl, 0
	
	cmp edi, ecx
	je endSubOperation
	
	cmp byte ptr[edi], '9'
	jg firstIsSign
	cmp byte ptr[esi], '9'
	jg decrement
	
	call subtractNumbers
	jmp decrement
	
	firstIsSign:
	cmp byte ptr[esi], '9'
	jg decrement
	mov al, 10
	mov bl, byte ptr[esi]
	sub bl, '0'
	sub al, bl
	add al, '0'
	mov byte ptr[edi], al
	
	jmp decrement
	endSubOperation:
	pop esi
	pop edi
	pop eax
		RET
subtraction	ENDP
;=================================================
; Процедура вычитания двух цифр
; edx - флаг заема
; output bx - флаг переполнения
;=================================================
subtractNumbers	PROC	NEAR
	mov al, byte ptr[edi]
	sub al, '0'
	mov bl, byte ptr[esi]
	sub bl, '0'
	
	sub al, bl
	cmp al, 0
	jge hf
	
	add al, 10
	mov dl, 1
	hf:
	add al, '0'
	mov byte ptr[edi], al
		RET
subtractNumbers	ENDP
;=================================================
; Процедура приведения элемента структуры к нормальному виду
;
; input - edi - адрес элемента
;=================================================
normalize	PROC	NEAR
	push ecx
	push edi
	push eax 
	push edx
	push ebx
	
	mov eax, edi;запоминаем edi

	add edi, 1
	
	xor ecx, ecx
	ui:
	cmp ecx, 10
	je endNormalize
	cmp byte ptr[edi], '|'
	je endui
	inc ecx
	inc edi
	jmp ui
	
	endui:
	
	mov ebx, 10
	sub ebx, ecx
	dec edi
	
	endIteration:
	cmp edi, eax
	je endNormalize
	
	mov dl, byte ptr[edi]
	mov byte ptr[edi + ebx],  dl
	mov dl, '|'
	mov byte ptr[edi], dl
		
	dec edi
	jmp endIteration
	endNormalize:
	pop ebx
	pop edx
	pop eax
	pop edi	
	pop ecx
		RET
normalize	ENDP

;=================================================
; Процедура вывода элемента структуры
; input - edi - адрес элемента
;=================================================
outStruct	PROC	NEAR
	push edi
	push ecx 
	push eax
	push edx 
	
	mov dl, byte ptr[edi]
	mov ah,2
	int 21h
	add edi, 1
	
	xor ecx, ecx
	rty:
	cmp ecx, 10
	je zxc
	cmp byte ptr[edi], '|'
	je jjj
		mov dl, byte ptr[edi]
		mov ah,2
		int 21h
	
	jjj:
	inc edi
	inc ecx
	jmp rty
	zxc:
	mov dl, '.'
	mov ah,2
	int 21h
	add edi, 1
	
	dec edi
	add ecx, 1
	rty1:
	cmp ecx, 18
	je zxc1
	cmp byte ptr[edi], '?'
	je jjj1
		mov dl, byte ptr[edi]
		mov ah,2
		int 21h
	
	jjj1:
	inc edi
	inc ecx
	jmp rty1
	zxc1:
	
	pop edx
	pop eax
	pop ecx
	pop edi
	
		RET
outStruct	ENDP
;=================================================
; перенос большего по модулю числа в левый операнд
;=================================================
changeOperand	PROC	NEAR
	push edi
	push esi
	add edi, 1
	add esi, 1
	iterationCycle:
	cmp byte ptr[edi], '9'
	jle secondCheck
	
	cmp byte ptr[esi], '9'
	jle secondHappening
	inc edi
	inc esi
	jmp iterationCycle
	
	
	secondCheck:
	cmp byte ptr[esi], '9'
	jle equalSize
	jmp firstHappening
	equalSize:
	mov al, byte ptr[edi]
	cmp al, byte ptr[esi]
	jl secondHappening
	
		firstHappening:
		pop esi
		pop edi
		mov eax, 0
		jmp emd
		
		secondHappening:
		pop edi
		pop esi
		mov eax, 1
		emd:
		RET
changeOperand	ENDP
;=================================================
; перенос влево минимального операнда
;=================================================
minimumOperand	PROC	NEAR
	push edi
	push esi

	cmp byte ptr[edi], '-'
	je firstMin
	jmp secondMin
	
		firstMin:
		pop esi
		pop edi
		jmp emd
		
		secondMin:
		pop edi
		pop esi
		ehd:
		RET
minimumOperand	ENDP

PUBLIC	PUTSS
PUBLIC	PUTC 
PUBLIC	BINtoDEC 
PUBLIC	OutMassive 
PUBLIC	GETCH
PUBLIC	bufferToStruct
PUBLIC	clearMassive
PUBLIC	checkOnDot
PUBLIC	checkOnSize
PUBLIC	checkOnNumber
PUBLIC	ATOI
PUBLIC	MulFive
PUBLIC	sumOperand
PUBLIC	outStruct
PUBLIC	normalize
PUBLIC	subtraction
PUBLIC	changeOperand
PUBLIC	minimumOperand
END