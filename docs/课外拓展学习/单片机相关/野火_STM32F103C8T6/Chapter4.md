# 什么？你也是影流之主？

上一章我们讲到了要如何去点亮我们的板载LED。但是众所周知，我们的日常生活中的LED灯都是可以做各种各样的操作的。像用开关操作LED灯啦、这个灯一遍遍地闪烁啦、又或者是让他有一个呼吸状态的效果啦，之类的。在本章中，我们要完成的任务就是——让这几个板载的LED灯实现一个流水灯的效果。

流水灯其实就是好几个灯 依次的 、 有间隔 的亮灭，也可以叫跑马灯或者其他的什么，但是我更喜欢叫流水灯。那请思考一下，我们要达成这样 依次的、有间隔的亮灭，应该如何去实现呢？

聪明的你应该能想到， 依次的 对应到代码中，就是要我们去控制他每一个灯对应的GPIO口的高低电平，相信你看了上一章的内容之后，你应该能很清楚的知道我们该怎么去实现这个功能了。而 有间隔的亮灭 ，对应到代码当中的含义就是，需要我们执行 延迟 操作，也就是让我们写一个 延时函数 。

如果你觉得自己已经差不多懂了，想迫不及待的上手练练你的stm32了，那接下来我估计得给你浇一盆冷水了——我在上一章写的任务，您完成了么？

我在上一章给的最后的任务的意思其实是想让你们把和led有关的程序——“LED_Config”、“LED_ON”、“LED_OFF”，给封装成一个led.c文件。和其他的库函数一样，有.c文件，就一定有.h文件（头文件），所以同时，我们要重新写出来一个led.h文件。

然后，你可以利用你在C语言中学到的 宏定义 （对的，就是那个你觉得没啥用的东西），来给你在上一章定义的那些莫名其妙的地址和端口什么的，重新命名一下。比方说像这样：

```
#define LED_PORT        GPIOA
#define LED_CLK         RCC_APB2Periph_GPIOA
#define RED_Pin         GPIO_Pin_1
#define GREEN_Pin       GPIO_Pin_2
#define BLUE_Pin        GPIO_Pin_3
```

当然，函数的声明什么的，也要在这里写一下：

```
void LED_Config(void)       ;

void LED_on	(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin);
void LED_off(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin);
```

然后就是别忘了你头文件(.h文件)的初始化和你写函数的那个.c文件的头文件导入：

这是写在.h文件最前面的部分：

```
#ifndef __LED_H
#define __LED_H

#include "stm32f10x.h"


……(写上你的那些宏定义和函数声明)


#endif /*  __LED_H  */
```

这是写在.c文件最前面的部分(导入你的刚刚写的头文件)：
```
#include "led.h"
```

剩下的就是写复制粘贴的事情了，跟你一开始写的时候一样，只不过所有函数的定义你都要放在对应的.c文件中。最后别忘了在 main.c 中，你要多导入一个头文件——嗯，对的，就是你刚刚定义的那个led.h文件。这样你才能去调用你刚刚写的那些控制LED的函数。

上次的课后题就讲这么多，接下来我们开始想想，如何延时，从而让LED灯实现流水灯的效果。

按照我们的正常思路，如果说你想要延迟，你就要让这个玩意儿休息一段时间。像python中有sleep函数，让一个器件在一段时间内 “如同婴儿般的入睡” 。同理，我们也可以让这个stm32在这段时间内什么事情都不执行，来做到我们延时的效果。

那现在效果有了，我们要如何书写函数来做到判断经过了多少时间呢？还记得我们在第3章中讲到的时钟么，我们就用这个stm32的心脏来判断流过了多少时间。

所以你要做的，就是在main.c文件中（也可以再用.c、.h文件来进行库函数的封装的，你喜欢哪个就用哪个，`建议后者`），用一个循环，让他什么也不做，然后反复测试你的时间来看下是否可行。但是这个函数归根结底是占用了我们的CPU资源，只能做到一个简单、粗略的延时功能。在后面的学习中，我们会用到定时器来书写更精准的延时函数，但是现在么，还是拿这个先将就着用一下叭。

