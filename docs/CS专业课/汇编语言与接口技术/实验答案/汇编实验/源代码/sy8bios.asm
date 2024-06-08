DATA SEGMENT

DATA ENDS
STACK SEGMENT STACK 'STACK'
	STA DB 128 DUP(?)
	TOP EQU LENGTH STA
STACK ENDS
CODE SEGMENT
ASSUME CS:CODE,DS:DATA,SS:STACK
START:
	;��ʼ����ؼĴ���
 	MOV AX,DATA
	MOV DS,AX
	MOV AX,STACK
	MOV SS,AX
	MOV SP,TOP
	
	
	MOV BL,0;BL�д��Ҫ��ӡ�ַ���ASCII��
	MOV DH,0;�����к�
OUTER:
	MOV DL,0;�����к�
INNER:
	;���ASCLL���һ���ַ�
	MOV AH,02H ;BH��0��ʾҳ��,DH����(Y����),DL�� ��(X����)
	INT 10H;����BIOS�ж����ù��λ��
	
	CMP BL,0AH;�ж��Ƿ�Ϊ���з�
	JZ CHANGE
	CMP BL,0DH;�ж��Ƿ�Ϊ�س���
	JZ CHANGE
	MOV AL,BL;��BL->AL������ʾ
SHOW:
	;����ַ�
	MOV CL,1;��������ַ�����
	MOV AH,0AH ;AL=�ַ���BH=ҳ�룬CX=��δ�ӡ�ַ�
	INT 10H;����BIOS�ж�����ַ�
	
	;�������Ŀո�
	INC DL;�к�+1
	INC BL;��һ���ַ�ASCII��
	MOV AH,02H;���ù��λ��
	INT 10H
	MOV AL,0
	MOV AH,0AH
	INT 10H;����ո���
	
	;���32��Ϊһ�У��ܹ�16��
	INC DL;�к�+1
	CMP DL,32;�ж�һ���Ƿ����
	JNZ INNER
	INC DH
	CMP DH,16;�ж������Ƿ���
	JNZ OUTER
	
	MOV AX,4C00H
	INT 21H;��������

CHANGE:;��Ϊ�����ַ������滻Ϊ0
        MOV AL,0
	JMP SHOW

CODE ENDS
END START





