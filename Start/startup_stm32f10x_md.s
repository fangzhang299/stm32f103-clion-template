@******************************************************************************
@* startup_stm32f10x_md.s
@* GNU assembler (arm-none-eabi-gcc) startup file
@* Target     : STM32F103C8 (Medium Density, 64K FLASH / 20K RAM)
@*
@* Converted from the STM32F10x SPL V3.5.1 MDK-ARM version.
@* The vector table content is identical; the directives were rewritten
@* for GNU as syntax (AREA/DCD -> .section/.word).
@*
@* Data/BSS initialization matches the CubeMX linker script
@* (STM32F103XX_FLASH.ld) symbols:
@*     _estack, _sidata, _sdata, _edata, _sbss, _ebss
@*
@* The original MDK-ARM file is kept as startup_stm32f10x_md.keil.s
@******************************************************************************

    .syntax unified
    .cpu cortex-m3
    .fpu softvfp
    .thumb

@ Vector Table Mapped to Address 0 at Reset
    .section .isr_vector,"a",%progbits
    .align 2
    .global g_pfnVectors
    .type   g_pfnVectors, %object

g_pfnVectors:
    .word  _estack                         @ Top of Stack
    .word  Reset_Handler                   @ Reset Handler
    .word  NMI_Handler                     @ NMI Handler
    .word  HardFault_Handler               @ Hard Fault Handler
    .word  MemManage_Handler               @ MPU Fault Handler
    .word  BusFault_Handler                @ Bus Fault Handler
    .word  UsageFault_Handler              @ Usage Fault Handler
    .word  0                               @ Reserved
    .word  0                               @ Reserved
    .word  0                               @ Reserved
    .word  0                               @ Reserved
    .word  SVC_Handler                     @ SVCall Handler
    .word  DebugMon_Handler                @ Debug Monitor Handler
    .word  0                               @ Reserved
    .word  PendSV_Handler                  @ PendSV Handler
    .word  SysTick_Handler                 @ SysTick Handler

    @ External Interrupts
    .word  WWDG_IRQHandler                 @ Window Watchdog
    .word  PVD_IRQHandler                  @ PVD through EXTI Line detect
    .word  TAMPER_IRQHandler               @ Tamper
    .word  RTC_IRQHandler                  @ RTC
    .word  FLASH_IRQHandler                @ Flash
    .word  RCC_IRQHandler                  @ RCC
    .word  EXTI0_IRQHandler                @ EXTI Line 0
    .word  EXTI1_IRQHandler                @ EXTI Line 1
    .word  EXTI2_IRQHandler                @ EXTI Line 2
    .word  EXTI3_IRQHandler                @ EXTI Line 3
    .word  EXTI4_IRQHandler                @ EXTI Line 4
    .word  DMA1_Channel1_IRQHandler        @ DMA1 Channel 1
    .word  DMA1_Channel2_IRQHandler        @ DMA1 Channel 2
    .word  DMA1_Channel3_IRQHandler        @ DMA1 Channel 3
    .word  DMA1_Channel4_IRQHandler        @ DMA1 Channel 4
    .word  DMA1_Channel5_IRQHandler        @ DMA1 Channel 5
    .word  DMA1_Channel6_IRQHandler        @ DMA1 Channel 6
    .word  DMA1_Channel7_IRQHandler        @ DMA1 Channel 7
    .word  ADC1_2_IRQHandler               @ ADC1_2
    .word  USB_HP_CAN1_TX_IRQHandler       @ USB High Priority or CAN1 TX
    .word  USB_LP_CAN1_RX0_IRQHandler      @ USB Low Priority or CAN1 RX0
    .word  CAN1_RX1_IRQHandler             @ CAN1 RX1
    .word  CAN1_SCE_IRQHandler             @ CAN1 SCE
    .word  EXTI9_5_IRQHandler              @ EXTI Line 9..5
    .word  TIM1_BRK_IRQHandler             @ TIM1 Break
    .word  TIM1_UP_IRQHandler              @ TIM1 Update
    .word  TIM1_TRG_COM_IRQHandler         @ TIM1 Trigger and Commutation
    .word  TIM1_CC_IRQHandler              @ TIM1 Capture Compare
    .word  TIM2_IRQHandler                 @ TIM2
    .word  TIM3_IRQHandler                 @ TIM3
    .word  TIM4_IRQHandler                 @ TIM4
    .word  I2C1_EV_IRQHandler              @ I2C1 Event
    .word  I2C1_ER_IRQHandler              @ I2C1 Error
    .word  I2C2_EV_IRQHandler              @ I2C2 Event
    .word  I2C2_ER_IRQHandler              @ I2C2 Error
    .word  SPI1_IRQHandler                 @ SPI1
    .word  SPI2_IRQHandler                 @ SPI2
    .word  USART1_IRQHandler               @ USART1
    .word  USART2_IRQHandler               @ USART2
    .word  USART3_IRQHandler               @ USART3
    .word  EXTI15_10_IRQHandler            @ EXTI Line 15..10
    .word  RTCAlarm_IRQHandler             @ RTC Alarm through EXTI Line
    .word  USBWakeUp_IRQHandler            @ USB Wakeup from suspend
    .size  g_pfnVectors, . - g_pfnVectors

    .section .text,"ax",%progbits

