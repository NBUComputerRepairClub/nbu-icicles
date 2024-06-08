DATAS SEGMENT
    string DB '1234',13,10,'$'
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
    LEA BX,string
    MOV DX,00H
    MOV DX,[BX] ;第一位
    MOV CL,4H
    SHL DX,CL ;z左移4位
    
    MOV AX,[BX+1]
    AND AX,000FH
    ADD DX,AX ;第2位
    MOV CL,04H
    SHL DX,CL ;z左移4位
    
    MOV AX,[BX+2]
    AND AX,000FH
    ADD DX,AX ;第3位
    MOV CL,04H
    SHL DX,CL ;z左移4位
    
    MOV AX,[BX+3]
    AND AX,000FH
    ADD DX,AX ;第3位
    MOV CL,04H
    
    
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START

