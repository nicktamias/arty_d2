/*
 * UART.c
 *
 *  Created on: 10 Íïå 2015
 *      Author: stelkork
 */
#include "UART.h"
#include "Interrupts.h"

#define Nc 10
#define buf_size 8

int UART_Init(XUartLite *UART_Inst_Ptr_1, u16 Uart_1_Dev_ID,  XUartLite *UART_Inst_Ptr_2, u16 Uart_2_Dev_ID)
{
	int Status;

	/* Initialize the UART drivers so that they are ready to use. */
	Status = XUartLite_Initialize(UART_Inst_Ptr_1, Uart_1_Dev_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = XUartLite_Initialize(UART_Inst_Ptr_2, Uart_2_Dev_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}


	/*
	 * Setup the handlers for the UartLite that will be called from the
	 * interrupt context when data has been sent and received, specify a
	 * pointer to the UartLite driver instance as the callback reference so
	 * that the handlers are able to access the instance data.
	 */
	XUartLite_SetSendHandler(UART_Inst_Ptr_1, SendHandler_UART_1, UART_Inst_Ptr_1);
	XUartLite_SetRecvHandler(UART_Inst_Ptr_1, RecvHandler_UART_1, UART_Inst_Ptr_1);

	XUartLite_SetSendHandler(UART_Inst_Ptr_2, SendHandler_UART_2, UART_Inst_Ptr_2);
	XUartLite_SetRecvHandler(UART_Inst_Ptr_2, RecvHandler_UART_2, UART_Inst_Ptr_2);

	/*
	 * Enable the interrupt of the UartLite so that interrupts will occur.
	 */
	XUartLite_EnableInterrupt(UART_Inst_Ptr_1);
	XUartLite_EnableInterrupt(UART_Inst_Ptr_2);

	return XST_SUCCESS;

}

/*****************************************************************************/
/**
*
* This function is the handler which performs processing to send data to the
* UartLite. It is called from an interrupt context such that the amount of
* processing performed should be minimized. It is called when the transmit
* FIFO of the UartLite is empty and more data can be sent through the UartLite.
*
* This handler provides an example of how to handle data for the UartLite,
* but is application specific.
*
* @param	CallBackRef contains a callback reference from the driver.
*		In this case it is the instance pointer for the UartLite driver.
* @param	EventData contains the number of bytes sent or received for sent
*		and receive events.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void SendHandler_UART_1(void *CallBackRef, unsigned int EventData)
{
	if(UART_DBG) xil_printf("UART1: Character was sent \r\n");
}

/****************************************************************************/
/**
*
* This function is the handler which performs processing to receive data from
* the UartLite. It is called from an interrupt context such that the amount of
* processing performed should be minimized.  It is called data is present in
* the receive FIFO of the UartLite such that the data can be retrieved from
* the UartLite. The size of the data present in the FIFO is not known when
* this function is called.
*
* This handler provides an example of how to handle data for the UartLite,
* but is application specific.
*
* @param	CallBackRef contains a callback reference from the driver, in
*		this case it is the instance pointer for the UartLite driver.
* @param	EventData contains the number of bytes sent or received for sent
*		and receive events.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void RecvHandler_UART_1(void *CallBackRef, unsigned int EventData)
{
	unsigned int num_of_chars;
	unsigned int i;
	static int cnt = 0, Wp = 1, Rp = 1;
	static int c_buf[buf_size] = {0};


	num_of_chars = XUartLite_Recv(&UART_Inst_Ptr_1, RxBuffer_1, BUF_SIZE);
	if(UART_DBG) xil_printf("UART1: Received %d bytes: %02X \r\n",num_of_chars,*RxBuffer_1);

	//while(XUartLite_IsSending(&UART_Inst_Ptr_1));
	//XUartLite_Send(&UART_Inst_Ptr_1, RxBuffer_1, num_of_chars);

	/* Transmit User FSM */

	/* Cyclic buffer not full */
	if(Wp != ((Rp-1) % buf_size)) {
		c_buf[Wp] = *RxBuffer_1;
		Wp = (Wp + 1) % buf_size;
	}

	cnt++;

	for(i=0; i<buf_size; i++) {
		xil_printf("%02X ", c_buf[i]);
	}
	xil_printf("\r\n");

	if(UART_DBG) xil_printf("cnt = %d\r\n", cnt);
}

/*****************************************************************************/
/**
*
* This function is the handler which performs processing to send data to the
* UartLite. It is called from an interrupt context such that the amount of
* processing performed should be minimized. It is called when the transmit
* FIFO of the UartLite is empty and more data can be sent through the UartLite.
*
* This handler provides an example of how to handle data for the UartLite,
* but is application specific.
*
* @param	CallBackRef contains a callback reference from the driver.
*		In this case it is the instance pointer for the UartLite driver.
* @param	EventData contains the number of bytes sent or received for sent
*		and receive events.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void SendHandler_UART_2(void *CallBackRef, unsigned int EventData)
{
	if(UART_DBG) xil_printf("UART2: Character was sent \r\n");
}

/****************************************************************************/
/**
*
* This function is the handler which performs processing to receive data from
* the UartLite. It is called from an interrupt context such that the amount of
* processing performed should be minimized.  It is called data is present in
* the receive FIFO of the UartLite such that the data can be retrieved from
* the UartLite. The size of the data present in the FIFO is not known when
* this function is called.
*
* This handler provides an example of how to handle data for the UartLite,
* but is application specific.
*
* @param	CallBackRef contains a callback reference from the driver, in
*		this case it is the instance pointer for the UartLite driver.
* @param	EventData contains the number of bytes sent or received for sent
*		and receive events.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void RecvHandler_UART_2(void *CallBackRef, unsigned int EventData)
{
	unsigned int num_of_chars;

	num_of_chars = XUartLite_Recv(&UART_Inst_Ptr_2, RxBuffer_2, BUF_SIZE);

	while(XUartLite_IsSending(&UART_Inst_Ptr_2));
	XUartLite_Send(&UART_Inst_Ptr_2, RxBuffer_2, num_of_chars);
	if(UART_DBG) xil_printf("UART2: Received %d bytes: %02X \r\n",num_of_chars,*RxBuffer_2);


}
