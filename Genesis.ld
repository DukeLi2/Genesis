MEMORY{
    FLASH : ORIGIN = 0x08000000, LENGTH = 0x100000
    RAM   : ORIGIN = 0x20020000, LENGTH = 0x60000
}

/* 程序的逻辑起点，给调试器和，烧录工具看的 */
ENTRY(Reset_Handler)

_heap_size = 0;
_stack_size = 0;

/* end of stack， 栈顶位置 */
_estack = ORIGIN(RAM)+ LENGTH(RAM);

SECTIONS{
    .text :
    {
        KEEP(*(.isr_vector))
        *(.text*)
        *(.rodata*)
        *(.eh_frame*)
        /* Static constructors and destructors */
        KEEP(*(.init))
        KEEP(*(.fini))
    } > FLASH 
    /* > FLASH 表示  运行地址（VMA）在flash,CPU 必须去 Flash 的地址空间里取指令执行 */

    _sidata = ALIGN(4);
    .data : AT(_sidata) /* 加载地址 LMA addres is sidata(in flash) */
    {
        . = ALIGN(4);
        _sdata = .; /* data section VMA address */
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } > RAM  /* >RAM 运行地址在RAM */

    .bss :
    {
        . = ALIGN(4);
		__bss_start__ = .;
		*(.bss*)
		*(COMMON)
		. = ALIGN(4);
		__bss_end__ = .;
    } >RAM

    end = .;
    ._heap :
    {
        . = ALIGN(4);
        . = . + _heap_size;
        . = ALIGN(4);
    } >RAM

    ._stack :
    {
        . = ALIGN(4);
        . = . + _stack_size;
        . = ALIGN(4);
    } >RAM

    /DISCARD/ :
    {
        *(.ARM.exidx) /* this is for c++ exceptions */
    }

    /* Keep DWARF sections for source-level debugging. */
    /* add -g option will auto link DWARF section */
}

/* Nice to have */
/*__isr_vector_size__ = SIZEOF(.isr_vector);*/
__text_size__ = SIZEOF(.text);
__data_size__ = SIZEOF(.data);
__bss_size__ = SIZEOF(.bss);
