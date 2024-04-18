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

/*
module dmem(
    input            clk, we,
    input  [`XLEN-1:0] a, wd,
    input  [`ADDR_SIZE-1:0] pc,
    input  [1:0] lwhb, swhb,
    input  lu,
    output [`XLEN-1:0] rd
);
// 重构RAM设计为32位宽的字，共256个字
reg [31:0] RAM[255:0];

// 用于读操作的临时寄存器
reg [`XLEN-1:0] rtmp;

// 读操作
always @(*) begin
    case (lwhb)
        2'b11: rtmp = RAM[a[9:2]]; // Load word, 仅用地址的高位部分，假设地址已经是字节对齐的
        2'b10: rtmp = lu ? {16'b0, RAM[a[9:2]][15:0]} : {{16{RAM[a[9:2]][15]}}, RAM[a[9:2]][15:0]}; // Load halfword
        2'b01: rtmp = lu ? {24'b0, RAM[a[9:2]][7:0]} : {{24{RAM[a[9:2]][7]}}, RAM[a[9:2]][7:0]}; // Load byte
    endcase
end

// 输出寄存器赋值
assign rd = rtmp;

// 写操作
always @(posedge clk) begin
    if (we) begin
        case (swhb)
            2'b11: RAM[a[9:2]] <= wd; // Store word
            2'b10: RAM[a[9:2]] <= (RAM[a[9:2]] & 32'hFFFF0000) | (wd & 32'h0000FFFF); // Store halfword
            2'b01: RAM[a[9:2]] <= (RAM[a[9:2]] & 32'hFFFFFF00) | (wd & 32'h000000FF); // Store byte
        endcase
    end
end

endmodule
*/