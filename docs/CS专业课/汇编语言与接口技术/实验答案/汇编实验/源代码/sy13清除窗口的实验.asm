DATA    SEGMENT
MESS    DB      'INPUT ANY KEY TO CLEAR THE SCREEN $'
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
    ;int 21,09�Ź�������ַ���
    LEA DX, MESS
    MOV AH, 9
    INT 21H 
            
	;int 21,01�Ź��ܵȴ���������
    MOV AH, 01H
    INT 21H
	;int 10,07�Ź�������,���¹����ܶ�
	MOV AX,0700H 
	mov ch,10  ;(0,0),;���Ͻǵ��к�
    mov cl,20  ;;���Ͻǵ��к�
    mov dh,50 ;(24,79),���½ǵ��к�
    mov dl,60 ;���½ǵ��к�
    mov bh,70H ;07����Ϊ�ڵװ��֣�17Ϊ���׸�����,70���׵İ׵׺���
	INT 10H

	;int 21,4C�Ź��ܽ������򣬷���DOSȨ��
	MOV AH, 4CH   ; exit to operating system.
	INT 21H

CODES  ENDS
END START


