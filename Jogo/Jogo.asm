;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2020/2021
;--------------------------------------------------------------
;
;		Tomás Gomes Silva 				- 2020143845
;		João Miguel Duarte dos Santos 	- 2020136093
;
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'


		STR12	 		DB 		"            "	; String para 12 digitos
		DDMMAAAA 		db		"                     "
		Parede 			db 		'±'
		
		Horas			dw		0				; Vai guardar a HORA actual
		Minutos			dw		0				; Vai guardar os minutos actuais
		Segundos		dw		0				; Vai guardar os segundos actuais
		Old_seg			dw		0				; Guarda os �ltimos segundos que foram lidos
		Tempo_init		dw		0				; Guarda O Tempo de inicio do jogo
		Tempo_j			dw		0				; Guarda O Tempo que decorre o  jogo
		Tempo_limite	dw		99				; tempo m�ximo de Jogo
		String_TJ		db		"   /100$"

		String_num 		db 		"  0 $"
        String_nome  	db	    "FIO     $"	
		Construir_nome	db	    "        $"	

		Dim_nome		dw		5	; Comprimento do Nome
		indice_nome		dw		0	; indice que aponta para Construir_nome
		Nivel			dw		1
		
		Fim_Ganhou		db	    " Ganhou $"	
		Fim_Perdeu		db	    " Perdeu $"	

        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'

        Fich         	db      'labi.TXT',0
		Fich_menu       db      'menu.TXT',0
        HandleFich      dw      0
        car_fich        db      ?

		ultimo_num_aleat dw 0
		str_num db 5 dup(?),'$'

		string			db	"Teste pr�tico de T.I",0
		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	3	; a linha pode ir de [1 .. 25]
		POSx			db	3	; POSx pode ir [1..80]	
		POSya			db	3	; Posi��o anterior de y
		POSxa			db	3	; Posi��o anterior de x
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg


;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;########################################################################
; MOSTRA - Faz o display de uma string terminada em $

MOSTRA MACRO STR 
	PUSH AX
	PUSH DX
	MOV AH,09H
	LEA DX,STR 
	INT 21H
	POP DX
	POP AX
ENDM

; FIM DAS MACROS



;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80
		
apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp


;########################################################################
; IMP_FICH

; MENU INICIAL - Mostra o menu principal
IMP_MENU	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich_menu
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo
		mov		ah,4CH
		INT		21h

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET

IMP_MENU ENDP

; MOSTRA LABIRINTO - Mostra o labirinto escrito no ficheiro labi.txt
IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo
		INT 	21h


erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET
		
IMP_FICH	endp		


Trata_Horas PROC

		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX		

		CALL 	Ler_TEMPO				; Horas MINUTOS e segundos do Sistema
		
		MOV		AX, Segundos
		cmp		AX, Old_seg			; VErifica se os segundos mudaram desde a ultima leitura
		je		fim_horas			; Se a hora não mudou desde a última leitura sai.
		mov		Old_seg, AX			; Se segundos são diferentes actualiza informação do tempo 
		inc		Tempo_j

		MOV 	AX, Tempo_j
		MOV 	BX, Tempo_limite
		cmp 	AX, BX
		je		JOGO_TERMINOU_TEMPO

		mov 	ax,Horas
		MOV		bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'h'		
		MOV 	STR12[3],'$'
		GOTO_XY 1,0
		MOSTRA STR12 		
        
		mov 	ax,Minutos
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'m'		
		MOV 	STR12[3],'$'
		GOTO_XY	5,0
		MOSTRA	STR12 		
		
		mov 	ax,Segundos
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'s'		
		MOV 	STR12[3],'$'
		GOTO_XY	9,0
		MOSTRA	STR12	

		mov 	ax,Tempo_j
		MOV		bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h
		MOV 	String_TJ[0],'0' 
		MOV 	String_TJ[1],al 
		MOV 	String_TJ[2],ah	

		mov 	ax,Tempo_limite
		MOV		bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h
		MOV 	String_TJ[3],'/'	
		MOV 	String_TJ[4],'0'	
		MOV 	String_TJ[5], al	
		MOV 	String_TJ[6], ah
		MOV 	String_TJ[7],'$'	
		GOTO_XY	59,0
		MOSTRA	String_TJ
		
						
