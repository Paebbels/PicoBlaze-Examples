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
use			PoC.my_project.MY_PROJECT_NAME;
use			PoC.config.all;
use			PoC.utils.all;
use			PoC.vectors.all;
use			PoC.strings.all;
use			PoC.physical.all;
use			PoC.io.all;
--use			PoC.lcd.all;
use			PoC.xil.all;

library L_PicoBlaze;
use			L_PicoBlaze.pb.all;

library L_Example;
use			L_Example.pb_SoFPGA.all;


entity ex_ExampleDesign is
	generic (
		DEBUG											: BOOLEAN;
		ENABLE_CHIPSCOPE					: BOOLEAN;
		ENABLE_DEBUGPORT					: BOOLEAN;
		
		SYSTEM_CLOCK_FREQ					: FREQ
	);
	port (
		ClockNetwork_Reset				: in	STD_LOGIC;
		ClockNetwork_ResetDone		: out	STD_LOGIC;
		
		System_Clock							: in	STD_LOGIC;
		System_Reset							: in	STD_LOGIC;

--		LCD_en										: out STD_LOGIC;
--		LCD_rw										: out STD_LOGIC;
--		LCD_rs										: out STD_LOGIC;
--		LCD_Data_i								: in	T_SLV_4;
--		LCD_Data_o								: out	T_SLV_4;
--		LCD_Data_t								: out	T_SLV_4;
		
		UART_TX										: out	STD_LOGIC;
		UART_RX										: in	STD_LOGIC;
		
		Raw_IIC_mux								: out	STD_LOGIC;
		Raw_IIC_Clock_i						: in	STD_LOGIC;
		Raw_IIC_Clock_t						: out	STD_LOGIC;
		Raw_IIC_Data_i						: in	STD_LOGIC;
		Raw_IIC_Data_t						: out	STD_LOGIC;
		Raw_IIC_Switch_Reset			: out	STD_LOGIC
		
--		IIC_SerialClock_i					: in	STD_LOGIC;
--		IIC_SerialClock_o					: out	STD_LOGIC;
--		IIC_SerialClock_t					: out	STD_LOGIC;
--		IIC_SerialData_i					: in	STD_LOGIC;
--		IIC_SerialData_o					: out	STD_LOGIC;
--		IIC_SerialData_t					: out	STD_LOGIC;
--		IICSwitch_Reset						: out	STD_LOGIC
	);
end;


