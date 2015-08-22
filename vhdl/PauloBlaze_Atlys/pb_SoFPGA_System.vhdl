-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- ============================================================================
-- Authors:					Patrick Lehmann
-- 
-- Module:					PicoBlaze System on FPGA (SoFPGA)
--
-- Description:
-- ------------------------------------
--		TODO
--		
--
-- License:
-- ============================================================================
-- Copyright 2007-2015 Technische Universitaet Dresden - Germany,
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

library IEEE;
use			IEEE.STD_LOGIC_1164.all;
use			IEEE.NUMERIC_STD.all;

library UNISIM;
use			UNISIM.VCOMPONENTS.all;

library PoC;
use			PoC.my_project.MY_PROJECT_NAME;
use			PoC.config.all;
use			PoC.utils.all;
use			PoC.vectors.all;
use			PoC.strings.all;
use			PoC.physical.all;
use			PoC.io.all;
use			PoC.xil.all;

library	L_PicoBlaze;
use			L_PicoBlaze.pb.all;

library L_PauloBlaze;

library L_Example;
use			L_Example.pb_SoFPGA.all;
--use			L_PicoBlaze.main_Page0_sim.all;


entity pb_SoFPGA_System is
	generic (
		DEBUG											: BOOLEAN												:= TRUE;
		CLOCK_FREQ								: FREQ													:= 100 MHz;
		EXTERNAL_DEVICE_COUNT			: NATURAL												:= 1;
		UART_BAUDRATE							: BAUD													:= 115200 Bd;
		ENABLE_JTAG_LOADER				: BOOLEAN												:= TRUE;
		ENABLE_SOFPGA_TRACER			: BOOLEAN												:= TRUE;
		ENABLE_UART_ILA						: BOOLEAN												:= FALSE
	);
	port (
		Clock											: in		STD_LOGIC;
		ClockStable								: in		STD_LOGIC;
		Reset											: in		STD_LOGIC;
		
		CSP_ICON_ControlBus_Trace	: inout	T_XIL_CHIPSCOPE_CONTROL;
		CSP_ICON_ControlBus_UART	: inout	T_XIL_CHIPSCOPE_CONTROL;
		CSP_Tracer_TriggerEvent		: out		STD_LOGIC;
		CSP_UART_TriggerEvent			: out		STD_LOGIC;

		PicoBlazeBusOut						: out		T_PB_IOBUS_PB_DEV_VECTOR(EXTERNAL_DEVICE_COUNT - 1 downto 0);
		PicoBlazeBusIn						: in		T_PB_IOBUS_DEV_PB_VECTOR(EXTERNAL_DEVICE_COUNT - 1 downto 0);
		
		UART_TX										: out		STD_LOGIC;
		UART_RX										: in		STD_LOGIC;
		
--		UARTFrame_TX_Valid				: out		STD_LOGIC;
--		UARTFrame_TX_Data					: out		T_SLV_8;
--		UARTFrame_TX_SOF					: out		STD_LOGIC;
--		UARTFrame_TX_EOF					: out		STD_LOGIC;
--		UARTFrame_TX_Ack					: in		STD_LOGIC;
--		
--		UARTFrame_RX_Valid				: in		STD_LOGIC;
--		UARTFrame_RX_Data					: in		T_SLV_8;
--		UARTFrame_RX_SOF					: in		STD_LOGIC;
--		UARTFrame_RX_EOF					: in		STD_LOGIC;
--		UARTFrame_RX_Ack					: out		STD_LOGIC;
		
		Raw_IIC_mux								: out		STD_LOGIC;
		Raw_IIC_Clock_i						: in		STD_LOGIC;
		Raw_IIC_Clock_t						: out		STD_LOGIC;
		Raw_IIC_Data_i						: in		STD_LOGIC;
		Raw_IIC_Data_t						: out		STD_LOGIC;
		Raw_IIC_Switch_Reset			: out		STD_LOGIC
		
--		-- IICController_IIC interface	
--		IIC1_Request							: out		STD_LOGIC;
--		IIC1_Grant								: in		STD_LOGIC;
--		
--		IIC1_Command							: out		T_IO_IIC_COMMAND;
--		IIC1_Status								: in		T_IO_IIC_STATUS;
--		IIC1_Error								: in		T_IO_IIC_ERROR;
--		
--		IIC1_Address							: out		STD_LOGIC_VECTOR(6 downto 0);
--		IIC1_WP_Valid							: out		STD_LOGIC;
--		IIC1_WP_Data							: out		T_SLV_8;
--		IIC1_WP_Last							: out		STD_LOGIC;
--		IIC1_WP_Ack								: in		STD_LOGIC;
--		IIC1_RP_Valid							: in		STD_LOGIC;
--		IIC1_RP_Data							: in		T_SLV_8;
--		IIC1_RP_Last							: in		STD_LOGIC;
--		IIC1_RP_Ack								: out		STD_LOGIC;
--		
--		-- IICController_IIC interface
--		IIC2_Request							: out		STD_LOGIC;
--		IIC2_Grant								: in		STD_LOGIC;
--		
--		IIC2_Command							: out		T_IO_IIC_COMMAND;
--		IIC2_Status								: in		T_IO_IIC_STATUS;
--		IIC2_Error								: in		T_IO_IIC_ERROR;
--		
--		IIC2_Address							: out		STD_LOGIC_VECTOR(6 downto 0);
--		IIC2_WP_Valid							: out		STD_LOGIC;
--		IIC2_WP_Data							: out		T_SLV_8;
--		IIC2_WP_Last							: out		STD_LOGIC;
--		IIC2_WP_Ack								: in		STD_LOGIC;
--		IIC2_RP_Valid							: in		STD_LOGIC;
--		IIC2_RP_Data							: in		T_SLV_8;
--		IIC2_RP_Last							: in		STD_LOGIC;
--		IIC2_RP_Ack								: out		STD_LOGIC
	);
end;


