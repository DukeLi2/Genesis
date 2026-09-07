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
    ldr sp, = _estack

    ldr r0, = _sdata
    ldr r1, = _edata
    ldr r2, = _sidata
    mov r3, #0
    b LoopCopyDataInit
CopyDataInit:
    ldr r4, [r2, r3]
    str r4, [r0, r3]
    adds r3, r3, #4

LoopCopyDataInit:
    adds r4, r0, r3
    cmp r4, r1
    bcc CopyDataInit

    /* 清除 BSS 段 */
    ldr r0, = __bss_start__
    ldr r1, = __bss_end__
    mov r2, #0
    mov r4, #0
    b LoopClearBSS

ClearBSS:
    str r4, [r3] 
    adds r2, r2, #4

LoopClearBSS:
    adds r3, r0, r2
    cmp r3, r1
    bcc ClearBSS  

    bl main
    bx lr
    .size Reset_Handler, . - Reset_Handler


.section .text.Default_Handler
    .weak   Default_Handler
    .type   Default_Handler, %function
    .align  1
Default_Handler:
    b .
    .size Default_Handler, . - Default_Handler


    .section .isr_vector, "a", %progbits
@ 声明一个全局符号
    .global g_pfnVectors
    .type g_pfnVectors, %object
@.size g_pfnVectors, . - g_pfnVectors
    .align 2
g_pfnVectors:   @ 符号定义在 .isr_vector 中
    .word   _estack
    .word   Reset_Handler
    .word   NMI_Handler
    .word   HardFault_Handler
    .word   MemManage_Handler
    .word   BusFault_Handler
    .word   UsageFault_Handler
    .word   0
    .word   0
    .word   0
    .word   0
    .word   SVC_Handler
    .word   DebugMon_Handler
    .word   0
    .word   PendSV_Handler
    .word   SysTick_Handler
    .size g_pfnVectors, . - g_pfnVectors

/**************************************/
    .weak NMI_Handler
    .thumb_set NMI_Handler, Default_Handler
    .weak HardFault_Handler
    .thumb_set HardFault_Handler, Default_Handler
    .weak MemManage_Handler
    .thumb_set MemManage_Handler, Default_Handler
    .weak BusFault_Handler
    .thumb_set BusFault_Handler, Default_Handler
    .weak UsageFault_Handler
    .thumb_set UsageFault_Handler, Default_Handler
    .weak SVC_Handler
    .thumb_set SVC_Handler, Default_Handler
    .weak DebugMon_Handler
    .thumb_set DebugMon_Handler, Default_Handler
    .weak PendSV_Handler
    .thumb_set PendSV_Handler, Default_Handler
    .weak SysTick_Handler
    .thumb_set SysTick_Handler, Default_Handler

.end