architecture rtl of ex_ExampleDesign is
	attribute KEEP											: BOOLEAN;
	attribute ENUM_ENCODING							: STRING;

	-- ===========================================================================
	-- configurations
	-- ===========================================================================
	-- UART configuration																													921.6 kBit/s	115.2 kBit/s	
	constant UART_BAUDRATE											: BAUD				:= ite(SIMULATION,	921600 Bd,		115200 Bd);

	-- ===========================================================================
	-- SoFPGA configuration
	-- ===========================================================================
	constant USE_PRECOMPILED_SOFPGA	: BOOLEAN			:= TRUE;
	constant ENABLE_SOFPGA_TRACER		: BOOLEAN			:= ENABLE_CHIPSCOPE;
	
	constant EXTNERN_PB_IOBUS_PORTS	: NATURAL			:= pb_GetBusWidth(SOFPGA_SYSTEM, "Extern");
	constant TEST_PB_IOBUS_PORTS		: NATURAL			:= pb_GetBusWidth(SOFPGA_SYSTEM, "Test");

	constant SOFPGA_DUMMY 					: T_BOOLVEC 	:= (
		0 => pb_PrintAddressMapping(SOFPGA_SYSTEM),
		1 => pb_PrintBusses(SOFPGA_SYSTEM),
		2 => pb_ExportAddressMappingAsAssemblerConstants(SOFPGA_SYSTEM,				PROJECT_DIR & "psm/" & MY_PROJECT_NAME & "/SoFPGA_PortID.psm"),
		3 => pb_ExportAddressMappingAsAssemblerInterruptVector(SOFPGA_SYSTEM,	PROJECT_DIR & "psm/" & MY_PROJECT_NAME & "/SoFPGA_InterruptVector.psm", 16),
		4 => pb_ExportAddressMappingAsChipScopeTokens(SOFPGA_SYSTEM,					PROJECT_DIR & "ChipScope/TokenFiles/SoFPGA_PortID." & MY_PROJECT_NAME & ".tok")
	);

	-- ===========================================================================
	-- signal declarations
	-- ===========================================================================
	-- Clock signals
	signal ClkNet_Reset											: STD_LOGIC;
	signal ClkNet_ResetDone									: STD_LOGIC;
	
	-- ChipScope Pro signals
	-- ================================================================
	constant CSP_ICON_PORTS												: NATURAL	:= ite(not ENABLE_CHIPSCOPE, 0, 2);

	constant CSP_ICON_BUSID_EXAMPLE_CTRL					: NATURAL	:= imin(CSP_ICON_PORTS, 0);
	constant CSP_ICON_BUSID_SOFPGA_ILA						: NATURAL	:= imin(CSP_ICON_PORTS, 1);
	
	signal ICON_ControlBus												: T_XIL_CHIPSCOPE_CONTROL_VECTOR(imax(0, CSP_ICON_PORTS - 1) downto 0);
	
	-- System on Chip
	-- ================================================================
	signal SoFPGA_Tracer_TriggerEvent				: STD_LOGIC;
	
	signal SoFPGA_PicoBlazeDeviceBus				: T_PB_IOBUS_PB_DEV_VECTOR(EXTNERN_PB_IOBUS_PORTS - 1 downto 0);
	signal SoFPGA_DevicePicoBlazeBus				: T_PB_IOBUS_DEV_PB_VECTOR(EXTNERN_PB_IOBUS_PORTS - 1 downto 0);

	signal SoFPGA_UART_TX										: STD_LOGIC;
	signal SoFPGA_UART_RX										: STD_LOGIC;
	
--	signal SoFPGA_PBIIC1_Request						: STD_LOGIC;
--	signal SoFPGA_PBIIC1_Command						: T_IO_IIC_COMMAND;
--	signal SoFPGA_PBIIC1_Address						: STD_LOGIC_VECTOR(6 downto 0);
--	signal SoFPGA_PBIIC1_WP_Valid						: STD_LOGIC;
--	signal SoFPGA_PBIIC1_WP_Data						: T_SLV_8;
--	signal SoFPGA_PBIIC1_WP_Last						: STD_LOGIC;
--	signal SoFPGA_PBIIC1_RP_Ack							: STD_LOGIC;
--
--	signal SoFPGA_PBIIC2_Request						: STD_LOGIC;
--	signal SoFPGA_PBIIC2_Command						: T_IO_IIC_COMMAND;
--	signal SoFPGA_PBIIC2_Address						: STD_LOGIC_VECTOR(6 downto 0);
--	signal SoFPGA_PBIIC2_WP_Valid						: STD_LOGIC;
--	signal SoFPGA_PBIIC2_WP_Data						: T_SLV_8;
--	signal SoFPGA_PBIIC2_WP_Last						: STD_LOGIC;
--	signal SoFPGA_PBIIC2_RP_Ack							: STD_LOGIC;
--	
--	-- IIC Bus
--	-- ================================================================
--	signal IICBus_PBIIC1_Grant							: STD_LOGIC;
--	signal IICBus_PBIIC1_Status							: T_IO_IIC_STATUS;
--	signal IICBus_PBIIC1_Error							: T_IO_IIC_ERROR;
--	signal IICBus_PBIIC1_WP_Ack							: STD_LOGIC;
--	signal IICBus_PBIIC1_RP_Valid						: STD_LOGIC;
--	signal IICBus_PBIIC1_RP_Data						: T_SLV_8;
--	signal IICBus_PBIIC1_RP_Last						: STD_LOGIC;
--	
--	signal IICBus_PBIIC2_Grant							: STD_LOGIC;
--	signal IICBus_PBIIC2_Status							: T_IO_IIC_STATUS;
--	signal IICBus_PBIIC2_Error							: T_IO_IIC_ERROR;
--	signal IICBus_PBIIC2_WP_Ack							: STD_LOGIC;
--	signal IICBus_PBIIC2_RP_Valid						: STD_LOGIC;
--	signal IICBus_PBIIC2_RP_Data						: T_SLV_8;
--	signal IICBus_PBIIC2_RP_Last						: STD_LOGIC;

