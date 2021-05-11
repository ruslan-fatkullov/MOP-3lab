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
	minElem	db	"minimum element", 0
	res	db	"result", 0
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
	
	mov byte ptr[edi], al
	add edi, 1
	
	ClearMas testStr
	inc ecx
	jmp IndexCycle
endIndexCycle:
;==============================================	


;==============приведение================================
	PUTL empty
	xor ecx, ecx
	lea edi, array
	startPriv:
	cmp ecx, 20
	je endPriv
	
	call normalize
	add edi, 18
	inc ecx
	jmp startPriv
	
	endPriv:
;==============приведение================================	

;==============поиск минимального====================================
;минимальный в edi
	;;;lea edi, array+18
	lea edi, index+1
	getElement 
	lea edi, array
	add edi, eax
	;;;
	push edi
	lea edi, index+2
	getElement 
	lea edi, array
	add edi, eax
	mov esi, edi
	pop edi
	
	call changeOperand
	call minimumOperand
	PUTL minElem
	call outStruct
	PUTL empty
	;;;
;==============поиск минимального====================================



;==============замена местами при необходимости 1 и 2 операндов================================
		
	mov esi, edi
	;;;
	lea edi, index
	getElement 
	lea edi, array
	add edi, eax
	;;;
	call changeOperand
;==============замена местами при необходимости 1 и 1 операндов================================

	push eax

;=====================сложение==================================	
	cmp byte ptr[edi], '+'
	je secondSIgn
	cmp byte ptr[esi], '+'
	je SecondPlus
	call sumOperand
	jmp endSUM
	SecondPlus:
	call subtraction
	jmp endSUM
	secondSIgn:
	cmp byte ptr[esi], '+'
	je sum
	call subtraction
	jmp endSUM
	sum:
	call sumOperand
	endSUM:
;=====================сложение==================================	
	pop eax
	;lea edi, array
	cmp eax, 1
	je jkl
		lea edi, index
		getElement 
		lea edi, array
		add edi, eax
		jmp rtyy
	jkl:
		lea edi, index+1
		getElement 
		lea edi, array
		add edi, eax
	rtyy:




;==========================
;	lea edi, array
;	call outStruct
;	PUTL empty
;	add edi, 18
;	call outStruct
;	PUTL empty
;	add edi, 18
	PUTL res
	call outStruct
;==========================
	
	


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
	EXTRN	minimumOperand:NEAR	
	
END START