DATA    SEGMENT
MESS    DB      'input 4*16H: $'
ERROR   DB      'input error',0DH,0AH,'$'
DATA    ENDS

STACK   SEGMENT STACK  ;栈定义
STA     DB      128 DUP (?)
TOP     DW      ?
STACK   ENDS

CODE    SEGMENT
        ASSUME  CS:CODE,DS:DATA,SS:STACK,ES:DATA

START: ;段初始化
  MOV AX,DATA                 
  MOV DS,AX
  MOV ES,AX
  MOV AX,STACK
  MOV SS,AX
  MOV AX,TOP
  MOV SP,AX
  
  ;提示输入4个16进制
  MOV AH,09H   ;09H号功能显示字符串
  MOV DX,OFFSET MESS
  INT 21H               
  
  ;函数：键盘输入数据，并转换后数据存在DX中,为输入4位16进制对应的16个二进制
  CALL GETNUM                 
  
  ;输出显示，循位移环输出最低位
  MOV CX,16    ;循环16次(二进制位数)
  MOV     BX,DX	;转换结果从DX放入BX
NEXTSHOW: 
  ROL     BX,01  ;循环左移1位，由最高位先输出
  MOV DL,BL		;输出的放入DL
  AND DL,01H   ;屏蔽高 7 位
  ADD DL,30H	;数字转字符输出
  MOV AH,02H	;输出DL
  INT 21H       ;显示某位二进制数
  LOOP NEXTSHOW
  
  ;结束进程，返回控制权限
  MOV     AX,4C00H
  INT     21H

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

CODE    ENDS
        END     START