begin

	genCSP : if (ENABLE_CHIPSCOPE and (CSP_ICON_PORTS > 0)) generate
		signal ControlVIO_In		: STD_LOGIC_VECTOR(7 downto 0);
		signal ControlVIO_Out		: STD_LOGIC_VECTOR(7 downto 0);
	begin
		ICON : entity PoC.xil_ChipScopeICON
			generic map (
				PORTS				=> CSP_ICON_PORTS
			)
			port map (
				ControlBus	=> ICON_ControlBus
			);
	
		ControlVIO : entity L_Example.CSP_ControlVIO
			port map (
				CONTROL			=> ICON_ControlBus(CSP_ICON_BUSID_EXAMPLE_CTRL),
				CLK					=> System_Clock,
				SYNC_IN			=> ControlVIO_In,
				SYNC_OUT		=> ControlVIO_Out
			);

		ControlVIO_In(0)				<= '0';										-- ClockNetwork_ResetDone;
		ControlVIO_In(1)				<= '0';										-- ClockTest
		ControlVIO_In(2)				<= '0';										-- unused
		ControlVIO_In(3)				<= '0';										-- unused
		ControlVIO_In(4)				<= '0';										-- unused
		ControlVIO_In(5)				<= '0';										-- unused
		ControlVIO_In(6)				<= '0';										-- unused
		ControlVIO_In(7)				<= '0';										-- unused
	
