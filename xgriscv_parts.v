//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The gadgets.
//
// ====================================================================

`include "xgriscv_defines.v"

// pc register with write enable
module pcenr (
	input             		clk, reset,
	input             		en,
	input      [`XLEN-1:0]	d, 
	output reg [`XLEN-1:0]	q);
 
	always @(posedge clk, posedge reset)
	
    /*if (reset) 
    	q <= 32'h00000000 ;
    else*/ if (en)    
    	q <=  d;
endmodule

// adder for address calculation
module addr_adder (//这种adder给取消
	input  [31:0] a, b,
	output [31:0] y);

	assign  y = a + b;
endmodule

// flop with reset and clear control
module floprc #(parameter WIDTH = 8)
              (input                  clk, reset, clear,
               input      [WIDTH-1:0] d, 
               output reg [WIDTH-1:0] q);

  always @(posedge clk, posedge reset)
    /*if (reset)      q <= 0;
    else */if (clear) q <= 0;
    else            q <= d;
endmodule

module imm (  //把立即数扩展
	input	[11:0]			iimm, 
	input	[11:0]			simm, 
	input	[11:0]			bimm, 
	input	[19:0]			uimm,
	input	[19:0]			jimm,
	input	[4:0]			 immctrl,

	output	reg [`XLEN-1:0] 	immout);
  always  @(*)
	 case (immctrl)
		`IMM_CTRL_ITYPE:	immout <= {{{`XLEN-12}{iimm[11]}}, iimm[11:0]};
		`IMM_CTRL_UTYPE:	immout <= {uimm[19:0], 12'b0};
		`IMM_CTRL_STYPE:	immout <= {{{32-12}{simm[11]}}, simm[11:0]};
		`IMM_CTRL_BTYPE:    immout <= {{{32-13}{bimm[11]}}, bimm[11:0], 1'b0};
		`IMM_CTRL_JTYPE:	immout <= {{{32-21}{jimm[19]}}, jimm[19:0], 1'b0};
		default:			immout <= `XLEN'b0;
	 endcase
endmodule
