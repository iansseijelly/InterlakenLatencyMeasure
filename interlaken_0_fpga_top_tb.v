`timescale 1ps/1ps

module interlaken_0_exdes_fpga_tb
(
);

//Declare wires
wire init_clk;
wire gt_ref_clk0_p;
wire gt_ref_clk0_n;
wire clk_reset;
wire send_msg1;
wire send_msg2;
wire send_msg3;
wire send_msg4;
wire send_msg5;
wire send_msg6;
wire send_msg7;
wire send_msg8;
wire send_msg9;

// Instantiate the top-level module
interlaken_0_exdes_fpga_top dut
(
    .init_clk(init_clk),
    .gt_ref_clk0_p(gt_ref_clk0_p),
    .gt_ref_clk0_n(gt_ref_clk0_n),
    .clk_reset(clk_reset),
    .send_msg1(send_msg1),
    .send_msg2(send_msg2),
    .send_msg3(send_msg3),
    .send_msg4(send_msg4),
    .send_msg5(send_msg5),
    .send_msg6(send_msg6),
    .send_msg7(send_msg7),
    .send_msg8(send_msg8),
    .send_msg9(send_msg9)
);

// Instantiate the clock wizard
 clk_wiz_0 i_CLK_GEN
(
//// Clock in ports
.clk_in1    (gt_txusrclk2), 
.clk_out1   (lbus_clk),

.reset      (clk_reset),
.locked     (locked)
);


endmodule