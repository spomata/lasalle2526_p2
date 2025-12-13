SIM = iverilog
RUN = vvp
CVT = sv2v
SYN = yosys

OUTv2 = fifo_tb_v2.out
OUTv3 = fifo_tb_v3.out

SRCSv2 = \
  tb_fifo_single_clock_reg_v2.v \
  fifo_single_clock_reg_v2.sv

SRCSv3 = \
  tb_fifo_single_clock_reg_v3.v \
  fifo_single_clock_reg_v3.sv
  
sim_v2:
	$(SIM) -g2012 -o $(OUTv2) $(SRCSv2)
	$(RUN) $(OUTv2)

syn_v2:
	$(CVT) fifo_single_clock_reg_v2.sv > fifo_single_clock_reg_v2.v
	$(SYN) -s synth_v2.ys | tee syn_v2.log

wave_v2:
	gtkwave fifo_v2.vcd

sim_v3:
	$(SIM) -g2012 -o $(OUTv3) $(SRCSv3)
	$(RUN) $(OUTv3)

syn_v3:
	$(CVT) fifo_single_clock_reg_v3.sv > fifo_single_clock_reg_v3.v
	$(SYN) -s synth_v3.ys | tee syn_v3.log

wave_v3:
	gtkwave fifo_v3.vcd


clean:
	rm -f $(OUTv2) $(OUTv3) fifo_v2.vcd fifo_v3.vcd