architecture rtl of pb_SoFPGA_System is
	attribute KEEP 											: BOOLEAN;

	constant PICOBLAZE_CLOCK_FREQ				: FREQ						:= CLOCK_FREQ;

	constant SOURCE_DIRECTORY						: STRING					:= PROJECT_DIR & "psm/" & MY_PROJECT_NAME & "/";
	constant ROM_PAGES									: POSITIVE				:= 2;

	constant ANY_PB_IOBUS_PORTS					: NATURAL					:= pb_GetBusWidth(SOFPGA_SYSTEM, "Any");
	constant INTERN_PB_IOBUS_PORTS			: NATURAL					:= pb_GetBusWidth(SOFPGA_SYSTEM, "Intern");
	constant EXTERN_PB_IOBUS_PORTS			: NATURAL					:= pb_GetBusWidth(SOFPGA_SYSTEM, "Extern");
	
	signal Any_PicoBlazeDeviceBus				: T_PB_IOBUS_PB_DEV_VECTOR(ANY_PB_IOBUS_PORTS - 1 downto 0)			:= (others => T_PB_IOBUS_PB_DEV_Z);
	signal Any_DevicePicoBlazeBus				: T_PB_IOBUS_DEV_PB_VECTOR(ANY_PB_IOBUS_PORTS - 1 downto 0)			:= (others => T_PB_IOBUS_DEV_PB_Z);
	signal Intern_PicoBlazeDeviceBus		: T_PB_IOBUS_PB_DEV_VECTOR(INTERN_PB_IOBUS_PORTS - 1 downto 0)	:= (others => T_PB_IOBUS_PB_DEV_Z);
	signal Intern_DevicePicoBlazeBus		: T_PB_IOBUS_DEV_PB_VECTOR(INTERN_PB_IOBUS_PORTS - 1 downto 0)	:= (others => T_PB_IOBUS_DEV_PB_Z);
	signal Extern_PicoBlazeDeviceBus		: T_PB_IOBUS_PB_DEV_VECTOR(EXTERN_PB_IOBUS_PORTS - 1 downto 0)	:= (others => T_PB_IOBUS_PB_DEV_Z);
	signal Extern_DevicePicoBlazeBus		: T_PB_IOBUS_DEV_PB_VECTOR(EXTERN_PB_IOBUS_PORTS - 1 downto 0)	:= (others => T_PB_IOBUS_DEV_PB_Z);

	signal SoFPGA_Reset									: STD_LOGIC;
	
	signal CPU_Clock										: STD_LOGIC;
	signal CPU_ClockStable							: STD_LOGIC;
	signal CPU_Reset										: STD_LOGIC;
	signal CPU_Reset_i									: STD_LOGIC;
	signal PB_Sleep											: STD_LOGIC;
	
	signal PB_InstructionFetch					: STD_LOGIC;
	signal PB_InstructionFetch_d				: STD_LOGIC				:= '0';
	signal PB_InstructionPointer				: T_SLV_12;
	
	signal PB_PortID										: T_SLV_8;
	signal PB_ReadStrobe								: STD_LOGIC;
	signal PB_WriteStrobe								: STD_LOGIC;
	signal PB_WriteStrobe_k							: STD_LOGIC;
	signal PB_DataIn										: T_SLV_8;
	signal PB_DataOut										: T_SLV_8;
	signal PB_Interrupt_Ack							: STD_LOGIC;
	attribute KEEP of PB_PortID					: signal is DEBUG;
	attribute KEEP of PB_ReadStrobe			: signal is DEBUG;
	attribute KEEP of PB_WriteStrobe		: signal is DEBUG;
	attribute KEEP of PB_DataIn					: signal is DEBUG;
	attribute KEEP of PB_DataOut				: signal is DEBUG;
	
	signal PicoBlazeDeviceBus						: T_PB_IOBUS_PB_DEV_VECTOR(ANY_PB_IOBUS_PORTS - 1 downto 0);
	
	-- Instruction ROM
	signal ROM_Instruction							: STD_LOGIC_VECTOR(17 downto 0);
	signal ROM_RebootCPU								: STD_LOGIC;
	signal DBG_PageNumber								: STD_LOGIC_VECTOR(2 downto 0);

	-- Interrupt Controller
	signal IntC_Interrupt								: STD_LOGIC;
		
	-- Reset Circuit
	signal UART_Reset										: STD_LOGIC;
	signal IICC1_Reset									: STD_LOGIC;
	signal IICC2_Reset									: STD_LOGIC;
	signal FreqM_Reset									: STD_LOGIC;

	signal CSP_Trigger									: STD_LOGIC;
	attribute KEEP of CSP_Trigger				: signal is TRUE;
	
	-- Accelerators
	signal Accelerator_Clear						: STD_LOGIC;

	-- UART
--	signal CSP_ICON_ControlBus_UART			: T_XIL_CHIPSCOPE_CONTROL;
	
