DATA SEGMENT
	X DD 22223333H
	Y DD 44445555H
	SUM DD ?
DATA ENDS
STACKS SEGMENT
 	DB  256 DUP (?)
    ;此处输入堆栈段代码
STACKS ENDS

CODE SEGMENT 'CODE'
	ASSUME DS:DATA,CS:CODE
	
	START:
		XOR SI,SI;位移量清零
		MOV cx,2
		clc ;清零cf
again:  mov ax,word ptr X[SI] ;取X的第一个字
 		ADC ax,word ptr Y[SI] ;取y的第一个字
		mov word ptr sum[SI],ax ;低4位相加
		INC SI ;SI移动一个字
		INC SI 
		LOOP again
		 
		;---查看结果是否正确
		MOV AX , WORD PTR SUM
		MOV BX , WORD PTR SUM+2
		;---
		MOV AH , 4CH
		INT 21H
		
CODE ENDS
	END START
		












