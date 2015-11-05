-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- =============================================================================
-- Package:					TODO
--
-- Authors:					Patrick Lehmann
--
-- Description:
-- ------------------------------------
--		TODO
-- 
-- License:
-- =============================================================================
-- Copyright 2007-2014 Technische Universitaet Dresden - Germany
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
-- =============================================================================

LIBRARY	IEEE;
USE			IEEE.STD_LOGIC_1164.ALL;
USE			IEEE.NUMERIC_STD.ALL;

LIBRARY	UNISIM;
USE			UNISIM.VCOMPONENTS.ALL;

LIBRARY PoC;
USE			PoC.utils.ALL;
USE			PoC.physical.ALL;
USE			PoC.components.ALL;
USE			PoC.io.ALL;


ENTITY ClockNetwork_ML505 IS
	GENERIC (
		DEBUG										: BOOLEAN						:= FALSE;
		CLOCK_IN_FREQ						: FREQ							:= 100.0 MHz
	);
	PORT (
		ClockIn_200MHz					: IN	STD_LOGIC;

		ClockNetwork_Reset			: IN	STD_LOGIC;
		ClockNetwork_ResetDone	:	OUT	STD_LOGIC;
		
		Control_Clock_200MHz		: OUT	STD_LOGIC;
		
		Clock_200MHz						: OUT	STD_LOGIC;
		Clock_125MHz						: OUT	STD_LOGIC;
		Clock_100MHz						: OUT	STD_LOGIC;
		Clock_10MHz							: OUT	STD_LOGIC;

		Clock_Stable_200MHz			: OUT	STD_LOGIC;
		Clock_Stable_125MHz			: OUT	STD_LOGIC;
		Clock_Stable_100MHz			: OUT	STD_LOGIC;
		Clock_Stable_10MHz			: OUT	STD_LOGIC
	);
END;


ARCHITECTURE trl OF ClockNetwork_ML505 IS
	ATTRIBUTE KEEP											: BOOLEAN;
	ATTRIBUTE ASYNC_REG									: STRING;
	ATTRIBUTE SHREG_EXTRACT							: STRING;

	SIGNAL ClkNet_Reset									: STD_LOGIC;
	
	SIGNAL DCM_Reset										: STD_LOGIC;
	SIGNAL DCM_Reset_clr								: STD_LOGIC;
	SIGNAL DCM_Locked										: STD_LOGIC;
	SIGNAL DCM_Locked_async							: STD_LOGIC;

	SIGNAL Locked												: STD_LOGIC;
	SIGNAL Reset												: STD_LOGIC;
	
	SIGNAL Control_Clock								: STD_LOGIC;
	SIGNAL Control_Clock_BUFR						: STD_LOGIC;
	
	SIGNAL DCM_Clock_10MHz							: STD_LOGIC;
	SIGNAL DCM_Clock_100MHz							: STD_LOGIC;
	SIGNAL DCM_Clock_125MHz							: STD_LOGIC;
	SIGNAL DCM_Clock_200MHz							: STD_LOGIC;

	SIGNAL DCM_Clock_10MHz_BUFG					: STD_LOGIC;
	SIGNAL DCM_Clock_100MHz_BUFG				: STD_LOGIC;
	SIGNAL DCM_Clock_125MHz_BUFG				: STD_LOGIC;
	SIGNAL DCM_Clock_200MHz_BUFG				: STD_LOGIC;

	ATTRIBUTE KEEP OF DCM_Clock_10MHz_BUFG		: SIGNAL IS DEBUG;
	ATTRIBUTE KEEP OF DCM_Clock_100MHz_BUFG		: SIGNAL IS DEBUG;
	ATTRIBUTE KEEP OF DCM_Clock_125MHz_BUFG		: SIGNAL IS DEBUG;
	ATTRIBUTE KEEP OF DCM_Clock_200MHz_BUFG		: SIGNAL IS DEBUG;

BEGIN
-- ==================================================================
	-- ResetControl
	-- ==================================================================
	-- synchronize external (async) ClockNetwork_Reset and internal (but async) DCM_Locked signals to "Control_Clock" domain
	syncControlClock : ENTITY PoC.sync_Bits_Xilinx
		GENERIC MAP (
			BITS					=> 2										-- number of BITS to synchronize
		)
		PORT MAP (
			Clock					=> Control_Clock,				-- Clock to be synchronized to
			Input(0)			=> ClockNetwork_Reset,	-- Data to be synchronized
			Input(1)			=> DCM_Locked_async,		-- 
--			Input(2)			=> PLL_Locked_async,		-- 
			Output(0)			=> ClkNet_Reset,				-- synchronised data
			Output(1)			=> DCM_Locked--,					-- 
--			Output(2)			=> PLL_Locked						-- 
		);
	
	DCM_Reset_clr						<= ClkNet_Reset NOR DCM_Locked;
