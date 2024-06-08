DATA    SEGMENT
MESS    DB      'input 4*16H: $'
ERROR   DB      'input error',0DH,0AH,'$'
DATA    ENDS

STACK   SEGMENT STACK  ;ջ����
STA     DB      128 DUP (?)
TOP     DW      ?
STACK   ENDS

CODE    SEGMENT
        ASSUME  CS:CODE,DS:DATA,SS:STACK,ES:DATA

START: ;�γ�ʼ��
  MOV AX,DATA                 
  MOV DS,AX
  MOV ES,AX
  MOV AX,STACK
  MOV SS,AX
  MOV AX,TOP
  MOV SP,AX
  
  ;��ʾ����4��16����
  MOV AH,09H   ;09H�Ź�����ʾ�ַ���
  MOV DX,OFFSET MESS
  INT 21H               
  
  ;�����������������ݣ���ת�������ݴ���DX��,Ϊ����4λ16���ƶ�Ӧ��16��������
  CALL GETNUM                 
  
  ;�����ʾ��ѭλ�ƻ�������λ
  MOV CX,16    ;ѭ��16��(������λ��)
  MOV     BX,DX	;ת�������DX����BX
NEXTSHOW: 
  ROL     BX,01  ;ѭ������1λ�������λ�����
  MOV DL,BL		;����ķ���DL
  AND DL,01H   ;���θ� 7 λ
  ADD DL,30H	;����ת�ַ����
  MOV AH,02H	;���DL
  INT 21H       ;��ʾĳλ��������
  LOOP NEXTSHOW
  
  ;�������̣����ؿ���Ȩ��
  MOV     AX,4C00H
  INT     21H

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

CODE    ENDS
        END     START






