DATAS SEGMENT
	BUFX DB 11H
	BUFY DB 12H
	BUFZ DB ?
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
    MOV AL,BUFX
    MOV CL,BUFY ;放地址里的数据
    cmp AL,CL
    MOV BX,offset BUFZ ;放地址
    jc Yjump
    mov [BX],AL  ;X大，BX里的偏移地址放X
    jc over
Yjump:mov [BX],CL ;Y大
over:MOV AH,4CH
    INT 21H
CODES ENDS
    END START


