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
.CODE
START:
	mov ax,@data
    mov ds,ax

	mov ecx, 0
	
	lea esi, testStr
	lea edi, array
	
	
	PUTL requestForInputNumbers
;==============================================
;цикл ввода чисел
InputCycle:
	cmp ecx, 2
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
	
	inc ecx
	jmp InputCycle
inputError:
	PUTL errString
endInputCycle:	
;==============================================
	
	PUTL empty
	lea edi, array
	lea esi, array
	add esi, 18
	
	call normalize
	mov edi, esi
	call normalize
	
	lea edi, array
	call subtraction
	
	lea edi, array
	call outStruct
	
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
	
	
END START