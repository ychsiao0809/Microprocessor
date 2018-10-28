	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	leds: .byte 0
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPE, 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR, 0x4800040C
	.equ GPIOB_ODR, 0x48000414
	.equ X, 10000
	.equ Y, 24

main:
	bl GPIO_init
	movs r0, #1	// count
	ldr r1, =GPIOB_ODR
loop:
	// TODO: Write the display pattern into leds variable
	cmp r0, #0	// r0 = counter
	IT eq
	moveq r1, 0x1

	cmp r0, #1
	IT eq
	moveq r1, 0x3

	cmp r0, #2
	IT eq
	moveq r1, 0x6

	cmp r0, #3
	IT eq
	moveq r1, 0xC

	cmp r0, #4
	IT eq
	moveq r1, 0x8

	cmp r0, #5
	IT eq
	moveq r1, 0xC

	cmp r0, #6
	IT eq
	moveq r1, 0x6

	cmp r0, #7
	IT eq
	moveq r1, 0x1

	add r0, r0, #1

	cmp r0, #8
	IT eq
	moveq r0, #0

	bl displayLED
	bl delay
	b loop

// TODO: Initial LED GPIO pins as output
GPIO_init:
	// Enable AHB2 clock
	ldr r0, =RCC_AHB2ENR
	movs r1, 0x2
	str r1, [r0]

	// configure PB3, PB4, PB5, PB6 as output pins => 0000 0000 0000 0000 0001 0101 0100 0000
	ldr r0, =GPIOB_MODER
	ldr r1, [r0]
	and r1, 0xFFFFC03F
	movs r2, 0x1540	// can press?
	orrs r1, r1, r2
	str r1, [r0]

	// configure OtypeR(default as Push-Pull), no need to set

	// configure Ospeed as high speed mode(10)
	ldr r0, =GPIOB_OSPEEDR
	movs r1, 0x2A80
	strh r1, [r0]

	bx lr

// Display LED by leds
displayLED:
	ldr r2, =GPIOB_ODR
	lsl r1, #5
	strh r1, [r2]
	bx lr
// TODO: write a delay 1 sec function
delay:	// 1cycle=0.25uS => 1sec=4*10^6cycle
	ldr r3, =X	// 2 cycle, X=10000
l1: sub r3, #1	// 1 cycle
	ldr r4, =Y	// 2 cycle, Y=24
l2:	sub r4, #1	// 1 cycle
	bne l2 		// 3 cycle
	bne l1		// 3 cycle
	bx lr		// 1 cycle
