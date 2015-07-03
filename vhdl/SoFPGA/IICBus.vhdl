-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- ============================================================================
-- Module:					I2C Bus
-- 
-- Authors:					Patrick Lehmann
--
-- Description:
-- ------------------------------------
--		TODO
--		
--
-- License:
-- ============================================================================
-- Copyright 2007-2014 Technische Universitaet Dresden - Germany,
--										 Chair for VLSI-Design, Diagnostics and Architecture
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
-- ============================================================================

LIBRARY IEEE;
USE			IEEE.STD_LOGIC_1164.ALL;
USE			IEEE.NUMERIC_STD.ALL;

LIBRARY PoC;
USE			PoC.config.ALL;
USE			PoC.utils.ALL;
USE			PoC.vectors.ALL;
USE			PoC.physical.ALL;
USE			PoC.io.ALL;


ENTITY IICBus IS
	GENERIC (
		DEBUG											: BOOLEAN																:= FALSE;
		CLOCK_FREQ								: FREQ																	:= 100.0 MHz
	);
	PORT (
		Clock											: IN	STD_LOGIC;
		Reset											: IN	STD_LOGIC;

		PUC_IICMaster_Request			: IN	STD_LOGIC;
		PUC_IICMaster_Grant				: OUT	STD_LOGIC;
		PUC_IICMaster_Command			: IN	T_IO_IIC_COMMAND;
		PUC_IICMaster_Status			: OUT	T_IO_IIC_STATUS;
		PUC_IICMaster_Error				: OUT	T_IO_IIC_ERROR;
		PUC_IICMaster_Address			: IN	STD_LOGIC_VECTOR(6 DOWNTO 0);
		PUC_IICMaster_WP_Valid		: IN	STD_LOGIC;
		PUC_IICMaster_WP_Data			: IN	T_SLV_8;
		PUC_IICMaster_WP_Last			: IN	STD_LOGIC;
		PUC_IICMaster_WP_Ack			: OUT	STD_LOGIC;
		PUC_IICMaster_RP_Valid		: OUT	STD_LOGIC;
		PUC_IICMaster_RP_Data			: OUT	T_SLV_8;
		PUC_IICMaster_RP_Last			: OUT	STD_LOGIC;
		PUC_IICMaster_RP_Ack			: IN	STD_LOGIC;

		SFP_IICMaster_Request			: IN	STD_LOGIC;
		SFP_IICMaster_Grant				: OUT	STD_LOGIC;
		SFP_IICMaster_Command			: IN	T_IO_IIC_COMMAND;
		SFP_IICMaster_Status			: OUT	T_IO_IIC_STATUS;
		SFP_IICMaster_Error				: OUT	T_IO_IIC_ERROR;
		SFP_IICMaster_Address			: IN	STD_LOGIC_VECTOR(6 DOWNTO 0);
		SFP_IICMaster_WP_Valid		: IN	STD_LOGIC;
		SFP_IICMaster_WP_Data			: IN	T_SLV_8;
		SFP_IICMaster_WP_Last			: IN	STD_LOGIC;
		SFP_IICMaster_WP_Ack			: OUT	STD_LOGIC;
		SFP_IICMaster_RP_Valid		: OUT	STD_LOGIC;
		SFP_IICMaster_RP_Data			: OUT	T_SLV_8;
		SFP_IICMaster_RP_Last			: OUT	STD_LOGIC;
		SFP_IICMaster_RP_Ack			: IN	STD_LOGIC;
		
		PB_IICMaster_Request			: IN	STD_LOGIC;
		PB_IICMaster_Grant				: OUT	STD_LOGIC;
		PB_IICMaster_Command			: IN	T_IO_IIC_COMMAND;
		PB_IICMaster_Status				: OUT	T_IO_IIC_STATUS;
		PB_IICMaster_Error				: OUT	T_IO_IIC_ERROR;
		PB_IICMaster_Address			: IN	STD_LOGIC_VECTOR(6 DOWNTO 0);
		PB_IICMaster_WP_Valid			: IN	STD_LOGIC;
		PB_IICMaster_WP_Data			: IN	T_SLV_8;
		PB_IICMaster_WP_Last			: IN	STD_LOGIC;
		PB_IICMaster_WP_Ack				: OUT	STD_LOGIC;
		PB_IICMaster_RP_Valid			: OUT	STD_LOGIC;
		PB_IICMaster_RP_Data			: OUT	T_SLV_8;
		PB_IICMaster_RP_Last			: OUT	STD_LOGIC;
		PB_IICMaster_RP_Ack				: IN	STD_LOGIC;

		IIC_SerialClock_i					: IN	STD_LOGIC;
		IIC_SerialClock_o					: OUT	STD_LOGIC;
		IIC_SerialClock_t					: OUT	STD_LOGIC;
		IIC_SerialData_i					: IN	STD_LOGIC;
		IIC_SerialData_o					: OUT	STD_LOGIC;
		IIC_SerialData_t					: OUT	STD_LOGIC;
		
		IICSwitch_Reset						: OUT	STD_LOGIC
	);
