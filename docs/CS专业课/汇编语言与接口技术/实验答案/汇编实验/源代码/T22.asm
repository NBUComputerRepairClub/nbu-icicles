DATAS SEGMENT
	;A DB 65H,32H 
	A DB 12H,45H,0F3H,6AH,20H,0FEH,90H,0C8H,57H,34H;数据
	num equ 10 ;数据个数
	sum DB ? ;预留结果存放处
    ;此处输入数据段代码  
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
	XOR SI,SI;位移量清零
	XOR AL,AL;清零
    MOV CX,num;累加次数
again:ADD AL,A[SI]; 累加
	INC SI ;指向下一个数
Loop again;CX未到0，继续累加
	MOV sum,AL;存结果
    ;此处输入代码段代码
    MOV AH,02  ;输出ascall对应字符
    INT 21H
CODES ENDS
    END START







