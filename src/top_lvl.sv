`timescale 1ns / 1ps

module top_lvl (
    input board_clk_100M,
    input rst_btn,
    input spi_miso,
    output logic spi_sclk,
    output logic spi_cs,
    output logic uart_tx,
    output logic led_fifo_full,
    output logic led_fifo_empty
);
  // clocking
  logic clk_100M;
  logic clk_11_52M;
  logic pll_locked;

  clk_wiz_0 u_clk_gen (
      .clk_in1(board_clk_100M),
      .reset(rst_btn),
      .clk_out1(clk_100M),
      .clk_out2(clk_11_52M),
      .locked(pll_locked)
  );

  // spi/write
  logic afifo_wr;
  logic [7:0] afifo_wdata;
  logic afifo_full;
  assign led_fifo_full = afifo_full;

  adc_continous_reader #(
      .INPUT_CLK_SPEED_M(100)
  ) adc_spi_con (
      .clk_i  (clk_100M),
      .rst_ni (pll_locked),
      .miso_i (spi_miso),
      .stop_i (afifo_full),
      .sclk_o (spi_sclk),
      .cs_no  (spi_cs),
      .valid_o(afifo_wr),
      .data_o (afifo_wdata)
  );

  // uart/read
  logic afifo_rd;
  logic [7:0] afifo_rdata;
  logic transfer_trigger;
  logic afifo_empty;
  logic uart_busy;
  assign led_fifo_empty   = afifo_empty;
  assign transfer_trigger = (~afifo_empty) & (~uart_busy);

  uart_writer #(
      .INPUT_CLK_SPEED(11_520_000),
      .UART_BAUD_RATE (115_200)
  ) uart_tx_block (
      .clk_i(clk_11_52M),
      .rst_ni(pll_locked),
      .data_i(afifo_rdata),
      .wr_i(transfer_trigger),
      .busy_o(uart_busy),
      .uart_tx_o(uart_tx)
  );

  afifo #(
      .DATA_WIDTH  (8),  // 8 bit data width
      .BUFFER_WIDTH(5)   // 32 entries
  ) afifo_spi_uart (
      .wclk_i(clk_100M),
      .wrst_ni(pll_locked),
      .wr_i(afifo_wr),
      .wdata_i(afifo_wdata),
      .wfull_o(afifo_full),
      .rclk_i(clk_11_52M),
      .rrst_ni(pll_locked),
      .rd_i(transfer_trigger),
      .rdata_o(afifo_rdata),
      .rempty_o(afifo_empty)
  );
endmodule
