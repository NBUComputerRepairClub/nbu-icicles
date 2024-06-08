DATA    SEGMENT
	MESS    DB      'INPUT one string:',13,10,'$'
	ERROR   DB 'INPUT ERRORt',13,10,'$'
DATA    ENDS

STACK   SEGMENT STACK                   ;ջ����
STA     DB      128 DUP (?)
TOP     DW      ?
STACK   ENDS

CODES    SEGMENT
        ASSUME  CS:CODES,DS:DATA,SS:STACK,ES:DATA

START: ;�γ�ʼ��
	MOV AX,DATA                 
    MOV DS,AX
    MOV ES,AX
    MOV AX,STACK
    MOV SS,AX
    MOV AX,TOP
    MOV SP,AX
	
	;��ʾ����
    MOV     AH,09H                  ;09H�Ź�����ʾ�ַ���
    MOV     DX,OFFSET MESS
    INT     21H   
    ;���̽��ռ�����,�����AL
    call GETASCLL  ;��ȡ����1���ַ�������DL��ACLL���ʾ
    PUSH DX;������������
    
    ;���ASCLL��
    MOV AL,DL
    CALL DISP1 ;���AL��Ӧ2���ַ�
    MOV AH,02H ;���H
    MOV DL,'H'
    int 21H
    
    CALL CRLF ;����
    ;�ָ�DX��������
    POP DX
    ;���������
  	CALL DISPBIN ;���������
    
    ;��������DOS
    MOV AH,4CH
    INT 21H
    
    
;�����ʾ��ѭλ�ƻ�������λ   
DISPBIN PROC NEAR
	MOV CX,8    ;ѭ��8��(������λ��)
  	MOV BL,DL	;ת�������DL����BL
  	MOV BH,DL	;ת�������DL����BL
	NEXTSHOW: 
  	ROL     BX,01  ;ѭ������1λ�������λ�����
  	MOV DL,BL		;����ķ���DL
  	AND DL,01H   ;���θ� 7 λ
  	ADD DL,30H	;����ת�ַ����
  	MOV AH,02H	;���DL
  	INT 21H       ;��ʾĳλ��������
  	LOOP NEXTSHOW
DISPBIN ENDP
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
;���̽��գ�1���ַ���ӦASCLL2����ֵ��2���ƴ�DL�С�2���ַ�DX
GETASCLL  PROC    NEAR  
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
;SUB AL,30H	 ;�ַ�ת����������-30H
CMP AL,3AH     ;��<10,��Ϊ 0 - 9 ���ּ�
  JB  GETS		 ;AL��ֵ��תΪ���֣�ascll���Ѵ����Ϊ2������ֵ
  ;�� A - F ��ĸ��
CMP AL,31H                  
  JB  error0	 ;<'A',error
;SUB AL,07H	 ;�ַ�ת��Ӧ����������-30-07H
CMP AL,46H     ;�� A - F ��ĸ��
  JBE GETS		 ;AL��ֵ�ѳɹ�תΪ���֣�
  ;�� a - f ��ĸ��       
CMP AL,61H	 ;��'a'�Ƚ�
  JB  error0	 ;<'a',error
CMP AL,66H     ;��'f'�Ƚ�
  JA  error0	 ;>'f',error
;SUB AL,20H	 ;�ַ�ת��Ӧ����-30-07-20H
  
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
GETASCLL  ENDP

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

DISPL PROC    near   ;ת�ַ���DL����λ������Ҫ�������
	ADD DL,30H
	CMP DL,3AH
	JB DDD
	ADD DL,27H
DDD:
	MOV AH,02H
	INT 21H	
	RET
DISPL ENDP
CODES ENDS
END START


















