DATAS SEGMENT
    ;此处输入数据段代码  
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
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
    ;此处输入代码段代码
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START
