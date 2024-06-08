data SEGMENT 
	ts DB 'please input:$' 
	again DB 0ah,0dh,'press ctrl+C to end,else again:$' 
	string DB 10 DUP(?),'$'
data ENDS 

code SEGMENT 
	ASSUME CS:code,DS:data 
start: 
	;加载数据段
	MOV AX,data  
	MOV DS,AX 

	
	LEA BX,STRING ;BX指向缓冲区
	XOR SI,SI ;将SI清零
	
	LEA DX,ts 
	MOV AH,09h ;显示输出提示字符串 
	INT 21h 
again1:
	
	MOV AH,01h ;调用01号功能接收字符 
	INT 21h 
	
	CMP AL,3 ;CTRL+C对应ascll为3
	JZ  done
	
	CMP AL,13 ;回车对应ascll为13
	JZ  show
 	
	CMP AL,'a' ;与a的ASCll比较，小于则转移 
	JB nochange
	CMP AL,'z' ;与z的ASCll比较，大于则转移 
	JA nochange
	SUB AL,20h ;将小写转换为大写 

nochange:
	mov [BX+SI],AL ;存放该字符
	INC SI ;SI+1
	jMP again1 
show:
	;mov [BX+SI],'$';
	LEA DX,STRING
	mov AH,09H  ;显示缓冲区的字符
	int 21H
done:
	MOV AH,4cH
	INT 21h 

;换行函数
CRLF    PROC    near 
	PUSH DX ;保护之前的数据
	PUSH AX                    
	MOV DL,0DH
    MOV AH,02H
    INT 21H       ;光标移到第一列              
    MOV DL,0AH
    MOV AH,02H
    INT 21H       ;光标移到下一行
    POP AX
	POP DX             
    RET
CRLF ENDP



code ENDS 
END start 



