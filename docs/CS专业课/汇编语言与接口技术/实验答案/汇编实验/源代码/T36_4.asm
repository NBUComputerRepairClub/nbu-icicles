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
    
    MOV BX,0B800H
    MOV CL,100
    MOV AX,0
    MOC DX,0
again:
	ADD AX,[BX+SI]
	jzc done ;�޽�λ
	inc dx ;��λ��һ
	ADD DX,
done:
	INC SI
	LOOP again
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START
