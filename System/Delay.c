#include "Delay.h"

/*
 * SysTick 轮询模式延时，不使能中断。
 * 无需初始化，可直接调用。
 *
 * 通过 SystemCoreClock 动态计算，自适应任意主频。
 * SysTick 时钟源为 HCLK，24-bit 计数器。
 */

/* 24-bit 计数器最大值 */
#define MAX_TICKS   0xFFFFFFUL

void Delay_us(uint32_t xus)
{
    uint32_t ticks_per_us;
    uint32_t ticks;

    if (xus == 0)
    {
        return;
    }

    ticks_per_us = SystemCoreClock / 1000000U;

    while (xus > 0)
    {
        /* 单次计数值不超过 24-bit 上限 */
        if (xus > (MAX_TICKS / ticks_per_us))
        {
            ticks = MAX_TICKS;
            xus -= (MAX_TICKS / ticks_per_us);
        }
        else
        {
            ticks = ticks_per_us * xus;
            xus = 0;
        }

        SysTick->LOAD = ticks;
        SysTick->VAL  = 0x00;
        SysTick->CTRL = 0x00000005;             /* HCLK, 不使能中断, 启动 */
        while (!(SysTick->CTRL & 0x00010000));  /* 等待 COUNTFLAG */
        SysTick->CTRL = 0x00000004;             /* 关闭定时器 */
    }
}

void Delay_ms(uint32_t xms)
{
    while (xms--)
    {
        Delay_us(1000);
    }
}

void Delay_s(uint32_t xs)
{
    while (xs--)
    {
        Delay_ms(1000);
    }
}

void delay_ms(unsigned long ms)
{
    Delay_ms(ms);
}

void mget_ms(unsigned long *count)
{
    *count = 0;
}