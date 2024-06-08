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
	
	
	MOV BL,0;BL中存放要打印字符的ASCII码
	MOV DH,0;设置行号
OUTER:
	MOV DL,0;设置列号
INNER:
	;输出ASCLL表的一个字符
	MOV AH,02H ;BH＝0显示页码,DH＝行(Y坐标),DL＝ 列(X坐标)
	INT 10H;调用BIOS中断设置光标位置
	
	CMP BL,0AH;判断是否为换行符
	JZ CHANGE
	CMP BL,0DH;判断是否为回车符
	JZ CHANGE
	MOV AL,BL;将BL->AL用于显示
SHOW:
	;输出字符
	MOV CL,1;设置输出字符字数
	MOV AH,0AH ;AL=字符，BH=页码，CX=多次打印字符
	INT 10H;调用BIOS中断输出字符
	
	;输出间隔的空格
	INC DL;列号+1
	INC BL;下一个字符ASCII码
	MOV AH,02H;设置光标位置
	INT 10H
	MOV AL,0
	MOV AH,0AH
	INT 10H;输出空格间隔
	
	;输出32个为一行，总共16行
	INC DL;列号+1
	CMP DL,32;判断一列是否完成
	JNZ INNER
	INC DH
	CMP DH,16;判断行数是否达标
	JNZ OUTER
	
	MOV AX,4C00H
	INT 21H;结束程序

CHANGE:;若为特殊字符则将其替换为0
        MOV AL,0
	JMP SHOW

CODE ENDS
END START





