`timescale 1ns / 1ps

module adc_continous_reader #(
    parameter int INPUT_CLK_SPEED_M = 100  // MHz
) (
    input clk_i,
    input rst_ni,
    input miso_i,
    input stop_i,
    output logic sclk_o,
    output logic cs_no,
    output logic valid_o,
    output logic [7:0] data_o
);
  logic spi_busy;
  logic spi_trigger;

  localparam int TimerDivs = 60 / (1000 / INPUT_CLK_SPEED_M);
  logic [$clog2(TimerDivs)-1:0] timer;  // require 50 ns of quiet time -> 60 ns

  always_ff @(posedge clk_i or negedge rst_ni) begin : continous_clocking
    if (!rst_ni) begin
      spi_trigger <= 1'b0;
      timer <= '0;
    end else begin
      spi_trigger <= 1'b0;  // default low

      if (!spi_busy && !stop_i) begin
        if (timer == TimerDivs) begin
          spi_trigger <= 1'b1;
          timer <= '0;
        end else begin
          timer <= timer + 1'b1;
        end
      end else begin
        timer <= '0;
      end

    end
  end

  adc_spi_reader #(
      .INPUT_CLK_SPEED_M(INPUT_CLK_SPEED_M),
      .SPI_CLK_SPEED_M  (4)
  ) adc_spi_rx (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .miso_i(miso_i),
      .trigger_i(spi_trigger),
      .sclk_o(sclk_o),
      .cs_no(cs_no),
      .valid_o(valid_o),
      .busy_o(spi_busy),
      .data_o(data_o)
  );
endmodule
