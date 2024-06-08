DATA SEGMENT
DATA1 DB ' ','6','8','5','9',0DH,0AH,'$' ;数据1，以字节为单位存放字符对应ASCAL码
DATA2 DB ' ', '4','7','6','4',0DH,0AH,'$'; 0DH是回车，0AH是换行 ，'$'为结束符
DATA ENDS

CODE SEGMENT
  ASSUME CS:CODE,DS:DATA
START:
  MOV AX,DATA ;数据放入AX
  MOV DS,AX   ;数据放入DS
  
  LEA DX,DATA1 ;将DATA1的有效地址（偏移地址），放入DX寄存器
  MOV AH,09H   ;09号中断，显示DX内容作为首地址的字符串
  INT 21H 
  
  LEA DX,DATA2 ;同上
  MOV AH,09H  
  INT 21H

  LEA DI,DATA1 ;DATA1地址放入DI 变址寄存器
  LEA SI,DATA2 ;DATA2地址放入SI
  MOV CX,5 ;下面循环重复5次
BEGIN:
  SUB BYTE PTR [DI],30H ;BYTE PTR [DI],DI里的地址的字符转数字
  SUB BYTE PTR [SI],30H

  INC SI ;+1,处理下一位数据
  INC DI 
LOOP BEGIN

  DEC SI ;-1 从最低位开始进行运算
  DEC DI
  MOV CX,5 ;5位，重复5次循环

  CLC ;进位清零
CALADD:
  MOV AL,BYTE PTR [DI] ;把DI存储的地址对应的数字放入AL
  ADC AL,BYTE PTR [SI] ;把SI存储的地址对应的数字放入AL
  
  AAA ;未组合的BCD调整指令
  MOV BYTE PTR [DI],AL ;两数相加，保存在DI存储的地址

  DEC SI ;下一个高位的运算
  DEC DI
LOOP CALADD
  
  INC DI ;+1 结果的最高位
  MOV CX,5 ;重复5次
DEALRESULT:
  ADD BYTE PTR [DI],30H ;数字转ASCAL字符
  
  INC DI ;下一位
LOOP DEALRESULT

   
  LEA DX,DATA1 ;输出显示结果
  MOV AH,09H
  INT 21H 
  
  MOV AH,4CH ;终止进程，返回
  INT 21H
CODE ENDS
END START


