DATAS SEGMENT
	;A DB 65H,32H 
	A DB 12H,45H,0F3H,6AH,20H,0FEH,90H,0C8H,57H,34H;����
	num equ 10 ;���ݸ���
	sum DB ? ;Ԥ�������Ŵ�
    ;�˴��������ݶδ���  
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
	XOR SI,SI;λ��������
	XOR AL,AL;����
    MOV CX,num;�ۼӴ���
again:ADD AL,A[SI]; �ۼ�
	INC SI ;ָ����һ����
Loop again;CXδ��0�������ۼ�
	MOV sum,AL;����
    ;�˴��������δ���
    MOV AH,02  ;���ascall��Ӧ�ַ�
    INT 21H
CODES ENDS
    END START