fim_horas:		
		goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas
		
		POPF
		POP DX		
		POP CX
		POP BX
		POP AX
		RET		
			
Trata_Horas ENDP


Ler_TEMPO PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos, AX		; guarda segundos na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minutos, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Horas,AX			; guarda HORAS na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_TEMPO   ENDP 




;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC

SEM_TECLA:
		call Trata_Horas	

		MOV	AH,0BH
		INT 21h
		cmp AL,0
		je	sem_tecla

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1

		
SAI_TECLA:	RET
LE_TECLA	endp




;########################################################################
; Avatar

AVATAR	PROC

			
			JMP CALC_RANDOM_Y
			JMP CALC_RANDOM_X
			goto_xy	POSx,POSy

			mov		ax,0B800h
			mov		es,ax
			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h		; Guarda o Caracter que est� na posi��o do Cursor
			mov		bh,0			; numero da p�gina
			int		10h			
			mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor	
	

CALC_RANDOM_X:
	call	CalcAleat
	pop	ax
	CMP AX, 72
	JNBE 	CALC_RANDOM_X
	MOV POSx, AL
	MOV POSxa, AL
	JMP CALC_RANDOM_Y

CALC_RANDOM_Y:
	call	CalcAleat
	pop	ax
	CMP AX, 18
	JNBE 	CALC_RANDOM_Y
	MOV POSy, AL
	MOV POSya, AL
	JMP CHECK_COORDS

CHECK_COORDS:
	goto_xy	POSx,POSy
	mov 	ah, 08h
	int 	10H 
	CMP		AL, ' '
	JE 		CICLO
	JMP 	CALC_RANDOM_X

FIM_LETRA:	
	MOV SI, -1
	goto_xy		POSx,POSy
	JMP CHECK_VITORIA

CHECK_LETRA:
	INC SI
	MOV AL, String_nome[SI]
	CMP AL, ' '
	JE FIM_LETRA
	CMP AL, CL
	JNE CHECK_LETRA
	MOV Construir_nome[SI], CL
	goto_xy		10,21
	MOSTRA 		Construir_nome
	JMP CHECK_LETRA

CHECK_VITORIA:
	INC SI
	MOV AL, String_nome[SI]
	MOV AH, Construir_nome[SI]
	CMP AL, ' '
	JE JOGO_TERMINOU_VITORIA
	CMP AL, AH
	JNE IMPRIME
	JMP CHECK_VITORIA


CICLO:     

			goto_xy		10,20
			MOSTRA 		String_nome

			goto_xy	POSxa,POSya		; Vai para a posi��o anterior do cursor
			mov		ah, 02h
			mov		dl, Car			; Repoe Caracter guardado 
			int		21H		
		
			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h		
			mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor
		
			goto_xy	76,0			; Mostra o caractr que estava na posi��o do AVATAR
			mov		ah, 02h			; IMPRIME caracter da posi��o no canto
			mov		dl, Car	
			int		21H		

			MOV		SI, -1
			MOV		CL, DL
			CMP		CL, ' '
			JNE		CHECK_LETRA

			goto_xy	POSx,POSy		; Vai para posi��o do cursor


IMPRIME:

			mov		ah, 02h
			mov		dl, 190	; Coloca AVATAR
			int		21H	
			goto_xy	POSxa,POSya	; Vai para posi��o do cursor
		
			mov		al, POSx	; Guarda a posi��o do cursor
			mov		POSxa, al
			mov		al, POSy	; Guarda a posi��o do cursor
			mov 	POSya, al
		
