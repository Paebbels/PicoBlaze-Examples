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

library PoC;
use			PoC.config.all;
use			PoC.utils.all;
use			PoC.vectors.all;
use			PoC.strings.all;
use			PoC.physical.all;
use			PoC.components.all;
--use			PoC.xil.all;
use			PoC.io.all;

library L_Example;


entity Top_PauloBlaze_DE4 is
	port (
		DE4_SystemClock_100MHz		: in		STD_LOGIC;
		
		DE4_GPIO_Button_Reset_n		: in		STD_LOGIC;
		DE4_GPIO_Button_n					: in		STD_LOGIC_VECTOR(3 downto 0);
		DE4_GPIO_SlideSwitches		: in		STD_LOGIC_VECTOR(3 downto 0);
		DE4_GPIO_DipSwitches_n		: in		STD_LOGIC_VECTOR(7 downto 0);
		DE4_GPIO_LED_n						: out		STD_LOGIC_VECTOR(7 downto 0);
		DE4_GPIO_Seg7_Digit0_n		: out		STD_LOGIC_VECTOR(7 downto 0);
		DE4_GPIO_Seg7_Digit1_n		: out		STD_LOGIC_VECTOR(7 downto 0);
 
		DE4_UART_RS232_TX					: out		STD_LOGIC;			-- USB-UART Bridge is "slave"
		DE4_UART_RS232_RX					: in		STD_LOGIC;			-- USB-UART Bridge is "slave"
		DE4_UART_RS232_CTS				: out		STD_LOGIC;			-- USB-UART Bridge is "slave"
		DE4_UART_RS232_RTS				: in		STD_LOGIC;			-- USB-UART Bridge is "slave"

		DE4_IIC_EEPROM_SerialClock			: inout	STD_LOGIC;
		DE4_IIC_EEPROM_SerialData				: inout	STD_LOGIC;
		
		DE4_SMBus_SerialClock						: inout	STD_LOGIC;
		DE4_SMBus_SerialData						: inout	STD_LOGIC;
		DE4_SMBus_Alert									: in		STD_LOGIC;
		
		DE4_FanControl									: out		STD_LOGIC;
		
		DE4_EthernetPHY_Reset_n					: out		STD_LOGIC;
		DE4_EthernetPHY0_Interrupt_n		: in		STD_LOGIC;
		DE4_EthernetPHY0_MDIO_Clock			: out		STD_LOGIC;
		DE4_EthernetPHY0_MDIO_Data			: inout	STD_LOGIC;
--		DE4_EthernetPHY0_TX_p						: out		STD_LOGIC;
--		DE4_EthernetPHY0_TX_n						: out		STD_LOGIC;
--		DE4_EthernetPHY0_RX_p						: in		STD_LOGIC;
--		DE4_EthernetPHY0_RX_n						: in		STD_LOGIC;
		
		DE4_EthernetPHY1_Interrupt_n		: in		STD_LOGIC;
		DE4_EthernetPHY1_MDIO_Clock			: out		STD_LOGIC;
		DE4_EthernetPHY1_MDIO_Data			: inout	STD_LOGIC;
--		DE4_EthernetPHY1_TX_p						: out		STD_LOGIC;
--		DE4_EthernetPHY1_TX_n						: out		STD_LOGIC;
--		DE4_EthernetPHY1_RX_p						: in		STD_LOGIC;
--		DE4_EthernetPHY1_RX_n						: in		STD_LOGIC;
		
		DE4_EthernetPHY2_Interrupt_n		: in		STD_LOGIC;
		DE4_EthernetPHY2_MDIO_Clock			: out		STD_LOGIC;
		DE4_EthernetPHY2_MDIO_Data			: inout	STD_LOGIC;
--		DE4_EthernetPHY2_TX_p						: out		STD_LOGIC;
--		DE4_EthernetPHY2_TX_n						: out		STD_LOGIC;
--		DE4_EthernetPHY2_RX_p						: in		STD_LOGIC;
--		DE4_EthernetPHY2_RX_n						: in		STD_LOGIC;
		
		DE4_EthernetPHY3_Interrupt_n		: in		STD_LOGIC;
		DE4_EthernetPHY3_MDIO_Clock			: out		STD_LOGIC;
		DE4_EthernetPHY3_MDIO_Data			: inout	STD_LOGIC
--		DE4_EthernetPHY3_TX_p						: out		STD_LOGIC;
--		DE4_EthernetPHY3_TX_n						: out		STD_LOGIC;
--		DE4_EthernetPHY3_RX_p						: in		STD_LOGIC;
--		DE4_EthernetPHY3_RX_n						: in		STD_LOGIC
	);
