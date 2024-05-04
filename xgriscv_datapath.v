//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The datapath of the pipeline.
// ====================================================================
//
`include "xgriscv_defines.v"

module datapath(
	input                    clk, reset,
	input [`INSTR_SIZE-1:0]  instrF, 	 // from instructon memory
	output[`ADDR_SIZE-1:0] 	 pcF, 		   // to instruction memory
  output[`XLEN-1:0]        aluoutM, 	 // to data memory: address
  output			                memwriteM,	// to data memory: write enable
 	output [`ADDR_SIZE-1:0]  pcM,        // to data memory: pc of the write instruction
 	
 	output [`ADDR_SIZE-1:0]  pcW,        // to testbench
	
	
	// from controller
	input [4:0]		            immctrlD,
	input			                 itype, jalD, jalrD, bunsignedD, pcsrcD,
	input [3:0]		            aluctrlD,
	input [2:0]					aluctrl1D,
	input [1:0]		            alusrcaD,
	input			                 alusrcbD,
	input			                 memwriteD, lunsignedD, jD, bD,
	input [1:0]		          	 lwhbD, swhbD,  
	input          		        memtoregD, regwriteD,
	
  	// to controller
	output [6:0]		           opD,
	output [2:0]		           funct3D,
	output [6:0]		           funct7D,
	output [4:0] 		          rdD, ReadData1Add,
	output [11:0]  		        immD,
	output 	       		        zeroD, ltD
	);


	wire jW, pcsrc;
	// next PC logic (operates in fetch and decode)
	wire [`ADDR_SIZE-1:0]	 pcplus4F, nextpcF, pcbranchD, pcadder2aD, pcadder2bD, pcbranch0D;
	//mux2 #(`ADDR_SIZE)	    pcsrcmux(pcplus4F, pcbranchD, pcsrcD, nextpcF);
	mux2to1	    pcsrcmux(pcplus4F, pcbranchD, pcsrc, nextpcF);
	
	// Fetch stage logic
	pcenr      	 pcreg(clk, reset, 1'b1, nextpcF, pcF);
	addr_adder  	pcadder1(pcF, `ADDR_SIZE'b100, pcplus4F);

	///////////////////////////////////////////////////////////////////////////////////
	// IF/ID pipeline registers
	wire [`INSTR_SIZE-1:0]	INSTRUCTION;
	wire [`ADDR_SIZE-1:0]	pcD, pcplus4D;
	wire flushD = pcsrc; 
	wire regwriteW;

	floprc #(`INSTR_SIZE) 	pr1D(clk, reset, flushD, instrF, INSTRUCTION);     // instruction,//contro register
	floprc #(`ADDR_SIZE)	  pr2D(clk, reset, flushD, pcF, pcD);           // pc
	floprc #(`ADDR_SIZE)	  pr3D(clk, reset, flushD, pcplus4F, pcplus4D); // pc+4

	// Decode
	wire [`RFIDX_WIDTH-1:0] ReadData2Add;
	assign  opD 	= INSTRUCTION[6:0];
	assign  rdD     = INSTRUCTION[11:7];
	assign  funct3D = INSTRUCTION[14:12];
	assign  ReadData1Add    = INSTRUCTION[19:15];
	assign  ReadData2Add   	= INSTRUCTION[24:20];
	assign  funct7D = INSTRUCTION[31:25];
	assign  immD    = INSTRUCTION[31:20];

	
	wire [11:0]  ItypeIm = INSTRUCTION[31:20];
	wire [11:0]		StypeIm	= {INSTRUCTION[31:25],INSTRUCTION[11:7]};
	wire [11:0]  BtypeIm	= {INSTRUCTION[31],INSTRUCTION[7],INSTRUCTION[30:25],INSTRUCTION[11:8]};//INSTRUCTION[31], INSTRUCTION[7], INSTRUCTION[30:25], INSTRUCTION[11:8], 12 bits
	wire [19:0]		UtypeIm	= INSTRUCTION[31:12];
	wire [19:0]  JtypeIm	= {INSTRUCTION[31],INSTRUCTION[19:12],INSTRUCTION[20],INSTRUCTION[30:21]};
	wire [`XLEN-1:0]	ImmResult;
	wire [`XLEN-1:0]	rdata1D;
	wire [`XLEN-1:0]	rdata2D;
	wire [`XLEN-1:0]	 WriRe;
	wire [`RFIDX_WIDTH-1:0]	waddrW;

	imm 	im(ItypeIm, StypeIm, BtypeIm, UtypeIm, JtypeIm, immctrlD, ImmResult);
	//对立即数进行扩展
	
	regfile rf(clk, ReadData1Add, ReadData2Add, rdata1D, rdata2D, regwriteW, waddrW, WriRe, pcW);
	//寄存器读写数据
	///////////////////////////////////////////////////////////////////////////////////
	// ID/EX pipeline registers

	// for control signals
	wire       regwriteE, memwriteE, alusrcbE, memtoregE;
	wire [1:0] alusrcaE;
	wire [1:0] lwhbE;
	wire [1:0] swhbE;
	wire [3:0] aluctrlE;
	wire [2:0] aluctrl1E;
	wire 	     flushE = pcsrc;
	wire luE, jE, bE;
	floprc #(20) regE(clk, reset, flushE,
                  {regwriteD, memwriteD, memtoregD, lwhbD, swhbD, lunsignedD, alusrcaD, alusrcbD, aluctrlD, aluctrl1D, jD, bD}, 
                  {regwriteE, memwriteE, memtoregE, lwhbE, swhbE, luE,		  alusrcaE, alusrcbE, aluctrlE, aluctrl1E, jE, bE});//通过这里写过来的，两位
  
	// for data
	//wire [`XLEN-1:0]	ALUA, ALUB, ImmOut, srcaE, srcbE, aluoutE;
	wire [`XLEN-1:0]	 ImmOut;
	wire [`XLEN-1:0]	ALUA;//先存寄存器读出来的
	wire [`XLEN-1:0]	 ALUB;//
	wire [`RFIDX_WIDTH-1:0] rdE;
	wire [`ADDR_SIZE-1:0] 	pcE, pcplus4E;
	floprc #(`XLEN) 	pr1E(clk, reset, flushE, rdata1D, ALUA);        	// data from rs1
	floprc #(`XLEN) 	pr2E(clk, reset, flushE, rdata2D, ALUB);         // data from rs2
	floprc #(`XLEN) 	pr3E(clk, reset, flushE, ImmResult, ImmOut);        // imm output
 	floprc #(`RFIDX_WIDTH)  pr6E(clk, reset, flushE, rdD, rdE);         // rd
 	floprc #(`ADDR_SIZE)	pr8E(clk, reset, flushE, pcD, pcE);            // pc
 	floprc #(`ADDR_SIZE)	pr9E(clk, reset, flushE, pcplus4D, pcplus4E);  // pc+4

	// EX阶段
	wire [`XLEN-1:0]	srcaE;
	wire [`XLEN-1:0]	srcbE;
	wire [`XLEN-1:0]	aluoutE;
	mux3to1   srcamux(ALUA, 0, pcE, alusrcaE, srcaE);   //倒数第二个是选择信号，在加了forwarding和 hazarding之后
	mux2to1  srcbmux(ALUB, ImmOut, alusrcbE, srcbE);			
	wire[`ADDR_SIZE-1:0] PCoutE;

	alu alu(srcaE, srcbE,  aluctrlE, aluctrl1E, aluoutE);
	alu alu1(pcE, ImmOut,  `ALU_CTRL_ADD, 3'b000, PCoutE);
		
	wire B;
	assign B = bE & aluoutE[0];
	mux2to1 brmux(aluoutE, PCoutE, B, pcbranchD);			 // pcsrc mux	

	assign pcsrc = jE | B;
		///////////////////////////////////////////////////////////////////////////////////
	// EX/MEM pipeline registers
	// for control signals
	wire 		regwriteM, luM, memtoregM, jM, bM;
	wire 		flushM = 0;
	wire [1:0] lwhbM, swhbM;
	wire [`XLEN-1:0] srcb1M;
	wire[`ADDR_SIZE-1:0] PCoutM;
	floprc #(`XLEN+10) 	regM(clk, reset, flushM,
                  	{ALUB, regwriteE, memwriteE, memtoregE, lwhbE, luE, swhbE, jE, bE},
                  	{srcb1M, regwriteM, memwriteM, memtoregM, lwhbM, luM, swhbM, jM, bM});
	floprc #(`ADDR_SIZE) 	regpcM(clk, reset, flushM, PCoutE, PCoutM);


	// for data
	wire [`ADDR_SIZE-1:0]	pcplus4M;
 	wire [`RFIDX_WIDTH-1:0]	 rdM;
	floprc #(`XLEN) 	        pr1M(clk, reset, flushM, aluoutE, aluoutM);
	floprc #(`RFIDX_WIDTH) 	 pr2M(clk, reset, flushM, rdE, rdM);
	floprc #(`ADDR_SIZE)	    pr3M(clk, reset, flushM, pcE, pcM);            // pc
	floprc #(`ADDR_SIZE)	    pr4M(clk, reset, flushM, pcplus4E, pcplus4M);            // pc+4
	
	//MEM阶段
	//*这里对mem的处理有不一样！！


	wire [`XLEN-1:0] dmoutM;
	dmem dmem(clk, memwriteM, aluoutM, srcb1M, /*pcM,*/ lwhbM, swhbM, luM, dmoutM);

  ///////////////////////////////////////////////////////////////////////////////////
  // MEM/WB pipeline registers
  // for control signals
  wire flushW = 0;
	wire memtoregW, bW;
		wire[`ADDR_SIZE-1:0] PCoutW;
  wire[`XLEN-1:0]		   AluOutW;//写寄存器的可能是ALU算出来的
  wire[`XLEN-1:0]		 dOutWr;//写寄存器的可能是DMEM读出来的
	floprc #(`XLEN+4) regW(clk, reset, flushW, {dmoutM, regwriteM, memtoregM, jM, bM}, {dOutWr, regwriteW, memtoregW, jW, bW});
	floprc #(`ADDR_SIZE) 	regpcW(clk, reset, flushW, PCoutM, PCoutW);
	
  // for data
								
  wire[`RFIDX_WIDTH-1:0]	 rdW;
	wire [`ADDR_SIZE-1:0]	pcplus4W;
//*****************这里有个forward
  floprc #(`XLEN) 	       pr1W(clk, reset, flushW, aluoutM, AluOutW);//clk,reset,clear,datain,
  floprc #(`RFIDX_WIDTH)  pr2W(clk, reset, flushW, rdM, rdW);
  floprc #(`ADDR_SIZE)	   pr3W(clk, reset, flushW, pcM, pcW);            // pc
  floprc #(`ADDR_SIZE)	   pr4W(clk, reset, flushW, pcplus4M, pcplus4W);            // pc+4
	mux3to1  wdatamux(AluOutW, pcplus4W, dOutWr, {memtoregW, jW}, WriRe);		//三选一写到register
	assign waddrW = rdW;
	//assign pcsrcD = jW;
	//assign pcsrc = jW | B;
endmodule