begin
	CPU_Clock				<= Clock;
	CPU_ClockStable	<= ClockStable;
	CPU_Reset				<= Reset			or SoFPGA_Reset or not CPU_ClockStable;
	CPU_Reset_i			<= CPU_Reset	or ROM_RebootCPU;
	PB_Sleep				<= '0';

	genPico : if (TRUE) generate
	begin
	PicoBlaze : entity L_PicoBlaze.KCPSM6
		generic map (
			hwbuild									=> x"00",
			interrupt_vector				=> x"FE0",
			scratch_pad_memory_size => 256
		)
		port map (
			clk											=> CPU_Clock,
			reset										=> CPU_Reset_i,
			sleep										=> PB_Sleep,
		
			bram_enable							=> PB_InstructionFetch,
			address									=> PB_InstructionPointer,
			instruction							=> ROM_Instruction,

			port_id									=> PB_PortID,
			read_strobe							=> PB_ReadStrobe,
			write_strobe						=> PB_WriteStrobe,
			k_write_strobe					=> PB_WriteStrobe_k,
			out_port								=> PB_DataOut,
			in_port									=> PB_DataIn,

			interrupt								=> IntC_Interrupt,
			interrupt_ack						=> open
		);
	end generate;
	
	genPaulo : if (FALSE) generate
	begin
		PauloBlaze : entity L_PauloBlaze.PauloBlaze
			generic map (
				hwbuild									=> x"00",
				interrupt_vector				=> x"FE0",
				scratch_pad_memory_size => 256
			)
			port map (
				clk											=> CPU_Clock,
				reset										=> CPU_Reset_i,
				sleep										=> PB_Sleep,
			
				bram_enable							=> PB_InstructionFetch,
				address									=> PB_InstructionPointer,
				instruction							=> ROM_Instruction,

				port_id									=> PB_PortID,
				read_strobe							=> PB_ReadStrobe,
				write_strobe						=> PB_WriteStrobe,
				k_write_strobe					=> PB_WriteStrobe_k,
				out_port								=> PB_DataOut,
				in_port									=> PB_DataIn,

				interrupt								=> IntC_Interrupt,
				interrupt_ack						=> open
			);
	end generate;

	-- new interrupt ack signal on RETURNI instruction
	PB_InstructionFetch_d	<= PB_InstructionFetch when rising_edge(CPU_Clock);
	PB_Interrupt_Ack			<= PB_InstructionFetch_d and
												 (to_sl("00" & ROM_Instruction = x"29000") or
													to_sl("00" & ROM_Instruction = x"29001"));

	genPBDevBus : for i in Any_PicoBlazeDeviceBus'range generate
		Any_PicoBlazeDeviceBus(i).PortID				<= PB_PortID;
		Any_PicoBlazeDeviceBus(i).Data					<= PB_DataOut;
		Any_PicoBlazeDeviceBus(i).WriteStrobe		<= PB_WriteStrobe;
		Any_PicoBlazeDeviceBus(i).WriteStrobe_K	<= PB_WriteStrobe_K;
		Any_PicoBlazeDeviceBus(i).ReadStrobe		<= PB_ReadStrobe;
	end generate;
	
	Intern_PicoBlazeDeviceBus		<= pb_GetSubOrdinateBus(Any_PicoBlazeDeviceBus, SOFPGA_SYSTEM, "Intern");
	Extern_PicoBlazeDeviceBus		<= pb_GetSubOrdinateBus(Any_PicoBlazeDeviceBus, SOFPGA_SYSTEM, "Extern");
	
	PicoBlazeBusOut							<= Extern_PicoBlazeDeviceBus;
	Extern_DevicePicoBlazeBus		<= PicoBlazeBusIn;
	
	pb_AssignSubOrdinateBus(Any_DevicePicoBlazeBus, Intern_DevicePicoBlazeBus,	SOFPGA_SYSTEM, "Intern");
	pb_AssignSubOrdinateBus(Any_DevicePicoBlazeBus, Extern_DevicePicoBlazeBus,	SOFPGA_SYSTEM, "Extern");
	
