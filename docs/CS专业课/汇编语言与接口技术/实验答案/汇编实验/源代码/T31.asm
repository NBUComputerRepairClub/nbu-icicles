DATAS SEGMENT
	A DW 0123H
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
    MOV AX,A
    MOV BL, AL
    and AL,0fH ;���θ�4λ,��AL 0-3
    
    MOV CL,4
    shr BL,CL ;BL���ƷŸ�4λ 4-7
    
    MOV DL,AH
    and DL,0F0H ;DL 15-12,�Ÿ�4λ,����
    MOV cl,4
    shr DL,CL
    
    MOV CL,AH
    mov CL,0FH ;CL���ƷŸ�4λ 8-11
    
    
    ;�˴��������δ���
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START
