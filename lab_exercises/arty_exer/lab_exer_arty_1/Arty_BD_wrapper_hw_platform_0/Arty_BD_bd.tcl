
################################################################
# This is a generated script based on design: Arty_BD
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2014.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source Arty_BD_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7a35tcsg324-1


# CHANGE DESIGN NAME HERE
set design_name Arty_BD

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -from 0 -to 0 -type rst SYS_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list CONFIG.C_ECC {0}  ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list CONFIG.C_ECC {0}  ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 lmb_bram ]
  set_property -dict [ list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.use_bram_block {BRAM_Controller}  ] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set HFC_CTS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 HFC_CTS_0 ]
  set HFC_CTS_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 HFC_CTS_1 ]
  set HFC_RTS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 HFC_RTS_0 ]
  set HFC_RTS_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 HFC_RTS_1 ]
  set led [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 led ]
  set uart_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 uart_0 ]
  set uart_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 uart_1 ]
  set uart_usb [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 uart_usb ]

  # Create ports
  set clk_100 [ create_bd_port -dir I -type clk clk_100 ]
  set reset_n [ create_bd_port -dir I -type rst reset_n ]
  set_property -dict [ list CONFIG.POLARITY {ACTIVE_LOW}  ] $reset_n

  # Create instance: LEDS, and set properties
  set LEDS [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 LEDS ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS_2 {0} CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO2_WIDTH {32} CONFIG.C_GPIO_WIDTH {8} CONFIG.C_IS_DUAL {0}  ] $LEDS

  # Create instance: STDIO_UART, and set properties
  set STDIO_UART [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 STDIO_UART ]

  # Create instance: Timer_0, and set properties
  set Timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 Timer_0 ]

  # Create instance: Timer_1, and set properties
  set Timer_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 Timer_1 ]

  # Create instance: Timer_2, and set properties
  set Timer_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 Timer_2 ]

  # Create instance: UART_0, and set properties
  set UART_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 UART_0 ]

  # Create instance: UART_0_FC, and set properties
  set UART_0_FC [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 UART_0_FC ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS_2 {1} CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO2_WIDTH {1} CONFIG.C_GPIO_WIDTH {1} CONFIG.C_IS_DUAL {1}  ] $UART_0_FC

  # Create instance: UART_1, and set properties
  set UART_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 UART_1 ]
  set_property -dict [ list CONFIG.C_BAUDRATE {38400}  ] $UART_1

  # Create instance: UART_1_FC, and set properties
  set UART_1_FC [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 UART_1_FC ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {0} CONFIG.C_ALL_INPUTS_2 {1} CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_ALL_OUTPUTS_2 {0} CONFIG.C_GPIO2_WIDTH {1} CONFIG.C_GPIO_WIDTH {1} CONFIG.C_IS_DUAL {1}  ] $UART_1_FC

  # Create instance: axi_intc_0, and set properties
  set axi_intc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 axi_intc_0 ]

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.1 clk_wiz_1 ]
  set_property -dict [ list CONFIG.CLKOUT2_JITTER {118.758} CONFIG.CLKOUT2_PHASE_ERROR {98.575} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {100.000} CONFIG.CLKOUT2_USED {false} CONFIG.CLKOUT3_JITTER {114.829} CONFIG.CLKOUT3_PHASE_ERROR {98.575} CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {100.000} CONFIG.CLKOUT3_USED {false} CONFIG.MMCM_CLKOUT1_DIVIDE {1} CONFIG.MMCM_CLKOUT2_DIVIDE {1} CONFIG.MMCM_DIVCLK_DIVIDE {1} CONFIG.NUM_OUT_CLKS {1} CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} CONFIG.RESET_PORT {resetn} CONFIG.RESET_TYPE {ACTIVE_LOW}  ] $clk_wiz_1

  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_1 ]

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:9.4 microblaze_0 ]
  set_property -dict [ list CONFIG.C_DEBUG_ENABLED {1} CONFIG.C_D_AXI {1} CONFIG.C_D_LMB {1} CONFIG.C_I_LMB {1}  ] $microblaze_0

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 microblaze_0_axi_periph ]
  set_property -dict [ list CONFIG.NUM_MI {10}  ] $microblaze_0_axi_periph

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: rst_clk_wiz_1_100M, and set properties
  set rst_clk_wiz_1_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_1_100M ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list CONFIG.NUM_PORTS {5}  ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net UART_0_FC_GPIO [get_bd_intf_ports HFC_RTS_0] [get_bd_intf_pins UART_0_FC/GPIO]
  connect_bd_intf_net -intf_net UART_0_FC_GPIO2 [get_bd_intf_ports HFC_CTS_0] [get_bd_intf_pins UART_0_FC/GPIO2]
  connect_bd_intf_net -intf_net UART_0_UART [get_bd_intf_ports uart_0] [get_bd_intf_pins UART_0/UART]
  connect_bd_intf_net -intf_net UART_1_FC_GPIO2 [get_bd_intf_ports HFC_CTS_1] [get_bd_intf_pins UART_1_FC/GPIO2]
  connect_bd_intf_net -intf_net UART_1_UART [get_bd_intf_ports uart_1] [get_bd_intf_pins UART_1/UART]
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO [get_bd_intf_ports led] [get_bd_intf_pins LEDS/GPIO]
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO1 [get_bd_intf_ports HFC_RTS_1] [get_bd_intf_pins UART_1_FC/GPIO]
  connect_bd_intf_net -intf_net axi_intc_0_interrupt [get_bd_intf_pins axi_intc_0/interrupt] [get_bd_intf_pins microblaze_0/INTERRUPT]
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports uart_usb] [get_bd_intf_pins STDIO_UART/UART]
  connect_bd_intf_net -intf_net microblaze_0_axi_dp [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M00_AXI [get_bd_intf_pins STDIO_UART/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins UART_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins UART_1/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M03_AXI [get_bd_intf_pins UART_0_FC/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins Timer_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M05_AXI [get_bd_intf_pins Timer_1/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M06_AXI [get_bd_intf_pins Timer_2/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M07_AXI [get_bd_intf_pins axi_intc_0/s_axi] [get_bd_intf_pins microblaze_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M08_AXI [get_bd_intf_pins LEDS/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M09_AXI [get_bd_intf_pins UART_1_FC/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M09_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]

  # Create port connections
  connect_bd_net -net Timer_0_interrupt [get_bd_pins Timer_0/interrupt] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net Timer_1_interrupt [get_bd_pins Timer_1/interrupt] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net Timer_2_interrupt [get_bd_pins Timer_2/interrupt] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net UART_0_interrupt [get_bd_pins UART_0/interrupt] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net UART_1_interrupt [get_bd_pins UART_1/interrupt] [get_bd_pins xlconcat_0/In4]
  connect_bd_net -net clk_in1_1 [get_bd_ports clk_100] [get_bd_pins clk_wiz_1/clk_in1]
  connect_bd_net -net clk_wiz_1_locked [get_bd_pins clk_wiz_1/locked] [get_bd_pins rst_clk_wiz_1_100M/dcm_locked]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_1/Debug_SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/mb_debug_sys_rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LEDS/s_axi_aclk] [get_bd_pins STDIO_UART/s_axi_aclk] [get_bd_pins Timer_0/s_axi_aclk] [get_bd_pins Timer_1/s_axi_aclk] [get_bd_pins Timer_2/s_axi_aclk] [get_bd_pins UART_0/s_axi_aclk] [get_bd_pins UART_0_FC/s_axi_aclk] [get_bd_pins UART_1/s_axi_aclk] [get_bd_pins UART_1_FC/s_axi_aclk] [get_bd_pins axi_intc_0/s_axi_aclk] [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/M03_ACLK] [get_bd_pins microblaze_0_axi_periph/M04_ACLK] [get_bd_pins microblaze_0_axi_periph/M05_ACLK] [get_bd_pins microblaze_0_axi_periph/M06_ACLK] [get_bd_pins microblaze_0_axi_periph/M07_ACLK] [get_bd_pins microblaze_0_axi_periph/M08_ACLK] [get_bd_pins microblaze_0_axi_periph/M09_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins rst_clk_wiz_1_100M/slowest_sync_clk]
  connect_bd_net -net reset_rtl_1 [get_bd_ports reset_n] [get_bd_pins clk_wiz_1/resetn] [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in]
  connect_bd_net -net rst_clk_wiz_1_100M_bus_struct_reset [get_bd_pins microblaze_0_local_memory/SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/bus_struct_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_interconnect_aresetn [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins rst_clk_wiz_1_100M/interconnect_aresetn]
  connect_bd_net -net rst_clk_wiz_1_100M_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins rst_clk_wiz_1_100M/mb_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins LEDS/s_axi_aresetn] [get_bd_pins STDIO_UART/s_axi_aresetn] [get_bd_pins Timer_0/s_axi_aresetn] [get_bd_pins Timer_1/s_axi_aresetn] [get_bd_pins Timer_2/s_axi_aresetn] [get_bd_pins UART_0/s_axi_aresetn] [get_bd_pins UART_0_FC/s_axi_aresetn] [get_bd_pins UART_1/s_axi_aresetn] [get_bd_pins UART_1_FC/s_axi_aresetn] [get_bd_pins axi_intc_0/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/M03_ARESETN] [get_bd_pins microblaze_0_axi_periph/M04_ARESETN] [get_bd_pins microblaze_0_axi_periph/M05_ARESETN] [get_bd_pins microblaze_0_axi_periph/M06_ARESETN] [get_bd_pins microblaze_0_axi_periph/M07_ARESETN] [get_bd_pins microblaze_0_axi_periph/M08_ARESETN] [get_bd_pins microblaze_0_axi_periph/M09_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins axi_intc_0/intr] [get_bd_pins xlconcat_0/dout]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x41C00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs Timer_0/S_AXI/Reg] SEG_Timer_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41C10000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs Timer_1/S_AXI/Reg] SEG_Timer_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41C20000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs Timer_2/S_AXI/Reg] SEG_Timer_2_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40010000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs UART_0_FC/S_AXI/Reg] SEG_UART_0_FC_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs UART_0/S_AXI/Reg] SEG_UART_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40020000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs UART_1/S_AXI/Reg] SEG_UART_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40040000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs LEDS/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40030000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs UART_1_FC/S_AXI/Reg] SEG_axi_gpio_0_Reg1
  create_bd_addr_seg -range 0x10000 -offset 0x41200000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_intc_0/s_axi/Reg] SEG_axi_intc_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40600000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs STDIO_UART/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x0 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x10000 -offset 0x0 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


