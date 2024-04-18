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
	
    if (reset) 
    	q <= 32'h00000000 ;
    else if (en)    
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
    if (reset)      q <= 0;
    else if (clear) q <= 0;
    else            q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, 
              input              s, 
              output [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, d2,
              input  [1:0]       s, 
              output [WIDTH-1:0] y);

  assign  y = s[1] ? d2 : (s[0] ? d1 : d0); 
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
/*
// shift left by 1 for address calculation
module sl1(
	input  [`ADDR_SIZE-1:0] a,
	output [`ADDR_SIZE-1:0] y);

  assign  y = {a[`ADDR_SIZE-2:0], 1'b0};
endmodule

// comparator for branch
module cmp(
  input [`XLEN-1:0] a, b,
  input             op_unsigned,
  output            zero,
  output            lt);

  assign zero = (a == b);
  assign lt = (!op_unsigned & ($signed(a) < $signed(b))) | (op_unsigned & (a < b));
endmodule

module ampattern (input [1:0] addr, input [1:0] swhb, output reg [3:0] amp); //amp: access memory pattern
  always@(*)
  case (swhb)
    2'b01: amp <= 4'b1111;
    2'b10: if (addr[1]) amp <= 4'b1100;
           else         amp <= 4'b0011; //addr[0]
    2'b11: case (addr)
              2'b00: amp <= 4'b0001;
              2'b01: amp <= 4'b0010;
              2'b10: amp <= 4'b0100;
              2'b11: amp <= 4'b1000;
           endcase
    default: amp <= 4'b1111;// it shouldn't happen
  endcase
endmodule
*/