END;

ARCHITECTURE rtl OF IICBus IS
	ATTRIBUTE KEEP 											: BOOLEAN;

	CONSTANT IIC_BUSMODE								: T_IO_IIC_BUSMODE			:= IO_IIC_BUSMODE_STANDARDMODE;		-- 100 kHz
	
	CONSTANT IICBUS_ADDRESS_BITS				: POSITIVE			:= 7;
	CONSTANT IICBUS_DATA_BITS						: POSITIVE			:= 8;
	
	CONSTANT IICSWITCH_ADDRESS					: T_SLV_8				:= x"00";
	CONSTANT IICSWITCH_UNUSED_LIST			: T_NATVEC			:= (1, 2, 3, 5, 6, 7);
--		0 => 1,		1 => 2,		2 => 3,
--		3 => 5,		4 => 6,		5 => 7
--	);
	CONSTANT ADD_BYPASS_PORT						: BOOLEAN				:= TRUE;
	CONSTANT PORTS											: POSITIVE			:= 9;
	
	SIGNAL IICMasters_Request						: STD_LOGIC_VECTOR(PORTS - 1 DOWNTO 0);
	SIGNAL IICSwitch_Grant							: STD_LOGIC_VECTOR(PORTS - 1 DOWNTO 0);
	SIGNAL IICMasters_Command						: T_IO_IIC_COMMAND_VECTOR(PORTS - 1 DOWNTO 0);
	SIGNAL IICSwitch_Status							: T_IO_IIC_STATUS_VECTOR(PORTS - 1 DOWNTO 0);
	SIGNAL IICMasters_Error							: T_IO_IIC_ERROR_VECTOR(PORTS - 1 DOWNTO 0);
	SIGNAL IICMasters_Address						: T_SLM(PORTS - 1 DOWNTO 0, IICBUS_ADDRESS_BITS - 1 DOWNTO 0)		:= (OTHERS => (OTHERS => 'Z'));
	SIGNAL IICMasters_WP_Valid					: STD_LOGIC_VECTOR(PORTS - 1 DOWNTO 0);
	SIGNAL IICMasters_WP_Data						: T_SLM(PORTS - 1 DOWNTO 0, IICBUS_DATA_BITS - 1 DOWNTO 0)			:= (OTHERS => (OTHERS => 'Z'));
	SIGNAL IICMasters_WP_Last						: STD_LOGIC_VECTOR(PORTS - 1 DOWNTO 0);
	SIGNAL IICSwitch_WP_Ack							: STD_LOGIC_VECTOR(PORTS - 1 DOWNTO 0);
	SIGNAL IICSwitch_RP_Valid						: STD_LOGIC_VECTOR(PORTS - 1 DOWNTO 0);
	SIGNAL IICSwitch_RP_Data						: T_SLM(PORTS - 1 DOWNTO 0, IICBUS_DATA_BITS - 1 DOWNTO 0);--			:= (OTHERS => (OTHERS => 'Z'));
	SIGNAL IICSwitch_RP_Last						: STD_LOGIC_VECTOR(PORTS - 1 DOWNTO 0);
	SIGNAL IICMasters_RP_Ack						: STD_LOGIC_VECTOR(PORTS - 1 DOWNTO 0);
	
	SIGNAL IICSwitch_IICC_Request				: STD_LOGIC;
	SIGNAL IICC_IICSwitch_Grant					: STD_LOGIC;
	SIGNAL IICSwitch_IICC_Command				: T_IO_IIC_COMMAND;
	SIGNAL IICC_IICSwitch_Status				: T_IO_IIC_STATUS;
	SIGNAL IICC_IICSwitch_Error					: T_IO_IIC_ERROR;
	SIGNAL IICSWITCH_IICC_Address				: STD_LOGIC_VECTOR(IICBUS_ADDRESS_BITS - 1 DOWNTO 0);
	SIGNAL IICSwitch_IICC_Valid					: STD_LOGIC;
	SIGNAL IICSwitch_IICC_Data					: STD_LOGIC_VECTOR(IICBUS_DATA_BITS - 1 DOWNTO 0);
	SIGNAL IICSwitch_IICC_Last					: STD_LOGIC;
	SIGNAL IICC_IICSwitch_Ack						: STD_LOGIC;
	SIGNAL IICC_IICSwitch_Valid					: STD_LOGIC;
	SIGNAL IICC_IICSwitch_Data					: STD_LOGIC_VECTOR(IICBUS_DATA_BITS - 1 DOWNTO 0);
	SIGNAL IICC_IICSwitch_Last					: STD_LOGIC;
	SIGNAL IICSwitch_IICC_Ack						: STD_LOGIC;
	
