DATA    SEGMENT
MESS    DB      'INPUT ANY KEY TO CLEAR THE SCREEN $'
DATA    ENDS

STACK   SEGMENT STACK                   ;栈定义
STA     DB      128 DUP (?)
TOP     DW      ?
STACK   ENDS

CODES    SEGMENT
        ASSUME  CS:CODES,DS:DATA,SS:STACK,ES:DATA

START: ;段初始化
	MOV AX,DATA                 
    MOV DS,AX
    MOV ES,AX
    MOV AX,STACK
    MOV SS,AX
    MOV AX,TOP
    MOV SP,AX
    ;int 21,09号功能输出字符串
    LEA DX, MESS
    MOV AH, 9
    INT 21H 
            
	;int 21,01号功能等待键盘输入
    MOV AH, 01H
    INT 21H
	;int 10,07号功能清屏,向下滚动很多
	MOV AX,0700H 
	mov ch,10  ;(0,0),;左上角的行号
    mov cl,20  ;;左上角的列号
    mov dh,50 ;(24,79),右下角的行号
    mov dl,60 ;右下角的列号
    mov bh,70H ;07属性为黑底白字，17为蓝底更明显,70反白的白底黑字
	INT 10H

	;int 21,4C号功能结束程序，返回DOS权限
	MOV AH, 4CH   ; exit to operating system.
	INT 21H

CODES  ENDS
END START


