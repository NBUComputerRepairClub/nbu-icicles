DATAS SEGMENT
	BUFX DB 11H
	BUFY DB 12H
	BUFZ DB ?
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
    MOV AL,BUFX
    MOV CL,BUFY ;�ŵ�ַ�������
    cmp AL,CL
    MOV BX,offset BUFZ ;�ŵ�ַ
    jc Yjump
    mov [BX],AL  ;X��BX���ƫ�Ƶ�ַ��X
    jc over
Yjump:mov [BX],CL ;Y��
over:MOV AH,4CH
    INT 21H
CODES ENDS
    END START