--		unused			<= ControlVIO_Out(0);
--		unused			<= ControlVIO_Out(1);
--		unused			<= ControlVIO_Out(2);
--		unused			<= ControlVIO_Out(3);
--		unused			<= ControlVIO_Out(4);
--		unused			<= ControlVIO_Out(5);
--		unused			<= ControlVIO_Out(6);
--		unused			<= ControlVIO_Out(7);
	end generate;

	-- ==========================================================================================================================================================
	-- System on Chip - PicoBlaze
	-- ==========================================================================================================================================================
	SoFPGA : entity L_Example.pb_SoFPGA_System
		generic map (
			DEBUG												=> DEBUG,
			ENABLE_CHIPSCOPE						=> ENABLE_SOFPGA_TRACER,
			CLOCK_FREQ									=> SYSTEM_CLOCK_FREQ,
			EXTERNAL_DEVICE_COUNT				=> EXTNERN_PB_IOBUS_PORTS,
			UART_BAUDRATE								=> UART_BAUDRATE
		)
		port map (
			Clock												=> System_Clock,
			Reset												=> System_Reset,
			
			CSP_ICON_ControlBus_Trace		=> ICON_ControlBus(CSP_ICON_BUSID_SOFPGA_ILA),
			CSP_Tracer_TriggerEvent			=> SoFPGA_Tracer_TriggerEvent,
			
			PicoBlazeBusOut							=> SoFPGA_PicoBlazeDeviceBus,
			PicoBlazeBusIn							=> SoFPGA_DevicePicoBlazeBus,
			
--			LCD_en											=> LCD_en,
--			LCD_rw											=> LCD_rw,
--			LCD_rs											=> LCD_rs,
--			LCD_Data_i									=> LCD_Data_i,
--			LCD_Data_o									=> LCD_Data_o,
--			LCD_Data_t									=> LCD_Data_t,
			
			UART_TX											=> UART_TX,
			UART_RX											=> UART_RX,
			
			Raw_IIC_mux									=> Raw_IIC_mux,
			Raw_IIC_Clock_i							=> Raw_IIC_Clock_i,
			Raw_IIC_Clock_t							=> Raw_IIC_Clock_t,
			Raw_IIC_Data_i							=> Raw_IIC_Data_i,
			Raw_IIC_Data_t							=> Raw_IIC_Data_t,
			Raw_IIC_Switch_Reset				=> Raw_IIC_Switch_Reset
			
--			-- IICController_IIC interface
--			IIC1_Request								=> SoFPGA_PBIIC1_Request,
--			IIC1_Grant									=> IICBus_PBIIC1_Grant,
--			
--			IIC1_Command								=> SoFPGA_PBIIC1_Command,
--			IIC1_Status									=> IICBus_PBIIC1_Status,
--			IIC1_Error									=> IICBus_PBIIC1_Error,
--			
--			IIC1_Address								=> SoFPGA_PBIIC1_Address,
--			IIC1_WP_Valid								=> SoFPGA_PBIIC1_WP_Valid,
--			IIC1_WP_Data								=> SoFPGA_PBIIC1_WP_Data,
--			IIC1_WP_Last								=> SoFPGA_PBIIC1_WP_Last,
--			IIC1_WP_Ack									=> IICBus_PBIIC1_WP_Ack,
--			IIC1_RP_Valid								=> IICBus_PBIIC1_RP_Valid,
--			IIC1_RP_Data								=> IICBus_PBIIC1_RP_Data,
--			IIC1_RP_Last								=> IICBus_PBIIC1_RP_Last,
--			IIC1_RP_Ack									=> SoFPGA_PBIIC1_RP_Ack,
--			
--			-- IICController_IIC interface
--			IIC2_Request								=> SoFPGA_PBIIC2_Request,
--			IIC2_Grant									=> IICBus_PBIIC2_Grant,
--			
--			IIC2_Command								=> SoFPGA_PBIIC2_Command,
--			IIC2_Status									=> IICBus_PBIIC2_Status,
--			IIC2_Error									=> IICBus_PBIIC2_Error,
--			
--			IIC2_Address								=> SoFPGA_PBIIC2_Address,
--			IIC2_WP_Valid								=> SoFPGA_PBIIC2_WP_Valid,
--			IIC2_WP_Data								=> SoFPGA_PBIIC2_WP_Data,
--			IIC2_WP_Last								=> SoFPGA_PBIIC2_WP_Last,
--			IIC2_WP_Ack									=> IICBus_PBIIC2_WP_Ack,
--			IIC2_RP_Valid								=> IICBus_PBIIC2_RP_Valid,
--			IIC2_RP_Data								=> IICBus_PBIIC2_RP_Data,
--			IIC2_RP_Last								=> IICBus_PBIIC2_RP_Last,
--			IIC2_RP_Ack									=> SoFPGA_PBIIC2_RP_Ack,
					
--			FreqM_ClockIn								=> SATA_Clock_i
		);
	