我也简单的写了一个delay的函数，如下：

```
void Rough_Delay(__IO uint32_t ncount)
{
	for ( uint32_t i = 0 ; i < ncount ; i++)
	{
		__NOP();
	}
}

void Rough_Delay_us(__IO uint32_t time)
{
	Rough_Delay(7*time);
}

void Rough_Delay_ms(__IO uint32_t time)
{
	Rough_Delay(0x318*7*time);
}

void Rough_Delay_s(__IO uint32_t time)
{
	Rough_Delay(0x318*0x318*7*time);
}
```

函数中的一些数值是通过计时测试得出来了，可以的话尽量不要做特别的修改，当然你想改也没啥太大的关系啦，别动 7 这个数字就可以了。0x318是十六进制的1000，乘上去相当于是单位的换算了。

那现在，我们有了延迟函数，也把LED相关的函数给封装了起来，聪明的你应该也能写出一个漂亮的流水灯了。？你说你还是不会写？八嘎，快快闭门再造造车叭。

你说你想照搬我的代码？行叭行叭，但只能参考借鉴哦：

led.c文件：

```
#include "led.h"

void LED_Config	(void)
{
	GPIO_InitTypeDef gpio_init = {0};                     //初始化端口
	
	RCC_APB2PeriphClockCmd(LED_CLK, ENABLE); //开启端口时钟
	
	//关闭灯（初始化灯的状态）
	GPIO_SetBits( LED_PORT, RED 	);                    //让红灯引脚端口输出1，使得灯灭
	GPIO_SetBits( LED_PORT, GREEN 	);                    //让绿灯引脚端口输出1，使得灯灭
	GPIO_SetBits( LED_PORT, BLUE 	);                    //让蓝灯引脚端口输出1，使得灯灭
	
	//配置io模式，推挽模式，50M
	gpio_init.GPIO_Pin    = RED		;
	gpio_init.GPIO_Mode   = GPIO_Mode_Out_PP;
	gpio_init.GPIO_Speed  = GPIO_Speed_50MHz;
	GPIO_Init(LED_PORT, & gpio_init);                        //配置端口引脚的模式
	
	gpio_init.GPIO_Pin    = GREEN	;
//	gpio_init.GPIO_Mode   = GPIO_Mode_Out_PP;
//	gpio_init.GPIO_Speed  = GPIO_Speed_50MHz;
	GPIO_Init(LED_PORT, & gpio_init);                        //配置端口引脚的模式	
	
	gpio_init.GPIO_Pin    = BLUE	;
//	gpio_init.GPIO_Mode   = GPIO_Mode_Out_PP;
//	gpio_init.GPIO_Speed  = GPIO_Speed_50MHz;	
	GPIO_Init(LED_PORT, & gpio_init);                        //配置端口引脚的模式	
}

void LED_on	(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
	GPIO_ResetBits( GPIOx, GPIO_Pin );					//让红灯引脚端口x输出1，使得灯灭
}

void LED_off(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
	GPIO_SetBits(  GPIOx, GPIO_Pin);						//让红灯引脚端口x输出1，使得灯灭
}
```

led.h文件：

