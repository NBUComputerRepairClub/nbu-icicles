DATA SEGMENT
	Data1 DB 50H ;数字1
	data2 DB 60H ;数字2
	Result DB 2 DUP(?) ;结果
	MES1 DB '*','$' ;字符串
	MES2 DB '=','$'
DATA ENDS

STACK SEGMENT PARA STACK 'STACK'
	STAPN DB 100 DUP(?) ;开辟100个字节的堆栈段
	TOP EQU LENGTH STAPN ;top=100
STACK ENDS

CODE SEGMENT
	ASSUME CS:CODE,DS:DATA,SS:STACK ;说明当前使用的段
START:
	;初始化数据段，堆栈段
	MOV AX,DATA
	MOV DS,AX
	MOV AX,STACK
	MOV SS,AX
	MOV AX,TOP
	MOV SP,AX
	
	;DL累加CL乘数2；DH累加进位，次数为BL
	MOV BL,Data1
	MOV CL,Data2
	MOV DX,0 ;初始值为0
	MOV AL,BL ;BL作为计数器，执行BL个data2相加
	
AGAIN:OR AL,AL ;BL=AL=0,则零标志位置=0,计数器结束
	JZ DONE ;零标志位置=0，则跳转DONE
	
	;低位与乘数2累加
	MOV AL,DL ;AL暂存DL
	ADD AL,CL ;DL+CL
	DAA       ;组合的BCD调整指令
	MOV DL,AL ;DL存累加后的值
	
	;高位进行进位调整
	MOV AL,DH ;暂存高位
	ADC AL,0 ;带进位的加法
	DAA		;组合的BCD调整指令
	MOV DH,AL ;DH存放进位后的值
	
	;计数器减一
	MOV AL,BL ;存data1
	DEC AL	  ;计数器BL-1
	DAS		  ;减法组合BCD码调整
	MOV BL,AL ;AL放
	
	JMP AGAIN
	
	;显示结果
DONE:
    
    LEA BX,result ;BX存变量result的地址
	MOV [BX],DX  ;DX计算结果存入result
	
	;输出Data1
	LEA SI,Data1 ;result地址存入SI
	CALL DIS  ;调用DIS函数，输出
	
	;输出变量MES1对应字符*
	XOR AX,AX ;AX清零
	MOV AH,09H ;
	LEA DX,MES1 
	INT 21H
	
	;输出Data2
	LEA SI,Data2
	CALL DIS
	
	;输出变量MES2对应字符=
	XOR AX,AX
	MOV AH,09H
	LEA DX,MES2
	INT 21H
	
	;输出result高8位，2个字符
	LEA SI,result
	INC SI ;SI地址+1,DH=DL+1
	CALL DIS
	
	;输出result低8位，2个字符
	DEC SI
	CALL DIS
	;程序结束
	MOV AX,4C00H
	INT 21H
	
;输出2个4位对应字符
DIS PROC NEAR
	;输出高4位对应字符
	MOV AL,[SI] ;AL存入结果数据
	MOV CL,04H  
	SHR AL,CL   ;逻辑右移4位，AL取高4位
	ADD AL,30H  ;数字转字符
	MOV DL,AL   ;结果存入DL
	MOV AH,02H  ;输出一个字符
	INT 21H
	;输出低4位对应字符
	MOV AL,[SI] 
	AND AL,0FH 
	ADD AL,30H
	MOV DL,AL
	MOV AH,02H
	INT 21H
	
	RET ;返回指令
DIS ENDP 

CODE ENDS
END START

