library IEEE;
use			IEEE.STD_LOGIC_1164.all;
use			IEEE.NUMERIC_STD.all;

--library PoC;
--use			PoC.utils.all;

library L_PicoBlaze;
use			L_PicoBlaze.pb.all;

package SoFPGA_sim is

	type T_PB_FUNCTIONS is (
		UNKNOWN, p0_ERROR_BLOCK, p0__push_arg0, p0__pop_arg0, p0__push_arg1, p0__pop_arg1, p0__push_arg2, p0__pop_arg2, p0__push_arg3, p0__pop_arg3, p0__push_arg03, p0__push_arg30, p0__pop_arg03, p0__pop_arg30, p0__push_tmp0, p0__pop_tmp0, p0__push_tmp1, p0__pop_tmp1, p0__push_tmp2, p0__pop_tmp2, p0__push_tmp3, p0__pop_tmp3, p0__push_tmp03, p0__push_tmp30, p0__pop_tmp03, p0__pop_tmp30, p0__get0_arg0, p0__put0_arg0, p0__get1_arg0, p0__put1_arg0, p0__get2_arg0, p0__put2_arg0, p0__get3_arg0, p0__put3_arg0, p0__get1_arg1, p0__put1_arg1, p0__get2_arg2, p0__put2_arg2, p0__get3_arg3, p0__put3_arg3, p0__get_arg03, p0__put_arg03, p0__put_arg30, p0__get0_tmp0, p0__put0_tmp0, p0__get1_tmp0, p0__put1_tmp0, p0__get2_tmp0, p0__put2_tmp0, p0__get3_tmp0, p0__put3_tmp0, p0__get1_tmp1, p0__put1_tmp1, p0__get2_tmp2, p0__put2_tmp2, p0__get3_tmp3, p0__put3_tmp3, p0__get_tmp03, p0__put_tmp03, p0_sleep_n_cy, p0_sleep_1_us, p0_sleep_n_us, p0_sleep_1_ms, p0_sleep_n_ms, p0_sleep_1_s, p0_sleep_loop, p0__Str_ByteToAscii, p0__Str_ByteToAscii2, p0__Str_ByteToDecimal, p0__Str_DoubleByteToDecimal, p0__Str_QuadByteToDecimal, p0_uart_reset, p0_uart_enableraw, p0_uart_disableraw, p0__UART_WriteChar, p0__UART_WriteDoubleChar, p0__UART_WriteTripleChar, p0__UART_WriteQuadChar, p0__UART_WriteRegLaR, p0__UART_WriteNewline, p0__UART_WriteHorizontalLine, p0__UART_WriteString, p0__UART_WriteLine, p0_uart_doubleident, p0_uart_quadident, p0_uart_readchar, p0_uart_readchar_block, p0_UART_WaitBufferNotFull, p0_UART_WaitBufferHalfFree, p0_UART_WaitBufferEmpty, p0_ISR_UART, p0__io_IIC_CheckAddress, p0__io_IIC_WriteByte, p0__io_IIC_ReadByte, p0__io_IIC_WriteRegister, p0__io_IIC_WriteDoubleRegister, p0__io_IIC_ReadRegister, p0__io_IIC_ReadDoubleRegister, p0__io_BBIO_IIC_EnableRaw, p0__io_BBIO_IIC_DisableRaw, p0__io_BBIO_IIC_Initialise, p0__io_BBIO_IIC_SendStartCond, p0__io_BBIO_IIC_SendStopCond, p0__io_BBIO_IIC_SendByte, p0__io_BBIO_IIC_SendAck, p0__io_BBIO_IIC_SendNAck, p0__io_BBIO_IIC_ReceiveByte, p0__io_BBIO_IIC_ReceiveAck, p0__io_BBIO_IIC_Abort, p0_BBIO_IIC_ClockToZ, p0_BBIO_IIC_ClockToLow, p0_BBIO_IIC_DataToZ, p0_BBIO_IIC_DataToLow, p0_BBIO_IIC_ReceiveBit, p0_BBIO_IIC_ClockPulse, p0_BBIO_IIC_Delay_Xus, p0_ISR_Timer, p0__dev_Mult32_Mult8, p0__dev_Mult32_Mult16, p0__dev_Mult32_Mult24, p0__dev_Mult32_Mult32, p0__dev_Div32_Wait, p0__dev_Div32_Div8_Begin, p0__dev_Div32_Div8_End, p0__dev_Div32_Div16, p0__dev_Div32_Div16_End, p0__dev_Div32_Div32, p0__dev_Div32_Div32_End, p0_ISR_Div32, p0__dev_ConvBCD24_Wait, p0__dev_ConvBCD24_Begin, p0__dev_ConvBCD24_End, p0__ISR_ConvBCD24, p0_ISR_GPIO, p0_ISR_BBIO, p0__dev_Term_Initialize, p0__dev_Term_CursorUp, p0__dev_Term_CursorDown, p0__dev_Term_CursorForward, p0__dev_Term_CursorBackward, p0__dev_Term_CursorNextLine, p0__dev_Term_CursorPreLine, p0__dev_Term_SetColumn, p0__dev_Term_GoToHome, p0__dev_Term_SetPosition, p0__dev_Term_ClearScreen, p0__dev_Term_ClearLine, p0__dev_Term_ScrollUp, p0__dev_Term_ScrollDown, p0__dev_Term_TextColor_Reset, p0__dev_Term_TextColor_Default, p0__dev_Term_TextColor_Black, p0__dev_Term_TextColor_Red, p0__dev_Term_TextColor_Green, p0__dev_Term_TextColor_Yellow, p0__dev_Term_TextColor_Blue, p0__dev_Term_TextColor_Magenta, p0__dev_Term_TextColor_Cyan, p0__dev_Term_TextColor_Gray, p0__dev_Term_TextColor_White, p0_dev_Term_EscSequence, p0_IIC_scan_devicemap, p0__tui_IIC_Dump_RegMap, p0_BootUp, p0__FatalError, p0__Initialize, p0_main, p0_sendok_I2C, p0_senderr_I2C, p0__Pager_PageX_Call_Table1, p0__Pager_PageX_Call_Table2, p0__Pager_Page0_HandleInterrupt, p0_main_isr
	);

	function InstructionPointer2FunctionName(PageNumber : STD_LOGIC_VECTOR(2 downto 0); InstAdr : T_PB_ADDRESS) return T_PB_FUNCTIONS;
