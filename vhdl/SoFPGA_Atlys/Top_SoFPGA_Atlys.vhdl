-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- =============================================================================
-- Authors:					Patrick Lehmann
--
-- Package:					TODO
--
-- Description:
-- ------------------------------------
--		TODO
-- 
-- License:
-- =============================================================================
-- Copyright 2007-2015 Patrick Lehmann - Dresden, Germany
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--		http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =============================================================================

library IEEE;
use			IEEE.STD_LOGIC_1164.all;
use			IEEE.NUMERIC_STD.all;

library UNISIM;
use			UNISIM.VCOMPONENTS.all;

library PoC;
use			PoC.config.all;
use			PoC.utils.all;
use			PoC.vectors.all;
use			PoC.strings.all;
use			PoC.physical.all;
use			PoC.components.all;
use			PoC.xil.all;

library L_Example;


entity ExampleDesign_Atlys is
	port (
		Atlys_SystemClock_100MHz		: in		STD_LOGIC;
		
		Atlys_GPIO_Button_CPU_Reset	: in	STD_LOGIC;
		Atlys_GPIO_Switches					: in	STD_LOGIC_VECTOR(7 downto 0);
		Atlys_GPIO_LED							: out	STD_LOGIC_VECTOR(7 downto 0);
 
		Atlys_USB_UART_TX						: in		STD_LOGIC;			-- USB-UART Bridge is "master"
		Atlys_USB_UART_RX						: out		STD_LOGIC;			-- USB-UART Bridge is "master"
		Atlys_USB_UART_RTS_n				: in		STD_LOGIC;			-- Ready to Transmit (USB-UART has new data)
		Atlys_USB_UART_CTS_n				: out		STD_LOGIC;			-- Clear to Send (FPGA is able to receive data)

		Atlys_IIC_SerialClock				: inout	STD_LOGIC;
		Atlys_IIC_SerialData				: inout	STD_LOGIC;
		Atlys_IIC_Switch_Reset_n		: out		STD_LOGIC
	);
end;
--
--
-- LED configuration
-- =============================================================================================================================================================
--	LED 7				LED 6				LED 5				LED 4				LED 3				LED 2				LED 1				LED 0
-- <unused>		<unused>		<unused>		LinkOK			SATAClkOK		TestClkOK		Generation(1 downto 0)


architecture top of ExampleDesign_Atlys is
	attribute KEEP											: BOOLEAN;
	attribute ASYNC_REG									: STRING;
	attribute SHREG_EXTRACT							: STRING;

	-- ==========================================================================================================================================================
	-- configurations
	-- ==========================================================================================================================================================
	-- common configuration
	constant DEBUG											: BOOLEAN							:= TRUE;
	constant ENABLE_CHIPSCOPE						: BOOLEAN							:= TRUE;
	constant ENABLE_DEBUGPORT						: BOOLEAN							:= TRUE;
	
	constant SYS_CLOCK_FREQ							: FREQ								:= 200.0 MHz;
	
	-- ClockNetwork configuration
	-- ===========================================================================
	constant SYSTEM_CLOCK_FREQ					: FREQ								:= SYS_CLOCK_FREQ / 2.0;
	

	-- ==========================================================================================================================================================
	-- signal declarations
	-- ==========================================================================================================================================================
	-- clock and reset signals
	signal System_RefClock_100MHz				: STD_LOGIC;

	signal ClkNet_Reset									: STD_LOGIC;
	signal ClkNet_ResetDone							: STD_LOGIC;

	signal SystemClock_200MHz						: STD_LOGIC;
	signal SystemClock_125MHz						: STD_LOGIC;
	signal SystemClock_100MHz						: STD_LOGIC;
	signal SystemClock_10MHz						: STD_LOGIC;

	signal SystemClock_Stable_200MHz		: STD_LOGIC;
	signal SystemClock_Stable_125MHz		: STD_LOGIC;
	signal SystemClock_Stable_100MHz		: STD_LOGIC;
	signal SystemClock_Stable_10MHz			: STD_LOGIC;

	signal System_Clock									: STD_LOGIC;
	signal System_Reset									: STD_LOGIC;
	
	attribute KEEP of System_Clock			: signal is TRUE;
	attribute KEEP of System_Reset			: signal is TRUE;
	
	-- active-low board signals
	signal Atlys_USB_UART_CTS						: STD_LOGIC;
	signal Atlys_IIC_Switch_Reset				: STD_LOGIC;
