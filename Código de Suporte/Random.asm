;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2020/2021
;--------------------------------------------------------------
; Demostração duma rotina de calculo de números aleatórios 
;
;--------------------------------------------------------------

.8086
.MODEL SMALL
.STACK 2048

DADOS	SEGMENT PARA 'DATA'
	ultimo_num_aleat dw 0

	str_num db 5 dup(?),'$'
DADOS	ENDS

CODIGO	SEGMENT PARA 'CODE'
	ASSUME CS:CODIGO, DS:DADOS

PRINC PROC
	MOV	AX, DADOS
	MOV	DS, AX

	mov	cx,10
ciclo:
	call	CalcAleat
	pop	ax ; vai buscar 'a pilha o numero aleatorio

	mov	dl,cl
	mov	dh,70
	push	dx
	push	ax
	call	impnum
	loop	ciclo

FIM:
	MOV	AH,4Ch
	INT	21h
PRINC ENDP

;------------------------------------------------------
;CalcAleat - calcula um numero aleatorio de 16 bits
;Parametros passados pela pilha
;entrada:
;não tem parametros de entrada
;saida:
;param1 - 16 bits - numero aleatorio calculado
;notas adicionais:
; deve estar definida uma variavel => ultimo_num_aleat dw 0
; assume-se que DS esta a apontar para o segmento onde esta armazenada ultimo_num_aleat
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
	mov	ax,65521
	push	dx
	mul	cx
	pop	dx
	xchg	dl,dh
	add	dx,32749
	add	dx,ax

	mov	ultimo_num_aleat,dx

	mov	[BP+4],dx

	pop	dx
	pop	cx
	pop	ax
	pop	bp
	ret
CalcAleat endp

;------------------------------------------------------
;impnum - imprime um numero de 16 bits na posicao x,y
;Parametros passados pela pilha
;entrada:
;param1 -  8 bits - posicao x
;param2 -  8 bits - posicao y
;param3 - 16 bits - numero a imprimir
;saida:
;não tem parametros de saída
;notas adicionais:
; deve estar definida uma variavel => str_num db 5 dup(?),'$'
; assume-se que DS esta a apontar para o segmento onde esta armazenada str_num
; sao eliminados da pilha os parametros de entrada
impnum proc near
	push	bp
	mov		bp,sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	mov		ax,[bp+4] ;param3
	lea		di,[str_num+5]
	mov		cx,5
prox_dig:
	xor		dx,dx
	mov		bx,10
	div		bx
	add		dl,'0' ; dh e' sempre 0
	dec		di
	mov		[di],dl
	loop	prox_dig

	mov		ah,02h
	mov		bh,00h
	mov		dl,[bp+7] ;param1
	mov		dh,[bp+6] ;param2
	int		10h
	mov		dx,di
	mov		ah,09h
	int		21h
	pop		di
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	pop		bp
	ret		4 ;limpa parametros (4 bytes) colocados na pilha
impnum endp

CODIGO	ENDS
END	PRINC

