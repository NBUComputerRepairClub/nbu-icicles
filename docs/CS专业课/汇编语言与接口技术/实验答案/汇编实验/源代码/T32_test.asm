DATA SEGMENT
DATA ENDS 

STACK SEGMENT
STACK ENDS    

CODE SEGMENT
ASSUME CS:CODE,DS:DATA,SS:STACK
START: 
    MOV AH,1  ;���������ַ��Զ�����AL��
    INT 21H    ;int�ж�
    SUB AL,32  ; Сд���д
    MOV DL,AL   ;��ֵ��DX
    MOV AH,2   ;��ʾ���  DL=����ַ�
    INT 21H    ;int�ж�
    MOV AH,4CH  ;�����������,AL=������
    INT 21H
CODE ENDS
END START