--	PLL_Reset_clr						<= ClkNet_Reset NOR PLL_Locked;
	
	--												RS-FF							Q										RST										SET														CLK
	DCM_Reset								<= ffrs(q => ClkNet_Reset,	rst => DCM_Reset_clr,	set => ClkNet_Reset) WHEN rising_edge(Control_Clock);
--	PLL_Reset								<= ffrs(q => PLL_Reset,			rst => PLL_Reset_clr,		set => ClkNet_Reset) WHEN rising_edge(Control_Clock);
	
	Locked									<= DCM_Locked;	-- AND PLL_Locked;
	Reset										<= NOT Locked;
	ClockNetwork_ResetDone	<= Locked;

	-- ==================================================================
	-- ClockBuffers
	-- ==================================================================
	-- Control_Clock
	BUFR_Control_Clock : BUFR
--		GENERIC MAP (
--			SIM_DEVICE	=> "7SERIES"
--		)
		PORT MAP (
			CE	=> '1',
			CLR	=> '0',
			I		=> ClockIn_200MHz,
			O		=> Control_Clock_BUFR
		);
	
	Control_Clock						<= Control_Clock_BUFR;
	
	-- 10 MHz BUFG
	BUFG_Clock_10MHz : BUFG
		PORT MAP (
			I		=> DCM_Clock_10MHz,
			O		=> DCM_Clock_10MHz_BUFG
		);

	-- 100 MHz BUFG
	BUFG_Clock_100MHz : BUFG
		PORT MAP (
			I		=> DCM_Clock_100MHz,
			O		=> DCM_Clock_100MHz_BUFG
		);

	-- 125 MHz BUFG
	BUFG_Clock_125MHz : BUFG
		PORT MAP (
			I		=> DCM_Clock_125MHz,
			O		=> DCM_Clock_125MHz_BUFG
		);
		
	-- 200 MHz BUFG
	BUFG_Clock_200MHz : BUFG
		PORT MAP (
			I		=> DCM_Clock_200MHz,
			O		=> DCM_Clock_200MHz_BUFG
		);
		
	-- ==================================================================
	-- Digital Clock Manager (DCM)
	-- ==================================================================
	System_DCM : DCM_BASE
		GENERIC MAP (
			DUTY_CYCLE_CORRECTION		=> TRUE,
			FACTORY_JF							=> x"F0F0",
			CLKIN_PERIOD						=> to_real(to_time(CLOCK_IN_FREQ), 1.0 ns),
			
			CLKDV_DIVIDE						=> 10.0,
			
			CLKFX_MULTIPLY					=> 5,
			CLKFX_DIVIDE						=> 4
		)
		PORT MAP (
			CLKIN										=> ClockIn_200MHz,
			CLKFB										=> DCM_Clock_100MHz_BUFG,
			
			RST											=> DCM_Reset,
			
			CLKDV										=> DCM_Clock_10MHz,
			
			CLK0										=> DCM_Clock_100MHz,
			CLK90										=> OPEN,
			CLK180									=> OPEN,
			CLK270									=> OPEN,
		
			CLK2X										=> DCM_Clock_200MHz,
			CLK2X180								=> OPEN,
			
			CLKFX										=> DCM_Clock_125MHz,
			CLKFX180								=> OPEN,
			
			LOCKED									=> DCM_Locked_async
		);
	
	Control_Clock_200MHz		<= Control_Clock_BUFR;
	Clock_200MHz			<= DCM_Clock_200MHz_BUFG;
	Clock_125MHz			<= DCM_Clock_125MHz_BUFG;
	Clock_100MHz			<= DCM_Clock_100MHz_BUFG;
	Clock_10MHz				<= DCM_Clock_10MHz_BUFG;
	
	-- synchronize internal Locked signal to ouput clock domains
	syncReset200MHz : ENTITY PoC.sync_Bits_Xilinx
		PORT MAP (
			Clock					=> DCM_Clock_200MHz_BUFG,		-- Clock to be synchronized to
			Input(0)			=> Locked,									-- Data to be synchronized
			Output(0)			=> Clock_Stable_200MHz			-- synchronised data
		);

	syncReset125MHz : ENTITY PoC.sync_Bits_Xilinx
		PORT MAP (
			Clock					=> DCM_Clock_125MHz_BUFG,		-- Clock to be synchronized to
			Input(0)			=> Locked,									-- Data to be synchronized
			Output(0)			=> Clock_Stable_125MHz			-- synchronised data
		);

	syncReset100MHz : ENTITY PoC.sync_Bits_Xilinx
		PORT MAP (
			Clock					=> DCM_Clock_100MHz_BUFG,		-- Clock to be synchronized to
			Input(0)			=> Locked,									-- Data to be synchronized
			Output(0)			=> Clock_Stable_100MHz			-- synchronised data
		);

	syncReset10MHz : ENTITY PoC.sync_Bits_Xilinx
		PORT MAP (
			Clock					=> DCM_Clock_10MHz_BUFG,		-- Clock to be synchronized to
			Input(0)			=> Locked,									-- Data to be synchronized
			Output(0)			=> Clock_Stable_10MHz				-- synchronised data
		);
END;
