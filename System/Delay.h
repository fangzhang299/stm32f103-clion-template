#ifndef __DELAY_H
#define __DELAY_H

#include "stm32f10x.h"


/*
 * 微秒延时
 */
void Delay_us(uint32_t us);


/*
 * 毫秒延时
 */
void Delay_ms(uint32_t ms);


/*
 * 秒延时
 */
void Delay_s(uint32_t s);



/*
 * MPU6050 DMP驱动接口
 *
 * 等价:
 * delay_ms()
 */
void delay_ms(unsigned long ms);



/*
 * MPU6050 DMP驱动接口
 *
 * 获取系统运行时间(ms)
 */
void mget_ms(unsigned long *count);



#endif
