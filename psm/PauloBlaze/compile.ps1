# EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
# vim: tabstop=2:shiftwidth=2:noexpandtab
# kate: tab-width 2; replace-tabs off; indent-width 2;
# 
# ==============================================================================
# Authors:						Patrick Lehmann
#
# PowerShell-Script:	ExampleDesign compile script for the PicoBlaze sources
# 
# Description:
# ------------------------------------
#		TODO
#		
#
# License:
# ==============================================================================
# Copyright 2007-2015 Technische Universitaet Dresden - Germany,
#											Chair for VLSI-Design, Diagnostics and Architecture
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#		http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#
# export help entries for Get-Help
<#
	.SYNOPSIS
		Compiles all pages with opbasm
	.DESCRIPTION
		TODO
	.EXAMPLE
		compile.ps1 -Verbose -Assemble -Optimze -PostProcess -Program -Remote
#>
 
# define script parameters
[CmdletBinding()]
param(
	# run pre processing
	[Switch]$PreProcess,

	# run opbasm assembler
	[Switch]$Assemble,
		# enable optimizations
		[Switch]$Optimize,
		# write MIF files
		[Switch]$MIF,
	
	# run post processing
	[Switch]$PostProcess,
	
	# program device after assembling
	[Switch]$Program,
		# program remotely on cloud
		[Switch]$Remote,
	
	# clean up directory after assembling
	[Switch]$Cleanup,

	# don't clean up directory after assembling
	[Switch]$NoClean,
	
	# show help page
	[Switch]$Help
)

# set default values
$Script_ExitCode = 0
if ($PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent) 		{	$Script_EnableDebug =		$true	}
if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent)	{	$Script_EnableVerbose =	$true	}

# 
$TemplateFile = "..\..\lib\L_PicoBlaze\ROM Templates\Page.Series-7.template.vhdl"

# pages
$Pages = @(
	@{'File'				= "main_Page0.psm4";
		'Main'				= "main_Page0";
		'EntryPoints'	= @("0xFE0")
	},
	@{'File'				= "main_Page1.psm4";
		'Main'				= "main_Page1";
		'EntryPoints'	= @("0xFE0")
	}
)

if (-not ($PreProcess -or $Assemble -or $PostProcess -or $Program -or $Cleanup))
	{	$Help = $True	}

Write-Host "ExampleDesign compiler - Copyright 2007-2015 Patrick Lehmann - Dresden, Germany"	-ForegroundColor Magenta
Write-Host "================================================================================"	-ForegroundColor Magenta
	
if ($Help)
	{	Write-Host ""
		Write-Host ".\compile.ps1"
		Write-Host "  [-PreProcess]  pre-process source files before assembling"
		Write-Host "  [-Assemble]    assemble all source files"
		Write-Host "    [-Optimize]  activate optimization"
		Write-Host "    [-MIF]       write MIF files for Altera tool chains"
		Write-Host "    [-NoClean]   don't delete temporary files"
		Write-Host "  [-PostProcess] post-process logfiles"
		Write-Host "  [-Program]     upload the program to device"
		Write-Host "    [-Remote]    use FPGA-Cloud remote programming"
		Write-Host "  [-Cleanup]     delete all generated files"
		Write-Host "  [-Help]        show this help page"
		Write-Host ""
	
		exit 1
	}
	
# run pre processing
if ($PreProcess)
	{	Write-Host "Running pre processing..." -ForegroundColor Yellow
		.\Page1_TextGenerator.py
	}