--	genSim : IF SIMULATION GENERATE
--		signal PB_FunctionName	: T_PB_FUNCTIONS;
--	BEGIN
--		PB_FunctionName					<= InstructionPointer2FunctionName(PB_InstructionPointer);
--	END GENERATE;
	
	-- instruction ROM
	blkROM : block
		constant DEV_SHORT		: STRING								:= "InstROM";
		constant BUSINDEX			: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, DEV_SHORT);
		constant DEVICE_INST	: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, DEV_SHORT);
		
	begin
		ROM : entity L_PicoBlaze.pb_InstructionROM_Device
			generic map (
				PAGES								=> ROM_PAGES,
				SOURCE_DIRECTORY		=> SOURCE_DIRECTORY,
				DEVICE_INSTANCE			=> DEVICE_INST,
				ENABLE_JTAG_LOADER	=> ENABLE_JTAG_LOADER
			)
			port map (
				Clock								=> CPU_Clock,
				Fetch								=> PB_InstructionFetch,
				InstructionPointer	=> PB_InstructionPointer(11 downto 0),
				Instruction					=> ROM_Instruction,
				Reboot							=> ROM_RebootCPU,
				
				-- PicoBlaze interface
				Address							=> Intern_PicoBlazeDeviceBus(BUSINDEX).PortID,
				WriteStrobe					=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe,
				WriteStrobe_K				=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe_K,
				ReadStrobe					=> Intern_PicoBlazeDeviceBus(BUSINDEX).ReadStrobe,
				DataIn							=> Intern_PicoBlazeDeviceBus(BUSINDEX).Data,
				DataOut							=> Intern_DevicePicoBlazeBus(BUSINDEX).Data,
				
				Interrupt						=> Intern_DevicePicoBlazeBus(BUSINDEX).Interrupt,
				Interrupt_Ack				=> Intern_PicoBlazeDeviceBus(BUSINDEX).Interrupt_Ack,
				Message							=> Intern_DevicePicoBlazeBus(BUSINDEX).Message,
				
				PageNumber					=> DBG_PageNumber
			);
	end block;
	
	-- PB_DataIn multiplexer
	blkDataInMux : block
		function getDeviceMappingInBus(System : T_PB_SYSTEM; BusID : T_PB_BUSID) return T_NATVEC is
			variable BusIndex 		: NATURAL;
			variable Result				: T_NATVEC(0 to System.DeviceInstanceCount-1);
			variable CurBus				: T_PB_BUS := System.Busses(BusID);
			variable SubBusID			: T_PB_BUSID;
			variable SubResult		: T_NATVEC(0 to System.DeviceInstanceCount-1);
		begin
			BusIndex := 0;
			assert not PB_VERBOSE report "DEVINBUS: Enter " & integer'image(BusID) severity note;
			for i in 0 to CurBus.SubBusCount-1 loop
				SubBusID	:= CurBus.SubBusses(i);
				SubResult := getDeviceMappingInBus(System, SubBusID);
				for j in 0 to System.Busses(SubBusID).TotalDeviceCount-1 loop
					Result(BusIndex)	:= SubResult(j);
					assert not PB_VERBOSE report "DEVINBUS: Result(" & integer'image(BusIndex) & ") := " & integer'image(SubResult(j)) severity note;
					BusIndex 					:= BusIndex+1;
				end loop;
			end loop;
			
			for i in 0 to CurBus.DeviceCount-1 loop
				Result(BusIndex) 	:= CurBus.Devices(i); -- DeviceID
				assert not PB_VERBOSE report "DEVINBUS: Result(" & integer'image(BusIndex) & ") := " & integer'image(CurBus.Devices(i)) severity note;
				BusIndex 					:= BusIndex+1;
			end loop;
			
			assert not PB_VERBOSE report "DEVINBUS: Exit  " & integer'image(BusID) severity note;
			return Result;
		end function;
		
		function swapKeyValue(Input : T_NATVEC) return T_NATVEC is
			variable Result : T_NATVEC(Input'range);
		begin
			for i in Input'range loop
				Result(Input(i)) := i;
			end loop;
			return Result;
		end function;
		
		constant DevMappingInAnyBus 	: T_NATVEC := getDeviceMappingInBus(SoFPGA_System, 0);
		constant PositionInsideAnyBus : T_NATVEC := swapKeyValue(DevMappingInAnyBus);
			
		function 	toMuxVector(DevicePicoBlazeBus : T_PB_IOBUS_DEV_PB_VECTOR; System : T_PB_SYSTEM) return T_SLVV_8 is
			variable Result						: T_SLVV_8(127 downto 0)	:= (others => (others => '-'));
			variable DeviceInstance		: T_PB_DEVICE_INSTANCE;
			variable Mapping					: T_PB_PORTNUMBER_MAPPING;
		begin
			for i in 0 to System.DeviceInstanceCount - 1 loop
				DeviceInstance := System.DeviceInstances(i);
			
				for j in DeviceInstance.Mappings'range loop
					Mapping := DeviceInstance.Mappings(j);
					
					if (Mapping.MappingKind = PB_MAPPING_KIND_READ) then
						Result(Mapping.PortNumber) := DevicePicoBlazeBus(PositionInsideAnyBus(i)).Data;
						assert not PB_VERBOSE report "MUXIN: PortNumber = " & integer'image(Mapping.PortNumber) & ", AnyBusID = " & integer'image(PositionInsideAnyBus(i)) severity note;
					end if;
				end loop;
			end loop;

			return Result;
		end function;
	
		signal DataIn_MuxVector			: T_SLVV_8(127 downto 0);
		
	begin
		DataIn_MuxVector		<= toMuxVector(Any_DevicePicoBlazeBus, SOFPGA_SYSTEM);

		process(CPU_Clock)
		begin
			if rising_edge(CPU_Clock) then
				PB_DataIn				<= DataIn_MuxVector(to_index(PB_PortID(log2ceilnz(DataIn_MuxVector'length) - 1 downto 0)));
			end if;
		end process;
	end block;
	
	genCSP : if (ENABLE_SOFPGA_TRACER = TRUE) generate
		signal Tracer_DataIn			: STD_LOGIC_VECTOR(62 downto 0);
		signal Tracer_Trigger0		: STD_LOGIC_VECTOR(14 downto 0);
		signal Tracer_Trigger1		: T_SLV_8;
		signal Tracer_Trigger2		: STD_LOGIC_VECTOR(5 downto 0);
		signal Tracer_Trigger3		: T_SLV_16;
		
		signal Tracer_DataIn_d		: STD_LOGIC_VECTOR(62 downto 0)			:= (others => '0');
		signal Tracer_Trigger0_d	: STD_LOGIC_VECTOR(14 downto 0)			:= (others => '0');
		signal Tracer_Trigger1_d	: T_SLV_8														:= (others => '0');
		signal Tracer_Trigger2_d	: STD_LOGIC_VECTOR(5 downto 0)			:= (others => '0');
		signal Tracer_Trigger3_d	: T_SLV_16													:= (others => '0');
		
	begin
		Tracer_DataIn(11 downto	 0)		<= PB_InstructionPointer;
		Tracer_DataIn(29 downto 12)		<= ROM_Instruction;
		Tracer_DataIn(37 downto 30)		<= PB_PortID;
		Tracer_DataIn(45 downto 38)		<= PB_DataOut;
		Tracer_DataIn(53 downto 46)		<= PB_DataIn;
		Tracer_DataIn(54)							<= PB_WriteStrobe;
		Tracer_DataIn(55)							<= PB_WriteStrobe_K;
		Tracer_DataIn(56)							<= PB_ReadStrobe;
		Tracer_DataIn(57)							<= IntC_Interrupt;
		Tracer_DataIn(58)							<= ROM_RebootCPU;
		Tracer_DataIn(59)							<= CSP_Trigger;
		Tracer_DataIn(62 downto 60)		<= DBG_PageNumber(2 downto 0);
		
		Tracer_Trigger0(11 downto 0)	<= PB_InstructionPointer;
		Tracer_Trigger0(14 downto 12)	<= DBG_PageNumber(2 downto 0);
		Tracer_Trigger1								<= PB_PortID;
		Tracer_Trigger2(0)						<= PB_WriteStrobe;
		Tracer_Trigger2(1)						<= PB_WriteStrobe_K;
		Tracer_Trigger2(2)						<= PB_ReadStrobe;
		Tracer_Trigger2(3)						<= IntC_Interrupt;
		Tracer_Trigger2(4)						<= ROM_RebootCPU;
		Tracer_Trigger2(5)						<= CSP_Trigger;
		Tracer_Trigger3(7	 downto 0)	<= PB_DataOut;
		Tracer_Trigger3(15 downto 8)	<= PB_DataIn;
		
		Tracer_DataIn_d			<= Tracer_DataIn		when rising_edge(CPU_Clock);
		Tracer_Trigger0_d		<= Tracer_Trigger0	when rising_edge(CPU_Clock);
		Tracer_Trigger1_d		<= Tracer_Trigger1	when rising_edge(CPU_Clock);
		Tracer_Trigger2_d		<= Tracer_Trigger2	when rising_edge(CPU_Clock);
		Tracer_Trigger3_d		<= Tracer_Trigger3	when rising_edge(CPU_Clock);
		
		Tracer : entity L_PicoBlaze.CSP_PB_Tracer_ILA
			port map (
				CONTROL		=> CSP_ICON_ControlBus_Trace,
				CLK				=> CPU_Clock,
				DATA			=> Tracer_DataIn_d,
				TRIG0			=> Tracer_Trigger0_d,
				TRIG1			=> Tracer_Trigger1_d,
				TRIG2			=> Tracer_Trigger2_d,
				TRIG3			=> Tracer_Trigger3_d,
				TRIG_OUT	=> CSP_Tracer_TriggerEvent
			);
	end generate;
	
	-- Reset registers
	blkReset : block
		constant DEV_SHORT				: STRING								:= "Reset";
		constant BUSINDEX					: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, DEV_SHORT);
		constant DEVICE_INSTANCE	: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, DEV_SHORT);
		
		signal AdrDec_we							: STD_LOGIC;
		signal AdrDec_re							: STD_LOGIC;
		signal AdrDec_WriteAddress		: T_SLV_8;
		signal AdrDec_ReadAddress			: T_SLV_8;
		signal AdrDec_Data						: T_SLV_8;
	
		signal Reset_d								: T_SLV_8		:= (others => '0');
		
	begin
		AdrDec : entity L_PicoBlaze.PicoBlaze_AddressDecoder
			generic map (
				DEVICE_NAME				=> str_trim(DEVICE_INSTANCE.DeviceShort),
				BUS_NAME					=> str_trim(DEVICE_INSTANCE.BusShort),
				READ_MAPPINGS			=> pb_FilterMappings(DEVICE_INSTANCE, PB_MAPPING_KIND_READ),
				WRITE_MAPPINGS		=> pb_FilterMappings(DEVICE_INSTANCE, PB_MAPPING_KIND_WRITE),
				WRITEK_MAPPINGS		=> pb_FilterMappings(DEVICE_INSTANCE, PB_MAPPING_KIND_WRITEK)
			)
			port map (
				Clock							=> CPU_Clock,
				Reset							=> CPU_Reset_i,

				-- PicoBlaze interface
				In_WriteStrobe		=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe,
				In_WriteStrobe_K	=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe_K,
				In_ReadStrobe			=> Intern_PicoBlazeDeviceBus(BUSINDEX).ReadStrobe,
				In_Address				=> Intern_PicoBlazeDeviceBus(BUSINDEX).PortID,
				In_Data						=> Intern_PicoBlazeDeviceBus(BUSINDEX).Data,
				Out_WriteStrobe		=> AdrDec_we,
				Out_ReadStrobe		=> open,		--AdrDec_re,
				Out_WriteAddress	=> open,		--AdrDec_WriteAddress,
				Out_ReadAddress		=> open,		--AdrDec_ReadAddress,
				Out_Data					=> AdrDec_Data
			);
		
		Intern_DevicePicoBlazeBus(BUSINDEX).Interrupt		<= '0';
		Intern_DevicePicoBlazeBus(BUSINDEX).Message			<= x"00";
	
		process(CPU_Clock)
		begin
			if rising_edge(CPU_Clock) then
				if (AdrDec_we = '1') then
					Reset_d			<= AdrDec_Data;
				else
					Reset_d			<= (others => '0');
				end if;
			end if;
		end process;
		
		Accelerator_Clear		<= Reset_d(0);
		UART_Reset					<= Reset_d(1);
--		free								<= Reset_d(2);
		IICC1_Reset					<= Reset_d(3);
		IICC2_Reset					<= Reset_d(3);
--		free								<= Reset_d(4);
--		free								<= Reset_d(5);
		SoFPGA_Reset				<= Reset_d(6);
		CSP_Trigger					<= Reset_d(7);
	end block;
	
	-- interrupt controller
	blkInterrupt : block
		constant DEV_SHORT		: STRING								:= "IntC";
		constant BUSINDEX			: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, DEV_SHORT);
		constant DEVICE_INST	: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, DEV_SHORT);
		constant INTC_PORTS		: POSITIVE							:= pb_GetInterruptCount(SOFPGA_SYSTEM);

		signal Interrupt_Vector			: STD_LOGIC_VECTOR(INTC_PORTS - 1 downto 0);
		signal Interrupt_Messages		: T_SLVV_8(INTC_PORTS - 1 downto 0);
		signal IntC_Interrupt_Ack		: STD_LOGIC_VECTOR(INTC_PORTS - 1 downto 0);
		
	begin
		IntC : entity L_PicoBlaze.pb_InterruptController_Device
			generic map (
				DEBUG									=> DEBUG,
				DEVICE_INSTANCE				=> DEVICE_INST,
				PORTS									=> INTC_PORTS
			)
			port map (
				Clock									=> CPU_Clock,
				Reset									=> CPU_Reset_i,
				
				-- PicoBlaze interface
				Address								=> Intern_PicoBlazeDeviceBus(BUSINDEX).PortID,
				WriteStrobe						=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe,
				WriteStrobe_K					=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe_K,
				ReadStrobe						=> Intern_PicoBlazeDeviceBus(BUSINDEX).ReadStrobe,
				DataIn								=> Intern_PicoBlazeDeviceBus(BUSINDEX).Data,
				DataOut								=> Intern_DevicePicoBlazeBus(BUSINDEX).Data,
				
				Interrupt							=> Intern_DevicePicoBlazeBus(BUSINDEX).Interrupt,
				Interrupt_Ack					=> Intern_PicoBlazeDeviceBus(BUSINDEX).Interrupt_Ack,
				Message								=> Intern_DevicePicoBlazeBus(BUSINDEX).Message,
				
				-- PicoBlaze interrupt interface (direct coupled)
				PB_Interrupt					=> IntC_Interrupt,
				PB_Interrupt_Ack			=> PB_Interrupt_Ack,
				
				-- Interrupt source interface
				Dev_Interrupt					=> Interrupt_Vector,
				Dev_Interrupt_Ack			=> IntC_Interrupt_Ack,
				Dev_Interrupt_Message	=> Interrupt_Messages
			);
		
		-- wire PicoBlaze bus 'any' to the InterruptController
		Interrupt_Vector		<= pb_GetInterruptVector(Any_DevicePicoBlazeBus, SOFPGA_SYSTEM);
		Interrupt_Messages	<= pb_GetInterruptMessages(Any_DevicePicoBlazeBus, SOFPGA_SYSTEM);
		pb_AssignInterruptAck(Any_PicoBlazeDeviceBus, IntC_Interrupt_Ack, SOFPGA_SYSTEM);
	end block;

--	blkTimer : block
--		constant DEV_SHORT		: STRING								:= "Timer";
--		constant BUSINDEX			: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, DEV_SHORT);
--		constant DEVICE_INST	: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, DEV_SHORT);
--	
--	begin
--		Timer : entity L_PicoBlaze.pb_Timer
--			generic map (
--				DEVICE_INSTANCE			=> DEVICE_INST
--			)
--			port map (
--				Clock								=> CPU_Clock,
--				Reset								=> CPU_Reset_i,
--				
--				-- PicoBlaze interface
--				Address							=> Intern_PicoBlazeDeviceBus(BUSINDEX).PortID,
--				WriteStrobe					=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe,
--				WriteStrobe_K				=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe_K,
--				ReadStrobe					=> Intern_PicoBlazeDeviceBus(BUSINDEX).ReadStrobe,
--				DataIn							=> Intern_PicoBlazeDeviceBus(BUSINDEX).Data,
--				DataOut							=> Intern_DevicePicoBlazeBus(BUSINDEX).Data,
--				
--				Interrupt						=> Intern_DevicePicoBlazeBus(BUSINDEX).Interrupt,
--				Interrupt_Ack				=> Intern_PicoBlazeDeviceBus(BUSINDEX).Interrupt_Ack,
--				Message							=> Intern_DevicePicoBlazeBus(BUSINDEX).Message,
--				
--				EventIn							=> "00001"
--			);
--	end block;

	blkAccellerator : block
		constant MULT_SHORT					: STRING								:= "Mult32";
		constant MULT_BUSINDEX			: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, MULT_SHORT);
		constant MULT_DEVICE_INST		: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, MULT_SHORT);
		
		constant DIV_SHORT					: STRING								:= "Div32";
		constant DIV_BUSINDEX				: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, DIV_SHORT);
		constant DIV_DEVICE_INST		: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, DIV_SHORT);
		
		constant BCD_SHORT					: STRING								:= "ConvBCD24";
		constant BCD_BUSINDEX				: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, BCD_SHORT);
		constant BCD_DEVICE_INST		: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, BCD_SHORT);

		signal Mult_Reset						: STD_LOGIC;
		signal Div_Reset						: STD_LOGIC;
		signal BCD_Reset						: STD_LOGIC;

	begin
		Mult_Reset		<= CPU_Reset or Accelerator_Clear;
		Div_Reset			<= CPU_Reset or Accelerator_Clear;
		BCD_Reset			<= CPU_Reset or Accelerator_Clear;

		Mult : entity L_PicoBlaze.pb_Multiplier_Device
			generic map (
				DEVICE_INSTANCE			=> MULT_DEVICE_INST,
				BITS								=> 32
			)
			port map (
				Clock								=> CPU_Clock,
				Reset								=> Mult_Reset,
				
				-- PicoBlaze interface
				Address							=> Intern_PicoBlazeDeviceBus(MULT_BUSINDEX).PortID,
				WriteStrobe					=> Intern_PicoBlazeDeviceBus(MULT_BUSINDEX).WriteStrobe,
				WriteStrobe_K				=> Intern_PicoBlazeDeviceBus(MULT_BUSINDEX).WriteStrobe_K,
				ReadStrobe					=> Intern_PicoBlazeDeviceBus(MULT_BUSINDEX).ReadStrobe,
				DataIn							=> Intern_PicoBlazeDeviceBus(MULT_BUSINDEX).Data,
				DataOut							=> Intern_DevicePicoBlazeBus(MULT_BUSINDEX).Data,
				
				Interrupt						=> Intern_DevicePicoBlazeBus(MULT_BUSINDEX).Interrupt,
				Interrupt_Ack				=> Intern_PicoBlazeDeviceBus(MULT_BUSINDEX).Interrupt_Ack,
				Message							=> Intern_DevicePicoBlazeBus(MULT_BUSINDEX).Message
			);
	
		Div : entity L_PicoBlaze.pb_Divider_Device
			generic map (
				DEVICE_INSTANCE			=> DIV_DEVICE_INST,
				BITS								=> 32
			)
			port map (
				Clock								=> CPU_Clock,
				Reset								=> Div_Reset,
				
				-- PicoBlaze interface
				Address							=> Intern_PicoBlazeDeviceBus(DIV_BUSINDEX).PortID,
				WriteStrobe					=> Intern_PicoBlazeDeviceBus(DIV_BUSINDEX).WriteStrobe,
				WriteStrobe_K				=> Intern_PicoBlazeDeviceBus(DIV_BUSINDEX).WriteStrobe_K,
				ReadStrobe					=> Intern_PicoBlazeDeviceBus(DIV_BUSINDEX).ReadStrobe,
				DataIn							=> Intern_PicoBlazeDeviceBus(DIV_BUSINDEX).Data,
				DataOut							=> Intern_DevicePicoBlazeBus(DIV_BUSINDEX).Data,
				
				Interrupt						=> Intern_DevicePicoBlazeBus(DIV_BUSINDEX).Interrupt,
				Interrupt_Ack				=> Intern_PicoBlazeDeviceBus(DIV_BUSINDEX).Interrupt_Ack,
				Message							=> Intern_DevicePicoBlazeBus(DIV_BUSINDEX).Message
			);

		ConvBCD : entity L_PicoBlaze.pb_ConverterBCD24_Device
			generic map (
				DEVICE_INSTANCE			=> BCD_DEVICE_INST
			)
			port map (
				Clock								=> CPU_Clock,
				Reset								=> BCD_Reset,
				
				-- PicoBlaze interface
				Address							=> Intern_PicoBlazeDeviceBus(BCD_BUSINDEX).PortID,
				WriteStrobe					=> Intern_PicoBlazeDeviceBus(BCD_BUSINDEX).WriteStrobe,
				WriteStrobe_K				=> Intern_PicoBlazeDeviceBus(BCD_BUSINDEX).WriteStrobe_K,
				ReadStrobe					=> Intern_PicoBlazeDeviceBus(BCD_BUSINDEX).ReadStrobe,
				DataIn							=> Intern_PicoBlazeDeviceBus(BCD_BUSINDEX).Data,
				DataOut							=> Intern_DevicePicoBlazeBus(BCD_BUSINDEX).Data,
				
				Interrupt						=> Intern_DevicePicoBlazeBus(BCD_BUSINDEX).Interrupt,
				Interrupt_Ack				=> Intern_PicoBlazeDeviceBus(BCD_BUSINDEX).Interrupt_Ack,
				Message							=> Intern_DevicePicoBlazeBus(BCD_BUSINDEX).Message
			);
	end block;

	blkGPIO : block
		constant DEV_SHORT		: STRING								:= "GPIO";
		constant BUSINDEX			: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, DEV_SHORT);
		constant DEVICE_INST	: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, DEV_SHORT);
	
		signal GPIO_DataIn	: T_SLV_8;
		signal GPIO_DataOut	: T_SLV_8;
		
	begin
		GPIO : entity L_PicoBlaze.pb_GPIO_Adapter
			generic map (
				DEVICE_INSTANCE			=> DEVICE_INST
			)
			port map (
				Clock								=> CPU_Clock,
				Reset								=> '0',
				
				-- PicoBlaze interface
				Address							=> Intern_PicoBlazeDeviceBus(BUSINDEX).PortID,
				WriteStrobe					=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe,
				WriteStrobe_K				=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe_K,
				ReadStrobe					=> Intern_PicoBlazeDeviceBus(BUSINDEX).ReadStrobe,
				DataIn							=> Intern_PicoBlazeDeviceBus(BUSINDEX).Data,
				DataOut							=> Intern_DevicePicoBlazeBus(BUSINDEX).Data,
				
				Interrupt						=> Intern_DevicePicoBlazeBus(BUSINDEX).Interrupt,
				Interrupt_Ack				=> Intern_PicoBlazeDeviceBus(BUSINDEX).Interrupt_Ack,
				Message							=> Intern_DevicePicoBlazeBus(BUSINDEX).Message,
				
				GPIO_Out						=> GPIO_DataOut,
				GPIO_In							=> GPIO_DataIn
			);
		
		GPIO_DataIn						<= x"00";
		
