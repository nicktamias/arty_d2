/*
 * Timer.c
 *
 *  Created on: 10 Íïå 2015
 *      Author: stelkork
 */
#include "Timer.h"
#include "Interrupts.h"
#include "xil_printf.h"
#include "UART.h"
#include <time.h>
#include <stdio.h>
#include <stdlib.h>

void Timer_Init(XTmrCtr *TmrCtrInstancePtr, u8 TmrCtrNumber, u16 DeviceId)
{

	/*
	 * Initialize the timer counter so that it's ready to use,
	 * specify the device ID that is generated in xparameters.h
	 */
	XTmrCtr_Initialize(TmrCtrInstancePtr, DeviceId);

	/*
	 * Setup the handler for the timer counter that will be called from the
	 * interrupt context when the timer expires, specify a pointer to the
	 * timer counter driver instance as the callback reference so the handler
	 * is able to access the instance data
	 */
	XTmrCtr_SetHandler(TmrCtrInstancePtr, TimerCounterHandler, TmrCtrInstancePtr);

	/*
	 * Enable the interrupt of the timer counter so interrupts will occur
	 * and use auto reload mode such that the timer counter will reload
	 * itself automatically and continue repeatedly, without this option
	 * it would expire once only
	 */
	XTmrCtr_SetOptions(TmrCtrInstancePtr, TmrCtrNumber,	XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION);

	/*
	 * Set a reset value for the timer counter such that it will expire
	 * eariler than letting it roll over from 0, the reset value is loaded
	 * into the timer counter when it is started
	 */
	XTmrCtr_SetResetValue(TmrCtrInstancePtr, TmrCtrNumber, RESET_VALUE);

	/*
	 * Start the timer counter such that it's incrementing by default,
	 * then wait for it to timeout a number of times
	 */
	XTmrCtr_Start(TmrCtrInstancePtr, TmrCtrNumber);

}

/*****************************************************************************/
/**
* This function is the handler which performs processing for the timer counter.
* It is called from an interrupt context such that the amount of processing
* performed should be minimized.  It is called when the timer counter expires
* if interrupts are enabled.
*
* This handler provides an example of how to handle timer counter interrupts
* but is application specific.
*
* @param	CallBackRef is a pointer to the callback function
* @param	TmrCtrNumber is the number of the timer to which this
*		handler is associated with.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void TimerCounterHandler(void *CallBackRef, u8 TmrCtrNumber)
{

	/* LED Blink */
	int *LED = (int *)XPAR_GPIO_0_BASEADDR;
	static int led_value = 1;
	led_value ^= 1;
	*LED = led_value;

	/* Receive User FSM */
	unsigned char *cts_1 = (unsigned char*) UART1_CTS_ADDR;
	unsigned char *rts_1 = (unsigned char*) UART1_RTS_ADDR;

	/* Cyclic buffer not empty */
	if(*cts_1 == 0x00) {
		if(Wp != Rp) {
			TxBuffer_1[0] = c_buf[Rp];
			XUartLite_Send(&UART_Inst_Ptr_1, TxBuffer_1, 1);
			Rp = (Rp + 1) % CBUF_SIZE;
		}
		xil_printf("Wp: %d, Rp: %d\r\n", Wp, Rp);
	}

	/* Transmit User FSM */

	/* Buffer is full when Wp = Rp-1 mod CBUF_SIZE
	 * but due to greater speed on the PC side we check
	 * if the buffer is almost full and stop the transmission then.
	 */
	if(Wp == ((Rp-1) % CBUF_SIZE)) {
		*rts_1 = 0x01; //RTS OFF
	}
	else {
		*rts_1 = 0x00; //RTS ON
	}
}
