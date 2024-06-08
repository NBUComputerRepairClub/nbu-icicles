assume cs:code,ds:data,ss:stack

data segment

;**********************************************************************************************************
;**********************************************************************************************************
;**********************************************************************************************************

BOUNDARY_COLOR		dw	1131H
NEXT_ROW		dw	160

SNAKE_HEAD		dw	0
SNAKE_STERN		dw	12

SNAKE_COLOR		dw	2201H

SNAKE			dw	200 dup (0,0,0)


NEW_NODE		dw	18


FOOD_LOCTION		dw	160*5 + 30*2
FOOD_COLOR		dw	4439H


UP			db	48H
DOWN			db	50H
LEFT			db	4BH		
RIGHT			db	4DH

BACK_GROUND_COLOR	dw	0700H	


DIRECTION		dw	3					;up 0 down 1 left 2 right 3

DIRECTION_FUNTION	dw	OFFSET isMoveUp 	- OFFSET greedy_snake + 7E00H	; 0
			dw	OFFSET isMoveDown 	- OFFSET greedy_snake + 7E00H	; 1
			dw	OFFSET isMoveLeft 	- OFFSET greedy_snake + 7E00H	; 2
			dw	OFFSET isMoveRight 	- OFFSET greedy_snake + 7E00H	; 3

;**********************************************************************************************************
;**********************************************************************************************************
;**********************************************************************************************************

data ends

stack segment stack
	db	128 dup (0)
stack ends



code segment

	start:	mov ax,stack
		mov ss,ax
		mov sp,128


		call sav_old_int9
		call set_new_int9
		call cpy_greedy_snake



		mov bx,0
		push bx
		mov bx,7E00H
		push bx

		retf


		mov ax,4C00H
		int 21H


;================================================================
greedy_snake:	call init_reg
		call clear_screen
		call init_screen
		call init_direction
		call init_food
		

;nextDelay:	call delay
;		cli
;		call isMoveDirection
;		sti
;		jmp nextDelay


testA:		mov ax,1000H
		jmp testA


		mov ax,4C00H
		int 21H


;================================================================
init_food:	mov si,FOOD_LOCTION
		mov dx,FOOD_COLOR

		mov es:[si],dx

	
		ret
;================================================================
isMoveDirection:
		mov bx,DIRECTION
		add bx,bx

		call word ptr ds:DIRECTION_FUNTION[bx]	

		ret
;================================================================
delay:		push ax
		push dx

		mov dx,9000H
		sub ax,ax

delaying:	sub ax,1000H
		sbb dx,0
		cmp ax,0
		jne delaying
		cmp dx,0
		jne delaying

		pop dx
		pop ax
		ret
;================================================================
init_direction:
		mov DIRECTION,3
		ret
;================================================================
new_int9:	push ax

		in al,60H
		pushf
		call dword ptr cs:[200H]


		cmp al,UP
		je isUp
		cmp al,DOWN
		je isDown
		cmp al,LEFT
		je isLeft
		cmp al,RIGHT
		je isRight


		cmp al,3BH
		jne int9Ret
		call change_screen_color

int9Ret:	pop ax
		iret

;================================================================
isUp:		mov di,160*24 + 40*2
		mov byte ptr es:[di],'U'
		cmp DIRECTION,1
		je int9Ret
		call isMoveUp
		jmp int9Ret

isDown:		mov di,160*24 + 40*2
		mov byte ptr es:[di],'D'
		cmp DIRECTION,0
		je int9Ret
		call isMoveDown
		jmp int9Ret

isLeft:		mov di,160*24 + 40*2
		mov byte ptr es:[di],'L'
		cmp DIRECTION,3
		je int9Ret
		call isMoveLeft
		jmp int9Ret

isRight:	mov di,160*24 + 40*2
		mov byte ptr es:[di],'R'
		cmp DIRECTION,2
		je int9Ret
		call isMoveRight
		jmp int9Ret
	


;================================================================
isFood:		cmp byte ptr es:[si],'9'
		jne noFood
		call eat_food
		call new_food
		ret

noFood:		mov di,160*24 + 10 *2
		mov word ptr es:[di],5535H
		call game_over
		ret


;================================================================
game_over:	call clear_screen

		mov ax,4C00H
		int 21H

		ret
;================================================================
new_food:	push ax
		push bx


newFood:	mov al,0
		out 70H,al
		in al,71H

		mov dl,al				;AL = 0001 0002
		shr al,1
		shr al,1
		shr al,1
		shr al,1
		and dl,00001111B

		mov bl,10
		mul bl

		add al,dl
		mov bl,al

		mul bl

		shr ax,1
		shl ax,1
		add ax,168
		
		mov di,ax
		cmp byte ptr es:[di],0
		jne newFood

		push FOOD_COLOR
		pop es:[di]


		pop bx
		pop ax
		ret
;================================================================
eat_food:	push NEW_NODE
		pop ds:[bx+0]

		mov bx,OFFSET SNAKE
		add bx,NEW_NODE


		mov word ptr ds:[bx+0],0		;0

		mov ds:[bx+2],si			;2
		push SNAKE_COLOR
		pop es:[si]

		push SNAKE_HEAD				;4
		pop ds:[bx+4]

		push NEW_NODE
		pop SNAKE_HEAD

	
		add NEW_NODE,6
	
		ret
