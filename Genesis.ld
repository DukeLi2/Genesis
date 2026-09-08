MEMORY{
    FLASH : ORIGIN = 0x08000000, LENGTH = 0x100000
    RAM   : ORIGIN = 0x20020000, LENGTH = 0x60000
}

/* 程序的逻辑起点，给调试器和，烧录工具看的 */
ENTRY(Reset_Handler)

_heap_size = 0;
_stack_size = 0;

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
    /* AT指示这个section的加载地址 LMA addres is sidata(in flash) */
    /* 至于section的长度，链接器会自己计算，这样烧录时就知道烧录到flash的起始地址和长度 */
    /* 搬到ram中，需要我们启动代码来实现  */
    .data : AT(_sidata) 
    {
        /* >RAM 告诉编译器下面地址都是ram地址，起始地址和长度也都知道 */
        /* 这样运行时知道从flash哪里搬，搬多少到目标ram地址范围 */
        . = ALIGN(4);
        _sdata = .; /* data section VMA address */
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } > RAM  /* >RAM 运行地址在RAM */

    /* 下面这个3个section, 在flash中不会有任何踪迹 */
    /* 但是bss要在ram中有所体现且要清0，而链接脚本给我们提供了地址和长度 */
    /* heap和stack不用改变数据，但是要设置ram地址范围 */
    /* 这就需要我们通过链接脚本提供的地址和长度，来在启动时初始化它们 */
    .bss :
    {
        . = ALIGN(4);
		__bss_start__ = .;
		*(.bss*)
        /* 未初始化的全局变量Common Symbol，不属于任何一个具体的section,将它们放入COMMON section */ 
		*(COMMON) 
		. = ALIGN(4);
		__bss_end__ = .;
    } >RAM

    ._heap :
    {
        . = ALIGN(4);
        PROVIDE(end = .); /* newlib中的 libgloss的 _sbrk 引用了end获得heap起点*/
        . = . + _heap_size;
        . = ALIGN(4);
    } >RAM

    ._stack :
    {
        . = ALIGN(4);
        . = . + _stack_size;
        . = ALIGN(4);
    } >RAM

    /* end of stack， 栈顶位置 */
    _estack = ORIGIN(RAM)+ LENGTH(RAM);

    /DISCARD/ :
    {
        *(.ARM.exidx) /* this is for c++ exceptions，don't need */
    }

    /* Keep DWARF sections for source-level debugging. */
    /* add -g option will auto link DWARF section */
}

/* Nice to have */
/*__isr_vector_size__ = SIZEOF(.isr_vector);*/
__text_size__ = SIZEOF(.text);
__data_size__ = SIZEOF(.data);
__bss_size__ = SIZEOF(.bss);
