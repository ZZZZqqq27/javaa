//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The instruction memory and data memory.
//
// ====================================================================

`include "xgriscv_defines.v"

module imem(input  [`ADDR_SIZE-1:0]   address,
            output [`INSTR_SIZE-1:0]  readData);

  reg  [`INSTR_SIZE-1:0] RAM[`IMEM_SIZE-1:0];

  assign readData = RAM[address[`ADDR_SIZE-1:2]]; // instruction size aligned
endmodule


module dmem(input           	         clk, we,
            input  [`XLEN-1:0]        a, wd,
            input  [`ADDR_SIZE-1:0] 	 pc,
			input	[1:0]				lwhb,
			input	[1:0]				swhb,
			input						lu,
            output [`XLEN-1:0]        rd);

  reg  [7:0] RAM[4095:0];
	reg [31:0] rtmp;
	always @(*) begin
		case(lwhb)
		2'b11: rtmp <= {RAM[a+3],RAM[a+2],RAM[a+1],RAM[a]};
		2'b10: rtmp <= lu?{16'b0,RAM[a+1],RAM[a]}:{{16{RAM[a+1][7]}},RAM[a+1],RAM[a]};
		2'b01: rtmp <= lu?{24'b0,RAM[a]}:{{24{RAM[a][7]}},RAM[a]};
		endcase
	end

  assign rd = rtmp; // word aligned

  always @(posedge clk)
    if (we)
      begin
		//$display("writemem: %d", wd);
		case(swhb)
		2'b11: begin
		RAM[a] <= wd[7:0];
		RAM[a+1] <= wd[15:8];
		RAM[a+2] <= wd[23:16];
		RAM[a+3] <= wd[31:24];
		end
		2'b10: begin
		RAM[a] <= wd[7:0];
		RAM[a+1] <= wd[15:8];
		end
		2'b01: RAM[a] <= wd[7:0];//whether there need to implement 0?
		endcase
       
  	  end
endmodule