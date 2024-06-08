DATA  SEGMENT
  PKEY  DB 'What is the date(mm/dd/yyyy)',3FH,07H,13,10,'$'
  HINT  DB 13,10,13,10,'The date is $'
  STRING  DB 100 DUP(0)  ;��������ַ���
  ERROR DB 'input error$' 
DATA  ENDS

STACK  SEGMENT
  DW 128 DUP(0)
STACK  ENDS

CODE  SEGMENT
  ASSUME    CS:CODE, DS:DATA, SS:STACK
START:
  ;��ʼ���μĴ���
  MOV AX, DATA
  MOV DS, AX
  MOV ES, AX

; add your code here
  LEA DX, PKEY
  MOV AH, 9
  INT 21H         ; output string at ds:dx

  MOV AH, 2       ;����
  MOV DL, 7
  INT 21H         ;��02�Ź��ܣ����һ��BEL��ASCII��ֵΪ07H���ַ�

  MOV BX, 0

  ;�����ַ���
  CALL GETNUM ;��ȡ��ֵ
  PUSH DX
  CALL GETNUM ;��ȡ��ֵ
  PUSH DX
  CALL GETNUM ;��ȡ��ֵ
  
  MOV AX,DX
  CALL DISP11 ;��ʾ��ֵ
  ;;;�����������һֱ��ס mov AX,02H,û��AH
  MOV AX,0200H
  MOV DL,'-'  ;����ַ���-��
  int 21H
  
  POP DX
  MOV AX,DX ;DISP1 ���AX������
  CALL DISP1 ;��ʾ��ֵ
  MOV AX,0200H
  MOV DL,'-'  ;����ַ���-��
  int 21H
  
  POP DX
  MOV AX,DX  ;;DISP1 ���AX������
  MOV DH,00H ;DH����ֵ����
  CALL DISP1 ;��ʾ��ֵ
  
  ;��������DOS
  MOV AX,4C00H
  INT 21H
  
  
  ;����
DISP1 PROC    near   ;���2λ16������
	PUSH CX 
	MOV BL,AL ;AL��ǰҪ�������
	MOV DL,BL ;DL�浱ǰҪ�������
	MOV CL,04
	ROL DL,CL ;DLѭ������4λ
	AND DL,0FH ;DL������λ
	CALL DISPL ;�����1������λ
	MOV DL,BL ;DL�浱ǰҪ�������
	AND DL,0FH ;
	CALL DISPL ;����ڶ�������λ
	POP CX
	RET
DISP1 ENDP

DISPL PROC    near   ;����ת�ַ���DL����λ������Ҫ�������
	ADD DL,30H
	CMP DL,3AH
	JB DDD
	ADD DL,27H
DDD:
	MOV AH,02H
	INT 21H	
	RET
DISPL ENDP

;����4λ����2�ε���disp1
DISP11 PROC NEAR
	PUSH DX
	PUSH CX
	PUSH BX
	PUSH AX
	;����2��
	MOV AL,AH ;�������λ
	CALL DISP1
	POP AX
	CALL DISP1
	
	POP BX
	POP CX
	POP DX
	RET
DISP11 ENDP
;���к���
CRLF    PROC    near                      
	MOV DL,0DH
    MOV AH,02H
    INT 21H       ;����Ƶ���һ��              
    MOV DL,0AH
    MOV AH,02H
    INT 21H       ;����Ƶ���һ��             
    RET
CRLF ENDP


GETNUM  PROC    NEAR  ;���̽����ӳ���2����ֵת��2���ƴ�DL�С�����2�Σ���һ����Ϊ���Ʊ�����DH
  XOR     AX,AX
again:  ;AH��01H���س���ո����
  MOV     AH,01H ;01H�Ź�������һ���ַ�
  INT 21H        ;���̽��ռ�����
  CMP AL,0DH     ;�лس���
  JZ  done
  
  CMP AL,20H     ;�пո��
  JZ  done
  ;��Ϊ 0 - 9 ���ּ�,����ת���ɶ����ƣ�����AL
  CMP AL,30H	 ;��'0'�Ƚ�
  JB  error0	 ;�����ַ�<'0',error
  SUB AL,30H	 ;�ַ�ת����������-30H
  CMP AL,0AH     ;��<10,��Ϊ 0 - 9 ���ּ�
  JB  GETS		 ;AL��ֵ��תΪ���֣�ascll���Ѵ����Ϊ2������ֵ
  ;�� A - F ��ĸ��
  CMP AL,11H                  
  JB  error0	 ;<'A',error
  SUB AL,07H	 ;�ַ�ת��Ӧ����������-30-07H
  CMP AL,0FH     ;�� A - F ��ĸ��
  JBE GETS		 ;AL��ֵ�ѳɹ�תΪ���֣�
  ;�� a - f ��ĸ��       
  CMP AL,2AH	 ;��'a'�Ƚ�
  JB  error0	 ;<'a',error
  CMP AL,2FH     ;��'f'�Ƚ�
  JA  error0	 ;>'f',error
  SUB AL,20H	 ;�ַ�ת��Ӧ����-30-07-20H
  
  ;AL�洢�ľ��������ַ���Ӧ��2�������֣�����DX
GETS:   
  MOV     CL,04H	;�������ƴ���
  SHL DX,CL      ;�߼�����4λ���ճ�4λ������֮ǰ��
  ADD DL,AL      ;��ǰ�ַ���Ӧ2���������� DX ��
  JMP again		 ;������һ���ַ����ж�ת��
  ;�������
error0: PUSH    DX
  MOV AH,09
  MOV DX,OFFSET ERROR
  INT 21H        ;��ʾ���������ʾ��Ϣ
  POP DX
  ;���ؽ����������
done:   PUSH    DX
  ;CALL CRLF
  POP DX
  RET
GETNUM  ENDP
  
CODE  ENDS
END START; set entry point and stop the assembler.

 










