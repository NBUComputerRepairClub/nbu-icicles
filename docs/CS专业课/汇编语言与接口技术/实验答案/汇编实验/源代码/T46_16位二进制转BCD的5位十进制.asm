data segment
	array dw 54321
	dbcd db 5 dup(?)
data ends
code segment
assume cs:code,ds:data;
start:
	mov ax,data
	mov ds,ax
	mov dx,array
	mov bx,10000;����
	mov cx,10;�����ĳ���
	mov si,5;ȡ�����
again:    
	mov ax,dx
	mov dx,0
	div bx
	mov dbcd[si],al
	push dx
	mov ax,bx
	mov dx,0
	div cx
	mov bx,ax
	pop dx
	dec si
	jnz again
	call disp
	mov ah,4ch
	int 21h
disp proc;������
	push si
	mov si,5
play:    
	mov dl,dbcd[si]
	add dl,30h
	mov ah,02h
	int 21h
	dec si
	jnz play
	pop si
	ret        
disp endp
code ends
end start