--		Raw_LCD_mux						<= GPIO_DataOut(0);
--		Raw_UART_mux					<= GPIO_DataOut(1);
		Raw_IIC_mux						<= GPIO_DataOut(2);
		
		Raw_IIC_Switch_Reset	<= GPIO_DataOut(7);
	end block;
	
	blkBBIO : block
		constant DEV_SHORT				: STRING								:= "BBIO8";
		constant BUSINDEX					: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, DEV_SHORT);
		constant DEVICE_INST			: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, DEV_SHORT);
		
		constant BBID_IIC_CLOCK		: NATURAL								:= 0;
		constant BBID_IIC_DATA		: NATURAL								:= 1;
		constant BITS							: POSITIVE							:= 2;
		
		constant INITIAL_VALUE		: STD_LOGIC_VECTOR(BITS - 1 downto 0) := (
			BBID_IIC_CLOCK =>	'1',	-- set IIC Clock to Tri-State by default (-> Pullup, Idle state)
			BBID_IIC_DATA =>	'1',	-- set IIC Data  to Tri-State by default (-> Pullup, Idle state)
			others =>					'0'
		);
		
		signal BBIO_DataIn				: STD_LOGIC_VECTOR(BITS - 1 downto 0);
		signal BBIO_DataOut				: STD_LOGIC_VECTOR(BITS - 1 downto 0);
		
	begin
		BBIO : entity L_PicoBlaze.pb_BitBangingIO_Device
			generic map (
				DEVICE_INSTANCE			=> DEVICE_INST,
				BITS								=> BITS,
				INITIAL_VALUE				=> INITIAL_VALUE
			)
			port map (
				Clock								=> CPU_Clock,
				Reset								=> CPU_Reset,
				
				-- PicoBlaze interface
				Address							=> Intern_PicoBlazeDeviceBus(BUSINDEX).PortID,
				WriteStrobe					=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe,
				WriteStrobe_K				=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe_K,
				ReadStrobe					=> Intern_PicoBlazeDeviceBus(BUSINDEX).ReadStrobe,
				DataIn							=> Intern_PicoBlazeDeviceBus(BUSINDEX).Data,
				DataOut							=> Intern_DevicePicoBlazeBus(BUSINDEX).Data,
				
				Interrupt						=> Intern_DevicePicoBlazeBus(BUSINDEX).Interrupt,
				Interrupt_Ack				=> Intern_PicoBlazeDeviceBus(BUSINDEX).Interrupt_Ack,
				Message							=> Intern_DevicePicoBlazeBus(BUSINDEX).Message,
				
				BBIO_Out						=> BBIO_DataOut,
				BBIO_In							=> BBIO_DataIn
			);
		
		BBIO_DataIn(BBID_IIC_CLOCK)		<= Raw_IIC_Clock_i;
		BBIO_DataIn(BBID_IIC_DATA)		<= Raw_IIC_Data_i;
		
		Raw_IIC_Clock_t								<= BBIO_DataOut(BBID_IIC_CLOCK);
		Raw_IIC_Data_t								<= BBIO_DataOut(BBID_IIC_DATA);
	end block;
	
	blkUART : block
		constant DEV_SHORT		: STRING								:= "UART";
		constant BUSINDEX			: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, DEV_SHORT);
		constant DEVICE_INST	: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, DEV_SHORT);
	begin
		UART : entity L_PicoBlaze.pb_UART_Wrapper
			generic map (
				DEBUG								=> DEBUG,
				ENABLE_CHIPSCOPE		=> ENABLE_UART_ILA,
				CLOCK_FREQ					=> CLOCK_FREQ,
				DEVICE_INSTANCE			=> DEVICE_INST,
				BAUDRATE						=> UART_BAUDRATE
			)
			port map (
				Clock								=> CPU_Clock,
				Reset								=> UART_Reset,
				
				-- PicoBlaze interface
				Address							=> Intern_PicoBlazeDeviceBus(BUSINDEX).PortID,
				WriteStrobe					=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe,
				WriteStrobe_K				=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe_K,
				ReadStrobe					=> Intern_PicoBlazeDeviceBus(BUSINDEX).ReadStrobe,
				DataIn							=> Intern_PicoBlazeDeviceBus(BUSINDEX).Data,
				DataOut							=> Intern_DevicePicoBlazeBus(BUSINDEX).Data,
				
				Interrupt						=> Intern_DevicePicoBlazeBus(BUSINDEX).Interrupt,
				Interrupt_Ack				=> Intern_PicoBlazeDeviceBus(BUSINDEX).Interrupt_Ack,
				Message							=> Intern_DevicePicoBlazeBus(BUSINDEX).Message,
				
				ICON_ControlBus			=> CSP_ICON_ControlBus_UART,
				
				UART_TX							=> UART_TX,
				UART_RX							=> UART_RX
			);
	end block;
	
