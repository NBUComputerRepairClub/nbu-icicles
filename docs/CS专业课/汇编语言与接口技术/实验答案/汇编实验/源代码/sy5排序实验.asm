DATA0 SEGMENT		;�������ݶ�
   ORG 20H  ;��20H��ʼ��������
   DATA1 DB 0Ch,09h,08h,07h,06h,05h,04h,03h,0Dh,02h ;data
 		 DB 1ah,19h,18h,07h,06h,05h,04h,03h,01h,12h
 		 DB 2ah,29h,28h,07h,06h,05h,04h,03h,01h,22h
 		 DB 3ah,39h,38h,07h,06h,05h,04h,03h,01h,32h
 		 DB 4ah,49h,48h,07h,06h,05h,04h,03h,01h,42h
DATA0 ENDS

DATAS SEGMENT ;�ı����ݶ�
   ORG 100H
   SORTNUM EQU 10   ;�ĵ�10��ʾ���£�50��ĿҪ��
   MESS1 DB 'INPUT SEGMENT VALUE:$'
   MESS2 DB 'INPUT OFFSET VALUE:$'
   MESS3 DB 'success sort',13,10,'$'
   ERROR DB 'INPUT ERRORt',13,10,'$'
DATAS ENDS

STACK   SEGMENT STACK          ;ջ����
STA     DB      32 DUP (?)
TOP     DW      ?
STACK   ENDS

CODES SEGMENT						
    ASSUME CS:CODES,DS:DATAS,SS:STACK
START:
	;�γ�ʼ��
	MOV AX,DATAS                 
    MOV DS,AX  ;DS��ǰʹ�ô���ı������ݶ�DATAS
    MOV AX,STACK
    MOV SS,AX
    MOV AX,TOP
    MOV SP,AX
    ;��ʾ����ѡ���
    MOV AH,09H          ;09H�Ź�����ʾ�ַ���
    MOV DX,OFFSET MESS1
    INT 21H        
    
    ;����GETNUM������ֵ��DL���������4λ�����ض����Ʊ�ʾ������DX
    CALL GETNUM

    ;����ε�ַ��ES����ʾ����λ��
    MOV DH,00H ;DH��ֵ����
    MOV ES,DX
    CALL CRLF ;����
    
    ;��ʾ����ƫ��ֵ
    MOV AH,09H          
    MOV DX,OFFSET MESS2
    INT  21H  
    
    ;����GETNUM������ֵ��DX
    CALL GETNUM    
    
    ;����ƫ������SI���������ݶ�λ��
	MOV DH,00H ;DH��ֵ����
    MOV SI,DX;���ݿ�ʼλ�ã�ƫ�ƶε�ַ����

	;DSָ������������ݶ�data0
	mov AX,DATA0
	MOV DS,AX
	
    MOV CX,SORTNUM  ;��ѭ������SORTNUM��1��CX
    DEC CX ;cx-1
    XOR BX,BX ;ƫ��ָ��BX��0
      
AGAIN0:
	MOV AL,[SI+BX] ;ƫ����+ƫ��ָ��,��[SI+BX]��Ԫȡ����AL
	MOV AH,BL     ;AHָ��ǰѡ�����������λ�ã�AH=BL
	PUSH CX       ;CX��ջ����ѭ����������
	MOV CX,SORTNUM   ;������ѭ��������CX
	SUB CX,BX        ;CX-BX,ʣ����Ҫ�������
	DEC CX
	MOV DX,BX     ;��ѭ�����Ʊ���DX��ʼ��
	;ѡ��BX֮��֮ǰ���Ѿ��źã�����С������λ�ñ�����AX
AGAIN1:
	INC DX  ;DXֵ��1
	PUSH BX ;����ѡ��������ѭ����ʼλ��
	MOV BX,DX   ;BXָ����һ������
	CMP AL,[SI+BX]  ;�Ƚ�AL��DX��ʾ��Ԫ��ֵ
JBE UUU			;��AL����ת
	MOV AL,[SI+BX] ;DXָʾ��Ԫ��ֵ����AL
	MOV AH,DL		;���޸�ָ��AH��AHָ����С��λ��
UUU:
	POP BX
LOOP AGAIN1
	;��Сֵ���ǰ���������Ŀǰλ�ý���
	MOV CL,[SI+BX] ;[SI+BX]��ֵ�ݴ�CL
	MOV [SI+BX],AL  ;[SI+BX]��ֵ�õ�AL��¼����Сֵ
	MOV DL,AH		;DL,��¼��Сֵλ��
	PUSH BX			;BX��ջ
	MOV BX,DX		;[SI+BX]��Ϊ��Сֵλ��
	MOV [SI+BX],CL 	;��Сֵλ�ø�������ֵ
	POP BX			;�ָ���ѭ��λ��
	;��ǰλ����������ź���һ��
	INC BX   ;ƫ��ָ��B��1
	POP CX	  ;һ��ѭ��������cx-1
LOOP AGAIN0
    
    PUSH DS  ;�����������ݶ�λ�� 
    MOV AX,DATAS ;��ʱ��Ϊ������ݶ�
    MOV     DS,AX
     ;����������
    MOV     AH,09H          ;09H�Ź�����ʾ�ַ���
    MOV     DX,OFFSET MESS3
    INT     21H        
    
    POP DS ;�ָ��������ݶ�λ��
    MOV CX,SORTNUM
    ;��ʾ���
AGAIN2:
	MOV AL,[SI]
    CALL DISP1 ;ѭ����DISP1������������������ʾ��
    CALL CRLF
    INC SI
LOOP AGAIN2

	;�������̣����ؿ���Ȩ��
    MOV     AX,4C00H
    INT     21H

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
  
CODES ENDS
END START























