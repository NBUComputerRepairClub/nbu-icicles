DATA  SEGMENT
  PKEY  DB 'What is the date(mm/dd/yyyy)',3FH,07H,13,10,'$'
  HINT  DB 13,10,13,10,'The date is $'
  STRING  DB 100 DUP(0)  ;存放日期字符串
  ERROR DB 'input error$' 
DATA  ENDS

STACK  SEGMENT
  DW 128 DUP(0)
STACK  ENDS

CODE  SEGMENT
  ASSUME    CS:CODE, DS:DATA, SS:STACK
START:
  ;初始化段寄存器
  MOV AX, DATA
  MOV DS, AX
  MOV ES, AX

; add your code here
  LEA DX, PKEY
  MOV AH, 9
  INT 21H         ; output string at ds:dx

  MOV AH, 2       ;响铃
  MOV DL, 7
  INT 21H         ;用02号功能，输出一个BEL（ASCII码值为07H）字符

  MOV BX, 0

  ;输入字符串
  CALL GETNUM ;获取日值
  PUSH DX
  CALL GETNUM ;获取月值
  PUSH DX
  CALL GETNUM ;获取年值
  
  MOV AX,DX
  CALL DISP11 ;显示年值
  ;;;本来下面这句一直卡住 mov AX,02H,没改AH
  MOV AX,0200H
  MOV DL,'-'  ;输出字符‘-’
  int 21H
  
  POP DX
  MOV AX,DX ;DISP1 输出AX里内容
  CALL DISP1 ;显示月值
  MOV AX,0200H
  MOV DL,'-'  ;输出字符‘-’
  int 21H
  
  POP DX
  MOV AX,DX  ;;DISP1 输出AX里内容
  MOV DH,00H ;DH，有值清零
  CALL DISP1 ;显示日值
  
  ;结束返回DOS
  MOV AX,4C00H
  INT 21H
  
  
  ;函数
DISP1 PROC    near   ;输出2位16进制数
	PUSH CX 
	MOV BL,AL ;AL当前要输出的数
	MOV DL,BL ;DL存当前要输出的数
	MOV CL,04
	ROL DL,CL ;DL循环左移4位
	AND DL,0FH ;DL保留低位
	CALL DISPL ;输出第1个数字位
	MOV DL,BL ;DL存当前要输出的数
	AND DL,0FH ;
	CALL DISPL ;输出第二个数字位
	POP CX
	RET
DISP1 ENDP

DISPL PROC    near   ;数字转字符，DL低四位保存需要输出的数
	ADD DL,30H
	CMP DL,3AH
	JB DDD
	ADD DL,27H
DDD:
	MOV AH,02H
	INT 21H	
	RET
DISPL ENDP

;年有4位数，2次调用disp1
DISP11 PROC NEAR
	PUSH DX
	PUSH CX
	PUSH BX
	PUSH AX
	;调用2次
	MOV AL,AH ;先输出高位
	CALL DISP1
	POP AX
	CALL DISP1
	
	POP BX
	POP CX
	POP DX
	RET
DISP11 ENDP
;换行函数
CRLF    PROC    near                      
	MOV DL,0DH
    MOV AH,02H
    INT 21H       ;光标移到第一列              
    MOV DL,0AH
    MOV AH,02H
    INT 21H       ;光标移到下一行             
    RET
CRLF ENDP


GETNUM  PROC    NEAR  ;键盘接收子程序，2个数值转换2进制存DL中。连续2次，上一次因为左移保留在DH
  XOR     AX,AX
again:  ;AH＝01H，回车或空格结束
  MOV     AH,01H ;01H号功能输入一个字符
  INT 21H        ;键盘接收键盘码
  CMP AL,0DH     ;判回车键
  JZ  done
  
  CMP AL,20H     ;判空格键
  JZ  done
  ;判为 0 - 9 数字键,满足转换成二进制，存在AL
  CMP AL,30H	 ;与'0'比较
  JB  error0	 ;输入字符<'0',error
  SUB AL,30H	 ;字符转二进制数字-30H
  CMP AL,0AH     ;并<10,判为 0 - 9 数字键
  JB  GETS		 ;AL的值已转为数字，ascll码已处理变为2进制数值
  ;判 A - F 字母键
  CMP AL,11H                  
  JB  error0	 ;<'A',error
  SUB AL,07H	 ;字符转对应二进制数字-30-07H
  CMP AL,0FH     ;判 A - F 字母键
  JBE GETS		 ;AL的值已成功转为数字，
  ;判 a - f 字母键       
  CMP AL,2AH	 ;与'a'比较
  JB  error0	 ;<'a',error
  CMP AL,2FH     ;与'f'比较
  JA  error0	 ;>'f',error
  SUB AL,20H	 ;字符转对应数字-30-07-20H
  
  ;AL存储的就是输入字符对应的2进制数字，放入DX
GETS:   
  MOV     CL,04H	;控制左移次数
  SHL DX,CL      ;逻辑左移4位，空出4位，接上之前的
  ADD DL,AL      ;当前字符对应2进制数加入 DX 中
  JMP again		 ;输入下一个字符，判断转换
  ;输入错误
error0: PUSH    DX
  MOV AH,09
  MOV DX,OFFSET ERROR
  INT 21H        ;显示输入错误提示信息
  POP DX
  ;返回结果，并换行
done:   PUSH    DX
  ;CALL CRLF
  POP DX
  RET
GETNUM  ENDP
  
CODE  ENDS
END START; set entry point and stop the assembler.

 










