#! /bin/bash
# EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
# vim: tabstop=2:shiftwidth=2:noexpandtab
# kate: tab-width 2; replace-tabs off; indent-width 2;
# 
# ==============================================================================
# Authors:					Martin Zabel
#										Patrick Lehmann
#
# Bash-Script:			DMATest_KC705 compile script for the PicoBlaze sources
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

FPGA_CLOUD_SERVER="141.76.94.14"
FPGA_CLOUD_USER="zabel"
FPGA_CLOUD_HOME="/home/$FPGA_CLOUD_USER"
FPGA_CLOUD_WORKINGDIR="$FPGA_CLOUD_HOME/bit/DMATest"
FPGA_CLOUD_JTAGLOADER_SCRIPT="programPicoBlaze.sh"

POSTPROCESSOR="../../lib/L_PicoBlaze/py/psmProcessor.py"

TEMPLATE_FILE="../../lib/L_PicoBlaze/ROM Templates/Page.Series-7.template.vhdl"
PAGES="Page0 Page1 Page2 Page3"

ANSI_RED="\e[31m"
ANSI_GREEN="\e[32m"
ANSI_YELLOW="\e[33m"
ANSI_BLUE="\e[34m"
ANSI_MAGENTA="\e[35m"
ANSI_RESET="\e[0m"

COLORED_ERROR="$ANSI_RED[ERROR]$ANSI_RESET"
COLORED_DONE="$ANSI_GREEN[DONE]$ANSI_RESET"

while [[ $# > 0 ]]; do
	key="$1"
	case $key in
		-p|--preprocess)
		PREPROCESS=TRUE
		;;
		-a|--assemble)
		ASSEMBLE=TRUE
		;;
		-v|--verbose)
		VERBOSE=TRUE
		;;
		-o|--optimize)
		OPTIMIZE=TRUE
		;;
		-P|--postprocess)
		POSTPROCESS=TRUE
		;;
		-u|--program)
		PROGRAM=TRUE
		;;
		-r|--remote)
		REMOTE=TRUE
		;;
		-c|--cleanup)
		CLEANUP=TRUE
		;;
		-n|--noclean)
		NOCLEAN=YES
		;;
		-h|--help)
		HELP=TRUE
		;;
		*)		# unknown option
		UNKNOWN_OPTION=TRUE
		;;
	esac
	shift # past argument or value
done

echo -e $ANSI_MAGENTA "DMATest_KC705 Compile Script for Linux" $ANSI_RESET
echo -e $ANSI_MAGENTA "======================================" $ANSI_RESET

if [ "$UNKNOWN_OPTION" == TRUE ]; then
	echo -e $COLORED_ERROR "Unknown command line option." $ANSI_RESET
	exit -1
elif [ "$HELP" == "TRUE" ]; then
	echo ""
	echo "Usage:"
	echo "  compile.sh [-v] [--preprocess] [--assemble [-o][-n]] [--postprocess] [--program [-r]] [--cleanup]"
	echo ""
	echo "Options:"
	echo "  -h --help           Print this help page"
	echo "  -p --preprocess     Run pre-processor(s)"
	echo "  -a --assemble       Assemble source files"
	echo "  -P --postprocess    Run post-processor(s)"
	echo "  -u --program        Upload ROM to device via JTAG_Loader"
	echo "  -c --cleanup        Remove ALL generated files"
	echo ""
	echo "Assemble sub options:"
	echo "  -v --verbose        Print more messages"
	echo "  -o --optimize       Enable optimizations in opbasm"
	echo "  -n --noclean        Don't remove temporary files after assemble"
	echo ""
	echo "Program sub options:"
	echo "  -r --remote         Program PicoBlaze on FPGA-Cloud"
	echo ""
	exit 0
fi


# preprocessing
if [ "$PREPROCESS" == "TRUE" ]; then
	echo -e $ANSI_YELLOW "Running pre processing ... " $ANSI_RESET
	./Page1_TextGenerator.py
	./Page3_TextGenerator.py
fi


# assembling
if [ "$ASSEMBLE" == "TRUE" ]; then
	echo -e $ANSI_YELLOW "Running opbasm..." $ANSI_RESET

	OPBASM_OPTIONS=(-m 4096)
	OPBASM_OPTIONS+=(-s 256)
	OPBASM_OPTIONS+=(-6)
	OPBASM_OPTIONS+=(-x)
	OPBASM_OPTIONS+=(-c)
	
	if [ "$OPTIMIZE" == "TRUE" ]; then
		OPBASM_OPTIONS+=(-d -r)	           	# dead code analysis & dead code removal
	fi
	if [ "$VERBOSE" != "TRUE" ]; then
		OPBASM_OPTIONS+=(-q)
	fi
	
	for page in $PAGES; do
		unset OPBASM_PARAMS
		OPBASM_PARAMS=(${OPBASM_OPTIONS[@]})
		OPBASM_PARAMS+=(-i main_$page.psm4)
		OPBASM_PARAMS+=(-n main_$page)
		OPBASM_PARAMS+=(-e 0xFE0)
	
		echo "Assembling $page ... "
		echo "opbasm -t '$TEMPLATE_FILE' ${OPBASM_PARAMS[@]}"
		opbasm -t "$TEMPLATE_FILE" ${OPBASM_PARAMS[@]}

		if [ $? -ne 0 ]; then
			echo -e $ANSI_RED "ERROR: opbasm return with an error. ReturnCode=$?" $ANSI_RESET
			exit -1
		fi
		
		if [ -f main_$page.log ]; then
			echo -n "  Process colored log file ... "
			cp main_$page.log main_$page.colored.log
			cat main_$page.colored.log | sed 's/\x1b\[[0-9;]*m//g' > main_$page.log
		fi
		
		if [ "$NOCLEAN" != "TRUE" ]; then
			echo -e $COLORED_DONE
			
			echo -n "  Deleting temporary files ... "
			rm -f *.fmt *.gen.psm
			echo -e $COLORED_DONE
		else
			echo -e $COLORED_DONE
		fi
	done	# for each page

fi	# ASSEMBLE

if [ "$POSTPROCESS" == "TRUE" ]; then

	POSTPROCESS_PARAMS="--prefix SoFPGA"
	for page in $PAGES; do
		POSTPROCESS_PARAMS+=" main_$page.log"
	done
	
	python3.4 $POSTPROCESSOR $POSTPROCESS_PARAMS
	
fi	# POSTPROCESS

if [ "$CLEANUP" == "TRUE" ]; then
	echo -en $ANSI_YELLOW "Cleaning up ... " $ANSI_RESET
	rm -f *.fmt *.gen.psm *.log *.vhdl *.tok *.hex
	echo -e $COLORED_DONE
fi	# CLEANUP

if [ "$PROGRAM" == "TRUE" ]; then
	if [ "$REMOTE" != "TRUE" ]; then
		echo -e $ANSI_RED "NOT IMPLEMENTED" $ANSI_RESET
	else
		
		echo -e $ANSI_YELLOW "Coping all hex files to FPGA-Cloud ... " $ANSI_RESET
		scp *.hex $FPGA_CLOUD_SERVER:$FPGA_CLOUD_WORKINGDIR/

		echo -e $ANSI_YELLOW "Remote programming on FPGA-Cloud with JTAG_Loader ... " $ANSI_RESET
		ssh $FPGA_CLOUD_SERVER "cd $FPGA_CLOUD_WORKINGDIR/; ./$FPGA_CLOUD_JTAGLOADER_SCRIPT"
	
	fi	# REMOTE
fi	# PROGRAM

echo -e "All tasks " $ANSI_GREEN "completed." $ANSI_RESET
