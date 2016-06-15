/*
 * UART.h
 *
 *  Created on: 10 Íïå 2015
 *      Author: stelkork
 */

#ifndef UART_H_
#define UART_H_

#include "xuartlite.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xil_exception.h"
#include "Interrupts.h"

/************************** UART Definitions and Initializations *****************************/

/* Define UARTs' IDs (from xparameters.h) */
#define UART_1_DEV_ID	  	XPAR_UARTLITE_1_DEVICE_ID
#define UART_1_INT_IRQ_ID	XPAR_INTC_0_UARTLITE_1_VEC_ID
#define UART_2_DEV_ID	  	XPAR_UARTLITE_2_DEVICE_ID
#define UART_2_INT_IRQ_ID	XPAR_INTC_0_UARTLITE_2_VEC_ID
#define TIMER_1_DEV_ID


/************************** Address Definitions *****************************/
/* BASE ADDRESSES */
#define UART1_BASE_ADDR						XPAR_UARTLITE_1_BASEADDR
#define UART2_BASE_ADDR						XPAR_UARTLITE_2_BASEADDR

#define UART1_RTS_ADDR						XPAR_GPIO_1_BASEADDR
#define UART1_CTS_ADDR						XPAR_GPIO_1_BASEADDR + 0x8

/* OFFSETS */
#define RECV_FIFO							0x00000000
#define TRAN_FIFO							0x00000004
#define STAT_REG							0x00000008
#define CONT_REG							0x0000000C

/************************** Debug Messages*****************************/
#define UART_DBG							1 	// 0: OFF, 1: ON

/************************** Function Prototypes ******************************/
int UART_Init(XUartLite *UART_Inst_Ptr_1, u16 Uart_1_Dev_ID,  XUartLite *UART_Inst_Ptr_2, u16 Uart_2_Dev_ID);
void RecvHandler_UART_1(void *CallBackRef, unsigned int EventData);
void SendHandler_UART_1(void *CallBackRef, unsigned int EventData);
void RecvHandler_UART_2(void *CallBackRef, unsigned int EventData);
void SendHandler_UART_2(void *CallBackRef, unsigned int EventData);

/************************** I/O Buffer Declarations *****************************/
#define BUF_SIZE							1

u8 RxBuffer_1[BUF_SIZE];
u8 TxBuffer_1[BUF_SIZE];

u8 RxBuffer_2[BUF_SIZE];
u8 TxBuffer_2[BUF_SIZE];

/************************** Device Pointer Declarations *****************************/
XUartLite UART_Inst_Ptr_1;            /* The instance of the UartLite Device */
XUartLite UART_Inst_Ptr_2;            /* The instance of the UartLite Device */

/************************** Cyclic Buffer Declarations *****************************/
#define CBUF_SIZE							8
#define Nc 									10

extern int Wp_Tx, Rp_Tx, Wp_Rx, Rp_Rx;
extern int Tx_cbuf[CBUF_SIZE], Rx_cbuf[CBUF_SIZE];

#endif /* UART_H_ */
