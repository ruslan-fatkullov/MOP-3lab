MODEL SMALL
.CODE
.386
	
 LOCALS
;==============================================
; Подпрограмма корректности введенного числа 
; input: esi -  адрес строки
;==============================================
InputValidation	PROC	NEAR
		push si
		xor eax, eax
		xor ecx, ecx
		V0:
		cmp byte ptr[si+2], '$'
		je V2
		cmp byte ptr[si+2], '.'
		je V1
			
		
		inc si
		jmp V0
		V1:
		inc eax
		inc si
		jmp V0
		V2:
		
		cmp eax, 1
		jne Er
		
		;-----one dot---
		pop si
		call BitCheck
		
		cmp eax, -1
		je Er
		
		;-----one dot---
		
		jmp endV
		
		;-------ошибка------------
		Er:
		mov eax, -1
		;-------ошибка------
		
		endV:
        RET
InputValidation	ENDP

;==============================================
; Подпрограмма проверки разрядности числа 
; input: esi -  адрес строки
;==============================================
BitCheck	PROC	NEAR
		xor ecx, ecx
		T0:
		cmp byte ptr[si+2], '.'
		je T3
		
		
		inc ecx
		inc si
		jmp T0
		
		T3:
		cmp ecx, 10
		JG T1
		
		inc si
		xor ecx, ecx
		T4:
		cmp byte ptr[si+2], '$'
		je T5
		inc ecx
		inc si
		jmp T4
		
		T5:
		mov eax,1
		cmp ecx, 8
		JG T1
		
		jmp T2
		
		T1:
		mov eax, -1
		
		T2:
        RET
BitCheck	ENDP
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
; Подпрограмма подсчета числа символов в сроке
;==============================================
SLENGHT	PROC	NEAR
        XOR AX, AX
	STARTLENGHT:
		cmp BYTE PTR[SI+2], '$'
		JE ENDLENGHT
		cmp BYTE PTR[SI+2], 0FFH
		JE ENDLENGHT
		inc AX
		inc SI
		JMP STARTLENGHT
        ENDLENGHT: 
		sub ax, 1
		ret
SLENGHT	ENDP

;==============================================
; Подпрограмма вывода числа на экран в 
; в десятичном виде из регистра AX
;==============================================
BINtoDEC	PROC	NEAR
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
	
		ret
BINtoDEC	ENDP



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

;==============================================
; Подпрограмма удаляет из строки лишние пробелы
; и записывает полученную строку в новый массив 
;==============================================
RemoveSpace	PROC	NEAR
  M02:
	cmp byte ptr[si+2], '$'
	je M03
	cmp byte ptr[si+2], ' '
	jne prop
		mov dl, [si+2]
		mov [di + 2], dl
		inc di
		M05:
		inc si
		cmp byte ptr[si+2], ' '
		jne prop
		jmp M05
	prop:
	mov dl, [si+2]
	mov [di + 2], dl
	inc si
	inc di
	M04:
	jmp M02
	M03:
	ret
RemoveSpace	ENDP
;==============================================
; Подпрограмма обнуляет массив
;==============================================
MassiveNull	PROC	NEAR
	mov ecx, 100d
	S1:
		mov [si+2], '$'
		inc si
		loop S1
	ret
MassiveNull	ENDP

PUBLIC	PUTSS, PUTC, SLENGHT, BINtoDEC, OutMassive, RemoveSpace, MassiveNull, GETCH, InputValidation
END