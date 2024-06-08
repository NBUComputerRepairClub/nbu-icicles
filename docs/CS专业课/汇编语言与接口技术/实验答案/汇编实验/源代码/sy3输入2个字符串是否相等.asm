data segment
	;定义提示信息的字符串
	MESS1 db 'input string1:',0DH,0AH,'$'
	MESS2 db 'input string2:',0DH,0AH,'$'
	MESS3 db 'MATCH.',0DH,0AH,'$'
	MESS4 db 'NO MATCH.',0DH,0AH,'$'
	
	MAXLEN1 db 10;定义string1
	ACTLEN1 db ?  ;自动获得输入的长度
	string1 db 9 dup(?),'$'   ;实际存放字符串的地方
	
	MAXLEN2 db 10;定义string2
	ACTLEN2 db ?   ;自动获得输入的长度
	string2 db 9 dup(?),'$'  ;实际存放字符串的地方
	
	CRLF   DB  0AH, 0DH,'$'     ;换行符
data ends
;定义栈段
stack segment stack 'stack'
	STA db 128 DUP(?)
	TOP EQU LENGTH STA
stack ends

code segment 
ASSUME cs:code,ds:data,es:data,ss:stack
START: ;初始化相关段
        mov ax,data
        mov ds,ax
        mov es,ax
        mov ax,stack
        mov ss,ax
        mov sp,TOP
        
        ;显示提示输入信息MESS1
        LEA DX,MESS1 
		MOV AH,09H
		INT 21H
        ;接收字符串string1
        LEA DX,MAXLEN1                 
		MOV AH, 0AH
		INT 21H
		
		;换行 
		LEA DX, CRLF                                    
		MOV AH, 09H							 
		INT 21H
        ;调用STRSHOW宏显示提示信息MESS2
        LEA DX,MESS2
		MOV AH,09H
		INT 21H
        ;接收字符串string2
        LEA DX,MAXLEN2           
		MOV AH, 0AH
		INT 21H
        
        ;换行 
		LEA DX, CRLF                                    
		MOV AH, 09H							 
		INT 21H

		;比较2个字符串
        LEA bx,ACTLEN1
        mov ah,[bx] ;ah中存放string1的实际长度
        LEA bx,ACTLEN2
        mov al,[bx] ;al中存放string2的实际长度
        sub ah,al;检查两个字符串长度是否一致
        jnz nomatch
        
        LEA SI,string1;取出字符串偏移量
        LEA DI,string2
        CLD; DF=0，向内存高地址增加
        CBW   ;AL向AH做符号扩展 AX，记录长度
        
        mov cx,ax ;记录比较次数
        REPZ CMPSB  ;重复按位比较，一样零标志位为0
        jnz nomatch
        
match:;若匹配则输出提示信息MESS3
        LEA DX,MESS3
		MOV AH,09H
		INT 21H
        jmp done
nomatch:;若不匹配则输出提示信息MESS4
        LEA DX,MESS4
		MOV AH,09H
		INT 21H
        jmp done       
done:;
        mov ax,4C00H
        int 21H
code ends
END START




