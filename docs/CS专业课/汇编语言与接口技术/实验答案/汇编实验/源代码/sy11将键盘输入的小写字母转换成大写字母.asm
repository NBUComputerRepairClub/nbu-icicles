data SEGMENT 
	ts DB 'please input:$' 
	again DB 0ah,0dh,'press ctrl+C to end,else again:$' 
	string DB 10 DUP(?),'$'
data ENDS 

code SEGMENT 
	ASSUME CS:code,DS:data 
start: 
	;�������ݶ�
	MOV AX,data  
	MOV DS,AX 

	
	LEA BX,STRING ;BXָ�򻺳���
	XOR SI,SI ;��SI����
	
	LEA DX,ts 
	MOV AH,09h ;��ʾ�����ʾ�ַ��� 
	INT 21h 
again1:
	
	MOV AH,01h ;����01�Ź��ܽ����ַ� 
	INT 21h 
	
	CMP AL,3 ;CTRL+C��ӦascllΪ3
	JZ  done
	
	CMP AL,13 ;�س���ӦascllΪ13
	JZ  show
 	
	CMP AL,'a' ;��a��ASCll�Ƚϣ�С����ת�� 
	JB nochange
	CMP AL,'z' ;��z��ASCll�Ƚϣ�������ת�� 
	JA nochange
	SUB AL,20h ;��Сдת��Ϊ��д 

nochange:
	mov [BX+SI],AL ;��Ÿ��ַ�
	INC SI ;SI+1
	jMP again1 
show:
	;mov [BX+SI],'$';
	LEA DX,STRING
	mov AH,09H  ;��ʾ���������ַ�
	int 21H
done:
	MOV AH,4cH
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



code ENDS 
END start 