@ Reset handler
    .global Reset_Handler
    .type   Reset_Handler, %function
Reset_Handler:
    ldr   sp, =_estack          @ set stack pointer
    bl    SystemInit            @ initialize system clock

    @ Copy the .data segment initializers from flash to SRAM
    ldr   r0, =_sidata          @ source address (LMA) in flash
    ldr   r1, =_sdata           @ destination start (VMA) in SRAM
    ldr   r2, =_edata           @ destination end (VMA) in SRAM
    bl    LoopCopyDataInit

    @ Zero fill the .bss segment
    ldr   r2, =_sbss
    ldr   r1, =_ebss
    mov   r0, #0
    bl    LoopFillZerobss

    @ Call the application's entry point
    bl    main
    b     .                     @ main should never return

LoopCopyDataInit:
    cmp   r1, r2
    bcs   CopyDataInitDone
    ldr   r3, [r0], #4
    str   r3, [r1], #4
    b     LoopCopyDataInit
CopyDataInitDone:
    bx    lr

LoopFillZerobss:
    cmp   r1, r2
    bcs   FillZerobssDone
    str   r0, [r1], #4
    b     LoopFillZerobss
FillZerobssDone:
    bx    lr
    .size Reset_Handler, . - Reset_Handler

@ Default handler: infinite loop for any unhandled interrupt
    .type   Default_Handler, %function
Default_Handler:
    b     .
    .size Default_Handler, . - Default_Handler

