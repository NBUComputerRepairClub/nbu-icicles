DATAS SEGMENT
MONTAB DB 'JAN',0AH,0DH,'$';1
		DB 'FEB',0AH,0DH,'$';2
		DB 'MAR',0AH,0DH,'$'
		DB 'APR',0AH,0DH,'$';3,4
		DB 'MAY',0AH,0DH,'$','JUN' ,0AH,0DH,'$';5,6
		DB 'JUL',0AH,0DH,'$','AUG' ,0AH,0DH,'$';7��8
		DB 'SEP',0AH,0DH,'$','OCT' ,0AH,0DH,'$';9,10
		DB 'MOV',0AH,0DH,'$','DEC' ,0AH,0DH,'$';11,12
MESS1 DB 'INPUT NUM 1-12:',0AH,0DH,'$'
MESS2 DB 'input y again:','$'
ERROR DB 'input ERROR',0AH,0DH,'$'		

DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
again0:  
    ;��ʾ����  
    LEA DX,MESS1
    MOV AH,09H;
    INT 21H
    ;���̻��һ������,���4λ������DX�����������2λ
    XOR DX,DX;����
    CALL GETNUM
    
    ;SIƫ�Ƶ�ַ��BXָ��ʼ���µ�ַ
    XOR AX,AX
    MOV AL,DL;��ֵ������SI
    DEC AL   ;��0��ʼ
    MOV CL,06H ;һ������Ϣռ6���ַ�
    MUL CL
    MOV SI,AX ;�����ƫ�Ƶ�ַ��SI
    LEA BX,MONTAB
    
    ;��ʾ�����
    LEA DX,[BX+SI]
    MOV AH,09H;
    INT 21H
    
    ;��ʾ����  
    LEA DX,MESS2
    MOV AH,09H;
    INT 21H
    
    MOV AH,01H;
    INT 21H
    CMP AL,'y' ;y����ִ��һ�γ���
    CALL CRLF ;����
    jz again0
    
    MOV AH,4CH
    INT 21H
    
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
CODES ENDS
    END START




