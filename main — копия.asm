.MODEL SMALL
.STACK 200h
.386
INCLUDE macros.mac
.DATA    
	Float	struc
		sign	db	0
		integer	dw	512
		double	dd	64 ; 24th bit set 
	Float	ends
	
	
	empty DB 0
	requestForInput DB "Enter from 3 to 20 binary numbers", 0
	errString DB "data entry error", 0
	questions	db	"want to enter another number? [y|n]", 0
	testStr DB 100,100 dup ('$')
	
	array	Float	20	dup(<>)	
.CODE
START:
	mov ax,@data
    mov ds,ax

	lea edi, array
	mov	[edi].integer, 30h
	inc edi
	mov	[edi].integer, 31h
	inc edi
	mov	[edi].integer, 32h
	inc edi
	mov	[edi].integer, 33h
	inc edi
	mov	[edi].integer, 34h
	inc edi
	mov	[edi].integer, 35h
	inc edi
	mov	[edi].integer, 35h
	inc edi
	mov	[edi].integer, 35h
	inc edi
	mov	[edi].integer, 35h
	inc edi
	mov	[edi].integer, 35h
	inc edi
	mov	[edi].integer, 35h
	inc edi
	mov	[edi].integer, 35h
	inc edi
	mov	[edi].integer, 35h
	inc edi
	mov	[edi].integer, 35h
	add edi, type Float
	
	PUTL requestForInput
	
	xor ecx, ecx
inputStr:
	push ecx
	
	mov ax, cx
	call BINtoDEC
	PUTL empty
	INPUTMAS testStr
	
	PUTL empty
	
	lea si, testStr
	call InputValidation
	
	cmp eax, -1
	je erorrString
	NullMass testStr
	PUTL empty
	
	
	
	pop ecx
	inc ecx
	cmp ecx, 1
	jl inputStr
	cmp ecx, 20
	jge inputIndex
	PUTLS questions
	call GETCH
	cmp al, 'n'
	je inputStr
	jmp inputIndex
erorrString:
	PUTLS errString
	
inputIndex:	
	
	MOV     AH, 4ch
    MOV     AL, 0  
    INT     21h
	EXTRN	PUTSS:NEAR
	EXTRN	PUTC:NEAR
	EXTRN	SLENGHT:NEAR
	EXTRN	BINtoDEC:NEAR
	EXTRN	OutMassive:NEAR
	EXTRN	RemoveSpace:NEAR
	EXTRN	MassiveNull:NEAR
	EXTRN	GETCH:NEAR
	EXTRN   InputValidation:NEAR
	
	
	
END START