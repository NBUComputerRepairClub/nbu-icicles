DATA    SEGMENT
	MESS    DB      'INPUT one string:',13,10,'$'
	ERROR   DB 'INPUT ERRORt',13,10,'$'
DATA    ENDS

STACK   SEGMENT STACK                   ;栈定义
STA     DB      128 DUP (?)
TOP     DW      ?
STACK   ENDS

CODES    SEGMENT
        ASSUME  CS:CODES,DS:DATA,SS:STACK,ES:DATA

START: ;段初始化
	MOV AX,DATA                 
    MOV DS,AX
    MOV ES,AX
    MOV AX,STACK
    MOV SS,AX
    MOV AX,TOP
    MOV SP,AX
	
	;提示输入
    MOV     AH,09H                  ;09H号功能显示字符串
    MOV     DX,OFFSET MESS
    INT     21H   
    ;键盘接收键盘码,结果放AL
    call GETASCLL  ;读取键盘1个字符保存在DL，ACLL码表示
    PUSH DX;保存输入数据
    
    ;输出ASCLL码
    MOV AL,DL
    CALL DISP1 ;输出AL对应2个字符
    MOV AH,02H ;输出H
    MOV DL,'H'
    int 21H
    
    CALL CRLF ;换行
    ;恢复DX输入数据
    POP DX
    ;输出二进制
  	CALL DISPBIN ;输出二进制
    
    ;结束返回DOS
    MOV AH,4CH
    INT 21H
    
    
;输出显示，循位移环输出最低位   
DISPBIN PROC NEAR
	MOV CX,8    ;循环8次(二进制位数)
  	MOV BL,DL	;转换结果从DL放入BL
  	MOV BH,DL	;转换结果从DL放入BL
	NEXTSHOW: 
  	ROL     BX,01  ;循环左移1位，由最高位先输出
  	MOV DL,BL		;输出的放入DL
  	AND DL,01H   ;屏蔽高 7 位
  	ADD DL,30H	;数字转字符输出
  	MOV AH,02H	;输出DL
  	INT 21H       ;显示某位二进制数
  	LOOP NEXTSHOW
DISPBIN ENDP
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
;键盘接收，1个字符对应ASCLL2个数值以2进制存DL中。2个字符DX
GETASCLL  PROC    NEAR  
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
;SUB AL,30H	 ;字符转二进制数字-30H
CMP AL,3AH     ;并<10,判为 0 - 9 数字键
  JB  GETS		 ;AL的值已转为数字，ascll码已处理变为2进制数值
  ;判 A - F 字母键
CMP AL,31H                  
  JB  error0	 ;<'A',error
;SUB AL,07H	 ;字符转对应二进制数字-30-07H
CMP AL,46H     ;判 A - F 字母键
  JBE GETS		 ;AL的值已成功转为数字，
  ;判 a - f 字母键       
CMP AL,61H	 ;与'a'比较
  JB  error0	 ;<'a',error
CMP AL,66H     ;与'f'比较
  JA  error0	 ;>'f',error
;SUB AL,20H	 ;字符转对应数字-30-07-20H
  
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
GETASCLL  ENDP

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

DISPL PROC    near   ;转字符，DL低四位保存需要输出的数
	ADD DL,30H
	CMP DL,3AH
	JB DDD
	ADD DL,27H
DDD:
	MOV AH,02H
	INT 21H	
	RET
DISPL ENDP
CODES ENDS
END START


















