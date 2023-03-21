`timescale 1ps/1ps

`include "interlaken_0_fpga_top.v"

module interlaken_0_fpga_tb
(
);

//Declare wires
wire init_clk;
reg gt_ref_clk0_p;
reg gt_ref_clk0_n;
reg ref_clk;
wire locked;

// Instantiate the top-level module
interlaken_0_fpga_top dut
(
    .init_clk(init_clk),
    .gt_ref_clk0_p(gt_ref_clk0_p),
    .gt_ref_clk0_n(gt_ref_clk0_n),
    .clk_reset(~locked)
);

// Instantiate the clock wizard
 clk_wiz_0 i_CLK_GEN
(
//// Clock in ports
.clk_in1    (ref_clk), 
.clk_out1   (init_clk),

.reset      (clk_reset),
.locked     (locked)
);

initial begin
  gt_ref_clk0_p =1;
  forever
    begin
      #1241.212   gt_ref_clk0_p = ~  gt_ref_clk0_p;
    end
end

initial begin
  gt_ref_clk0_n =0;
  forever 
    begin
      #1241.212   gt_ref_clk0_n = ~  gt_ref_clk0_n;
   end
end

initial begin
  ref_clk =1;
  forever #5000.000 ref_clk = ~ref_clk;
end

endmodule
