DATA SEGMENT
	X DD 22223333H
	Y DD 44445555H
	SUM DD ?
DATA ENDS
STACKS SEGMENT
 	DB  256 DUP (?)
    ;�˴������ջ�δ���
STACKS ENDS

CODE SEGMENT 'CODE'
	ASSUME DS:DATA,CS:CODE
	
	START:
		XOR SI,SI;λ��������
		MOV cx,2
		clc ;����cf
again:  mov ax,word ptr X[SI] ;ȡX�ĵ�һ����
 		ADC ax,word ptr Y[SI] ;ȡy�ĵ�һ����
		mov word ptr sum[SI],ax ;��4λ���
		INC SI ;SI�ƶ�һ����
		INC SI 
		LOOP again
		 
		;---�鿴����Ƿ���ȷ
		MOV AX , WORD PTR SUM
		MOV BX , WORD PTR SUM+2
		;---
		MOV AH , 4CH
		INT 21H
		
CODE ENDS
	END START
		












