DATAS SEGMENT
MONTAB DB 'JAN',0AH,0DH,'$';1
		DB 'FEB',0AH,0DH,'$';2
		DB 'MAR',0AH,0DH,'$'
		DB 'APR',0AH,0DH,'$';3,4
		DB 'MAY',0AH,0DH,'$','JUN' ,0AH,0DH,'$';5,6
		DB 'JUL',0AH,0DH,'$','AUG' ,0AH,0DH,'$';7，8
		DB 'SEP',0AH,0DH,'$','OCT' ,0AH,0DH,'$';9,10
		DB 'MOV',0AH,0DH,'$','DEC' ,0AH,0DH,'$';11,12
MESS1 DB 'INPUT NUM 1-12:',0AH,0DH,'$'
MESS2 DB 'input y again:','$'
ERROR DB 'input ERROR',0AH,0DH,'$'		

DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
again0:  
    ;提示输入  
    LEA DX,MESS1
    MOV AH,09H;
    INT 21H
    ;键盘获得一个数字,最多4位保存在DX，本程序最多2位
    XOR DX,DX;清零
    CALL GETNUM
    
    ;SI偏移地址，BX指向开始的月地址
    XOR AX,AX
    MOV AL,DL;数值保存在SI
    DEC AL   ;从0开始
    MOV CL,06H ;一个月信息占6个字符
    MUL CL
    MOV SI,AX ;计算出偏移地址给SI
    LEA BX,MONTAB
    
    ;显示输出，
    LEA DX,[BX+SI]
    MOV AH,09H;
    INT 21H
    
    ;提示输入  
    LEA DX,MESS2
    MOV AH,09H;
    INT 21H
    
    MOV AH,01H;
    INT 21H
    CMP AL,'y' ;y重新执行一次程序
    CALL CRLF ;换行
    jz again0
    
    MOV AH,4CH
    INT 21H
    
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
CODES ENDS
    END START




