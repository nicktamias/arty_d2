/*
 * Timer.c
 *
 *  Created on: 10 Эях 2015
 *      Author: stelkork
 */
#include "Timer.h"
#include "Interrupts.h"
#include "xil_printf.h"
#include "UART.h"
#include <time.h>
#include <stdio.h>
#include <stdlib.h>

#define Nc 10

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
	static int state;
	static int upc = 0;
	static int cnt = 0;
	static int range = 255;
	static int time_vals[Nc] = {0};
	static u8 char_vals[Nc] = {0};
	static int qs[3] = {16, 40, 66};
	int val;

	/* LED Blink */
	int *LED = (int *)XPAR_GPIO_0_BASEADDR;
	static int led_value = 1;

	led_value ^= 1;

	*LED = led_value;

	/* Character generator */
	upc++;

	switch(state) {
		case 0:
				cnt++;
				//xil_printf("%d\r\n", cnt);
				char_vals[cnt] = (u8) (rand() % (range + 1));

				xil_printf("%d\r\n", char_vals[cnt]);

				//XUartLite_ResetFifos(&UART_Inst_Ptr_2);
				XUartLite_Send(&UART_Inst_Ptr_2, &char_vals[cnt], 1);

				time_vals[cnt] = upc;

				if (cnt!=Nc){
					state = 1;
				}
				else{
					//xil_printf("END\r\n");
					XTmrCtr_Stop((XTmrCtr *)CallBackRef, TmrCtrNumber);
				}
				break;
		case 1:
				val = rand() % 100;
				if (val>qs[0]){
					state = 2;
				}
				else{
					state = 0;
				}
				break;
		case 2:
				val = rand() % 100;
				if (val>qs[1]){
					state = 3;
				}
				else{
					state = 0;
				}
				break;
		case 3:
				state = 4;
				break;
		case 4:
				val = rand() % 100;
				if (val>qs[2]){
					state = 5;
				}
				else{
					state = 0;
				}
				break;
		case 5:
				state = 0;
				break;
		default:
				state = 0;
	}
}
