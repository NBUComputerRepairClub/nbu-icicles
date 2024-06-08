DATA SEGMENT
	Data1 DB 50H ;����1
	data2 DB 60H ;����2
	Result DB 2 DUP(?) ;���
	MES1 DB '*','$' ;�ַ���
	MES2 DB '=','$'
DATA ENDS

STACK SEGMENT PARA STACK 'STACK'
	STAPN DB 100 DUP(?) ;����100���ֽڵĶ�ջ��
	TOP EQU LENGTH STAPN ;top=100
STACK ENDS

CODE SEGMENT
	ASSUME CS:CODE,DS:DATA,SS:STACK ;˵����ǰʹ�õĶ�
START:
	;��ʼ�����ݶΣ���ջ��
	MOV AX,DATA
	MOV DS,AX
	MOV AX,STACK
	MOV SS,AX
	MOV AX,TOP
	MOV SP,AX
	
	;DL�ۼ�CL����2��DH�ۼӽ�λ������ΪBL
	MOV BL,Data1
	MOV CL,Data2
	MOV DX,0 ;��ʼֵΪ0
	MOV AL,BL ;BL��Ϊ��������ִ��BL��data2���
	
AGAIN:OR AL,AL ;BL=AL=0,�����־λ��=0,����������
	JZ DONE ;���־λ��=0������תDONE
	
	;��λ�����2�ۼ�
	MOV AL,DL ;AL�ݴ�DL
	ADD AL,CL ;DL+CL
	DAA       ;��ϵ�BCD����ָ��
	MOV DL,AL ;DL���ۼӺ��ֵ
	
	;��λ���н�λ����
	MOV AL,DH ;�ݴ��λ
	ADC AL,0 ;����λ�ļӷ�
	DAA		;��ϵ�BCD����ָ��
	MOV DH,AL ;DH��Ž�λ���ֵ
	
	;��������һ
	MOV AL,BL ;��data1
	DEC AL	  ;������BL-1
	DAS		  ;�������BCD�����
	MOV BL,AL ;AL��
	
	JMP AGAIN
	
	;��ʾ���
DONE:
    
    LEA BX,result ;BX�����result�ĵ�ַ
	MOV [BX],DX  ;DX����������result
	
	;���Data1
	LEA SI,Data1 ;result��ַ����SI
	CALL DIS  ;����DIS���������
	
	;�������MES1��Ӧ�ַ�*
	XOR AX,AX ;AX����
	MOV AH,09H ;
	LEA DX,MES1 
	INT 21H
	
	;���Data2
	LEA SI,Data2
	CALL DIS
	
	;�������MES2��Ӧ�ַ�=
	XOR AX,AX
	MOV AH,09H
	LEA DX,MES2
	INT 21H
	
	;���result��8λ��2���ַ�
	LEA SI,result
	INC SI ;SI��ַ+1,DH=DL+1
	CALL DIS
	
	;���result��8λ��2���ַ�
	DEC SI
	CALL DIS
	;�������
	MOV AX,4C00H
	INT 21H
	
;���2��4λ��Ӧ�ַ�
DIS PROC NEAR
	;�����4λ��Ӧ�ַ�
	MOV AL,[SI] ;AL����������
	MOV CL,04H  
	SHR AL,CL   ;�߼�����4λ��ALȡ��4λ
	ADD AL,30H  ;����ת�ַ�
	MOV DL,AL   ;�������DL
	MOV AH,02H  ;���һ���ַ�
	INT 21H
	;�����4λ��Ӧ�ַ�
	MOV AL,[SI] 
	AND AL,0FH 
	ADD AL,30H
	MOV DL,AL
	MOV AH,02H
	INT 21H
	
	RET ;����ָ��
DIS ENDP 

CODE ENDS
END START

