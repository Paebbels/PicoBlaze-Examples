-------------------------------------------------------------------------------
-- Copyright (c) 2015 Xilinx, Inc.
-- All Rights Reserved
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor     : Xilinx
-- \   \   \/     Version    : 14.7
--  \   \         Application: XILINX CORE Generator
--  /   /         Filename   : CSP_ControlVIO.vhd
-- /___/   /\     Timestamp  : Fri Jun 26 19:02:38 Mitteleuropäische Sommerzeit 2015
-- \   \  /  \
--  \___\/\___\
--
-- Design Name: VHDL Synthesis Wrapper
-------------------------------------------------------------------------------
-- This wrapper is used to integrate with Project Navigator and PlanAhead

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY CSP_ControlVIO IS
  port (
    CONTROL: inout std_logic_vector(35 downto 0);
    CLK: in std_logic;
    SYNC_IN: in std_logic_vector(7 downto 0);
    SYNC_OUT: out std_logic_vector(7 downto 0));
END CSP_ControlVIO;

ARCHITECTURE CSP_ControlVIO_a OF CSP_ControlVIO IS
BEGIN

END CSP_ControlVIO_a;