# 
if ($Assemble)
	{	Write-Host "Running opbasm.exe..." -ForegroundColor Yellow
	
		$OPBASMExecutable				= "opbasm.exe"
		$OPBASMCommonParameters	= @(
				"-t", $TemplateFile,								# template file for instruction ROM pages
				"-m", "4096",												# instruction ROM size = 4096 instructions
				"-s", "256",												# scratch pad size = 256 entries
				"-6"																# compile for KCPSM6
				#"-c"																# generate colored log file
			)


		if (-not $Script_EnableVerbose)					# if verbose is disabled
			{	$OPBASMCommonParameters += "-q"	}		# add quite switch to parameter list

		if ($Optimize)													# if optimization is enabled
			{	$OPBASMCommonParameters += "-d"			# analyse unreachable instructions
				$OPBASMCommonParameters += "-r"			# remove dead instructions
			}
		
		if ($MIF)																# if Altera MIF file generation is enabled
			{	$OPBASMCommonParameters += "--mif"	# generate MIF file instead of hex file
			}
		else
			{	$OPBASMCommonParameters += "-x"			# generate hex file
			}		
		
		foreach ($Page in $Pages)
			{	$OPBASMParameters	= @()
				$OPBASMParameters	+= "-i"
				$OPBASMParameters	+= $Page['File']
				$OPBASMParameters	+= "-n"
				$OPBASMParameters	+= $Page['Main']
				$OPBASMParameters	+= $OPBASMCommonParameters
				foreach ($EntryPoint in $Page['EntryPoints'])
					{	$OPBASMParameters += "-e"
						$OPBASMParameters += $EntryPoint
					}
				
				# call opbasm
				Write-Host "Assembling $($Page['File']) ... " -NoNewline
				Write-Debug ($OPBASMExecutable + " " + ($OPBASMParameters -join " "))
				& $OPBASMExecutable $OPBASMParameters
				
				if ($LastExitCode -ne 0)
					{	$Script_ExitCode = 1
						Write-Host "ERROR: $OPBASMExecutable return with an error. ErrorCode=$LastExitCode" -ForegroundColor Red
						exit 1
					}
				elseif (-not $NoClean)
					{	Write-Host "[DONE]" -ForegroundColor DarkGreen
						
						$fileList  = Get-ChildItem -Path "..\..\psm"							-Recurse -Filter "*.fmt"
						$fileList += Get-ChildItem -Path "..\..\lib\L_PicoBlaze"	-Recurse -Filter "*.fmt"
						$fileList += Get-ChildItem -Path "..\..\psm"							-Recurse -Filter "*.gen.psm"
						$fileCount = $fileList.Count
						
						Write-Host "  Deleting $fileCount temporary files ... " -NoNewline
						if ($fileCount -gt 0)
							{	$fileList | Remove-Item		}
						Write-Host "[DONE]" -ForegroundColor DarkGreen
					}
				else
					{	Write-Host "[DONE]" -ForegroundColor DarkGreen		}
			}
		Write-Host ""
	}

if ($PostProcess)
	{	Write-Host "Running post processing ..." -ForegroundColor Yellow
	
		$PostProcessParameters	= @()
		$PostProcessParameters	+= ("-p", "SoFPGA")
	
		foreach ($Page in $Pages)
			{	$PostProcessParameters	+= ($Page['Main'] + ".log")		}
			
		if ($Script_EnableDebug)
			{	Write-Host ("& ..\..\lib\L_PicoBlaze\py\psmProcessor.py " + $PostProcessParameters)	}
			
		& ..\..\lib\L_PicoBlaze\py\psmProcessor.py $PostProcessParameters
	}
	
if ($Cleanup)
	{	Write-Host "Not implemented" -ForegroundColor Red	}
	