--	blkIIC : block
--		constant IICC1_DEV_SHORT		: STRING								:= "IICCtrl1";
--		constant IICC1_BUSINDEX			: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, IICC1_DEV_SHORT);
--		constant IICC1_DEVICE_INST	: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, IICC1_DEV_SHORT);
--		
--		constant IICC2_DEV_SHORT		: STRING								:= "IICCtrl2";
--		constant IICC2_BUSINDEX			: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, IICC2_DEV_SHORT);
--		constant IICC2_DEVICE_INST	: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, IICC2_DEV_SHORT);
--	begin
--		IICC1 : entity L_PicoBlaze.pb_IICController_Adapter
--			generic map (
--				DEBUG										=> DEBUG,
--				ALLOW_MEALY_TRANSITION	=> FALSE,
--				DEVICE_INSTANCE					=> IICC1_DEVICE_INST
--			)
--			port map(
--				Clock									=> CPU_Clock,
--				Reset									=> IICC1_Reset,
--
--				-- PicoBlaze interface
--				Address								=> Intern_PicoBlazeDeviceBus(IICC1_BUSINDEX).PortID,
--				WriteStrobe						=> Intern_PicoBlazeDeviceBus(IICC1_BUSINDEX).WriteStrobe,
--				WriteStrobe_K					=> Intern_PicoBlazeDeviceBus(IICC1_BUSINDEX).WriteStrobe_K,
--				ReadStrobe						=> Intern_PicoBlazeDeviceBus(IICC1_BUSINDEX).ReadStrobe,
--				DataIn								=> Intern_PicoBlazeDeviceBus(IICC1_BUSINDEX).Data,
--				DataOut								=> Intern_DevicePicoBlazeBus(IICC1_BUSINDEX).Data,
--
--				Interrupt							=> Intern_DevicePicoBlazeBus(IICC1_BUSINDEX).Interrupt,
--				Interrupt_Ack					=> Intern_PicoBlazeDeviceBus(IICC1_BUSINDEX).Interrupt_Ack,
--				Message								=> Intern_DevicePicoBlazeBus(IICC1_BUSINDEX).Message,
--
--				-- IICController_IIC interface
--				IIC_Request						=> IIC1_Request,
--				IIC_Grant							=> IIC1_Grant,
--			
--				IIC_Command						=> IIC1_Command,
--				IIC_Status						=> IIC1_Status,
--				IIC_Error							=> IIC1_Error,
--
--				IIC_Address						=> IIC1_Address,
--				IIC_WP_Valid					=> IIC1_WP_Valid,
--				IIC_WP_Data						=> IIC1_WP_Data,
--				IIC_WP_Last						=> IIC1_WP_Last,
--				IIC_WP_Ack						=> IIC1_WP_Ack,
--				IIC_RP_Valid					=> IIC1_RP_Valid,
--				IIC_RP_Data						=> IIC1_RP_Data,
--				IIC_RP_Last						=> IIC1_RP_Last,
--				IIC_RP_Ack						=> IIC1_RP_Ack
--			);
--
--		IICC2 : entity L_PicoBlaze.pb_IICController_Adapter
--			generic map (
--				DEBUG										=> DEBUG,
--				ALLOW_MEALY_TRANSITION	=> FALSE,
--				DEVICE_INSTANCE					=> IICC2_DEVICE_INST
--			)
--			port map(
--				Clock									=> CPU_Clock,
--				Reset									=> IICC2_Reset,
--
--				-- PicoBlaze interface
--				Address								=> Intern_PicoBlazeDeviceBus(IICC2_BUSINDEX).PortID,
--				WriteStrobe						=> Intern_PicoBlazeDeviceBus(IICC2_BUSINDEX).WriteStrobe,
--				WriteStrobe_K					=> Intern_PicoBlazeDeviceBus(IICC2_BUSINDEX).WriteStrobe_K,
--				ReadStrobe						=> Intern_PicoBlazeDeviceBus(IICC2_BUSINDEX).ReadStrobe,
--				DataIn								=> Intern_PicoBlazeDeviceBus(IICC2_BUSINDEX).Data,
--				DataOut								=> Intern_DevicePicoBlazeBus(IICC2_BUSINDEX).Data,
--
--				Interrupt							=> Intern_DevicePicoBlazeBus(IICC2_BUSINDEX).Interrupt,
--				Interrupt_Ack					=> Intern_PicoBlazeDeviceBus(IICC2_BUSINDEX).Interrupt_Ack,
--				Message								=> Intern_DevicePicoBlazeBus(IICC2_BUSINDEX).Message,
--
--				-- IICController_IIC interface
--				IIC_Request						=> IIC2_Request,
--				IIC_Grant							=> IIC2_Grant,
--			
--				IIC_Command						=> IIC2_Command,
--				IIC_Status						=> IIC2_Status,
--				IIC_Error							=> IIC2_Error,
--
--				IIC_Address						=> IIC2_Address,
--				IIC_WP_Valid					=> IIC2_WP_Valid,
--				IIC_WP_Data						=> IIC2_WP_Data,
--				IIC_WP_Last						=> IIC2_WP_Last,
--				IIC_WP_Ack						=> IIC2_WP_Ack,
--				IIC_RP_Valid					=> IIC2_RP_Valid,
--				IIC_RP_Data						=> IIC2_RP_Data,
--				IIC_RP_Last						=> IIC2_RP_Last,
--				IIC_RP_Ack						=> IIC2_RP_Ack
--			);
--	end block;
	
