DATAS SEGMENT
	COUNT EQU 20
	ARRAY DW 20 DUP (?) ;�������
	COUNT1 DB 0 ;��������ĸ���
	ARRAY1 DW 20 DUP (?) ;�������
	COUNT2 DB 0 ;��Ÿ����ĸ���
	ARRAY2 DW 20 DUP (?) ;��Ÿ���
	ZHEN DB 0DH, 0AH, 'The positive number is��', '$' ;�����ĸ����ǣ�
	FU DB 0DH, 0AH, 'The negative number is��', '$' ;�����ĸ����ǣ�
	CRLF DB 0DH, 0AH, '$'
DATAS ENDS

CODE SEGMENT
	ASSUME CS: CODE, DS: DATAS
START:
	MOV AX,DATAS
	MOV DS, AX ;��DS��ֵ
	
BEGIN: 
	MOV CX, COUNT
	LEA BX, ARRAY
	LEA SI, ARRAY1
	LEA DI, ARRAY2
	BEGIN1: MOV AX, [BX]
	CMP AX, 0 ;�Ǹ����룿
	JS FUSHU
	MOV [SI], AX ;��������������������
	INC COUNT1 ;��������+1
	ADD SI, 2
	JMP SHORT NEXT
FUSHU: MOV [DI], AX ;�Ǹ��������븺������
	INC COUNT2 ;��������+1
	ADD DI, 2
	NEXT: ADD BX, 2
	LOOP BEGIN1
	LEA DX, ZHEN ;��ʾ��������
	MOV AL, COUNT1
	CALL DISPLAY ;����ʾ�ӳ���
	LEA DX, FU ;��ʾ��������
	MOV AL, COUNT2
	CALL DISPLAY ;����ʾ�ӳ���
	;����
	MOV AH,4CH
    INT 21H
	

	
DISPLAY PROC NEAR ;��ʾ�ӳ���
	MOV AH, 9 ;��ʾһ���ַ�����DOS����
	INT 21H
	AAM ;��(AL)�еĶ�������ת��Ϊ������ѹ��BCD��
	ADD AH, '0' ;��Ϊ0��9��ASCII��
	MOV DL, AH
	MOV AH, 2 ;��ʾһ���ַ���DOS����
	INT 21H
	ADD AL, '0' ;��Ϊ0��9��ASCII��
	MOV DL, AL
	MOV AH, 2 ;��ʾһ���ַ���DOS����
	INT 21H
	LEA DX, CRLF ;��ʾ�س�����
	MOV AH, 9 ;��ʾһ���ַ�����DOS����
	INT 21H
	RET
DISPLAY ENDP ;��ʾ�ӳ������
CODE ENDS ;���϶�������
END START





