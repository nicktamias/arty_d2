/*
 * University of Patras, Communications and Embedded Systems (COMES) Group
 *
 * Embedded Communication Systems
 * ========================================================================
 *
 * This is an example of how to initialize UART devices and Timers. It provides all the initialization
 * functions and some interrupt handlers to use as a reference. The hardware design (built for ARTY board)
 * includes three UARTS and three Timers. The first UART is connected to STDIO in order to print debug and
 * information messages to the user. The rest two UARTs are connected to PMOD pins and will be used to
 * transmit and receive data. Only one Timer is initialized in the code below, but it is up to the developer
 * to use the other two if needed.
 *
 * This example implements the following processes:
 * - Initialize Timer 0
 * - Initialize UART 1 and UART2
 * - Initialize Interrupt controller and connects the above devices to it
 * - Stays in the while(1) loop forever and waits for the Interrupt handlers to be called.
 *
 *----------------------------------------------------------------------------------------------------------------------
 *
 * The code is organized as follows:
 * - Interrupts.c / Interrupts.h:
 *  					They include the Interrupt controller's initialization function and all parameters
 *  					and variables related to it
 *
 * - UART.c / UART.h:
 * 						They include the UARTs' initialization function, the interrupt handlers and all
 * 						variables and parameters related to them
 *
 * * - Timer.c / Timer.h:
 * 						They include the Timer's initialization function, the interrupt handler and all
 * 						variables and parameters related to it
 *
 *----------------------------------------------------------------------------------------------------------------------
 *
 * UART Interrupt Handlers (UART.c):
 * - Receive Handler:  	It is executed when the UART's receive FIFO is not empty (when a character has been received)
 * 						Reads the character and sends it back to the same UART.
 * - Transmit Handler:	It is executed when the UART's transmit FIFO has been emptied (once all characters
 * 						have been transmitted)
 *
 * Timer 0 Interrupt Handler (Timer.c):
 * 	It blinks LED 0 periodically. The period is set by the timer's RESET_VALUE definition in "Timer.h"
 *
 *----------------------------------------------------------------------------------------------------------------------
 *
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "Interrupts.h"
#include "UART.h"
#include "Timer.h"


int main()
{
	int Status;
	unsigned char *rts_1 	 = (unsigned char*) UART1_RTS_ADDR;
	unsigned char *cts_1 	 = (unsigned char*) UART1_CTS_ADDR;

    init_platform();

    //xil_printf("Application Started\n\r");

    /* UART1: Clear to Send -> OFF (Negative Logic) */
	*rts_1 = 0x01;


    /* Initialize Timer 0 */
    Timer_Init(&TimerCounterInst_0, TIMER_CNTR_0, XPAR_TMRCTR_0_DEVICE_ID);

    /* Initialize the UART devices */
    UART_Init(&UART_Inst_Ptr_1, UART_1_DEV_ID,  &UART_Inst_Ptr_2, UART_2_DEV_ID);

    /* Initialize Interrupt Controller, Enable interrupts in devices and connect them to the Interrupt Controller*/
    Status = SetupInterruptSystem(&UART_Inst_Ptr_1, UART_1_INT_IRQ_ID, &UART_Inst_Ptr_2, UART_2_INT_IRQ_ID, &TimerCounterInst_0, TMRCTR_INTERRUPT_ID_0);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

    /* UART1: Clear to Send -> ON (Negative Logic) */
	*rts_1 = 0x00;

	/* Wait in the never-ending while loop until an interrupt has been occurred */
    while(1);

    cleanup_platform();
    return 0;
}