--	blkIICBus : block
--	begin
--		IICBus : entity L_DMATest.IICBus
--			generic map (
--				CLOCK_FREQ									=> IIC_CLOCK_FREQ,
--				DEBUG												=> DEBUG
--			)
--			port map (
--				Clock												=> IIC_Clock,
--				Reset												=> IIC_Reset,
--
----				PUC_IICMaster_Request				=> '0',
----				PUC_IICMaster_Grant					=> OPEN,
----				PUC_IICMaster_Command				=> IO_IIC_CMD_NONE,
----				PUC_IICMaster_Status				=> OPEN,
----				PUC_IICMaster_Error					=> OPEN,
----				PUC_IICMaster_Address				=> (others => '0'),
----				PUC_IICMaster_WP_Valid			=> '0',
----				PUC_IICMaster_WP_Data				=> (others => '0'),
----				PUC_IICMaster_WP_Last				=> '0',
----				PUC_IICMaster_WP_Ack				=> OPEN,
----				PUC_IICMaster_RP_Valid			=> OPEN,
----				PUC_IICMaster_RP_Data				=> OPEN,
----				PUC_IICMaster_RP_Last				=> OPEN,
----				PUC_IICMaster_RP_Ack				=> '0',
--	
--				PUC_IICMaster_Request				=> SoFPGA_PBIIC2_Request,
--				PUC_IICMaster_Grant					=> IICBus_PBIIC2_Grant,
--				PUC_IICMaster_Command				=> SoFPGA_PBIIC2_Command,
--				PUC_IICMaster_Status				=> IICBus_PBIIC2_Status,
--				PUC_IICMaster_Error					=> IICBus_PBIIC2_Error,
--				PUC_IICMaster_Address				=> SoFPGA_PBIIC2_Address,
--				PUC_IICMaster_WP_Valid			=> SoFPGA_PBIIC2_WP_Valid,
--				PUC_IICMaster_WP_Data				=> SoFPGA_PBIIC2_WP_Data,
--				PUC_IICMaster_WP_Last				=> SoFPGA_PBIIC2_WP_Last,
--				PUC_IICMaster_WP_Ack				=> IICBus_PBIIC2_WP_Ack,
--				PUC_IICMaster_RP_Valid			=> IICBus_PBIIC2_RP_Valid,
--				PUC_IICMaster_RP_Data				=> IICBus_PBIIC2_RP_Data,
--				PUC_IICMaster_RP_Last				=> IICBus_PBIIC2_RP_Last,
--				PUC_IICMaster_RP_Ack				=> SoFPGA_PBIIC2_RP_Ack,
--	
--				SFP_IICMaster_Request				=> '0',
--				SFP_IICMaster_Grant					=> OPEN,
--				SFP_IICMaster_Command				=> IO_IIC_CMD_NONE,
--				SFP_IICMaster_Status				=> OPEN,
--				SFP_IICMaster_Error					=> OPEN,
--				SFP_IICMaster_Address				=> (others => '0'),
--				SFP_IICMaster_WP_Valid			=> '0',
--				SFP_IICMaster_WP_Data				=> (others => '0'),
--				SFP_IICMaster_WP_Last				=> '0',
--				SFP_IICMaster_WP_Ack				=> OPEN,
--				SFP_IICMaster_RP_Valid			=> OPEN,
--				SFP_IICMaster_RP_Data				=> OPEN,
--				SFP_IICMaster_RP_Last				=> OPEN,
--				SFP_IICMaster_RP_Ack				=> '0',
--
--				PB_IICMaster_Request				=> SoFPGA_PBIIC1_Request,
--				PB_IICMaster_Grant					=> IICBus_PBIIC1_Grant,
--				PB_IICMaster_Command				=> SoFPGA_PBIIC1_Command,
--				PB_IICMaster_Status					=> IICBus_PBIIC1_Status,
--				PB_IICMaster_Error					=> IICBus_PBIIC1_Error,
--				PB_IICMaster_Address				=> SoFPGA_PBIIC1_Address,
--				PB_IICMaster_WP_Valid				=> SoFPGA_PBIIC1_WP_Valid,
--				PB_IICMaster_WP_Data				=> SoFPGA_PBIIC1_WP_Data,
--				PB_IICMaster_WP_Last				=> SoFPGA_PBIIC1_WP_Last,
--				PB_IICMaster_WP_Ack					=> IICBus_PBIIC1_WP_Ack,
--				PB_IICMaster_RP_Valid				=> IICBus_PBIIC1_RP_Valid,
--				PB_IICMaster_RP_Data				=> IICBus_PBIIC1_RP_Data,
--				PB_IICMaster_RP_Last				=> IICBus_PBIIC1_RP_Last,
--				PB_IICMaster_RP_Ack					=> SoFPGA_PBIIC1_RP_Ack,
--		
--				IIC_SerialClock_i						=> IIC_SerialClock_i,
--				IIC_SerialClock_o						=> IIC_SerialClock_o,
--				IIC_SerialClock_t						=> IIC_SerialClock_t,
--				IIC_SerialData_i						=> IIC_SerialData_i,
--				IIC_SerialData_o						=> IIC_SerialData_o,
--				IIC_SerialData_t						=> IIC_SerialData_t,
--				IICSwitch_Reset							=> IICSwitch_Reset
--			);
--	
--	end block;
end;
