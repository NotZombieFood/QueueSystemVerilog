module queue 
#(
  parameter SIZE = 16,
  parameter COUNTER = 3,
  parameter NUM_REGS = 8 
)(
  input clk,
  input rst,
  input  wr,
  input  rd,
  input  [SIZE-1:0] wr_data,
  output [SIZE-1:0] rd_data
  output logic flagFull, flagEmpty
);
 logic  [COUNTER:0]  rd_addr, wr_addr;

 always_comb begin
 	flagEmpty = ~(wr_addr[COUNTER:0]^rd_addr[COUNTER:0]);
	flagFull = ~(wr_addr[COUNTER-1:0]^rd_addr[COUNTER-1:0])&(wr_addr[COUNTER]^rd_addr[COUNTER]);
 end

logic [SIZE-1:0] rf [NUM_REGS-1:0];

integer i;
	always_ff @ (posedge clk) begin
    	if (rst)
			for (i = 0; i < NUM_REGS-1; i = i + 1)
				rf[i] <= 0;
		else  if (wr)
        rf[wr_addr] <= wr_data;
	end
 always_ff @(posedge clk) begin
 	if(rst) begin
 		rd_addr <=0;
	end else if(rd&~flagEmpty) begin
 		rd_addr <= rd_addr + 1;
 	end
 end
  always_ff @(posedge clk) begin
 	if(rst) begin
 		wr_addr <= 0;
 	end else if(wr&~flagFull) begin
 		wr_addr <= wr_addr + 1;
 	end
 end
    assign rd_data = rf[rd_addr];
endmodule