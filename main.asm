.MODEL SMALL
.STACK 200h
.386
INCLUDE macros.mac
.DATA    
	Float	struc
		sign	db	1 dup('+')
		integer	db	10 dup('|')
		real	db	7 dup('?')
	Float	ends
	
	
	ten DB 10d
	empty DB 0
	requestForInputNumbers DB "Enter from 3 to 20 numbers", 0
	requestForInputIndex DB "Enter i, j, k", 0
	errString DB "data entry error", 0
	questions	db	"want to enter another number? [y|n]", 0
	testStr db 20 
		db 21 dup(?)
	
	array	Float	20	dup(<>)	
	
	
	index DB 0,0,0
.CODE
START:
	mov ax,@data
    mov ds,ax

	mov cx, 0
	
	INPUTMAS testStr
	lea esi, testStr
	call ATOI
	
	lea edi, array
	
	
	PUTL requestForInputNumbers
;==============================================
;цикл ввода чисел
InputCycle:
	cmp cx, ax
	je endInputCycle
	
	;==============================================
	;ввод числа в буфер
	;проверка на корректность
	;запись из буфера в массив структур
	INPUTMAS testStr
	push eax
	CheckStr testStr ;меняется eax
	pop eax
	call bufferToStruct
	add edi, 18
	ClearMas testStr
	;==============================================
	PUTL empty
	inc cx
	jmp InputCycle
inputError:
	PUTL errString
endInputCycle:	
;==============================================


;==============================================
;цикл ввода индексов 
;записывает индексы в стек	
	lea di, index

	PUTL requestForInputIndex
	xor ecx, ecx
	lea esi, testStr
IndexCycle:
	cmp ecx, 3
	je endIndexCycle
	
	INPUTMAS testStr
	call ATOI; меняет AX
	PUTL empty
	call BINtoDEC
	
	mov byte ptr[edi], al
	add edi, 1
	
	ClearMas testStr
	inc ecx
	jmp IndexCycle
endIndexCycle:
;==============================================	


;==============умножение================================
	PUTL empty
	lea edi, array
	lea esi, array
	
	add edi, 36
	call MulFive
	lea edi, array
	call normalize
	add edi, 18
	call normalize
	add edi, 18
	call normalize
;==============умножение================================	
;==============замена местами при необходимости 2 и 3 операндов================================
	lea edi, array+18
	lea esi, array+36
	call changeOperand
;==============замена местами при необходимости 2 и 3 операндов================================



;=====================вычитание==================================	

	;первое отрицательное
	minusFirst:
	cmp byte ptr[edi], '+'
	je plusFirst
	cmp byte ptr[esi], '+'
	je plusSecond
	
	;второе отрицательное
	call subtraction
	cmp eax, 1
	jne endOfSUB
	mov byte ptr[edi], '+'
	
	jmp endOfSUB
	
	
	plusSecond:
	;второе положительно
	call sumOperand
	cmp eax, 1
	jne endOfSUB
	mov byte ptr[edi], '+'
	jmp endOfSUB
	
	
	;первое положительное
	plusFirst:
	cmp byte ptr[esi], '+'
	je fbdg
	call sumOperand
	cmp eax, 1
	jne endOfSUB
	mov byte ptr[edi], '-'
	jmp endOfSUB
	
	;второе положительно
	fbdg:
	call subtraction
	cmp eax, 1
	jne endOfSUB
	mov byte ptr[edi], '-'

	endOfSUB:
;=====================вычитание==================================	

	lea edi, array
	cmp eax, 1
	je jkl
		lea esi, array + 18
		jmp rtyy
	jkl:
		lea esi, array + 36
	rtyy:




;==========================
;	lea edi, array
;	call outStruct
;	PUTL empty
;	add edi, 18
;	call outStruct
;	PUTL empty
;	add edi, 18
	mov edi, esi
	call outStruct
;==========================
	
	
;==============================================
;цикл ввода индексов 
;записывает индексы в стек	
;	PUTL requestForInputIndex
;	xor ecx, ecx
;	lea esi, testStr
;IndexCycle:
;	cmp ecx, 3
;	je endIndexCycle
;	
;	INPUTMAS testStr
;	call ATOI; меняет AX
;	PUTL empty
;	call BINtoDEC
;	push ax
;	ClearMas testStr
;	inc ecx
;	jmp IndexCycle
;endIndexCycle:
;==============================================


	MOV     AH, 4ch
    MOV     AL, 0  
    INT     21h
	EXTRN	PUTSS:NEAR
	EXTRN	PUTC:NEAR
	EXTRN	BINtoDEC:NEAR
	EXTRN	OutMassive:NEAR
	EXTRN	GETCH:NEAR
	EXTRN	bufferToStruct:NEAR
	EXTRN	clearMassive:NEAR
	EXTRN	checkOnDot:NEAR
	EXTRN	checkOnSize:NEAR
	EXTRN	checkOnNumber:NEAR
	EXTRN	ATOI:NEAR
	EXTRN	MulFive:NEAR	
	EXTRN	sumOperand:NEAR
	EXTRN	outStruct:NEAR
	EXTRN	normalize:NEAR
	EXTRN	subtraction:NEAR
	EXTRN	changeOperand:NEAR
	
	
END START