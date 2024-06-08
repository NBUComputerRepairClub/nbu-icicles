data segment
	;������ʾ��Ϣ���ַ���
	MESS1 db 'input string1:',0DH,0AH,'$'
	MESS2 db 'input string2:',0DH,0AH,'$'
	MESS3 db 'MATCH.',0DH,0AH,'$'
	MESS4 db 'NO MATCH.',0DH,0AH,'$'
	
	MAXLEN1 db 10;����string1
	ACTLEN1 db ?  ;�Զ��������ĳ���
	string1 db 9 dup(?),'$'   ;ʵ�ʴ���ַ����ĵط�
	
	MAXLEN2 db 10;����string2
	ACTLEN2 db ?   ;�Զ��������ĳ���
	string2 db 9 dup(?),'$'  ;ʵ�ʴ���ַ����ĵط�
	
	CRLF   DB  0AH, 0DH,'$'     ;���з�
data ends
;����ջ��
stack segment stack 'stack'
	STA db 128 DUP(?)
	TOP EQU LENGTH STA
stack ends

code segment 
ASSUME cs:code,ds:data,es:data,ss:stack
START: ;��ʼ����ض�
        mov ax,data
        mov ds,ax
        mov es,ax
        mov ax,stack
        mov ss,ax
        mov sp,TOP
        
        ;��ʾ��ʾ������ϢMESS1
        LEA DX,MESS1 
		MOV AH,09H
		INT 21H
        ;�����ַ���string1
        LEA DX,MAXLEN1                 
		MOV AH, 0AH
		INT 21H
		
		;���� 
		LEA DX, CRLF                                    
		MOV AH, 09H							 
		INT 21H
        ;����STRSHOW����ʾ��ʾ��ϢMESS2
        LEA DX,MESS2
		MOV AH,09H
		INT 21H
        ;�����ַ���string2
        LEA DX,MAXLEN2           
		MOV AH, 0AH
		INT 21H
        
        ;���� 
		LEA DX, CRLF                                    
		MOV AH, 09H							 
		INT 21H

		;�Ƚ�2���ַ���
        LEA bx,ACTLEN1
        mov ah,[bx] ;ah�д��string1��ʵ�ʳ���
        LEA bx,ACTLEN2
        mov al,[bx] ;al�д��string2��ʵ�ʳ���
        sub ah,al;��������ַ��������Ƿ�һ��
        jnz nomatch
        
        LEA SI,string1;ȡ���ַ���ƫ����
        LEA DI,string2
        CLD; DF=0�����ڴ�ߵ�ַ����
        CBW   ;AL��AH��������չ AX����¼����
        
        mov cx,ax ;��¼�Ƚϴ���
        REPZ CMPSB  ;�ظ���λ�Ƚϣ�һ�����־λΪ0
        jnz nomatch
        
match:;��ƥ���������ʾ��ϢMESS3
        LEA DX,MESS3
		MOV AH,09H
		INT 21H
        jmp done
nomatch:;����ƥ���������ʾ��ϢMESS4
        LEA DX,MESS4
		MOV AH,09H
		INT 21H
        jmp done       
done:;
        mov ax,4C00H
        int 21H
code ends
END START