if ($Program)
	{	if ($Remote)
			{
				$FPGA_Cloud_Server = "141.76.94.14"
				$FPGA_Cloud_User = "lehmann"
				$FPGA_Cloud_Home = "/home/$FPGA_Cloud_User"
				
				$Command = "pscp.exe"
				$Arguments = @("-agent")
				foreach ($Page in $Pages)
					{	$Arguments	+= (".\" + $Page['Main'] + ".hex")	}
				$Arguments	+= ($FPGA_Cloud_User + "@" + $FPGA_Cloud_Server + ":" + $FPGA_Cloud_Home + "/bit/DMATest/")
				
				Write-Debug ($Command + " " + ($Arguments -join " "))
				Write-Host "Coping all hex files to FPGA-Cloud." -ForegroundColor Yellow
				& $Command $Arguments

				
				$Command = "plink.exe"
				$Arguments = @(
					"-agent",
					($FPGA_Cloud_User + "@" + $FPGA_Cloud_Server),
					("cd " + $FPGA_Cloud_Home + "/bit/DMATest; ./programPicoBlaze.sh")
				)
				
				Write-Debug ($Command + " " + ($Arguments -join " "))
				Write-Host "Remote programming on FPGA-Cloud with JTAG_Loader." -ForegroundColor Yellow
				& $Command $Arguments
			}
		else	# $Remote
			{# load Xilinx ISE environment
				$Command = "..\..\lib\PoC\poc.ps1 --ise-settingsfile"
				$ISE_SettingsFile = Invoke-Expression $Command
				if ($LastExitCode -eq 0)
					{	if ($ISE_SettingsFile -eq "")
							{	Write-Host "ERROR: No Xilinx ISE installation found." -ForegroundColor Red
								Write-Host "Run 'poc.ps1 --configure' to configure your Xilinx ISE installation." -ForegroundColor Red
								exit 1
							}
						else
							{	Write-Host "Loading Xilinx ISE environment '$ISE_SettingsFile'" -ForegroundColor Yellow
								if (($ISE_SettingsFile -like "*.bat") -or ($ISE_SettingsFile -like "*.cmd"))
									{	Import-Module PSCX
										Invoke-BatchFile -path $ISE_SettingsFile
									}
								else
									{	. $ISE_SettingsFile		}
							}
					}
				
				$JTAGLoaderExecutable				= "..\..\lib\L_PicoBlaze\JTAG Loader\JTAG_Loader_Win7_64.exe"
				$JTAGLoaderCommonParameters	= @(
					"-d",					# select Digilent programmer
					"-i", "2"			# select JTAG chain 2
				)

				for ($i = ($Pages.Count - 1); $i -ge 0; $i--)
					{	Write-Host "Writing page$i ..." -ForegroundColor Yellow
						
						$JTAGLoaderParameters	= @()
						$JTAGLoaderParameters	+= $JTAGLoaderCommonParameters
						$JTAGLoaderParameters	+= "-b" + $i
						$JTAGLoaderParameters	+= "-l"
						$JTAGLoaderParameters	+= $Pages[$i]['main'] + ".hex"
						
						Write-Debug ($JTAGLoaderExecutable + " " + ($JTAGLoaderParameters -join " "))
						$JTAGLoaderOutput = & $JTAGLoaderExecutable $JTAGLoaderParameters
						
						foreach ($Line in $JTAGLoaderOutput)
							{	if (-not (($Line.Contains("Info")) -or ($Line.Length -eq 0)))
									{	if ($Line.Contains("JTAG Loader was not found in this device"))
											{	Write-Host $Line -ForegroundColor Red }
										elseif ($Line.Contains("Initiating load of BlockRAM"))
											{	Write-Host $Line -ForegroundColor White }
										elseif ($Line.Contains("Selection"))
											{	Write-Host $Line -ForegroundColor White }
										elseif ($Line.Contains("Resetting PicoBlaze"))
											{	Write-Host $Line -ForegroundColor White }
										elseif ($Line.Contains("Programming Bram"))
											{	Write-Host $Line -ForegroundColor White }
										elseif ($Line.Contains("Releasing reset on PicoBlaze"))
											{	Write-Host $Line -ForegroundColor White }
										elseif ($Line.Contains("Hex file appears to be in range for targeted BlockRAM"))
											{	Write-Host $Line -ForegroundColor White }
										elseif ($Line.Contains("JTAG Loader has completed successfully"))
											{	Write-Host $Line -ForegroundColor Green	}
										else
											{	Write-Host $Line -ForegroundColor Gray	}
									}
							}
					}
			} # remote
	} # program
