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
    
    MOV BX,0B800H
    MOV CL,100
    MOV AX,0
    MOC DX,0
again:
	ADD AX,[BX+SI]
	jzc done ;无进位
	inc dx ;进位加一
	ADD DX,
done:
	INC SI
	LOOP again
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START