LER_SETA:	
	call 	LE_TECLA
	cmp		ah, 1
	je		ESTEND
	CMP 	AL, 27	; ESCAPE
	JE		FIM
	jmp		LER_SETA
		
ESTEND:		
			cmp 	al,48h
			jne		BAIXO
			dec		POSy		;cima

			goto_xy	POSx,POSy ; Move o jogador uma posição para cima
			mov 	ah, 08h ; Ler o caractere que está no sítio do cursor
			int 	10H ; Executar o interrupt
			cmp		al, 10110001b ; Comparar se na posição do cursor está o símbolo '±' que neste caso é a parede
			jne		CICLO ; Se não está então é uma jogada válida e o jogador fica lá
			inc 	POSy ; Se está em cima de uma parece a posição é incrementada (para voltar à posição inicial)
			goto_xy	POSx,POSy ; Move o jogador de volta para onde estava
			jmp 	CICLO ; Volta para o ciclo sem ter alterado a posição em que estava

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			inc 	POSy		;Baixo

			goto_xy	POSx,POSy
			mov 	ah, 08h
			int 	10H
			cmp		al, 10110001b
			jne		CICLO
			dec 	POSy
			goto_xy	POSx,POSy
			jmp 	CICLO

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			dec		POSx		;Esquerda

			goto_xy	POSx,POSy
			mov 	ah, 08h
			int 	10H
			cmp		al, 10110001b
			jne		CICLO
			inc 	POSx
			goto_xy	POSx,POSy
			jmp 	CICLO

DIREITA:
			cmp		al,4Dh
			jne		LER_SETA 
			inc		POSx		;Direita

			goto_xy	POSx,POSy
			mov 	ah, 08h
			int 	10H
			cmp		al, 10110001b
			jne		CICLO
			dec 	POSx
			goto_xy	POSx,POSy
			jmp 	CICLO
	

fim:				
			RET
AVATAR		endp

JOGO_TERMINOU_GANHOU PROC
	CALL 		apaga_ecran
	goto_xy		1, 1
	MOSTRA		Fim_Ganhou
	MOV			AH,4CH
	INT			21H
JOGO_TERMINOU_GANHOU ENDP

JOGO_TERMINOU_TEMPO PROC
	CALL 		apaga_ecran
	goto_xy		1, 1
	MOSTRA		Fim_Perdeu
	MOV			AH,4CH
	INT			21H
JOGO_TERMINOU_TEMPO ENDP

JOGO_TERMINOU_VITORIA PROC
	MOV			AX, 10
	SUB			Tempo_limite, AX
	XOR			AX, AX	
	MOV			Tempo_j, AX
	CALL 		Trata_Horas	
	INC 		Nivel

	MOV AX, 2
	CMP AX, Nivel
	JE 	CARREGAR_NIVEL_2
	MOV AX, 3
	CMP AX, Nivel
	JE 	CARREGAR_NIVEL_3
	MOV AX, 4
	CMP AX, Nivel
	JE 	CARREGAR_NIVEL_4
	MOV AX, 5
	CMP AX, Nivel
	JE 	CARREGAR_NIVEL_5
	MOV AX, 6
	
	CALL JOGO_TERMINOU_GANHOU

CARREGAR_NIVEL_2:
	MOV 	String_nome[0],'M'
	MOV 	String_nome[1],'E'
	MOV 	String_nome[2],'D'
	MOV 	String_nome[3],'O'

	MOV 	Construir_nome[0],' '
	MOV 	Construir_nome[1],' '
	MOV 	Construir_nome[2],' '
	MOV 	Construir_nome[3],' '
	MOV 	Construir_nome[4],' '
	MOV 	Construir_nome[5],' '
	MOV 	Construir_nome[6],' '

	goto_xy		10,20
	MOSTRA 		String_nome
	goto_xy		10,21
	MOSTRA 		Construir_nome

	JMP 		AVATAR