```
#ifndef __LED_H
#define __LED_H

#include "stm32f10x.h"

#define LED_PORT    GPIOA
#define LED_CLK     RCC_APB2Periph_GPIOA
#define RED         GPIO_Pin_1
#define GREEN       GPIO_Pin_2
#define BLUE        GPIO_Pin_3

#define LED_RED_ON          LED_on( LED_PORT,RED    );
#define LED_GREEN_ON        LED_on( LED_PORT,GREEN  );
#define LED_BLUE_ON         LED_on( LED_PORT,BLUE   );

#define LED_RED_OFF         LED_off( LED_PORT,RED    );
#define LED_GREEN_OFF       LED_off( LED_PORT,GREEN  );
#define LED_BLUE_OFF        LED_off( LED_PORT,BLUE   );

#define LED_ONLY_RED_ON     LED_on  ( LED_PORT,RED    );    \
                            LED_off ( LED_PORT,GREEN  );    \
                            LED_off ( LED_PORT,BLUE   );

#define LED_ONLY_GREEN_ON   LED_off ( LED_PORT,RED    );    \
                            LED_on  ( LED_PORT,GREEN  );    \
                            LED_off ( LED_PORT,BLUE   );

#define LED_ONLY_BLUE_ON    LED_off ( LED_PORT,RED    );    \
                            LED_off ( LED_PORT,GREEN  );    \
                            LED_on  ( LED_PORT,BLUE   );

#define LED_ONLY_RED_OFF    LED_off ( LED_PORT,RED    );    \
                            LED_on  ( LED_PORT,GREEN  );    \
                            LED_on  ( LED_PORT,BLUE   );

#define LED_ONLY_GREEN_OFF  LED_on  ( LED_PORT,RED    );    \
                            LED_off ( LED_PORT,GREEN  );    \
                            LED_on  ( LED_PORT,BLUE   );

#define LED_ONLY_BLUE_OFF   LED_on  ( LED_PORT,RED    );    \
                            LED_on  ( LED_PORT,GREEN  );    \
                            LED_off ( LED_PORT,BLUE   );

#define LED_ALL_ON          LED_on  ( LED_PORT,RED    );    \
                            LED_on  ( LED_PORT,GREEN  );    \
                            LED_on  ( LED_PORT,BLUE   );

#define LED_ALL_OFF         LED_off ( LED_PORT,RED    );    \
                            LED_off ( LED_PORT,GREEN  );    \
                            LED_off ( LED_PORT,BLUE   );

void LED_Config(void)       ;

void LED_on	(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin);
void LED_off(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin);

#endif /*  __LED_H  */
```

delay.c文件：

```
#include "delay.h"

void Rough_Delay(__IO uint32_t ncount)
{
	for ( uint32_t i = 0 ; i < ncount ; i++)
	{
		__NOP();
	}
}

void Rough_Delay_us(__IO uint32_t time)
{
	Rough_Delay(7*time);
}

void Rough_Delay_ms(__IO uint32_t time)
{
	Rough_Delay(0x318*7*time);
}

void Rough_Delay_s(__IO uint32_t time)
{
	Rough_Delay(0x318*0x318*7*time);
}
```

delay.h文件：

```
#ifndef __DELAY_H
#define __DELAY_H

#include "stm32f10x.h"

void Rough_Delay(__IO uint32_t ncount);
void Rough_Delay_us(__IO uint32_t time);
void Rough_Delay_ms(__IO uint32_t time);
void Rough_Delay_s(__IO uint32_t time);

#endif /*  __DELAY_H  */
```

main.c文件：

```
#include "stm32f10x.h"

#include "led.h"
#include "delay.h"

int main(void)
{
	LED_Config();
	uint32_t time_temp = 1000;

    while(1)
	{
		LED_ONLY_RED_ON ;
		Rough_Delay_ms(time_temp);
		LED_ONLY_GREEN_ON ;
		Rough_Delay_ms(time_temp);
		LED_ONLY_BLUE_ON ;
		Rough_Delay_ms(time_temp);
		LED_ALL_ON
		Rough_Delay_ms(time_temp);
		LED_ALL_OFF
		Rough_Delay_ms(time_temp);
	}
}
```

如果你把这些代码一通复制进去然后又说什么报错什么的，想想你的是不是漏了什么：文件有放到keil里面么？又或者是你忘记把相关文件夹的路径给放进去了？又或者——你在mainn.c文件里面忘记#include "led.h"了么？

![文件位置](./相关图片/4-1%20keil中虚拟文件位置.png)

![文件路径](./相关图片/4-2%20文件路径.png)


好了，说再多的话，你就失去了自主探索的能力了。人本来就是在不断犯错当中成长的，如果说你总是一帆风顺的话，那也不太好，对叭(ゝ∀･)？

