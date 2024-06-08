DATAS SEGMENT
	STRING DB 128 DUP(?)
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
    
    LEA BX,STRING
    MOV DX,01111111B
again:
    MOV AX,[BX+SI]
    cmp AX,'$'
    jNZ nochange
    MOV AX,' '
nochange:
	CMP DX,0
	DEC DX ;DX-1
	JNZ again 
    ;此处输入代码段代码
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START

