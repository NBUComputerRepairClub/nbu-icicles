.model small
.data
	A dd 12345678h
	B dd 534acde3h
	SUM dd ?
.code
start:
	mov ax,@data
	mov ds,ax
	mov es,ax
	lea si,A
	mov ax,word ptr[si] ;读取低16位5678h
	mov dx,word ptr[si+2] ;读取高兆拦中16位1234h
	lea si,B
	mov bx,word ptr[si]
	mov cx,word ptr[si+2] ;下面完成 DX:AX+CX:BX
	add ax,bx
	adc dx,cx ;如果低16位产生衡基进位则自动加上1（2进制族山进位只可能进1）
	lea di,SUM
	mov word ptr[di],ax
	mov word ptr[di+2],dx
	mov ah,4ch
	int 21h
END