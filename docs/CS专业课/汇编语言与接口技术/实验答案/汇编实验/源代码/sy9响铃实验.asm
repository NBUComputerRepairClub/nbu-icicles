data SEGMENT 
	ts DB 'please input:$' 
	again DB 0ah,0dh,'press ctrl+C to end,else again:$' 
data ENDS 

code SEGMENT 
	ASSUME CS:code,DS:data 
start: 
	;加载数据段
	MOV AX,data  
	MOV DS,AX 
again1:
	LEA DX,ts 
	MOV AH,09h ;显示输出提示字符串 
	INT 21h 
	
	MOV AH,01h ;调用01号功能接收字符 
	INT 21h 
	CMP AL,'1' ;与1的ASCll比较，小于则转移 
	JB restart 
	CMP AL,'9' ;与9比较，大于则转移 
	JA restart  
	
	SUB AL,30h ;将ASCll码转换为数字 
	XOR AH,AH ;将AX高八位清零，此时AX中的数字为接收的数字 
	MOV BP,AX ;将AX的值赋给BP以控制循环 
BELL:
	MOV AH,02 ;响铃程序段 
	MOV DL,07 
	INT 21H 
	;延时
	CALL delayp
	DEC BP ;BP-1
	CMP BP,30H
	JNZ BELL 	;不等于0时跳转继续循环
 
restart:
	LEA DX,again ;提示是否再次运行本程序 
	MOV AH,09h 
	INT 21h  
	MOV AH,01h ;接收字符 
	INT 21h 
	CALL CRLF
	CMP AL,3 ;CTRL+C对应ascll为3，不相同则继续循环
	JNZ again1

MOV AH,4ch 
INT 21h 

;换行函数
CRLF    PROC    near 
	PUSH DX ;保护之前的数据
	PUSH AX                    
	MOV DL,0DH
    MOV AH,02H
    INT 21H       ;光标移到第一列              
    MOV DL,0AH
    MOV AH,02H
    INT 21H       ;光标移到下一行
    POP AX
	POP DX             
    RET
CRLF ENDP

DELAYP PROC
	push dx
	push cx
	push ax ;保存数据
	
	MOV AH, 2DH ;2DH，设置系统时间,初始为0
    MOV CX, 0
    MOV DX, 0
    INT 21H
READ:  
	MOV AH, 2CH ;查询系统时间
    INT 21H

    MOV AL, 100 ;=100D
    MUL DH 		;AL=DH*100
    MOV DH, 0 
    ADD AX, DX  ;Ax=当前秒数*100
    CMP AX, 100  ;=100时结束，不产生进位或借位，概率问题
    JC  READ

	pop ax ;恢复数据
	pop cx
	pop dx
    RET
DELAYP ENDP

code ENDS 
END start 

