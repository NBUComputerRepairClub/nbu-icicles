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
    mov AH,1 ;���̴���һ��ֵ��
    int 21H
    cmp AL,'a'
    jb DAjump
    cmp AL,'z'
    ja error
    sub AL,20H
    MOV DL,AL
    jmp over
    ;�˴��������δ���
DAjump:MOV AH,02H
error:MOV AH,02H
over:MOV AH,2
    INT 21H
CODES ENDS
    END START