--	signal Atlys_EthernetPHY_Reset			: STD_LOGIC;
--	signal Atlys_EthernetPHY_Interrupt	: STD_LOGIC;
	
	-- cross-over signals
	signal Atlys_UART_TX								: STD_LOGIC;
	signal Atlys_UART_RX								: STD_LOGIC;
	
	-- debounced button signals (debounce circuit works @10 MHz)
	signal GPIO_Button_CPU_Reset				: STD_LOGIC;
	
	-- synchronized button signals
	signal Button_Reset									: STD_LOGIC;
	
	-- edge-detections on GPIO_Button_*
	
	-- PerformanceTest signals
	signal ex_ClkNet_Reset							: STD_LOGIC;
	signal ex_ClkNet_ResetDone					: STD_LOGIC;
	
	signal UART_TX											: STD_LOGIC;
	signal UART_RX											: STD_LOGIC;

	signal Raw_IIC_mux									: STD_LOGIC;
	signal Raw_IIC_Clock_i							: STD_LOGIC;
	signal Raw_IIC_Clock_t							: STD_LOGIC;
	signal Raw_IIC_Data_i								: STD_LOGIC;
	signal Raw_IIC_Data_t								: STD_LOGIC;
	signal Raw_IIC_Switch_Reset					: STD_LOGIC;
	
	signal IIC_SerialClock_i						: STD_LOGIC;
	signal IIC_SerialClock_o						: STD_LOGIC;
	signal IIC_SerialClock_t						: STD_LOGIC;
	signal IIC_SerialData_i							: STD_LOGIC;
	signal IIC_SerialData_o							: STD_LOGIC;
	signal IIC_SerialData_t							: STD_LOGIC;
	signal IIC_Switch_Reset							: STD_LOGIC;

begin
	
	-- ==========================================================================================================================================================
	-- assert statements
	-- ==========================================================================================================================================================
	assert FALSE report "SoFPGA configuration:"																								severity NOTE;
	assert FALSE report "  SYS_CLOCK_FREQ:         " & to_string(SYS_CLOCK_FREQ, 3)						severity note;

	-- ==========================================================================================================================================================
	-- Input/output buffers
	-- ==========================================================================================================================================================
	IBUFGDS_SystemClock : IBUFG
		port map (
			I			=> Atlys_SystemClock_100MHz,
			O			=> System_RefClock_100MHz
		);

	-- ==========================================================================================================================================================
	-- active-low to active-high conversion
	-- ==========================================================================================================================================================
	-- input signals
--	Atlys_EthernetPHY_Interrupt		<= NOT Atlys_EthernetPHY_Interrupt_n;
	
	-- output signals
	Atlys_USB_UART_CTS_n				<= not Atlys_USB_UART_CTS;
	Atlys_IIC_Switch_Reset_n		<= not Atlys_IIC_Switch_Reset;
--	Atlys_EthernetPHY_Reset_n		<= not Atlys_EthernetPHY_Reset;

	-- ==========================================================================================================================================================
	-- cross-over signal renaming
	-- ==========================================================================================================================================================
	-- USB-UART is the master, FPGA is the slave => so TX is an input and RX an output
	Atlys_USB_UART_RX		<= Atlys_UART_TX;
	Atlys_UART_RX				<= Atlys_USB_UART_TX;


	-- ==========================================================================================================================================================
	-- ClockNetwork
	-- ==========================================================================================================================================================
	ClkNet_Reset		<= '0';