end;
--
--
-- LED configuration
-- =============================================================================================================================================================
--	LED 7				LED 6				LED 5				LED 4				LED 3				LED 2				LED 1				LED 0
-- <unused>		<unused>		<unused>		<unused>		<unused>		<unused>		<unused>		<unused>


architecture top of Top_PauloBlaze_DE4 is
	attribute PRESERVE									: BOOLEAN;

	-- ==========================================================================================================================================================
	-- configurations
	-- ==========================================================================================================================================================
	-- common configuration
	constant DEBUG											: BOOLEAN							:= TRUE;
	constant ENABLE_CHIPSCOPE						: BOOLEAN							:= TRUE;
	constant ENABLE_DEBUGPORT						: BOOLEAN							:= TRUE;
	
	constant SYS_CLOCK_FREQ							: FREQ								:= 100 MHz;
	
	-- ClockNetwork configuration
	-- ===========================================================================
	constant SYSTEM_CLOCK_FREQ					: FREQ								:= SYS_CLOCK_FREQ;
	

	-- ==========================================================================================================================================================
	-- signal declarations
	-- ==========================================================================================================================================================
	-- clock and reset signals
	signal System_RefClock_100MHz				: STD_LOGIC;

	signal ClkNet_Reset									: STD_LOGIC;
	signal ClkNet_ResetDone							: STD_LOGIC;

	signal Control_Clock								: STD_LOGIC;
	
	signal SystemClock_200MHz						: STD_LOGIC;
	signal SystemClock_125MHz						: STD_LOGIC;
	signal SystemClock_100MHz						: STD_LOGIC;
	signal SystemClock_10MHz						: STD_LOGIC;

	signal SystemClock_Stable_200MHz		: STD_LOGIC;
	signal SystemClock_Stable_125MHz		: STD_LOGIC;
	signal SystemClock_Stable_100MHz		: STD_LOGIC;
	signal SystemClock_Stable_10MHz			: STD_LOGIC;

	signal System_Clock									: STD_LOGIC;
	signal System_ClockStable						: STD_LOGIC;
	signal System_Reset									: STD_LOGIC;
	
	attribute PRESERVE of System_Clock	: signal is TRUE;
	attribute PRESERVE of System_Reset	: signal is TRUE;

	-- active-low board signals
	signal DE4_GPIO_Button_Reset				: STD_LOGIC;
	signal DE4_GPIO_Button							: STD_LOGIC_VECTOR(3 downto 0);
	signal DE4_GPIO_DipSwitches					: STD_LOGIC_VECTOR(7 downto 0);
--	signal DE4_EthernetPHYernetPHY_Reset			: STD_LOGIC;
--	signal DE4_EthernetPHYernetPHY_Interrupt	: STD_LOGIC;
	signal DE4_GPIO_LED									: STD_LOGIC_VECTOR(7 downto 0);
	signal DE4_GPIO_Seg7_Digit0					: STD_LOGIC_VECTOR(7 downto 0);
	signal DE4_GPIO_Seg7_Digit1					: STD_LOGIC_VECTOR(7 downto 0);
	
	-- cross-over signals
