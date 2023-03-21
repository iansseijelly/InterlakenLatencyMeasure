`timescale 1ps/1ps

module interlaken_0_fpga_top (
  input wire     init_clk,
  input wire     gt_ref_clk0_p,
  input wire     gt_ref_clk0_n,
  input wire     clk_reset
);

localparam GT_LOCK_WAIT        = 0;
localparam RX_ALIGN_WAIT       = 1;
localparam PACKET_SEND_1       = 2;
localparam PACKET_RECEIVE_1    = 3;
localparam PACKET_RESTART_WAIT = 4;
localparam TX_RX_RESTART       = 5;
localparam TX_RX_BUSY_WAIT     = 6;
localparam PACKET_SEND_2       = 7;
localparam PACKET_RECEIVE_2    = 8;
localparam DONE_WAIT           = 9;
localparam DONE                = 10;

reg [4:0]     present_state;
reg           lbus_tx_rx_restart_in;

reg           sys_reset;
wire          tx_done_led;
wire          tx_busy_led;
wire          tx_fail_led;
wire          rx_gt_locked_led;
wire          rx_aligned_led;
wire          rx_done_led;
wire          rx_failed_led;
wire          rx_busy_led;

wire          drv_tx_done_led;
wire          drv_tx_busy_led;
wire          drv_tx_fail_led;
wire          drv_rx_gt_locked_led;
wire          drv_rx_aligned_led;
wire          drv_rx_done_led;
wire          drv_rx_failed_led;
wire          drv_rx_busy_led;
wire          rpt_tx_done_led;
wire          rpt_tx_busy_led;
wire          rpt_tx_fail_led;
wire          rpt_rx_gt_locked_led;
wire          rpt_rx_aligned_led;
wire          rpt_rx_done_led;
wire          rpt_rx_failed_led;
wire          rpt_rx_busy_led;

wire [3:0]    gt_rpttodrv_p;
wire [3:0]    gt_rpttodrv_n;
wire [3:0]    gt_drvtorpt_p;
wire [3:0]    gt_drvtorpt_n;

reg           timed_out;
reg           time_out_cntr_en;
reg [19:0]    time_out_cntr;
reg           rx_failed_flag;
reg           s_axi_pm_tick;
reg           tx_rx_restart_sent;

// Debug signals for simulation testbench
// TODO: Must remove before running on actual FPGA simulation
assign tx_done_led      = drv_tx_done_led & rpt_tx_done_led;
assign tx_busy_led      = drv_tx_busy_led & rpt_tx_busy_led;
assign tx_fail_led      = drv_tx_fail_led & rpt_tx_fail_led;
assign rx_gt_locked_led = drv_rx_gt_locked_led & rpt_rx_gt_locked_led;
assign rx_aligned_led   = drv_rx_aligned_led & rpt_rx_aligned_led;
assign rx_done_led      = drv_rx_done_led & rpt_rx_done_led;
assign rx_failed_led    = drv_rx_failed_led & rpt_rx_failed_led;
assign rx_busy_led      = drv_rx_busy_led & rpt_rx_busy_led;

// state machine
// TODO: Eventually will have to become 2 state machines (one for each core which are on separate FPGAs), this
//       will involve a post-rx-alignment handshake between the cores prior to beginning actual packet generation
always @(posedge init_clk) begin
  if (clk_reset == 1'b1) begin
    present_state         <= GT_LOCK_WAIT;

    sys_reset             <= 1'b1;
    lbus_tx_rx_restart_in <= 1'b0;
    rx_failed_flag        <= 1'b0;
    s_axi_pm_tick         <= 1'b0;

    tx_rx_restart_sent    <= 1'b0;
  end else begin
    sys_reset             <= 1'b0;
    case (present_state)
      GT_LOCK_WAIT : begin
        if (rx_gt_locked_led == 1'b1) begin
          present_state <= RX_ALIGN_WAIT;
        end else begin
          present_state <= GT_LOCK_WAIT;
        end
      end

      RX_ALIGN_WAIT : begin // TODO: must modify example design to perform handshake before sending actual packets
        if (rx_aligned_led == 1'b1) begin
          present_state <= PACKET_SEND_1;
        end else begin
          present_state <= RX_ALIGN_WAIT;
        end
      end

      PACKET_SEND_1 : begin
        if (tx_done_led == 1'b1) begin
          present_state <= PACKET_RECEIVE_1;
        end else begin
          present_state <= PACKET_SEND_1;
        end
      end

      PACKET_RECEIVE_1 : begin
        if (rx_done_led == 1'b1) begin
          present_state <= PACKET_RESTART_WAIT; 
        end else begin
          present_state <= PACKET_RECEIVE_1;
        end
      end

      PACKET_RESTART_WAIT : begin
        if ((~tx_busy_led) && (~rx_busy_led)) begin
          present_state <= TX_RX_RESTART;
        end else begin
          present_state <= PACKET_RESTART_WAIT;
        end
      end

      TX_RX_RESTART : begin
        if (tx_rx_restart_sent == 1'b0) begin
          lbus_tx_rx_restart_in <= 1'b1;
          tx_rx_restart_sent    <= 1'b1;
          present_state         <= TX_RX_RESTART;
        end else begin
          lbus_tx_rx_restart_in <= 1'b0;
          present_state         <= TX_RX_BUSY_WAIT;
        end
      end

      TX_RX_BUSY_WAIT : begin
        if ((tx_busy_led) && (rx_busy_led)) begin
          present_state <= PACKET_SEND_2;
        end else begin
          present_state <= TX_RX_BUSY_WAIT;
        end
      end

      PACKET_SEND_2 : begin
        if (tx_done_led == 1'b1) begin
          present_state <= PACKET_RECEIVE_2;
        end else begin
          present_state <= PACKET_SEND_2;
        end
      end

      PACKET_RECEIVE_2 : begin
        if (rx_done_led == 1'b1) begin
          present_state <= DONE_WAIT;
        end else begin
          present_state <= PACKET_RECEIVE_2;
        end
      end

      DONE_WAIT : begin
        if ((~tx_busy_led) && (~rx_busy_led)) begin
          present_state <= DONE;
        end else begin
          present_state <= DONE_WAIT;
        end
      end

      DONE : begin
        present_state <= DONE;
      end
    endcase
  end
end

interlaken_0_exdes #(.IS_DRIVER(1)) EXDES_DRV
(
  .init_clk                     (init_clk),
  .gt_ref_clk0_p                (gt_ref_clk0_p),
  .gt_ref_clk0_n                (gt_ref_clk0_n),
  .sys_reset                    (sys_reset),
  
  .gt_rxp_in                    (gt_rpttodrv_p),
  .gt_rxn_in                    (gt_rpttodrv_n),
  .gt_txp_out                   (gt_drvtorpt_p),
  .gt_txn_out                   (gt_drvtorpt_n),
  
  .tx_done_led                  (drv_tx_done_led),
  .tx_busy_led                  (drv_tx_busy_led),
  .tx_fail_led                  (drv_tx_fail_led),
  .rx_gt_locked_led             (drv_rx_gt_locked_led),
  .rx_aligned_led               (drv_rx_aligned_led),
  .rx_done_led                  (drv_rx_done_led),
  .rx_failed_led                (drv_rx_failed_led),
  .rx_busy_led                  (drv_rx_busy_led),
  .s_axi_pm_tick                (s_axi_pm_tick),
  .lbus_tx_rx_restart_in        (lbus_tx_rx_restart_in)
);

interlaken_0_exdes #(.IS_DRIVER(0)) EXDES_RPT
(
  .init_clk                     (init_clk),
  .gt_ref_clk0_p                (gt_ref_clk0_p),
  .gt_ref_clk0_n                (gt_ref_clk0_n),
  .sys_reset                    (sys_reset),
  
  .gt_rxp_in                    (gt_drvtorpt_p),
  .gt_rxn_in                    (gt_drvtorpt_n),
  .gt_txp_out                   (gt_rpttodrv_p),
  .gt_txn_out                   (gt_rpttodrv_n),
  
  .tx_done_led                  (rpt_tx_done_led),
  .tx_busy_led                  (rpt_tx_busy_led),
  .tx_fail_led                  (rpt_tx_fail_led),
  .rx_gt_locked_led             (rpt_rx_gt_locked_led),
  .rx_aligned_led               (rpt_rx_aligned_led),
  .rx_done_led                  (rpt_rx_done_led),
  .rx_failed_led                (rpt_rx_failed_led),
  .rx_busy_led                  (rpt_rx_busy_led),
  .s_axi_pm_tick                (s_axi_pm_tick),
  .lbus_tx_rx_restart_in        (lbus_tx_rx_restart_in)
);

endmodule