;================================================================
isMoveRight:	mov bx,OFFSET SNAKE
		add bx,SNAKE_HEAD
		mov si,ds:[bx+2]
		add si,2
	
		cmp byte ptr es:[si],0
		jne noMoveRight
		call new_snake
		mov DIRECTION,3
		ret

noMoveRight:	call isFood
		ret
;================================================================
isMoveLeft:	mov bx,OFFSET SNAKE
		add bx,SNAKE_HEAD
		mov si,ds:[bx+2]
		sub si,2
	
		cmp byte ptr es:[si],0
		jne noMoveLeft
		call new_snake
		mov DIRECTION,2
		ret

noMoveLeft:	call isFood
		ret
;================================================================
isMoveDown:	mov bx,OFFSET SNAKE
		add bx,SNAKE_HEAD
		mov si,ds:[bx+2]
		add si,NEXT_ROW
	
		cmp byte ptr es:[si],0
		jne noMoveDown
		call new_snake
		mov DIRECTION,1
		ret

noMoveDown:	call isFood
		ret
;================================================================
isMoveUp:	mov bx,OFFSET SNAKE
		add bx,SNAKE_HEAD
		mov si,ds:[bx+2]
		sub si,NEXT_ROW

		cmp byte ptr es:[si],0
		jne noMoveUp
		call new_snake	
		mov DIRECTION,0
		ret


noMoveUp:	call isFood
		ret


;================================================================
new_snake:	push SNAKE_STERN
		pop ds:[bx+0]

		mov bx,OFFSET SNAKE
		add bx,SNAKE_STERN

		push ds:[bx+0]
		mov word ptr ds:[bx+0],0
		
		mov di,ds:[bx+2]
		push BACK_GROUND_COLOR
		pop es:[di]

		mov ds:[bx+2],si
		push SNAKE_COLOR
		pop es:[si]

		push SNAKE_HEAD
		pop ds:[bx+4]

		
		push SNAKE_STERN
		pop SNAKE_HEAD

		pop SNAKE_STERN

		ret
;================================================================
change_screen_color:
		push bx
		push cx
		push dx

		mov bx,0B800H
		mov es,bx

		mov bx,1
		mov cx,2000

changeScreenColor:
		inc byte ptr es:[bx]
		add bx,2
		loop changeScreenColor

		pop dx
		pop cx
		pop bx
		ret
;================================================================
init_screen:	mov dx,BOUNDARY_COLOR
		call init_up_down_line
		call init_left_right_line

		call init_snake
		
		ret

;================================================================
init_snake:	mov bx,OFFSET SNAKE
		add bx,SNAKE_HEAD
		mov dx,SNAKE_COLOR
		mov si,160*10 + 40*2

		mov word ptr ds:[bx+0],0
		mov ds:[bx+2],si
		mov es:[si],dx
		mov word ptr ds:[bx+4],6

		add bx,6
		sub si,2

		mov word ptr ds:[bx+0],0
		mov ds:[bx+2],si
		mov es:[si],dx
		mov word ptr ds:[bx+4],12

		add bx,6
		sub si,2

		mov word ptr ds:[bx+0],6
		mov ds:[bx+2],si
		mov es:[si],dx
		mov word ptr ds:[bx+4],18

		ret
;================================================================
init_left_right_line:
		mov bx,0
		mov cx,23
	
initLeftRightLine:
		mov es:[bx],dx
		mov es:[bx+158],dx
		add bx,NEXT_ROW
		loop initLeftRightLine

		ret
;================================================================
init_up_down_line:
		mov bx,0
		mov cx,80

initUpDownLine:	mov es:[bx],dx
		mov es:[bx+160*23],dx
		add bx,2
		loop initUpDownLine

		ret
;================================================================
clear_screen:	mov bx,0
		mov dx,0700H
		mov cx,2000

clearScreen:	mov es:[bx],dx
		add bx,2
		loop clearScreen
		
		ret
;================================================================
init_reg:	mov bx,0B800H
		mov es,bx

		mov bx,data
		mov ds,bx		
		ret

snake_end:	nop








;================================================================
set_new_int9:
		mov bx,0
		mov es,bx

		cli
		mov word ptr es:[9*4],OFFSET new_int9 - OFFSET greedy_snake + 7E00H
		mov word ptr es:[9*4+2],0
		sti

		ret
;================================================================
sav_old_int9:
		mov bx,0
		mov es,bx

		push es:[9*4]
		pop es:[200H]
		push es:[9*4+2]
		pop es:[202H]

		ret
;================================================================
cpy_greedy_snake:
		mov bx,cs
		mov ds,bx
		mov si,OFFSET greedy_snake

		mov bx,0
		mov es,bx
		mov di,7E00H

		mov cx,OFFSET snake_end - OFFSET greedy_snake
		cld
		rep movsb


		ret

code ends



end start




