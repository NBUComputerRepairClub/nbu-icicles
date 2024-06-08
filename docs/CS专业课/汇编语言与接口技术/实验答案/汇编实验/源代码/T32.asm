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
    mov AH,1 ;键盘存入一个值，
    int 21H
    cmp AL,'a'
    jb DAjump
    cmp AL,'z'
    ja error
    sub AL,20H
    MOV DL,AL
    jmp over
    ;此处输入代码段代码
DAjump:MOV AH,02H
error:MOV AH,02H
over:MOV AH,2
    INT 21H
CODES ENDS
    END START

