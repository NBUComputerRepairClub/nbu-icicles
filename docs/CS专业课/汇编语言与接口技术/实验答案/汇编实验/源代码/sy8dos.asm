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
	
	;���С��м�����ֵ,�ַ�0��ʼ
	MOV BL,0;BL�д��Ҫ��ӡ�ַ���ASCII��
	MOV CX,16;�������ѭ��������������
OUTER:
	PUSH CX
	MOV CX,16;�����ڲ�ѭ��������������
INNER:        
	CMP BL,0AH;�ж��Ƿ�Ϊ���з�
	JZ CHANGE
	CMP BL,0DH;�ж��Ƿ�Ϊ�س���
	JZ CHANGE
	MOV DL,BL;��ʾ���DL
SHOW:
	;���DL�������
	MOV AH,2
	INT 21H ;int 21 02�Ź��ܣ����ֵ��DL
	
	;����ո���
	MOV DL,0
	INT 21H;����ո���
	INC BL;��һ���ַ�ASCII��
	LOOP INNER
	
	CALL CRLF;���к���
	POP CX
	LOOP OUTER
	
	MOV AX,4C00H;�˳�����
	INT 21H
	
CHANGE:;�ǿ����������滻Ϊ0
	MOV DL,0
	JMP SHOW
	
;���к���
CRLF    PROC    NEAR                      
	MOV DL,0DH
    MOV AH,02H
    INT 21H       ;����Ƶ���һ��              
    MOV DL,0AH
    MOV AH,02H
    INT 21H       ;����Ƶ���һ��             
    RET
CRLF ENDP
CODE ENDS
END START