end;


package body SoFPGA_sim is
	function InstructionPointer2FunctionName(PageNumber : STD_LOGIC_VECTOR(2 downto 0); InstAdr : T_PB_ADDRESS) return T_PB_FUNCTIONS is
		variable InstructionPointer		: UNSIGNED(InstAdr'range);
	begin
		InstructionPointer	:= unsigned(InstAdr);
	
		if ((x"000" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0_ERROR_BLOCK;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__push_arg0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__pop_arg0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__push_arg1;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__pop_arg1;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__push_arg2;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__pop_arg2;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__push_arg3;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__pop_arg3;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__push_arg03;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__push_arg30;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__pop_arg03;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__pop_arg30;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__push_tmp0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__pop_tmp0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__push_tmp1;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__pop_tmp1;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__push_tmp2;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__pop_tmp2;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__push_tmp3;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__pop_tmp3;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__push_tmp03;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__push_tmp30;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__pop_tmp03;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__pop_tmp30;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get0_arg0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put0_arg0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get1_arg0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put1_arg0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get2_arg0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put2_arg0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get3_arg0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put3_arg0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get1_arg1;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put1_arg1;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get2_arg2;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put2_arg2;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get3_arg3;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put3_arg3;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get_arg03;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put_arg03;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put_arg30;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get0_tmp0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put0_tmp0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get1_tmp0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put1_tmp0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get2_tmp0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put2_tmp0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get3_tmp0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put3_tmp0;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get1_tmp1;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put1_tmp1;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get2_tmp2;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put2_tmp2;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get3_tmp3;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put3_tmp3;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__get_tmp03;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0__put_tmp03;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"010")) then
			return p0_sleep_n_cy;
		elsif ((x"010" <= InstructionPointer) and (InstructionPointer < x"015")) then
			return p0_sleep_1_us;
		elsif ((x"015" <= InstructionPointer) and (InstructionPointer < x"015")) then
			return p0_sleep_n_us;
		elsif ((x"015" <= InstructionPointer) and (InstructionPointer < x"015")) then
			return p0_sleep_1_ms;
		elsif ((x"015" <= InstructionPointer) and (InstructionPointer < x"015")) then
			return p0_sleep_n_ms;
		elsif ((x"015" <= InstructionPointer) and (InstructionPointer < x"018")) then
			return p0_sleep_1_s;
		elsif ((x"018" <= InstructionPointer) and (InstructionPointer < x"01D")) then
			return p0_sleep_loop;
		elsif ((x"01D" <= InstructionPointer) and (InstructionPointer < x"01D")) then
			return p0__Str_ByteToAscii;
		elsif ((x"01D" <= InstructionPointer) and (InstructionPointer < x"01D")) then
			return p0__Str_ByteToAscii2;
		elsif ((x"01D" <= InstructionPointer) and (InstructionPointer < x"01D")) then
			return p0__Str_ByteToDecimal;
		elsif ((x"01D" <= InstructionPointer) and (InstructionPointer < x"01D")) then
			return p0__Str_DoubleByteToDecimal;
		elsif ((x"01D" <= InstructionPointer) and (InstructionPointer < x"01D")) then
			return p0__Str_QuadByteToDecimal;
		elsif ((x"01D" <= InstructionPointer) and (InstructionPointer < x"01F")) then
			return p0_uart_reset;
		elsif ((x"01F" <= InstructionPointer) and (InstructionPointer < x"023")) then
			return p0_uart_enableraw;
		elsif ((x"023" <= InstructionPointer) and (InstructionPointer < x"023")) then
			return p0_uart_disableraw;
		elsif ((x"023" <= InstructionPointer) and (InstructionPointer < x"026")) then
			return p0__UART_WriteChar;
		elsif ((x"026" <= InstructionPointer) and (InstructionPointer < x"02A")) then
			return p0__UART_WriteDoubleChar;
		elsif ((x"02A" <= InstructionPointer) and (InstructionPointer < x"02A")) then
			return p0__UART_WriteTripleChar;
		elsif ((x"02A" <= InstructionPointer) and (InstructionPointer < x"030")) then
			return p0__UART_WriteQuadChar;
		elsif ((x"030" <= InstructionPointer) and (InstructionPointer < x"030")) then
			return p0__UART_WriteRegLaR;
		elsif ((x"030" <= InstructionPointer) and (InstructionPointer < x"033")) then
			return p0__UART_WriteNewline;
		elsif ((x"033" <= InstructionPointer) and (InstructionPointer < x"033")) then
			return p0__UART_WriteHorizontalLine;
		elsif ((x"033" <= InstructionPointer) and (InstructionPointer < x"033")) then
			return p0__UART_WriteString;
		elsif ((x"033" <= InstructionPointer) and (InstructionPointer < x"033")) then
			return p0__UART_WriteLine;
		elsif ((x"033" <= InstructionPointer) and (InstructionPointer < x"033")) then
			return p0_uart_doubleident;
		elsif ((x"033" <= InstructionPointer) and (InstructionPointer < x"033")) then
			return p0_uart_quadident;
		elsif ((x"033" <= InstructionPointer) and (InstructionPointer < x"033")) then
			return p0_uart_readchar;
		elsif ((x"033" <= InstructionPointer) and (InstructionPointer < x"039")) then
			return p0_uart_readchar_block;
		elsif ((x"039" <= InstructionPointer) and (InstructionPointer < x"03E")) then
			return p0_UART_WaitBufferNotFull;
		elsif ((x"03E" <= InstructionPointer) and (InstructionPointer < x"043")) then
			return p0_UART_WaitBufferHalfFree;
		elsif ((x"043" <= InstructionPointer) and (InstructionPointer < x"043")) then
			return p0_UART_WaitBufferEmpty;
		elsif ((x"043" <= InstructionPointer) and (InstructionPointer < x"04B")) then
			return p0_ISR_UART;
		elsif ((x"04B" <= InstructionPointer) and (InstructionPointer < x"04B")) then
			return p0__io_IIC_CheckAddress;
		elsif ((x"04B" <= InstructionPointer) and (InstructionPointer < x"04B")) then
			return p0__io_IIC_WriteByte;
		elsif ((x"04B" <= InstructionPointer) and (InstructionPointer < x"04B")) then
			return p0__io_IIC_ReadByte;
		elsif ((x"04B" <= InstructionPointer) and (InstructionPointer < x"04B")) then
			return p0__io_IIC_WriteRegister;
		elsif ((x"04B" <= InstructionPointer) and (InstructionPointer < x"04B")) then
			return p0__io_IIC_WriteDoubleRegister;
		elsif ((x"04B" <= InstructionPointer) and (InstructionPointer < x"04B")) then
			return p0__io_IIC_ReadRegister;
		elsif ((x"04B" <= InstructionPointer) and (InstructionPointer < x"04B")) then
			return p0__io_IIC_ReadDoubleRegister;
		elsif ((x"04B" <= InstructionPointer) and (InstructionPointer < x"04F")) then
			return p0__io_BBIO_IIC_EnableRaw;
		elsif ((x"04F" <= InstructionPointer) and (InstructionPointer < x"04F")) then
			return p0__io_BBIO_IIC_DisableRaw;
		elsif ((x"04F" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0__io_BBIO_IIC_Initialise;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0__io_BBIO_IIC_SendStartCond;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0__io_BBIO_IIC_SendStopCond;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0__io_BBIO_IIC_SendByte;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0__io_BBIO_IIC_SendAck;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0__io_BBIO_IIC_SendNAck;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0__io_BBIO_IIC_ReceiveByte;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0__io_BBIO_IIC_ReceiveAck;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0__io_BBIO_IIC_Abort;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0_BBIO_IIC_ClockToZ;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0_BBIO_IIC_ClockToLow;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0_BBIO_IIC_DataToZ;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0_BBIO_IIC_DataToLow;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0_BBIO_IIC_ReceiveBit;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0_BBIO_IIC_ClockPulse;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"052")) then
			return p0_BBIO_IIC_Delay_Xus;
		elsif ((x"052" <= InstructionPointer) and (InstructionPointer < x"053")) then
			return p0_ISR_Timer;
		elsif ((x"053" <= InstructionPointer) and (InstructionPointer < x"053")) then
			return p0__dev_Mult32_Mult8;
		elsif ((x"053" <= InstructionPointer) and (InstructionPointer < x"053")) then
			return p0__dev_Mult32_Mult16;
		elsif ((x"053" <= InstructionPointer) and (InstructionPointer < x"053")) then
			return p0__dev_Mult32_Mult24;
		elsif ((x"053" <= InstructionPointer) and (InstructionPointer < x"053")) then
			return p0__dev_Mult32_Mult32;
		elsif ((x"053" <= InstructionPointer) and (InstructionPointer < x"053")) then
			return p0__dev_Div32_Wait;
		elsif ((x"053" <= InstructionPointer) and (InstructionPointer < x"053")) then
			return p0__dev_Div32_Div8_Begin;
		elsif ((x"053" <= InstructionPointer) and (InstructionPointer < x"053")) then
			return p0__dev_Div32_Div8_End;
		elsif ((x"053" <= InstructionPointer) and (InstructionPointer < x"053")) then
			return p0__dev_Div32_Div16;
		elsif ((x"053" <= InstructionPointer) and (InstructionPointer < x"053")) then
			return p0__dev_Div32_Div16_End;
		elsif ((x"053" <= InstructionPointer) and (InstructionPointer < x"053")) then
			return p0__dev_Div32_Div32;
		elsif ((x"053" <= InstructionPointer) and (InstructionPointer < x"053")) then
			return p0__dev_Div32_Div32_End;
		elsif ((x"053" <= InstructionPointer) and (InstructionPointer < x"054")) then
			return p0_ISR_Div32;
		elsif ((x"054" <= InstructionPointer) and (InstructionPointer < x"054")) then
			return p0__dev_ConvBCD24_Wait;
		elsif ((x"054" <= InstructionPointer) and (InstructionPointer < x"054")) then
			return p0__dev_ConvBCD24_Begin;
		elsif ((x"054" <= InstructionPointer) and (InstructionPointer < x"054")) then
			return p0__dev_ConvBCD24_End;
		elsif ((x"054" <= InstructionPointer) and (InstructionPointer < x"055")) then
			return p0__ISR_ConvBCD24;
		elsif ((x"055" <= InstructionPointer) and (InstructionPointer < x"056")) then
			return p0_ISR_GPIO;
		elsif ((x"056" <= InstructionPointer) and (InstructionPointer < x"056")) then
			return p0_ISR_BBIO;
		elsif ((x"056" <= InstructionPointer) and (InstructionPointer < x"05E")) then
			return p0__dev_Term_Initialize;
		elsif ((x"05E" <= InstructionPointer) and (InstructionPointer < x"05E")) then
			return p0__dev_Term_CursorUp;
		elsif ((x"05E" <= InstructionPointer) and (InstructionPointer < x"05E")) then
			return p0__dev_Term_CursorDown;
		elsif ((x"05E" <= InstructionPointer) and (InstructionPointer < x"05E")) then
			return p0__dev_Term_CursorForward;
		elsif ((x"05E" <= InstructionPointer) and (InstructionPointer < x"05E")) then
			return p0__dev_Term_CursorBackward;
		elsif ((x"05E" <= InstructionPointer) and (InstructionPointer < x"05E")) then
			return p0__dev_Term_CursorNextLine;
		elsif ((x"05E" <= InstructionPointer) and (InstructionPointer < x"05E")) then
			return p0__dev_Term_CursorPreLine;
		elsif ((x"05E" <= InstructionPointer) and (InstructionPointer < x"05E")) then
			return p0__dev_Term_SetColumn;
		elsif ((x"05E" <= InstructionPointer) and (InstructionPointer < x"05E")) then
			return p0__dev_Term_GoToHome;
		elsif ((x"05E" <= InstructionPointer) and (InstructionPointer < x"05E")) then
			return p0__dev_Term_SetPosition;
		elsif ((x"05E" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_ClearScreen;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_ClearLine;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_ScrollUp;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_ScrollDown;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_TextColor_Reset;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_TextColor_Default;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_TextColor_Black;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_TextColor_Red;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_TextColor_Green;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_TextColor_Yellow;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_TextColor_Blue;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_TextColor_Magenta;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_TextColor_Cyan;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_TextColor_Gray;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"062")) then
			return p0__dev_Term_TextColor_White;
		elsif ((x"062" <= InstructionPointer) and (InstructionPointer < x"065")) then
			return p0_dev_Term_EscSequence;
		elsif ((x"065" <= InstructionPointer) and (InstructionPointer < x"065")) then
			return p0_IIC_scan_devicemap;
		elsif ((x"065" <= InstructionPointer) and (InstructionPointer < x"065")) then
			return p0__tui_IIC_Dump_RegMap;
		elsif ((x"065" <= InstructionPointer) and (InstructionPointer < x"070")) then
			return p0_BootUp;
		elsif ((x"070" <= InstructionPointer) and (InstructionPointer < x"070")) then
			return p0__FatalError;
		elsif ((x"070" <= InstructionPointer) and (InstructionPointer < x"07D")) then
			return p0__Initialize;
		elsif ((x"07D" <= InstructionPointer) and (InstructionPointer < x"0A1")) then
			return p0_main;
		elsif ((x"0A1" <= InstructionPointer) and (InstructionPointer < x"0D3")) then
			return p0_sendok_I2C;
		elsif ((x"0D3" <= InstructionPointer) and (InstructionPointer < x"FB0")) then
			return p0_senderr_I2C;
		elsif ((x"FB0" <= InstructionPointer) and (InstructionPointer < x"FC5")) then
			return p0__Pager_PageX_Call_Table1;
		elsif ((x"FC5" <= InstructionPointer) and (InstructionPointer < x"FDA")) then
			return p0__Pager_PageX_Call_Table2;
		elsif ((x"FDA" <= InstructionPointer) and (InstructionPointer < x"FE0")) then
			return p0__Pager_Page0_HandleInterrupt;
		elsif ((x"FE0" <= InstructionPointer) and (InstructionPointer < x"FFF")) then
			return p0_main_isr;
		else
			return UNKNOWN;
		end if;
	end function;
end package body;
