module fifo_single_clock_reg_v2 (
	clk,
	nrst,
	w_req,
	w_data,
	r_req,
	r_data,
	cnt,
	empty,
	full,
	fail
);
	reg _sv2v_0;
	parameter FWFT_MODE = "TRUE";
	parameter DEPTH = 8;
	parameter DEPTH_W = $clog2(DEPTH) + 1;
	parameter DATA_W = 32;
	parameter USE_INIT_FILE = "FALSE";
	parameter INIT_CNT = 1'sb0;
	input clk;
	input nrst;
	input w_req;
	input [DATA_W - 1:0] w_data;
	input r_req;
	output reg [DATA_W - 1:0] r_data;
	output reg [DEPTH_W - 1:0] cnt;
	output reg empty;
	output reg full;
	output reg fail;
	reg [(DEPTH * DATA_W) - 1:0] data;
	reg [DEPTH_W - 1:0] w_ptr;
	reg [DEPTH_W - 1:0] r_ptr;
	initial begin
		data = 1'sb0;
		w_ptr[DEPTH_W - 1:0] = 1'sb0;
		r_ptr[DEPTH_W - 1:0] = 1'sb0;
		cnt[DEPTH_W - 1:0] = 1'sb0;
	end
	reg [DATA_W - 1:0] data_buf = 1'sb0;
	function [DEPTH_W - 1:0] inc_ptr;
		input [DEPTH_W - 1:0] ptr;
		if (ptr[DEPTH_W - 1:0] == (DEPTH - 1))
			inc_ptr[DEPTH_W - 1:0] = 1'sb0;
		else
			inc_ptr[DEPTH_W - 1:0] = ptr[DEPTH_W - 1:0] + 1'b1;
	endfunction
	always @(posedge clk) begin : sv2v_autoblock_1
		integer i;
		if (~nrst) begin
			data <= 1'sb0;
			w_ptr[DEPTH_W - 1:0] <= 1'sb0;
			r_ptr[DEPTH_W - 1:0] <= 1'sb0;
			cnt[DEPTH_W - 1:0] <= 1'sb0;
			data_buf[DATA_W - 1:0] <= 1'sb0;
		end
		else
			case ({w_req, r_req})
				2'b00:
					;
				2'b01:
					if (~empty) begin
						r_ptr[DEPTH_W - 1:0] <= inc_ptr(r_ptr[DEPTH_W - 1:0]);
						cnt[DEPTH_W - 1:0] <= cnt[DEPTH_W - 1:0] - 1'b1;
						data_buf[DATA_W - 1:0] <= data[r_ptr[DEPTH_W - 1:0] * DATA_W+:DATA_W];
					end
				2'b10:
					if (~full) begin
						w_ptr[DEPTH_W - 1:0] <= inc_ptr(w_ptr[DEPTH_W - 1:0]);
						data[w_ptr[DEPTH_W - 1:0] * DATA_W+:DATA_W] <= w_data[DATA_W - 1:0];
						cnt[DEPTH_W - 1:0] <= cnt[DEPTH_W - 1:0] + 1'b1;
					end
				2'b11:
					if (empty) begin
						w_ptr[DEPTH_W - 1:0] <= inc_ptr(w_ptr[DEPTH_W - 1:0]);
						data[w_ptr[DEPTH_W - 1:0] * DATA_W+:DATA_W] <= w_data[DATA_W - 1:0];
						cnt[DEPTH_W - 1:0] <= cnt[DEPTH_W - 1:0] + 1'b1;
					end
					else if (full) begin
						r_ptr[DEPTH_W - 1:0] <= inc_ptr(r_ptr[DEPTH_W - 1:0]);
						cnt[DEPTH_W - 1:0] <= cnt[DEPTH_W - 1:0] - 1'b1;
						data_buf[DATA_W - 1:0] <= data[r_ptr[DEPTH_W - 1:0] * DATA_W+:DATA_W];
					end
					else begin
						w_ptr[DEPTH_W - 1:0] <= inc_ptr(w_ptr[DEPTH_W - 1:0]);
						data[w_ptr[DEPTH_W - 1:0] * DATA_W+:DATA_W] <= w_data[DATA_W - 1:0];
						r_ptr[DEPTH_W - 1:0] <= inc_ptr(r_ptr[DEPTH_W - 1:0]);
						data_buf[DATA_W - 1:0] <= data[r_ptr[DEPTH_W - 1:0] * DATA_W+:DATA_W];
					end
			endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		empty = cnt[DEPTH_W - 1:0] == {DEPTH_W * 1 {1'sb0}};
		full = cnt[DEPTH_W - 1:0] == DEPTH;
		if (FWFT_MODE == "TRUE") begin
			if (~empty)
				r_data[DATA_W - 1:0] = data[r_ptr[DEPTH_W - 1:0] * DATA_W+:DATA_W];
			else
				r_data[DATA_W - 1:0] = 1'sb0;
		end
		else
			r_data[DATA_W - 1:0] = data_buf[DATA_W - 1:0];
		fail = (empty && r_req) || (full && w_req);
	end
	initial _sv2v_0 = 0;
endmodule