CARREGAR_NIVEL_3:
	MOV 	String_nome[0],'P'
	MOV 	String_nome[1],'R'
	MOV 	String_nome[2],'A'
	MOV 	String_nome[3],'I'
	MOV 	String_nome[4],'A'

	MOV 	Construir_nome[0],' '
	MOV 	Construir_nome[1],' '
	MOV 	Construir_nome[2],' '
	MOV 	Construir_nome[3],' '
	MOV 	Construir_nome[4],' '
	MOV 	Construir_nome[5],' '
	MOV 	Construir_nome[6],' '

	goto_xy		10,20
	MOSTRA 		String_nome
	goto_xy		10,21
	MOSTRA 		Construir_nome

	JMP 		AVATAR

CARREGAR_NIVEL_4:
	MOV 	String_nome[0],'P'
	MOV 	String_nome[1],'L'
	MOV 	String_nome[2],'A'
	MOV 	String_nome[3],'N'
	MOV 	String_nome[4],'T'
	MOV 	String_nome[5],'A'

	MOV 	Construir_nome[0],' '
	MOV 	Construir_nome[1],' '
	MOV 	Construir_nome[2],' '
	MOV 	Construir_nome[3],' '
	MOV 	Construir_nome[4],' '
	MOV 	Construir_nome[5],' '
	MOV 	Construir_nome[6],' '

	goto_xy		10,20
	MOSTRA 		String_nome
	goto_xy		10,21
	MOSTRA 		Construir_nome

	JMP 		AVATAR

CARREGAR_NIVEL_5:
	MOV 	String_nome[0],'V'
	MOV 	String_nome[1],'I'
	MOV 	String_nome[2],'R'
	MOV 	String_nome[3],'T'
	MOV 	String_nome[4],'U'
	MOV 	String_nome[5],'A'
	MOV 	String_nome[6],'L'

	MOV 	Construir_nome[0],' '
	MOV 	Construir_nome[1],' '
	MOV 	Construir_nome[2],' '
	MOV 	Construir_nome[3],' '
	MOV 	Construir_nome[4],' '
	MOV 	Construir_nome[5],' '
	MOV 	Construir_nome[6],' '

	goto_xy		10,20
	MOSTRA 		String_nome
	goto_xy		10,21
	MOSTRA 		Construir_nome

	JMP 		AVATAR


JOGO_TERMINOU_VITORIA ENDP

CalcAleat proc near

	sub	sp,2
	push	bp
	mov	bp,sp
	push	ax
	push	cx
	push	dx	
	mov	ax,[bp+4]
	mov	[bp+2],ax

	mov	ah,00h
	int	1ah

	add	dx,ultimo_num_aleat
	add	cx,dx	
	mov	ax,80
	push	dx
	mul	cx
	pop	dx
	xchg	dl,dh
	add	dx,0
	add	dx,ax

	mov	ultimo_num_aleat,dx

	mov	[BP+4],dx

	pop	dx
	pop	cx
	pop	ax
	pop	bp
	ret
CalcAleat endp


;########################################################################
Main  proc

		mov			ax, dseg
		mov			ds,ax

		mov			ax,0B800h
		mov			es,ax

		call		apaga_ecran
		goto_xy		0,0
		call		IMP_MENU
		
MENU_PRINCIPAL:
	MOV	AH,0BH
	INT 21h
	CMP AL, 0 ; sem tecla
	JE MENU_PRINCIPAL

	xor ax, ax

	mov		ah,08h
	int		21h
	cmp		al,'1' ; tecla para jogar
	je		PRINT_LAB 

	xor ax, ax

	mov		ah,08h
	int		21h
	cmp		al,'2' ; tecla para sair
	je		SAIR 

	jmp MENU_PRINCIPAL


PRINT_LAB:
	call		apaga_ecran
	goto_xy		0,0
	call		IMP_FICH
	call 		AVATAR

SAIR:
	mov			ah,4CH
	INT			21h
Main	endp
Cseg	ends
end	Main


		