@ Dummy Exception Handlers (weak aliases -> Default_Handler)
@ A strong definition elsewhere (e.g. in stm32f10x_it.c) overrides these.
    .weak  NMI_Handler
    .thumb_set NMI_Handler, Default_Handler
    .weak  HardFault_Handler
    .thumb_set HardFault_Handler, Default_Handler
    .weak  MemManage_Handler
    .thumb_set MemManage_Handler, Default_Handler
    .weak  BusFault_Handler
    .thumb_set BusFault_Handler, Default_Handler
    .weak  UsageFault_Handler
    .thumb_set UsageFault_Handler, Default_Handler
    .weak  SVC_Handler
    .thumb_set SVC_Handler, Default_Handler
    .weak  DebugMon_Handler
    .thumb_set DebugMon_Handler, Default_Handler
    .weak  PendSV_Handler
    .thumb_set PendSV_Handler, Default_Handler
    .weak  SysTick_Handler
    .thumb_set SysTick_Handler, Default_Handler

    .weak  WWDG_IRQHandler
    .thumb_set WWDG_IRQHandler, Default_Handler
    .weak  PVD_IRQHandler
    .thumb_set PVD_IRQHandler, Default_Handler
    .weak  TAMPER_IRQHandler
    .thumb_set TAMPER_IRQHandler, Default_Handler
    .weak  RTC_IRQHandler
    .thumb_set RTC_IRQHandler, Default_Handler
    .weak  FLASH_IRQHandler
    .thumb_set FLASH_IRQHandler, Default_Handler
    .weak  RCC_IRQHandler
    .thumb_set RCC_IRQHandler, Default_Handler
    .weak  EXTI0_IRQHandler
    .thumb_set EXTI0_IRQHandler, Default_Handler
    .weak  EXTI1_IRQHandler
    .thumb_set EXTI1_IRQHandler, Default_Handler
    .weak  EXTI2_IRQHandler
    .thumb_set EXTI2_IRQHandler, Default_Handler
    .weak  EXTI3_IRQHandler
    .thumb_set EXTI3_IRQHandler, Default_Handler
    .weak  EXTI4_IRQHandler
    .thumb_set EXTI4_IRQHandler, Default_Handler
    .weak  DMA1_Channel1_IRQHandler
    .thumb_set DMA1_Channel1_IRQHandler, Default_Handler
    .weak  DMA1_Channel2_IRQHandler
    .thumb_set DMA1_Channel2_IRQHandler, Default_Handler
    .weak  DMA1_Channel3_IRQHandler
    .thumb_set DMA1_Channel3_IRQHandler, Default_Handler
    .weak  DMA1_Channel4_IRQHandler
    .thumb_set DMA1_Channel4_IRQHandler, Default_Handler
    .weak  DMA1_Channel5_IRQHandler
    .thumb_set DMA1_Channel5_IRQHandler, Default_Handler
    .weak  DMA1_Channel6_IRQHandler
    .thumb_set DMA1_Channel6_IRQHandler, Default_Handler
    .weak  DMA1_Channel7_IRQHandler
    .thumb_set DMA1_Channel7_IRQHandler, Default_Handler
    .weak  ADC1_2_IRQHandler
    .thumb_set ADC1_2_IRQHandler, Default_Handler
    .weak  USB_HP_CAN1_TX_IRQHandler
    .thumb_set USB_HP_CAN1_TX_IRQHandler, Default_Handler
    .weak  USB_LP_CAN1_RX0_IRQHandler
    .thumb_set USB_LP_CAN1_RX0_IRQHandler, Default_Handler
    .weak  CAN1_RX1_IRQHandler
    .thumb_set CAN1_RX1_IRQHandler, Default_Handler
    .weak  CAN1_SCE_IRQHandler
    .thumb_set CAN1_SCE_IRQHandler, Default_Handler
    .weak  EXTI9_5_IRQHandler
    .thumb_set EXTI9_5_IRQHandler, Default_Handler
    .weak  TIM1_BRK_IRQHandler
    .thumb_set TIM1_BRK_IRQHandler, Default_Handler
    .weak  TIM1_UP_IRQHandler
    .thumb_set TIM1_UP_IRQHandler, Default_Handler
    .weak  TIM1_TRG_COM_IRQHandler
    .thumb_set TIM1_TRG_COM_IRQHandler, Default_Handler
    .weak  TIM1_CC_IRQHandler
    .thumb_set TIM1_CC_IRQHandler, Default_Handler
    .weak  TIM2_IRQHandler
    .thumb_set TIM2_IRQHandler, Default_Handler
    .weak  TIM3_IRQHandler
    .thumb_set TIM3_IRQHandler, Default_Handler
    .weak  TIM4_IRQHandler
    .thumb_set TIM4_IRQHandler, Default_Handler
    .weak  I2C1_EV_IRQHandler
    .thumb_set I2C1_EV_IRQHandler, Default_Handler
    .weak  I2C1_ER_IRQHandler
    .thumb_set I2C1_ER_IRQHandler, Default_Handler
    .weak  I2C2_EV_IRQHandler
    .thumb_set I2C2_EV_IRQHandler, Default_Handler
    .weak  I2C2_ER_IRQHandler
    .thumb_set I2C2_ER_IRQHandler, Default_Handler
    .weak  SPI1_IRQHandler
    .thumb_set SPI1_IRQHandler, Default_Handler
    .weak  SPI2_IRQHandler
    .thumb_set SPI2_IRQHandler, Default_Handler
    .weak  USART1_IRQHandler
    .thumb_set USART1_IRQHandler, Default_Handler
    .weak  USART2_IRQHandler
    .thumb_set USART2_IRQHandler, Default_Handler
    .weak  USART3_IRQHandler
    .thumb_set USART3_IRQHandler, Default_Handler
    .weak  EXTI15_10_IRQHandler
    .thumb_set EXTI15_10_IRQHandler, Default_Handler
    .weak  RTCAlarm_IRQHandler
    .thumb_set RTCAlarm_IRQHandler, Default_Handler
    .weak  USBWakeUp_IRQHandler
    .thumb_set USBWakeUp_IRQHandler, Default_Handler

    .end
