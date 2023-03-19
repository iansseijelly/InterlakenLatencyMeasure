#------------------------------------------------------------------------------
#  (c) Copyright 2013 Xilinx, Inc. All rights reserved.
#
#  This file contains confidential and proprietary information
#  of Xilinx, Inc. and is protected under U.S. and
#  international copyright and other intellectual property
#  laws.
#
#  DISCLAIMER
#  This disclaimer is not a license and does not grant any
#  rights to the materials distributed herewith. Except as
#  otherwise provided in a valid license issued to you by
#  Xilinx, and to the maximum extent permitted by applicable
#  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
#  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
#  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
#  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
#  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
#  (2) Xilinx shall not be liable (whether in contract or tort,
#  including negligence, or under any other theory of
#  liability) for any loss or damage of any kind or nature
#  related to, arising under or in connection with these
#  materials, including for any direct, or any indirect,
#  special, incidental, or consequential loss or damage
#  (including loss of data, profits, goodwill, or any type of
#  loss or damage suffered as a result of any action brought
#  by a third party) even if such damage or loss was
#  reasonably foreseeable or Xilinx had been advised of the
#  possibility of the same.
#
#  CRITICAL APPLICATIONS
#  Xilinx products are not designed or intended to be fail-
#  safe, or for use in any application requiring fail-safe
#  performance, such as life-support or safety devices or
#  systems, Class III medical devices, nuclear facilities,
#  applications related to the deployment of airbags, or any
#  other applications that could lead to death, personal
#  injury, or severe property or environmental damage
#  (individually and collectively, "Critical
#  Applications"). Customer assumes the sole risk and
#  liability of any use of Xilinx products in Critical
#  Applications, subject only to applicable laws and
#  regulations governing limitations on product liability.
#
#  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
#  PART OF THIS FILE AT ALL TIMES.
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Interlaken example design-level XDC file
# ----------------------------------------------------------------------------------------------------------------------
create_clock -period 10.000 [get_ports init_clk]
set_property IOSTANDARD LVCMOS18 [get_ports init_clk]
create_clock -period 2.482 [get_ports gt_ref_clk0_p]
#set_property IOSTANDARD DIFF_SSTL15 [get_ports gt_ref_clk0_n]
#set_property IOSTANDARD DIFF_SSTL15 [get_ports gt_ref_clk0_p]

###Constraints to fix the ILKN core Location
#set_property LOC ILKNE4_X1Y5 [get_cells DUT/inst/i_ilkn_top_inst/ilkn_inst]
set_false_path -to [get_pins DUT/inst/i_ilkn_top_inst/*/CTL_RX_FORCE_RESYNC]
set_false_path -to [get_pins DUT/inst/i_ilkn_top_inst/*/CTL_TX_RLIM_ENABLE]

set_max_delay -from [get_clocks -of_objects [get_pins i_CLK_GEN/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins DUT/inst/i_interlaken_gtwiz_userclk_tx_inst/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk_inst/O]] 6.0
set_max_delay -from [get_clocks -of_objects [get_pins DUT/inst/i_interlaken_gtwiz_userclk_tx_inst/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk_inst/O]] -to [get_clocks -of_objects [get_pins i_CLK_GEN/inst/mmcme4_adv_inst/CLKOUT0]] 6.0

set_max_delay -from [get_pins DUT/inst/*_axi4_lite_if_wrapper/*_axi4_lite_reg_map/*_ilkn_config_tx_reg_syncer/data_out_1d_*/C] -to [get_pins DUT/inst/i_ilkn_top_inst/*/CTL_TX_ENABLE] 6.000 





 


set_max_delay -from [get_clocks -of_objects [get_pins i_CLK_GEN/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins DUT/inst/i_interlaken_gtwiz_userclk_tx_inst/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk_inst/O]] 6.0





set_false_path -to [get_pins -leaf -of_objects [get_cells -hier *cdc_to* -filter {is_sequential}] -filter {NAME=~*ilkn_cdc*/*/D}]

### These are sample constraints, please use correct constraints for your device 
### As per GT recommendation, ref_clk should be connected to the middle quad.
 
   ### User needs to uncomment the below line and based on ILKN core location and GT group selected, change the gt_ref_clk pin location accordingly.
   #set_property PACKAGE_PIN AC9 [get_ports gt_ref_clk0_p]


  ### For init_clk input pin assignment, If single ended clock is not available on board, user has to instantiate IBUFDS to covert differential clock to 
  ### single ended clock and make the necessary changes for the clock mapping. 
### Change these IO Loc XDC constraints as per your board and device
  #set_property PACKAGE_PIN AM12 [get_ports init_clk]
  #set_property PACKAGE_PIN AG12 [get_ports sys_reset]
  #set_property PACKAGE_PIN AJ14 [get_ports lbus_tx_rx_restart_in]
  #set_property LOC AR12 [get_ports tx_done_led]
  #set_property LOC AR13 [get_ports tx_busy_led]
  #set_property LOC AM9 [get_ports tx_fail_led]
  #set_property LOC AN8 [get_ports rx_gt_locked_led]
  #set_property LOC AP8 [get_ports rx_aligned_led]
  #set_property LOC AP10 [get_ports rx_done_led]
  #set_property LOC AR10 [get_ports rx_failed_led]
  #set_property LOC AR11 [get_ports rx_busy_led]



### Push Buttons
set_property IOSTANDARD LVCMOS18 [get_ports sys_reset]
set_property IOSTANDARD LVCMOS18 [get_ports lbus_tx_rx_restart_in]

### Output as LEDs
set_property IOSTANDARD LVCMOS18 [get_ports tx_done_led]
##
set_property IOSTANDARD LVCMOS18 [get_ports tx_busy_led]
##
set_property IOSTANDARD LVCMOS18 [get_ports tx_fail_led]
##
set_property IOSTANDARD LVCMOS18 [get_ports rx_gt_locked_led]
##
set_property IOSTANDARD LVCMOS18 [get_ports rx_aligned_led]
##
set_property IOSTANDARD LVCMOS18 [get_ports rx_done_led]
##
set_property IOSTANDARD LVCMOS18 [get_ports rx_failed_led]
##
set_property IOSTANDARD LVCMOS18 [get_ports rx_busy_led]