--	blkFreqM : block
--		constant DEV_SHORT		: STRING								:= "FreqM";
--		constant BUSINDEX			: NATURAL								:= pb_GetBusIndex(SOFPGA_SYSTEM, DEV_SHORT);
--		constant DEVICE_INST	: T_PB_DEVICE_INSTANCE	:= pb_GetDeviceInstance(SOFPGA_SYSTEM, DEV_SHORT);
--	begin
--		FreqM_Reset	<= CPU_Reset;
--	
--		FreqM : entity L_PicoBlaze.pb_FrequencyMeasurement_Wrapper
--			generic map (
--				REFERENCE_CLOCK_FREQ	=> PICOBLAZE_CLOCK_FREQ,
--				DEVICE_INSTANCE				=> DEVICE_INST
--			)
--			port map (
--				Clock								=> CPU_Clock,
--				Reset								=> FreqM_Reset,
--				
--				-- PicoBlaze interface
--				Address							=> Intern_PicoBlazeDeviceBus(BUSINDEX).PortID,
--				WriteStrobe					=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe,
--				WriteStrobe_K				=> Intern_PicoBlazeDeviceBus(BUSINDEX).WriteStrobe_K,
--				ReadStrobe					=> Intern_PicoBlazeDeviceBus(BUSINDEX).ReadStrobe,
--				DataIn							=> Intern_PicoBlazeDeviceBus(BUSINDEX).Data,
--				DataOut							=> Intern_DevicePicoBlazeBus(BUSINDEX).Data,
--				
--				Interrupt						=> open,
--				Interrupt_Ack				=> '0',
--				Message							=> open,
--				
--				ClockIn							=> FreqM_ClockIn
--			);
--		
--		Intern_DevicePicoBlazeBus(BUSINDEX).Interrupt		<= '0';
--		Intern_DevicePicoBlazeBus(BUSINDEX).Message			<= x"00";
--	end block;

end;
