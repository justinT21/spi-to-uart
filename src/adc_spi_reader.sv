`timescale 1ns / 1ps

module adc_spi_reader #(
    parameter int INPUT_CLK_SPEED_M = 100,  // MHz
    parameter int SPI_CLK_SPEED_M   = 2   // MHz
) (
    input clk_i,
    input rst_ni,
    input miso_i,
    input trigger_i,
    output logic sclk_o,
    output logic cs_no,
    output logic valid_o,
    output logic busy_o,
    output logic [7:0] data_o
);
  // toggle SCLK twice per period
  localparam int ClkDiv = INPUT_CLK_SPEED_M / (SPI_CLK_SPEED_M * 2);

  logic [$clog2(ClkDiv)-1:0] div_cnt;
  logic [15:0] shift_reg;
  logic [4:0] bit_cnt;


  always_ff @(posedge clk_i or negedge rst_ni) begin : adc_clocked
    if (!rst_ni) begin
      sclk_o <= 1'b1;  // default high
      cs_no <= 1'b1;
      valid_o <= 1'b0;
      busy_o <= 1'b0;
      data_o <= '0;
      bit_cnt <= '0;
      shift_reg <= '0;
      div_cnt <= '0;
    end else begin
      valid_o <= '0;  // only pulse for one cycle

      if (!busy_o) begin
        if (trigger_i) begin
          busy_o  <= '1;
          cs_no <= '0;
        end
      end else begin
        if (div_cnt == ClkDiv - 1) begin
          div_cnt <= '0;
          sclk_o  <= ~sclk_o;  // toggle SPI clk

          // rising edge (0 -> 1)
          if (sclk_o == 1'b0) begin
            shift_reg <= {shift_reg[14:0], miso_i};
            bit_cnt   <= bit_cnt + 1'b1;

            if (bit_cnt == 5'd15) begin // EOF
              busy_o <= 1'b0;
              bit_cnt <= '0;

              data_o <= {shift_reg[14:0], miso_i}[12:5]; // hasn't been loaded yet so manually do it
              valid_o <= 1'b1;

              // defaults
              cs_no <= 1'b1;
              sclk_o <= 1'b1;
            end
          end

        end else begin
          div_cnt <= div_cnt + 1'b1;
        end
      end
    end
  end
endmodule
