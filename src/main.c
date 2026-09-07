
typedef int int32;
typedef unsigned int uint32;
typedef char int8;
typedef unsigned char uint8;


#define RCC_BASE (0x40023800)
#define RCC_AHB1RSTR (RCC_BASE + 0x10)
#define RCC_AHB1ENR (RCC_BASE + 0x30)

#define RCC_AHB1RSTR_GPIOBRST (0x1 << 1)
#define RCC_AHB1ENR_GPIOBEN (0x1 << 1)

#define GPIOB_BASE (0x40020400)
#define GPIOB_MODER (GPIOB_BASE + 0x00)
#define GPIOB_ODR   (GPIOB_BASE + 0x14)

#define GPIO_PIN_1 (1U << 1)
#define GPIO_PIN_1_MODE_MASK (3U << 2)

#define WREG32(reg, value)  (*(volatile uint32 *)(reg) = (value))
#define RREG32(reg)        (*(volatile uint32 *)(reg))


// typedef struct
// {
//     uint32 RCC_AHB1RSTR_GPIOARST:1;
//     uint32 RCC_AHB1RSTR_GPIOBRST:1;
//     uint32 RCC_AHB1RSTR_RESERVED:30;
// } RCC_AHB1RSTR_TypeDef;

void delay(volatile uint32 count)
{
    while(count--);
}

void GPIOB_Init(void)
{
    WREG32(RCC_AHB1ENR, RREG32(RCC_AHB1ENR) | RCC_AHB1ENR_GPIOBEN);
    WREG32(RCC_AHB1RSTR, RREG32(RCC_AHB1RSTR) | RCC_AHB1RSTR_GPIOBRST);
    WREG32(RCC_AHB1RSTR, RREG32(RCC_AHB1RSTR) & ~RCC_AHB1RSTR_GPIOBRST);
}

void GPIOB_Config(void)
{
    uint32 moder = RREG32(GPIOB_MODER);

    moder = (moder & ~GPIO_PIN_1_MODE_MASK) | (1U << 2);
    WREG32(GPIOB_MODER, moder);
    WREG32(GPIOB_ODR, RREG32(GPIOB_ODR) | GPIO_PIN_1);
}


int main(void)
{
    GPIOB_Init();
    GPIOB_Config();

    while(1)
    {
        WREG32(GPIOB_ODR, RREG32(GPIOB_ODR) & ~GPIO_PIN_1);
        delay(1000000);

        WREG32(GPIOB_ODR, RREG32(GPIOB_ODR) | GPIO_PIN_1);
        delay(1000000);
    }
}