DATA SEGMENT
DATA ENDS 

STACK SEGMENT
STACK ENDS    

CODE SEGMENT
ASSUME CS:CODE,DS:DATA,SS:STACK
START: 
    MOV AH,1  ;键盘输入字符自动存入AL中
    INT 21H    ;int中断
    SUB AL,32  ; 小写变大写
    MOV DL,AL   ;赋值给DX
    MOV AH,2   ;显示输出  DL=输出字符
    INT 21H    ;int中断
    MOV AH,4CH  ;带返回码结束,AL=返回码
    INT 21H
CODE ENDS
END START