--	ClkNet_Reset		<= Button_Reset;
	
	ClkNet : entity L_Example.ClockNetwork_Atlys
		generic map (
			CLOCK_IN_FREQ						=> SYS_CLOCK_FREQ
		)
		port map (
			ClockIn_100MHz					=> System_RefClock_100MHz,

			ClockNetwork_Reset			=> ClkNet_Reset,
			ClockNetwork_ResetDone	=> ClkNet_ResetDone,
			
			Control_Clock_100MHz		=> open,
			
			Clock_200MHz						=> SystemClock_200MHz,
			Clock_125MHz						=> SystemClock_125MHz,
			Clock_100MHz						=> SystemClock_100MHz,
			Clock_10MHz							=> SystemClock_10MHz,

			Clock_Stable_200MHz			=> SystemClock_Stable_200MHz,
			Clock_Stable_125MHz			=> SystemClock_Stable_125MHz,
			Clock_Stable_100MHz			=> SystemClock_Stable_100MHz,
			Clock_Stable_10MHz			=> SystemClock_Stable_10MHz
		);
	
	-- system signals
	System_Clock		<= SystemClock_100MHz;
	System_Reset		<= not SystemClock_Stable_100MHz;

	-- ==========================================================================================================================================================
	-- signal debouncing
	-- ==========================================================================================================================================================
	DebBtn : entity PoC.io_Debounce
		generic map (
			CLOCK_FREQ				=> SYSTEM_CLOCK_FREQ,		-- 100 MHz
			BOUNCE_TIME				=> 5.0 ms,							-- 5.0 ms
			BITS							=> 1										-- 3 bit
		)
		port map (
			clk								=> System_Clock,
			rst								=> '0',
			Input(0)					=> Atlys_GPIO_Button_CPU_Reset,
			Output(0)					=> GPIO_Button_CPU_Reset
		);

	-- synchronize to System_Clock
	sync1 : entity PoC.xil_SyncBits
		port map (
			Clock			=> System_Clock,						-- Clock to be synchronized to
			Input(0)	=> GPIO_Button_CPU_Reset,		-- Data to be synchronized
			Output(0)	=> Button_Reset							-- synchronised data
		);

	-- synchronize to SATAC_Clock
	

	-- ==========================================================================================================================================================
	-- main design
	-- ==========================================================================================================================================================
	-- Button inputs, some are also driven by Chipscope


	-- Switch inputs

	
	-- LED outputs
	blkLED : block
		signal GPIO_LED					: T_SLV_8;
		signal GPIO_LED_meta		: T_SLV_8			:= (others => '0');
		signal GPIO_LED_sync		: T_SLV_8			:= (others => '0');
		
	begin
		GPIO_LED(1 downto 0)	<= "00";
	
		GPIO_LED(2)						<= ClkNet_ResetDone;
		GPIO_LED(3)						<= Ex_ClkNet_ResetDone;
		GPIO_LED(4)						<= '0';
		GPIO_LED(5)						<= '0';
		GPIO_LED(6)						<= '0';
		GPIO_LED(7)						<= '0';
	
		GPIO_LED_meta					<= GPIO_LED				when rising_edge(System_Clock);
		GPIO_LED_sync					<= GPIO_LED_meta	when rising_edge(System_Clock);
		Atlys_GPIO_LED				<= GPIO_LED_sync;
	end block;
	

	Ex_ClkNet_Reset		<= '0';

	Ex : entity L_Example.ex_ExampleDesign
		generic map (
			DEBUG											=> DEBUG,
			ENABLE_CHIPSCOPE					=> ENABLE_CHIPSCOPE,
			ENABLE_DEBUGPORT					=> ENABLE_DEBUGPORT,
			
			SYSTEM_CLOCK_FREQ					=> SYS_CLOCK_FREQ
		)
		port map (
			ClockNetwork_Reset				=> Ex_ClkNet_Reset,
			ClockNetwork_ResetDone		=> Ex_ClkNet_ResetDone,
		
			System_Clock							=> System_Clock,
			System_Reset							=> System_Reset,
			
			UART_TX										=> UART_TX,
			UART_RX										=> UART_RX,
			
			Raw_IIC_mux								=> Raw_IIC_mux,
			Raw_IIC_Clock_i						=> Raw_IIC_Clock_i,
			Raw_IIC_Clock_t						=> Raw_IIC_Clock_t,
			Raw_IIC_Data_i						=> Raw_IIC_Data_i,
			Raw_IIC_Data_t						=> Raw_IIC_Data_t,
			Raw_IIC_Switch_Reset			=> Raw_IIC_Switch_Reset--,
			
--			IIC_SerialClock_i					=> IIC_SerialClock_i,
--			IIC_SerialClock_o					=> IIC_SerialClock_o,
--			IIC_SerialClock_t					=> IIC_SerialClock_t,
--			IIC_SerialData_i					=> IIC_SerialData_i,
--			IIC_SerialData_o					=> IIC_SerialData_o,
--			IIC_SerialData_t					=> IIC_SerialData_t,
--			IICSwitch_Reset						=> IIC_Switch_Reset
		);

	-- ==========================================================================================================================================================
	-- I2C Bus
	-- ==========================================================================================================================================================
	blkIOBUF_IIC : block
		signal SerialClock_o				: STD_LOGIC;
		signal SerialClock_t				: STD_LOGIC;
		signal SerialData_o					: STD_LOGIC;
		signal SerialData_t					: STD_LOGIC;
		signal IICSwitch_Reset			: STD_LOGIC;
		
		signal SerialClock_o_d			: STD_LOGIC					:= '0';
		signal SerialClock_t_d			: STD_LOGIC					:= '1';
		signal SerialData_o_d				: STD_LOGIC					:= '0';
		signal SerialData_t_d				: STD_LOGIC					:= '1';
		signal IICSwitch_Reset_d		: STD_LOGIC					:= '0';
		
		signal SerialClock_async		: STD_LOGIC;
		signal SerialClock_i_meta		: STD_LOGIC					:= '1';
		signal SerialClock_i_sync		: STD_LOGIC					:= '1';
		signal SerialData_async			: STD_LOGIC;
		signal SerialData_i_meta		: STD_LOGIC					:= '1';
		signal SerialData_i_sync		: STD_LOGIC					:= '1';
		
		-- Mark register DataSync_meta's input as asynchronous
		attribute ASYNC_REG of SerialClock_i_meta				: signal is "TRUE";
		attribute ASYNC_REG of SerialData_i_meta				: signal is "TRUE";

		-- Prevent XST from translating two FFs into SRL plus FF
		attribute SHREG_EXTRACT of SerialClock_i_meta		: signal is "NO";
		attribute SHREG_EXTRACT of SerialClock_i_sync		: signal is "NO";
		attribute SHREG_EXTRACT of SerialData_i_meta		: signal is "NO";
		attribute SHREG_EXTRACT of SerialData_i_sync		: signal is "NO";
		
	BEGIN
		SerialClock_o					<= mux(Raw_IIC_mux, IIC_SerialClock_o, '0');
		SerialClock_t					<= mux(Raw_IIC_mux, IIC_SerialClock_t, Raw_IIC_Clock_t);
		
		SerialData_o					<= mux(Raw_IIC_mux, IIC_SerialData_o, '0');
		SerialData_t					<= mux(Raw_IIC_mux, IIC_SerialData_t, Raw_IIC_Data_t);
		
		IICSwitch_Reset				<= mux(Raw_IIC_mux, IIC_Switch_Reset, Raw_IIC_Switch_Reset);
		
		SerialClock_o_d				<= SerialClock_o			when rising_edge(System_Clock);
		SerialClock_t_d				<= SerialClock_t			when rising_edge(System_Clock);
		SerialData_o_d				<= SerialData_o				when rising_edge(System_Clock);
		SerialData_t_d				<= SerialData_t				when rising_edge(System_Clock);
		IICSwitch_Reset_d			<= IICSwitch_Reset		when rising_edge(System_Clock);
		
		SerialClock_i_meta		<= SerialClock_async	when rising_edge(System_Clock);
		SerialClock_i_sync		<= SerialClock_i_meta	when rising_edge(System_Clock);
		SerialData_i_meta			<= SerialData_async		when rising_edge(System_Clock);
		SerialData_i_sync			<= SerialData_i_meta	when rising_edge(System_Clock);
	
		IIC_SerialClock_i			<= SerialClock_i_sync	or		 Raw_IIC_mux;
		Raw_IIC_Clock_i				<= SerialClock_i_sync	or not Raw_IIC_mux;
		IIC_SerialData_i			<= SerialData_i_sync	or		 Raw_IIC_mux;
		Raw_IIC_Data_i				<= SerialData_i_sync	or not Raw_IIC_mux;
	
		IOBUF_IIC_SerialClock : IOBUF
			port map (
				T		=> SerialClock_t_d,					-- 3-state enable input, high=input, low=output
				I		=> SerialClock_o_d,					-- buffer input
				O		=> SerialClock_async,				-- buffer output
				IO	=> Atlys_IIC_SerialClock		-- buffer inout port (connect directly to top-level port)
			);

		IOBUF_IIC_SerialData : IOBUF
			port map (
				T		=> SerialData_t_d,					-- 3-state enable input, high=input, low=output
				I		=> SerialData_o_d,					-- buffer input
				O		=> SerialData_async,				-- buffer output
				IO	=> Atlys_IIC_SerialData			-- buffer inout port (connect directly to top-level port)
			);
		
		Atlys_IIC_Switch_Reset		<= IICSwitch_Reset_d;
	end block;
	
	blkIOBUF_UART : block
		signal blkUART_TX_d			: STD_LOGIC			:= '1';
		
		signal blkUART_RX_async	: STD_LOGIC;
		signal blkUART_RX_meta	: STD_LOGIC			:= '1';
		signal blkUART_RX_sync	: STD_LOGIC			:= '1';
		
		-- Mark register DataSync_meta's input as asynchronous
		attribute ASYNC_REG of blkUART_RX_meta			: signal is "TRUE";

		-- Prevent XST from translating two FFs into SRL plus FF
		attribute SHREG_EXTRACT of blkUART_RX_meta	: signal is "NO";
		attribute SHREG_EXTRACT of blkUART_RX_sync	: signal is "NO";
		
	begin
		blkUART_TX_d		<= UART_TX	when rising_edge(System_Clock);
	
		OBUF_UART_TX : OBUF
			port map (
				I => blkUART_TX_d,
				O => Atlys_UART_TX
			);
	
		IBUF_UART_RX : IBUF
			port map (
				I => Atlys_UART_RX,
				O => blkUART_RX_async
			);
	
		Atlys_USB_UART_CTS	<= '1';		-- USB-UART can always send new data to the FPGA
	
		blkUART_RX_meta			<= blkUART_RX_async	when rising_edge(System_Clock);
		blkUART_RX_sync			<= blkUART_RX_meta	when rising_edge(System_Clock);
		UART_RX							<= blkUART_RX_sync;
	end block;
end;
