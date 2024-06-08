DATAS SEGMENT
    STRING1 DB 10, ? , 10 DUP(?)
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
        LEA DX,STRING1
        MOV AH,0AH
        INT 21H
        ;显示输出
        ADD DX,2
        MOV AH,09H ;
		INT 21H
    ;此处输入代码段代码
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START




