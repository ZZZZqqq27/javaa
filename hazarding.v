`include "xgriscv_defines.v"
/*
module hazard (input clk, input memtoreg, input[`RFIDX_WIDTH-1:0] rdE, input[`RFIDX_WIDTH-1:0] rs1D, input[`RFIDX_WIDTH-1:0] rs2D, input writenM, output reg writen);
	always @ (*)
	if(memtoreg && (rdE == rs1D || rdE == rs2D) && writenM)
		writen <= 1'b0;
	else
		writen <= 1'b1;
endmodule
*/

module forward (input STYPE,input regwriteM, input[`RFIDX_WIDTH-1:0] rdM, input[`RFIDX_WIDTH-1:0] rs1E, input[`RFIDX_WIDTH-1:0] rs2E,
				input regwriteW, input[`RFIDX_WIDTH-1:0] rdW, output reg[1:0] forwardA, output reg[1:0] forwardB);
	always@(*)	begin
		forwardA=2'b00;
		forwardB=2'b00;
		if(regwriteM&&rdM!=0)	begin
			if(rdM == rs1E)	forwardA=2'b10;
			if((rdM == rs2E)&&(STYPE==0)) forwardB=2'b10;
		end
		if(regwriteW&&rdW!=0)	begin
			if(!(regwriteM&&(rdM!=0)&&rdM==rs1E)
				&& rdW == rs1E)	forwardA=2'b01;
			if(!(regwriteM&&(rdM!=0)&&rdM==rs2E&&STYPE==0)
				&& rdW == rs2E) forwardB=2'b01;
		end
	end
endmodule
/*
addi x4,x0,3
sw x4,0(x0)
lw x5,0(x0)

lw	 x9, 0(x0)		
		sw	 x9, 4(x0)

*/
//WB/MEM
/*
module WBMEM(input memwriteM,input[`RFIDX_WIDTH-1:0] rs2M,input[`RFIDX_WIDTH-1:0] rdW,output reg MEMWBDATASELECT);
	always@(*)begin
		MEMWBDATASELECT=0;
	if(memwriteM==1)begin
		if(memtoregM==1&&(rdW==rs2M))begin
		MEMWBDATASELECT=1;
		end
		end
	end
	endmodule
*/
	module WBMEM(
    input memwriteM, // 写入内存的信号
    input [`RFIDX_WIDTH-1:0] rs2M, // rs2M 寄存器的索引，用于数据写入
    input [`RFIDX_WIDTH-1:0] rdW, // rdW 寄存器的索引
    output reg MEMWBDATASELECT // 内存数据选择信号
);

always @(*) begin
    MEMWBDATASELECT = 0; // 默认选择写入寄存器的数据

    if (memwriteM == 1) begin // 如果允许写入内存
        if (memwriteM == 1 && (rdW == rs2M)) begin // 如果写回到寄存器并且是需要写入的数据
            MEMWBDATASELECT = 1; // 切换为选择内存的数据
        end
    end
end

endmodule