--	signal DE4_UART_TX									: STD_LOGIC;
--	signal DE4_UART_RX									: STD_LOGIC;
	
	-- debounced button signals (debounce circuit works @10 MHz)
	signal GPIO_Button_Reset						: STD_LOGIC;
	
	-- synchronized button signals
	signal Button_Reset									: STD_LOGIC;
	
	-- edge-detections on GPIO_Button_*
	
	-- PerformanceTest signals
	signal ex_ClkNet_Reset							: STD_LOGIC;
	signal ex_ClkNet_ResetDone					: STD_LOGIC;
	
	signal UART_TX											: STD_LOGIC;
	signal UART_RX											: STD_LOGIC;
	signal UART_CTS											: STD_LOGIC;
	signal UART_RTS											: STD_LOGIC;

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
	assert FALSE report "  SYS_CLOCK_FREQ:         " & to_string(SYS_CLOCK_FREQ, 3)						severity NOTE;

	-- ==========================================================================================================================================================
	-- Input/output buffers
	-- ==========================================================================================================================================================
	System_RefClock_100MHz		<= DE4_SystemClock_100MHz;
	

	-- ==========================================================================================================================================================
	-- active-low to active-high conversion
	-- ==========================================================================================================================================================
	-- input signals
	DE4_GPIO_Button_Reset				<= not DE4_GPIO_Button_Reset_n;
	DE4_GPIO_Button							<= not DE4_GPIO_Button_n;
	DE4_GPIO_DipSwitches				<= not DE4_GPIO_DipSwitches_n;
--	DE4_EthernetPHYernetPHY_Interrupt		<= NOT DE4_EthernetPHYernetPHY_Interrupt_n;
	
	-- output signals
	DE4_GPIO_LED_n							<= not DE4_GPIO_LED;
	DE4_GPIO_Seg7_Digit0_n			<= not DE4_GPIO_Seg7_Digit0;
	DE4_GPIO_Seg7_Digit1_n			<= not DE4_GPIO_Seg7_Digit1;
--	DE4_EthernetPHYernetPHY_Reset_n		<= not DE4_EthernetPHYernetPHY_Reset;

	-- ==========================================================================================================================================================
	-- cross-over signal renaming
	-- ==========================================================================================================================================================
	-- USB-UART is the slave, FPGA is the master
