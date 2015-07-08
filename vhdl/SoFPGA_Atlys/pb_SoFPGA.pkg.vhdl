-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- ============================================================================
-- Authors:					Patrick Lehmann
-- 
-- Package:					VHDL package to describe the SoFPGA AddressMapping structure
--									(PicoBlaze PortID to device register mapping).
--
-- Description:
-- ------------------------------------
--		For detailed documentation see below.
--
-- License:
-- ============================================================================
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
-- ============================================================================


library IEEE;
use			IEEE.NUMERIC_STD.all;
use			IEEE.STD_LOGIC_1164.all;
use			IEEE.STD_LOGIC_TEXTIO.all;

library	PoC;
use			PoC.utils.all;
use			PoC.vectors.all;
use			PoC.strings.all;

library L_PicoBlaze;
use			L_PicoBlaze.pb.all;
use			L_PicoBlaze.pb_Devices.all;


package pb_SoFPGA is
	-- ===========================================================================
	-- SoFPGA device list; bus affiliation; PortID to register number mapping
	-- ===========================================================================
	constant SOFPGA_SYSTEM : T_PB_SYSTEM := pb_CreateSystem(
		"SoFPGA", "System on FPGA",
		-- add connected busses to the system
		pb_ConnectBusses(
			C_PB_BUSSES &
			pb_CreateBus("Test",	"Test",		"Extern")
		), (
		-- add instantiated devices to the system							BusName		Start	KStart			Map		KMap	 Int	Comment
			pb_CreateDeviceInstance(PB_DEV_RESET,								"Intern",		 0,		0) &	-- 0..0		0..0				Reset
			pb_CreateDeviceInstance(PB_DEV_ROM,									"Intern",		 1,		1) &	-- 1..1		1..1				InstructionROM
			--																																					-- 2..3								------
			pb_CreateDeviceInstance(PB_DEV_INTERRUPT,						"Intern",		 4,		4) &	-- 4..7		4..7				InterruptController 16 ports
			pb_CreateDeviceInstance(PB_DEV_TIMER,								"Intern",		 8,		2) &	-- 8..11	2..2		*		Timer
			pb_CreateDeviceInstance(PB_DEV_CONVERTER_BCD24,			"Intern",		12		 ) &	-- 12..15					*		BCD2BIN converter 24 bit
			pb_CreateDeviceInstance(PB_DEV_MULTIPLIER32,				"Intern",		16		 ) &	-- 16..23							Multiplier 32 bit
			pb_CreateDeviceInstance(PB_DEV_DIVIDER32,						"Intern",		24		 ) &	-- 24..31					*		Divider 32 bit
			pb_CreateDeviceInstance(PB_DEV_GPIO,								"Intern",		40,		8) &	-- 40..41					*		General Perpose I/O
			pb_CreateDeviceInstance(PB_DEV_BIT_BANGING_IO8,			"Intern",		42,		9) &	-- 42..43					*		Bitbanging I/O 8 bit
--			pb_CreateDeviceInstance(PB_DEV_LCDISPLAY,						"Intern",		44,	 11 - 1) &	-- 44..45							LC-Display
			pb_CreateDeviceInstance(PB_DEV_UART,								"Intern",		46,	 12 - 1)	-- 46..47					*		UART
	--		pb_CreateDeviceInstance(PB_DEV_UARTSTREAM,					"Intern",		42) &				-- 40..47							
--			pb_CreateDeviceInstance(PB_DEV_IICCONTROLLER, 1,		"Intern",		48		 ) &	-- 48..51							I2C Controller 1
--			pb_CreateDeviceInstance(PB_DEV_IICCONTROLLER, 2,		"Intern",		52		 ) &	-- 52..55							I2C Controller 2
--			pb_CreateDeviceInstance(PB_DEV_MDIOCONTROLLER,			"Intern",		56) &				-- 56..59							MDIO Controller
--																																								-- 60..63							
--			pb_CreateDeviceInstance(PB_DEV_FREQM,								"Intern",		96		 ) &	-- 96..99							Frequency Measurement
--			pb_CreateDeviceInstance(PB_DEV_BCDCOUNTER,					"Intern",		100		 )		-- 100..103						BCD Counter
		)
	);
	
end package;


package body pb_SoFPGA is

end package body;
