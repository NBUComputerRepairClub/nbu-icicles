DATA SEGMENT
DATA ENDS
STACK SEGMENT STACK 'STACK'
	STA DB 128 DUP(?)
	TOP EQU LENGTH STA
STACK ENDS
CODE SEGMENT
ASSUME CS:CODE,DS:DATA,SS:STACK
START:
	;初始化相关寄存器
    MOV AX,DATA
	MOV DS,AX
	MOV AX,STACK
	MOV SS,AX
	MOV SP,TOP
	
	;置行、列计数初值,字符0开始
	MOV BL,0;BL中存放要打印字符的ASCII码
	MOV CX,16;设置外层循环次数，即行数
OUTER:
	PUSH CX
	MOV CX,16;设置内层循环次数，即列数
INNER:        
	CMP BL,0AH;判断是否为换行符
	JZ CHANGE
	CMP BL,0DH;判断是否为回车符
	JZ CHANGE
	MOV DL,BL;显示码→DL
SHOW:
	;输出DL里的内容
	MOV AH,2
	INT 21H ;int 21 02号功能，输出值放DL
	
	;输出空格间隔
	MOV DL,0
	INT 21H;输出空格间隔
	INC BL;下一个字符ASCII码
	LOOP INNER
	
	CALL CRLF;换行函数
	POP CX
	LOOP OUTER
	
	MOV AX,4C00H;退出程序
	INT 21H
	
CHANGE:;是控制码则将其替换为0
	MOV DL,0
	JMP SHOW
	
;换行函数
CRLF    PROC    NEAR                      
	MOV DL,0DH
    MOV AH,02H
    INT 21H       ;光标移到第一列              
    MOV DL,0AH
    MOV AH,02H
    INT 21H       ;光标移到下一行             
    RET
CRLF ENDP
CODE ENDS
END START





