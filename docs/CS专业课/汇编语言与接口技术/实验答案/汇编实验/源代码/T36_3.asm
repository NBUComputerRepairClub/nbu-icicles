DATAS SEGMENT
    ;�˴��������ݶδ���  
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
    AND DX,1000H
    MOV AX,0000H
    JNZ jump
    MOV AX,-1
jump:
    ;�˴��������δ���
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START
