DATAS SEGMENT
    STRING1 DB 10, ? , 10 DUP(?)
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
        LEA DX,STRING1
        MOV AH,0AH
        INT 21H
        ;��ʾ���
        ADD DX,2
        MOV AH,09H ;
		INT 21H
    ;�˴��������δ���
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START