--	DE4_UART_RS232_TX		<= DE4_UART_RX;
--	DE4_UART_TX					<= DE4_UART_RS232_RX;

	-- ==========================================================================================================================================================
	-- ClockNetwork
	-- ==========================================================================================================================================================
	ClkNet_Reset			<= GPIO_Button_Reset;
	Ex_ClkNet_Reset		<= GPIO_Button_Reset;
	
	ClkNet : entity L_Example.clknet_ClockNetwork_DE4
		generic map (
			CLOCK_IN_FREQ						=> SYS_CLOCK_FREQ
		)
		port map (
			ClockIn_100MHz					=> System_RefClock_100MHz,

			ClockNetwork_Reset			=> ClkNet_Reset,
			ClockNetwork_ResetDone	=> ClkNet_ResetDone,
			
			Control_Clock_100MHz		=> Control_Clock,
			
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
	System_Clock				<= SystemClock_100MHz;
	System_ClockStable	<= SystemClock_Stable_100MHz;
	System_Reset				<= not SystemClock_Stable_100MHz;

	-- ==========================================================================================================================================================
	-- signal debouncing
	-- ==========================================================================================================================================================
	DebBtn : entity PoC.io_Debounce
		generic map (
			CLOCK_FREQ				=> SYSTEM_CLOCK_FREQ,
			BOUNCE_TIME				=> 50 ms,
			BITS							=> 1
		)
		port map (
			clk								=> Control_Clock,
			rst								=> '0',
			Input(0)					=> DE4_GPIO_Button_Reset,
			Output(0)					=> GPIO_Button_Reset
		);

	-- synchronize to System_Clock
	sync1 : entity PoC.sync_Bits_Altera
		port map (
			Clock			=> System_Clock,						-- Clock to be synchronized to
			Input(0)	=> GPIO_Button_Reset,				-- Data to be synchronized
			Output(0)	=> Button_Reset							-- synchronised data
		);

	-- ==========================================================================================================================================================
	-- main design
	-- ==========================================================================================================================================================
	-- Button inputs


	-- Switch inputs
	-- unused				<= DE4_GPIO_Switches(0);
	-- unused				<= DE4_GPIO_Switches(1);
	-- unused				<= DE4_GPIO_Switches(2);
	-- unused				<= DE4_GPIO_Switches(3);
	-- unused				<= DE4_GPIO_Switches(4);
	-- unused				<= DE4_GPIO_Switches(5);
	-- unused				<= DE4_GPIO_Switches(6);
	-- unused				<= DE4_GPIO_Switches(7);
	
	-- LED outputs
	blkLED : block
		signal GPIO_LED				: T_SLV_8;
		signal GPIO_LED_iob		: T_SLV_8			:= (others => '0');
	begin
		GPIO_LED(0)						<= ClkNet_ResetDone;
		GPIO_LED(1)						<= System_ClockStable;
		GPIO_LED(2)						<= Button_Reset;
		GPIO_LED(3)						<= '0';
		GPIO_LED(4)						<= '0';
		GPIO_LED(5)						<= '0';
		GPIO_LED(6)						<= '0';
		GPIO_LED(7)						<= '0';
	
		GPIO_LED_iob					<= GPIO_LED	when rising_edge(System_Clock);
		DE4_GPIO_LED					<= GPIO_LED_iob;
	end block;
	
	blkSeg7 : block
	begin
		DE4_GPIO_Seg7_Digit0		<= io_7SegmentDisplayEncoding(x"2", '1');
		DE4_GPIO_Seg7_Digit1		<= io_7SegmentDisplayEncoding(x"4", '0');
	end block;
	
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
			System_ClockStable				=> System_ClockStable,
			System_Reset							=> System_Reset,
			
			UART_TX										=> UART_TX,
			UART_RX										=> UART_RX,
			
			Raw_IIC_mux								=> Raw_IIC_mux,
			Raw_IIC_Clock_i						=> Raw_IIC_Clock_i,
			Raw_IIC_Clock_t						=> Raw_IIC_Clock_t,
			Raw_IIC_Data_i						=> Raw_IIC_Data_i,
			Raw_IIC_Data_t						=> Raw_IIC_Data_t--,
			
--			IIC_SerialClock_i					=> IIC_SerialClock_i,
--			IIC_SerialClock_o					=> IIC_SerialClock_o,
--			IIC_SerialClock_t					=> IIC_SerialClock_t,
--			IIC_SerialData_i					=> IIC_SerialData_i,
--			IIC_SerialData_o					=> IIC_SerialData_o,
--			IIC_SerialData_t					=> IIC_SerialData_t,
--			IICSwitch_Reset						=> IIC_Switch_Reset
		);

	UART_CTS		<= UART_RTS;
		
	blkFanControl : block
		signal Fan_PWM		: STD_LOGIC;
	begin
		Fan : entity PoC.io_FanControl
			generic map (
				CLOCK_FREQ			=> SYS_CLOCK_FREQ
			)
			port map (
				Clock						=> System_Clock,
				Reset						=> System_Reset,
				
				Fan_PWM					=> Fan_PWM,
				Fan_Tacho				=> '0',
				
				TachoFrequency	=> open
			);			
		
		DE4_FanControl			<= Fan_PWM;
	end block;
		
	-- ==========================================================================================================================================================
	-- I2C Bus
	-- ==========================================================================================================================================================
	blkIOBUF_IIC : block
		signal SerialClock_o				: STD_LOGIC;
		signal SerialClock_t				: STD_LOGIC;
		signal SerialData_o					: STD_LOGIC;
		signal SerialData_t					: STD_LOGIC;
		
		signal SerialClock_o_iob		: STD_LOGIC					:= '0';
		signal SerialClock_t_iob		: STD_LOGIC					:= '1';
		signal SerialData_o_iob			: STD_LOGIC					:= '0';
		signal SerialData_t_iob			: STD_LOGIC					:= '1';
		
		signal SerialClock_async		: STD_LOGIC;
		signal SerialClock_i_meta		: STD_LOGIC					:= '1';
		signal SerialClock_i_sync		: STD_LOGIC					:= '1';
		signal SerialData_async			: STD_LOGIC;
		signal SerialData_i_meta		: STD_LOGIC					:= '1';
		signal SerialData_i_sync		: STD_LOGIC					:= '1';
		
	BEGIN
		SerialClock_o					<= mux(Raw_IIC_mux, IIC_SerialClock_o, '0');
		SerialClock_t					<= mux(Raw_IIC_mux, IIC_SerialClock_t, Raw_IIC_Clock_t);
		
		SerialData_o					<= mux(Raw_IIC_mux, IIC_SerialData_o, '0');
		SerialData_t					<= mux(Raw_IIC_mux, IIC_SerialData_t, Raw_IIC_Data_t);
		
		SerialClock_o_iob			<= SerialClock_o			when rising_edge(System_Clock);
		SerialClock_t_iob			<= SerialClock_t			when rising_edge(System_Clock);
		SerialData_o_iob			<= SerialData_o				when rising_edge(System_Clock);
		SerialData_t_iob			<= SerialData_t				when rising_edge(System_Clock);
		
		SerialClock_i_meta		<= SerialClock_async	when rising_edge(System_Clock);
		SerialClock_i_sync		<= SerialClock_i_meta	when rising_edge(System_Clock);
		SerialData_i_meta			<= SerialData_async		when rising_edge(System_Clock);
		SerialData_i_sync			<= SerialData_i_meta	when rising_edge(System_Clock);
	
		IIC_SerialClock_i			<= SerialClock_i_sync	or		 Raw_IIC_mux;
		Raw_IIC_Clock_i				<= SerialClock_i_sync	or not Raw_IIC_mux;
		IIC_SerialData_i			<= SerialData_i_sync	or		 Raw_IIC_mux;
		Raw_IIC_Data_i				<= SerialData_i_sync	or not Raw_IIC_mux;
	
		DE4_IIC_EEPROM_SerialClock	<= 'Z' when (SerialClock_t_iob = '1')	else SerialClock_o_iob;
		DE4_IIC_EEPROM_SerialData		<= 'Z' when (SerialData_t_iob = '1')	else SerialData_o_iob;
		SerialClock_async						<= DE4_IIC_EEPROM_SerialClock;
		SerialData_async						<= DE4_IIC_EEPROM_SerialData;
	end block;
	
	blkSMBus : block
	
	begin
		DE4_SMBus_SerialClock			<= '1';
		DE4_SMBus_SerialData			<= '1';
	end block;
	
	blkMDIO : block
	
	begin
		DE4_EthernetPHY_Reset_n					<= '1';
		DE4_EthernetPHY0_MDIO_Clock			<= '0';
		DE4_EthernetPHY0_MDIO_Data			<= '0';
		DE4_EthernetPHY1_MDIO_Clock			<= '0';
		DE4_EthernetPHY1_MDIO_Data			<= '0';
		DE4_EthernetPHY2_MDIO_Clock			<= '0';
		DE4_EthernetPHY2_MDIO_Data			<= '0';
		DE4_EthernetPHY3_MDIO_Clock			<= '0';
		DE4_EthernetPHY3_MDIO_Data			<= '0';
	end block;
	
	blkIOBUF_UART : block
		signal blkUART_TX_iob			: STD_LOGIC			:= '1';
		signal blkUART_CTS_iob		: STD_LOGIC			:= '1';
		
		signal blkUART_RX_async		: STD_LOGIC;
		signal blkUART_RX_meta		: STD_LOGIC			:= '1';
		signal blkUART_RX_sync		: STD_LOGIC			:= '1';
		signal blkUART_RTS_async	: STD_LOGIC;
		signal blkUART_RTS_meta		: STD_LOGIC			:= '1';
		signal blkUART_RTS_sync		: STD_LOGIC			:= '1';
	begin
		blkUART_TX_iob			<= UART_TX	when rising_edge(System_Clock);
		blkUART_CTS_iob			<= UART_CTS	when rising_edge(System_Clock);
	
		-- assign to outputs
		DE4_UART_RS232_TX		<= blkUART_TX_iob;
		DE4_UART_RS232_CTS	<= blkUART_CTS_iob;
		-- assign from inputs
		blkUART_RX_async		<= DE4_UART_RS232_RX;
		blkUART_RTS_async		<= DE4_UART_RS232_RTS;
	
		blkUART_RX_meta			<= blkUART_RX_async		when rising_edge(System_Clock);
		blkUART_RTS_meta		<= blkUART_RTS_async	when rising_edge(System_Clock);
		blkUART_RX_sync			<= blkUART_RX_meta		when rising_edge(System_Clock);
		blkUART_RTS_sync		<= blkUART_RTS_meta		when rising_edge(System_Clock);
		UART_RX							<= blkUART_RX_sync;
		UART_RTS						<= blkUART_RTS_sync;
	end block;
end;
