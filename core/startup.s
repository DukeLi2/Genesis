# 写给汇编器的指令（操作说明书） 语法设置为统一（ARM and THUMB instructions统一指令）
    .syntax unified
    .cpu cortex-m7
    .fpu softvfp
    .thumb

@ .section（定义代码区域）.text.Reset_Handler（自定义的段名） 
    .section .text.Reset_Handler
    .weak   Reset_Handler
    .type   Reset_Handler, %function
    .align  2
Reset_Handler:
    bl main
    bx lr
    .size Reset_Handler, . - Reset_Handler


    .section .isr_vector, "a", %progbits
@ 声明一个全局符号
    .global g_pfnVectors
    .type g_pfnVectors, %object
@.size g_pfnVectors, . - g_pfnVectors
    .align 2
g_pfnVectors:   @ 符号定义在 .isr_vector 中
    .word   _estack
    .word   Reset_Handler
    .size g_pfnVectors, . - g_pfnVectors

