DATA0 SEGMENT		;排序数据段
   ORG 20H  ;从20H开始安排数据
   DATA1 DB 0Ch,09h,08h,07h,06h,05h,04h,03h,0Dh,02h ;data
 		 DB 1ah,19h,18h,07h,06h,05h,04h,03h,01h,12h
 		 DB 2ah,29h,28h,07h,06h,05h,04h,03h,01h,22h
 		 DB 3ah,39h,38h,07h,06h,05h,04h,03h,01h,32h
 		 DB 4ah,49h,48h,07h,06h,05h,04h,03h,01h,42h
DATA0 ENDS

DATAS SEGMENT ;文本数据段
   ORG 100H
   SORTNUM EQU 10   ;改到10显示得下，50题目要求
   MESS1 DB 'INPUT SEGMENT VALUE:$'
   MESS2 DB 'INPUT OFFSET VALUE:$'
   MESS3 DB 'success sort',13,10,'$'
   ERROR DB 'INPUT ERRORt',13,10,'$'
DATAS ENDS

STACK   SEGMENT STACK          ;栈定义
STA     DB      32 DUP (?)
TOP     DW      ?
STACK   ENDS

CODES SEGMENT						
    ASSUME CS:CODES,DS:DATAS,SS:STACK
START:
	;段初始化
	MOV AX,DATAS                 
    MOV DS,AX  ;DS当前使用存放文本的数据段DATAS
    MOV AX,STACK
    MOV SS,AX
    MOV AX,TOP
    MOV SP,AX
    ;提示输入选择段
    MOV AH,09H          ;09H号功能显示字符串
    MOV DX,OFFSET MESS1
    INT 21H        
    
    ;调用GETNUM，返回值放DL，最多输入4位，返回二进制表示保存在DX
    CALL GETNUM

    ;键入段地址送ES，提示数据位置
    MOV DH,00H ;DH有值清零
    MOV ES,DX
    CALL CRLF ;换行
    
    ;提示输入偏移值
    MOV AH,09H          
    MOV DX,OFFSET MESS2
    INT  21H  
    
    ;调用GETNUM，返回值放DX
    CALL GETNUM    
    
    ;键入偏移量送SI，排序数据段位置
	MOV DH,00H ;DH有值清零
    MOV SI,DX;数据开始位置，偏移段地址多少

	;DS指向存放排序的数据段data0
	mov AX,DATA0
	MOV DS,AX
	
    MOV CX,SORTNUM  ;外循环次数SORTNUM—1送CX
    DEC CX ;cx-1
    XOR BX,BX ;偏移指针BX清0
      
AGAIN0:
	MOV AL,[SI+BX] ;偏移量+偏移指针,从[SI+BX]单元取数送AL
	MOV AH,BL     ;AH指向当前选择排序的数的位置，AH=BL
	PUSH CX       ;CX入栈，外循环计数保存
	MOV CX,SORTNUM   ;计算内循环次数送CX
	SUB CX,BX        ;CX-BX,剩余需要排序的数
	DEC CX
	MOV DX,BX     ;内循环控制变量DX初始化
	;选择BX之后（之前的已经排好），最小的数据位置保存在AX
AGAIN1:
	INC DX  ;DX值加1
	PUSH BX ;保存选择排序内循环开始位置
	MOV BX,DX   ;BX指向下一个数据
	CMP AL,[SI+BX]  ;比较AL与DX批示单元的值
JBE UUU			;比AL大跳转
	MOV AL,[SI+BX] ;DX指示单元的值赋给AL
	MOV AH,DL		;并修改指针AH，AH指向最小的位置
UUU:
	POP BX
LOOP AGAIN1
	;最小值与从前往后遍历的目前位置交换
	MOV CL,[SI+BX] ;[SI+BX]旧值暂存CL
	MOV [SI+BX],AL  ;[SI+BX]新值得到AL记录的最小值
	MOV DL,AH		;DL,记录最小值位置
	PUSH BX			;BX入栈
	MOV BX,DX		;[SI+BX]变为最小值位置
	MOV [SI+BX],CL 	;最小值位置赋交换的值
	POP BX			;恢复外循环位置
	;当前位置完成排序，排后面一个
	INC BX   ;偏移指针B加1
	POP CX	  ;一个循环结束后cx-1
LOOP AGAIN0
    
    PUSH DS  ;保存排序数据段位置 
    MOV AX,DATAS ;临时换为输出数据段
    MOV     DS,AX
     ;输出完成排序
    MOV     AH,09H          ;09H号功能显示字符串
    MOV     DX,OFFSET MESS3
    INT     21H        
    
    POP DS ;恢复排序数据段位置
    MOV CX,SORTNUM
    ;显示输出
AGAIN2:
	MOV AL,[SI]
    CALL DISP1 ;循环调DISP1，将排序后的数依次显示出
    CALL CRLF
    INC SI
LOOP AGAIN2

	;结束进程，返回控制权限
    MOV     AX,4C00H
    INT     21H

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
  
CODES ENDS
END START