BEGIN
	
	-- I2C 8-Channel Switch Ports
	-- ==========================================================================
	-- Port 0 - programmable user clock
	IICMasters_Request(0)			<= PUC_IICMaster_Request;
	PUC_IICMaster_Grant				<= IICSwitch_Grant(0);
	IICMasters_Command(0)			<= PUC_IICMaster_Command;
	PUC_IICMaster_Status			<= IICSwitch_Status(0);
	PUC_IICMaster_Error				<= IICMasters_Error(0);
	assign_row(IICMasters_Address, PUC_IICMaster_Address, 0);
	IICMasters_WP_Valid(0)		<= PUC_IICMaster_WP_Valid;
	assign_row(IICMasters_WP_Data, PUC_IICMaster_WP_Data, 0);
	IICMasters_WP_Last(0)			<= PUC_IICMaster_WP_Last;
	PUC_IICMaster_WP_Ack			<= IICSwitch_WP_Ack(0);
	PUC_IICMaster_RP_Valid		<= IICSwitch_RP_Valid(0);
	PUC_IICMaster_RP_Data			<= get_row(IICSwitch_RP_Data, 0);
	PUC_IICMaster_RP_Last			<= IICSwitch_RP_Last(0);
	IICMasters_RP_Ack(0)			<= PUC_IICMaster_RP_Ack;

	-- Port 4 - SFP+ cage
	IICMasters_Request(4)			<= SFP_IICMaster_Request;
	SFP_IICMaster_Grant				<= IICSwitch_Grant(4);
	IICMasters_Command(4)			<= SFP_IICMaster_Command;
	SFP_IICMaster_Status			<= IICSwitch_Status(4);
	SFP_IICMaster_Error				<= IICMasters_Error(4);
	assign_row(IICMasters_Address, SFP_IICMaster_Address, 4);
	IICMasters_WP_Valid(4)		<= SFP_IICMaster_WP_Valid;
	assign_row(IICMasters_WP_Data, SFp_IICMaster_WP_Data, 4);
	IICMasters_WP_Last(4)			<= SFP_IICMaster_WP_Last;
	SFP_IICMaster_WP_Ack			<= IICSwitch_WP_Ack(4);
	SFP_IICMaster_RP_Valid		<= IICSwitch_RP_Valid(4);
	SFP_IICMaster_RP_Data			<= get_row(IICSwitch_RP_Data, 4);
	SFP_IICMaster_RP_Last			<= IICSwitch_RP_Last(4);
	IICMasters_RP_Ack(4)			<= SFP_IICMaster_RP_Ack;

	-- Port 8 (bypass) - MicroControllerAdapter
	IICMasters_Request(8)			<= PB_IICMaster_Request;
	PB_IICMaster_Grant				<= IICSwitch_Grant(8);
	IICMasters_Command(8)			<= PB_IICMaster_Command;
	PB_IICMaster_Status				<= IICSwitch_Status(8);
	PB_IICMaster_Error				<= IICMasters_Error(8);
	assign_row(IICMasters_Address, PB_IICMaster_Address, 8);
	IICMasters_WP_Valid(8)		<= PB_IICMaster_WP_Valid;
	assign_row(IICMasters_WP_Data, PB_IICMaster_WP_Data, 8);
	IICMasters_WP_Last(8)			<= PB_IICMaster_WP_Last;
	PB_IICMaster_WP_Ack				<= IICSwitch_WP_Ack(8);
	PB_IICMaster_RP_Valid			<= IICSwitch_RP_Valid(8);
	PB_IICMaster_RP_Data			<= get_row(IICSwitch_RP_Data, 8);
	PB_IICMaster_RP_Last			<= IICSwitch_RP_Last(8);
	IICMasters_RP_Ack(8)			<= PB_IICMaster_RP_Ack;

	-- unused ports
	genUnused : FOR I IN IICSWITCH_UNUSED_LIST'range GENERATE
		IICMasters_Request(	IICSWITCH_UNUSED_LIST(I))		<= '0';
		IICMasters_Command(	IICSWITCH_UNUSED_LIST(I))		<= IO_IIC_CMD_NONE;
		IICMasters_WP_Valid(IICSWITCH_UNUSED_LIST(I))		<= '0';
		IICMasters_WP_Last(	IICSWITCH_UNUSED_LIST(I))		<= '0';
		IICMasters_RP_Ack(	IICSWITCH_UNUSED_LIST(I))		<= '0';
		
		assign_row(IICMasters_Address, (0 TO IICBUS_ADDRESS_BITS - 1 => '0'),	IICSWITCH_UNUSED_LIST(I));
		assign_row(IICMasters_WP_Data, (0 TO IICBUS_DATA_BITS - 1 => '0'),		IICSWITCH_UNUSED_LIST(I));
	END GENERATE;

	
	IICSwitch : ENTITY PoC.iic_IICSwitch_PCA9548A
		GENERIC MAP (
			DEBUG										=> DEBUG,
			ALLOW_MEALY_TRANSITION	=> FALSE,
			SWITCH_ADDRESS					=> IICSWITCH_ADDRESS,
			ADD_BYPASS_PORT					=> ADD_BYPASS_PORT,
			ADDRESS_BITS						=> IICBUS_ADDRESS_BITS,
			DATA_BITS								=> IICBUS_DATA_BITS
		)
		PORT MAP (
			Clock										=> Clock,
			Reset										=> Reset,
			
			-- IICSwitch interface ports
			Request									=> IICMasters_Request,
			Grant										=> IICSwitch_Grant,
			Command									=> IICMasters_Command,
			Status									=> IICSwitch_Status,
			Error										=> IICMasters_Error,
			Address									=> IICMasters_Address,
			WP_Valid								=> IICMasters_WP_Valid,
			WP_Data									=> IICMasters_WP_Data,
			WP_Last									=> IICMasters_WP_Last,
			WP_Ack									=> IICSwitch_WP_Ack,
			RP_Valid								=> IICSwitch_RP_Valid,
			RP_Data									=> IICSwitch_RP_Data,
			RP_Last									=> IICSwitch_RP_Last,
			RP_Ack									=> IICMasters_RP_Ack,
			
			-- IICController master interface
			IICC_Request						=> IICSwitch_IICC_Request,
			IICC_Grant							=> IICC_IICSwitch_Grant,
			IICC_Command						=> IICSwitch_IICC_Command,
			IICC_Status							=> IICC_IICSwitch_Status,
			IICC_Error							=> IICC_IICSwitch_Error,
			IICC_Address						=> IICSWITCH_IICC_Address,
			IICC_WP_Valid						=> IICSwitch_IICC_Valid,
			IICC_WP_Data						=> IICSwitch_IICC_Data,
			IICC_WP_Last						=> IICSwitch_IICC_Last,
			IICC_WP_Ack							=> IICC_IICSwitch_Ack,
			IICC_RP_Valid						=> IICC_IICSwitch_Valid,
			IICC_RP_Data						=> IICC_IICSwitch_Data,
			IICC_RP_Last						=> IICC_IICSwitch_Last,
			IICC_RP_Ack							=> IICSwitch_IICC_Ack,
			
			IICSwitch_Reset					=> IICSwitch_Reset
		);

	IICC : ENTITY PoC.iic_IICController
		GENERIC MAP (
			DEBUG													=> DEBUG,
			ALLOW_MEALY_TRANSITION				=> FALSE,
			CLOCK_FREQ										=> CLOCK_FREQ,
			IIC_BUSMODE										=> IIC_BUSMODE,
			IIC_ADDRESS										=> x"01",
			ADDRESS_BITS									=> IICBUS_ADDRESS_BITS,
			DATA_BITS											=> IICBUS_DATA_BITS
		)
		PORT MAP (
			Clock													=> Clock,
			Reset													=> Reset,

			-- IICController master interface
			Master_Request								=> IICSwitch_IICC_Request,
			Master_Grant									=> IICC_IICSwitch_Grant,
			Master_Command								=> IICSwitch_IICC_Command,
			Master_Status									=> IICC_IICSwitch_Status,
			Master_Error									=> IICC_IICSwitch_Error,
			
			Master_Address								=> IICSWITCH_IICC_Address,
			
			Master_WP_Valid								=> IICSwitch_IICC_Valid,
			Master_WP_Data								=> IICSwitch_IICC_Data,
			Master_WP_Last								=> IICSwitch_IICC_Last,
			Master_WP_Ack									=> IICC_IICSwitch_Ack,
			Master_RP_Valid								=> IICC_IICSwitch_Valid,
			Master_RP_Data								=> IICC_IICSwitch_Data,
			Master_RP_Last								=> IICC_IICSwitch_Last,
			Master_RP_Ack									=> IICSwitch_IICC_Ack,
			
			-- tristate interface
			SerialClock_i									=> IIC_SerialClock_i,
			SerialClock_o									=> IIC_SerialClock_o,
			SerialClock_t									=> IIC_SerialClock_t,
			SerialData_i									=> IIC_SerialData_i,
			SerialData_o									=> IIC_SerialData_o,
			SerialData_t									=> IIC_SerialData_t
		);

END;
