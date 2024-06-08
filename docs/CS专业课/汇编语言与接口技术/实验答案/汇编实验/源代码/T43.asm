DATAS SEGMENT
	COUNT EQU 20
	ARRAY DW 20 DUP (?) ;存放数组
	COUNT1 DB 0 ;存放正数的个数
	ARRAY1 DW 20 DUP (?) ;存放正数
	COUNT2 DB 0 ;存放负数的个数
	ARRAY2 DW 20 DUP (?) ;存放负数
	ZHEN DB 0DH, 0AH, 'The positive number is：', '$' ;正数的个数是：
	FU DB 0DH, 0AH, 'The negative number is：', '$' ;负数的个数是：
	CRLF DB 0DH, 0AH, '$'
DATAS ENDS

CODE SEGMENT
	ASSUME CS: CODE, DS: DATAS
START:
	MOV AX,DATAS
	MOV DS, AX ;给DS赋值
	
BEGIN: 
	MOV CX, COUNT
	LEA BX, ARRAY
	LEA SI, ARRAY1
	LEA DI, ARRAY2
	BEGIN1: MOV AX, [BX]
	CMP AX, 0 ;是负数码？
	JS FUSHU
	MOV [SI], AX ;是正数，存入正数数组
	INC COUNT1 ;正数个数+1
	ADD SI, 2
	JMP SHORT NEXT
FUSHU: MOV [DI], AX ;是负数，存入负数数组
	INC COUNT2 ;负数个数+1
	ADD DI, 2
	NEXT: ADD BX, 2
	LOOP BEGIN1
	LEA DX, ZHEN ;显示正数个数
	MOV AL, COUNT1
	CALL DISPLAY ;调显示子程序
	LEA DX, FU ;显示负数个数
	MOV AL, COUNT2
	CALL DISPLAY ;调显示子程序
	;结束
	MOV AH,4CH
    INT 21H
	

	
DISPLAY PROC NEAR ;显示子程序
	MOV AH, 9 ;显示一个字符串的DOS调用
	INT 21H
	AAM ;将(AL)中的二进制数转换为二个非压缩BCD码
	ADD AH, '0' ;变为0～9的ASCII码
	MOV DL, AH
	MOV AH, 2 ;显示一个字符的DOS调用
	INT 21H
	ADD AL, '0' ;变为0～9的ASCII码
	MOV DL, AL
	MOV AH, 2 ;显示一个字符的DOS调用
	INT 21H
	LEA DX, CRLF ;显示回车换行
	MOV AH, 9 ;显示一个字符串的DOS调用
	INT 21H
	RET
DISPLAY ENDP ;显示子程序结束
CODE ENDS ;以上定义代码段
END START





