//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The overall of the pipelined xg-riscv implementation.
//
// ====================================================================

`include "xgriscv_defines.v"
module xgriscv_pipeline(//主模块
  input                   clk, reset,
  output[`ADDR_SIZE-1:0]  pcW);
  
  wire [31:0]    instr;
  wire [31:0]    pcF, pcM;
  wire           memwrite;
  wire [31:0]    addr, writedata, readdata;//从内存中读出来的数据
  
  imem U_imem(pcF, instr);

  xgriscv U_xgriscv(clk, reset, pcF, instr, memwrite, addr, writedata, pcM, pcW, readdata);
  
endmodule

// xgriscv: a pipelined riscv processor
module xgriscv(input         			        clk, reset,
               output [31:0] 			        pcF,
               input  [`INSTR_SIZE-1:0] instr,//把instruction送进来
               output					              memwrite,

               output [`ADDR_SIZE-1:0] 	daddr, 
               output [`XLEN-1:0] 		    writedata,
               output [`ADDR_SIZE-1:0] 	pcM,
               output [`ADDR_SIZE-1:0] 	pcW,
               input  [`XLEN-1:0] 		    readdata);
	
  wire [6:0]  opD;
 	wire [2:0]  funct3D, aluctrl1D;
	wire [6:0]  funct7D;
  wire [4:0]  immctrlD;
  wire        itypeD, jalD, jalrD, bunsignedD, pcsrcD;
  wire [3:0]  aluctrlD;
  wire [1:0]  alusrcaD;
  wire        alusrcbD, jD, bD;
  wire        memwriteD, lunsignedD;
  wire  lb;
  wire  lh;
      wire   sb;
        wire   sh;

  wire        memtoregD, regwriteD;
wire STYPE;
  controller  CONTROLLER(opD, funct3D, funct7D,
              immctrlD, itypeD,  bunsignedD,jalD, jalrD, pcsrcD, 
              aluctrlD, aluctrl1D, alusrcaD, alusrcbD,
              memtoregD, regwriteD,
              memwriteD, lunsignedD, jD, bD, lb,lh, sb,sh,STYPE); 


  datapath   DATA_PATH(clk, reset,
              instr, pcF,
             daddr,  memwrite, pcM, pcW,
              immctrlD, itypeD, jalD, jalrD, bunsignedD, pcsrcD, 
              aluctrlD, aluctrl1D, alusrcaD, alusrcbD, 
              memwriteD, lunsignedD,  jD, bD, lb,lh, sb,sh,
              memtoregD, regwriteD, STYPE,
              opD, funct3D, funct7D);

endmodule
