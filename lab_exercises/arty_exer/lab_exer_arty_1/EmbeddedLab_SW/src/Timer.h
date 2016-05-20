/*
 * Timer.h
 *
 *  Created on: 10 Íïå 2015
 *      Author: stelkork
 */

#ifndef TIMER_H_
#define TIMER_H_

#include <time.h>
#include "xparameters.h"
#include "xtmrctr.h"
#include "xil_exception.h"
#include "xil_printf.h"

void TimerCounterHandler(void *CallBackRef, u8 TmrCtrNumber);
void Timer_Init(XTmrCtr *TmrCtrInstancePtr, u8 TmrCtrNumber, u16 DeviceId);

#define TIMER_CNTR_0		 		0
#define TIMER_CNTR_1	 			1
#define TIMER_CNTR_2	 			2
#define TMRCTR_DEVICE_ID_0			XPAR_TMRCTR_0_DEVICE_ID
#define TMRCTR_INTERRUPT_ID_0		XPAR_INTC_0_TMRCTR_0_VEC_ID
#define TMRCTR_DEVICE_ID_1			XPAR_TMRCTR_1_DEVICE_ID
#define TMRCTR_INTERRUPT_ID_1		XPAR_INTC_0_TMRCTR_1_VEC_ID
#define TMRCTR_DEVICE_ID_2			XPAR_TMRCTR_2_DEVICE_ID
#define TMRCTR_INTERRUPT_ID_2		XPAR_INTC_0_TMRCTR_2_VEC_ID

/*
 * The following constant is used to set the reset value of the timer counter,
 * making this number larger reduces the amount of time this example consumes
 * because it is the value the timer counter is loaded with when it is started
 */
#define RESET_VALUE	 				0xFF000000

/* The instance of the first Timer Counter */
XTmrCtr TimerCounterInst_0;

#endif /* TIMER_H_ */
