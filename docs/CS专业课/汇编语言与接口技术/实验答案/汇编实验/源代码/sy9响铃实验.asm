data SEGMENT 
	ts DB 'please input:$' 
	again DB 0ah,0dh,'press ctrl+C to end,else again:$' 
data ENDS 

code SEGMENT 
	ASSUME CS:code,DS:data 
start: 
	;�������ݶ�
	MOV AX,data  
	MOV DS,AX 
again1:
	LEA DX,ts 
	MOV AH,09h ;��ʾ�����ʾ�ַ��� 
	INT 21h 
	
	MOV AH,01h ;����01�Ź��ܽ����ַ� 
	INT 21h 
	CMP AL,'1' ;��1��ASCll�Ƚϣ�С����ת�� 
	JB restart 
	CMP AL,'9' ;��9�Ƚϣ�������ת�� 
	JA restart  
	
	SUB AL,30h ;��ASCll��ת��Ϊ���� 
	XOR AH,AH ;��AX�߰�λ���㣬��ʱAX�е�����Ϊ���յ����� 
	MOV BP,AX ;��AX��ֵ����BP�Կ���ѭ�� 
BELL:
	MOV AH,02 ;�������� 
	MOV DL,07 
	INT 21H 
	;��ʱ
	CALL delayp
	DEC BP ;BP-1
	CMP BP,30H
	JNZ BELL 	;������0ʱ��ת����ѭ��
 
restart:
	LEA DX,again ;��ʾ�Ƿ��ٴ����б����� 
	MOV AH,09h 
	INT 21h  
	MOV AH,01h ;�����ַ� 
	INT 21h 
	CALL CRLF
	CMP AL,3 ;CTRL+C��ӦascllΪ3������ͬ�����ѭ��
	JNZ again1

MOV AH,4ch 
INT 21h 

;���к���
CRLF    PROC    near 
	PUSH DX ;����֮ǰ������
	PUSH AX                    
	MOV DL,0DH
    MOV AH,02H
    INT 21H       ;����Ƶ���һ��              
    MOV DL,0AH
    MOV AH,02H
    INT 21H       ;����Ƶ���һ��
    POP AX
	POP DX             
    RET
CRLF ENDP

DELAYP PROC
	push dx
	push cx
	push ax ;��������
	
	MOV AH, 2DH ;2DH������ϵͳʱ��,��ʼΪ0
    MOV CX, 0
    MOV DX, 0
    INT 21H
READ:  
	MOV AH, 2CH ;��ѯϵͳʱ��
    INT 21H

    MOV AL, 100 ;=100D
    MUL DH 		;AL=DH*100
    MOV DH, 0 
    ADD AX, DX  ;Ax=��ǰ����*100
    CMP AX, 100  ;=100ʱ��������������λ���λ����������
    JC  READ

	pop ax ;�ָ�����
	pop cx
	pop dx
    RET
DELAYP ENDP

code ENDS 
END start 

