DATAS SEGMENT
    string DB '123456',13,10,'$'
    
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    lea BX,string
    MOV DX,[BX]
    MOV AH 02H
    int 21H
    MOV DX,[BX+5]
    MOV AH 02H
    int 21H
    
    ;此处输入代码段代码
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START
