`timescale 1ns/1ps

module tb_fifo_single_clock_reg_v3;

  // ------------------------------------------------------------
  // Clock / reset
  // ------------------------------------------------------------
  reg clk;
  reg nrst;

  // ------------------------------------------------------------
  // FIFO inputs
  // ------------------------------------------------------------
  reg         w_req;
  reg [31:0]  w_data;
  reg         r_req;

  // ------------------------------------------------------------
  // FIFO outputs
  // ------------------------------------------------------------
  wire [31:0] r_data;
  wire [3:0]  cnt;     // DEPTH=8 -> DEPTH_W = clog2(8)+1 = 4
  wire        empty;
  wire        full;
  wire        fail;

  // ------------------------------------------------------------
  // DUT (default parameters)
  // ------------------------------------------------------------
  fifo_single_clock_reg_v3 dut (
    .clk    (clk),
    .nrst   (nrst),
    .w_req  (w_req),
    .w_data (w_data),
    .r_req  (r_req),
    .r_data (r_data),
    .cnt    (cnt),
    .empty  (empty),
    .full   (full),
    .fail   (fail)
  );

  // ------------------------------------------------------------
  // Clock generation: 100 MHz (10 ns period)
  // ------------------------------------------------------------
initial begin
  clk = 0;
  forever #5 clk = ~clk;
end

initial begin
  $dumpfile("fifo_v3.vcd");
  $dumpvars(0, tb_fifo_single_clock_reg_v3);
end

  // ------------------------------------------------------------
  // Stimulus
  // ------------------------------------------------------------

  integer cycle;
  integer push_cnt;
  integer pop_cnt;

  always @(posedge clk) begin
    cycle <= cycle + 1;

    // defaults
    w_req <= 0;
    r_req <= 0;

    // Reset for first 3 cycles
    if (cycle < 3) begin
      nrst <= 0;
      w_data <= 0;
    end
    else begin
      nrst <= 1;

      // -------------------------------
      // Push 10 words
      // -------------------------------
      if (push_cnt < 10) begin
        w_req  <= 1;
        w_data <= 32'h1000_0000 + push_cnt;
        push_cnt <= push_cnt + 1;
      end

      // -------------------------------
      // Then pop 10 words
      // -------------------------------
      else if (pop_cnt < 10) begin
        r_req <= 1;
        pop_cnt <= pop_cnt + 1;
      end

      // -------------------------------
      // Finish
      // -------------------------------
      else if (cycle > 50) begin
      	$finish;
      end

    end
  end

  // ------------------------------------------------------------
  // Initial values (no timing)
  // ------------------------------------------------------------
  initial begin
    cycle    = 0;
    push_cnt = 0;
    pop_cnt  = 0;
    nrst     = 0;
    w_req    = 0;
    r_req    = 0;
    w_data   = 0;
  end

endmodule

