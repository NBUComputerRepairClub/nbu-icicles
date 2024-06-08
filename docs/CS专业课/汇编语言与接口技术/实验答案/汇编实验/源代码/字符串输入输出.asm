DATAS SEGMENT
    ;此处输入数据段代码  
 
BUF DB  10				    ;预定义10字节的空间
       DB  ?				    ;待输入完成后，自动获得输入的字符个数
       DB  10  DUP(?)    
CRLF   DB  0AH, 0DH,'$'     ;换行符
    
DATAS ENDS
 
STACKS SEGMENT
    ;此处输入堆栈段代码  
STACKS ENDS
 
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
    LEA DX,BUF                    ;接收字符串
    MOV AH, 0AH
    INT 21H
    
    MOV AL,BUF+1                  ;对字符串进行处理，buf+1标识输入字符的长度，BUF+2是字符串字符的首地址
    ADD AL,2					  ;字符长度+2
    MOV AH, 0
    MOV SI, AX					  ;AX是buf缓冲区总长度
    MOV BUF[SI], '$'              ;末尾添加'$'符号标识字符串结尾
    LEA DX, CRLF                  ;换行                   
    MOV AH, 09H							 
    INT 21H
  
    LEA DX, BUF+2                  ;输出输入的字符串
    MOV AH, 09H							 
    INT 21H
   
    
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START

