DATAS SEGMENT
	A DW 0123H
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
    MOV AX,A
    MOV BL, AL
    and AL,0fH ;屏蔽高4位,给AL 0-3
    
    MOV CL,4
    shr BL,CL ;BL右移放高4位 4-7
    
    MOV DL,AH
    and DL,0F0H ;DL 15-12,放高4位,右移
    MOV cl,4
    shr DL,CL
    
    MOV CL,AH
    mov CL,0FH ;CL右移放高4位 8-11
    
    
    ;此处输入代码段代码
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START
