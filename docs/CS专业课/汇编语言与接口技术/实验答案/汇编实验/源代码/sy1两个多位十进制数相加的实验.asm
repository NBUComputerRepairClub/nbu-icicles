DATA SEGMENT
DATA1 DB ' ','6','8','5','9',0DH,0AH,'$' ;����1�����ֽ�Ϊ��λ����ַ���ӦASCAL��
DATA2 DB ' ', '4','7','6','4',0DH,0AH,'$'; 0DH�ǻس���0AH�ǻ��� ��'$'Ϊ������
DATA ENDS

CODE SEGMENT
  ASSUME CS:CODE,DS:DATA
START:
  MOV AX,DATA ;���ݷ���AX
  MOV DS,AX   ;���ݷ���DS
  
  LEA DX,DATA1 ;��DATA1����Ч��ַ��ƫ�Ƶ�ַ��������DX�Ĵ���
  MOV AH,09H   ;09���жϣ���ʾDX������Ϊ�׵�ַ���ַ���
  INT 21H 
  
  LEA DX,DATA2 ;ͬ��
  MOV AH,09H  
  INT 21H

  LEA DI,DATA1 ;DATA1��ַ����DI ��ַ�Ĵ���
  LEA SI,DATA2 ;DATA2��ַ����SI
  MOV CX,5 ;����ѭ���ظ�5��
BEGIN:
  SUB BYTE PTR [DI],30H ;BYTE PTR [DI],DI��ĵ�ַ���ַ�ת����
  SUB BYTE PTR [SI],30H

  INC SI ;+1,������һλ����
  INC DI 
LOOP BEGIN

  DEC SI ;-1 �����λ��ʼ��������
  DEC DI
  MOV CX,5 ;5λ���ظ�5��ѭ��

  CLC ;��λ����
CALADD:
  MOV AL,BYTE PTR [DI] ;��DI�洢�ĵ�ַ��Ӧ�����ַ���AL
  ADC AL,BYTE PTR [SI] ;��SI�洢�ĵ�ַ��Ӧ�����ַ���AL
  
  AAA ;δ��ϵ�BCD����ָ��
  MOV BYTE PTR [DI],AL ;������ӣ�������DI�洢�ĵ�ַ

  DEC SI ;��һ����λ������
  DEC DI
LOOP CALADD
  
  INC DI ;+1 ��������λ
  MOV CX,5 ;�ظ�5��
DEALRESULT:
  ADD BYTE PTR [DI],30H ;����תASCAL�ַ�
  
  INC DI ;��һλ
LOOP DEALRESULT

   
  LEA DX,DATA1 ;�����ʾ���
  MOV AH,09H
  INT 21H 
  
  MOV AH,4CH ;��ֹ���̣�����
  INT 21H
CODE ENDS
END START


