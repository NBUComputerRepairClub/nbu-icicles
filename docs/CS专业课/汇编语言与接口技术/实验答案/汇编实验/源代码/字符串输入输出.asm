DATAS SEGMENT
    ;�˴��������ݶδ���  
 
BUF DB  10				    ;Ԥ����10�ֽڵĿռ�
       DB  ?				    ;��������ɺ��Զ����������ַ�����
       DB  10  DUP(?)    
CRLF   DB  0AH, 0DH,'$'     ;���з�
    
DATAS ENDS
 
STACKS SEGMENT
    ;�˴������ջ�δ���  
STACKS ENDS
 
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
    LEA DX,BUF                    ;�����ַ���
    MOV AH, 0AH
    INT 21H
    
    MOV AL,BUF+1                  ;���ַ������д���buf+1��ʶ�����ַ��ĳ��ȣ�BUF+2���ַ����ַ����׵�ַ
    ADD AL,2					  ;�ַ�����+2
    MOV AH, 0
    MOV SI, AX					  ;AX��buf�������ܳ���
    MOV BUF[SI], '$'              ;ĩβ���'$'���ű�ʶ�ַ�����β
    LEA DX, CRLF                  ;����                   
    MOV AH, 09H							 
    INT 21H
  
    LEA DX, BUF+2                  ;���������ַ���
    MOV AH, 09H							 
    INT 21H
   
    
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START

