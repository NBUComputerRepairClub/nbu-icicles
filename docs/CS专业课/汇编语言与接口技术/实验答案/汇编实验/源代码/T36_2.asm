DATAS SEGMENT
    string DB '1234',13,10,'$'
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
    LEA BX,string
    MOV DX,00H
    MOV DX,[BX] ;��һλ
    MOV CL,4H
    SHL DX,CL ;z����4λ
    
    MOV AX,[BX+1]
    AND AX,000FH
    ADD DX,AX ;��2λ
    MOV CL,04H
    SHL DX,CL ;z����4λ
    
    MOV AX,[BX+2]
    AND AX,000FH
    ADD DX,AX ;��3λ
    MOV CL,04H
    SHL DX,CL ;z����4λ
    
    MOV AX,[BX+3]
    AND AX,000FH
    ADD DX,AX ;��3λ
    MOV CL,04H
    
    
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START

