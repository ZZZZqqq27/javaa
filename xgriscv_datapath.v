//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The datapath of the pipeline.
//de ====================================================================
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
	input 		          	lb,lh,sb,sh,
	input          		        memtoregD, regwriteD,
	input STYPE,
  	// to controller
	output [6:0]		           opD,
	output [2:0]		           funct3D,
	output [6:0]		           funct7D
	);
	wire hazardRESULT=1'b0;
	wire resetHelp= reset ?1 :hazardRESULT ;

	wire jW, pcsrc;
	// next PC logic (operates in fetch and decode)
	wire [`ADDR_SIZE-1:0]	 pcplus4F, nextpcF, pcbranchD, pcadder2aD, pcadder2bD, pcbranch0D;
	wire [`INSTR_SIZE-1:0]	INSTRUCTION;
	wire [`ADDR_SIZE-1:0]	pcD, pcplus4D;
	wire flushD = pcsrc; 
	wire regwriteW;
	wire  NOCHANGEIFIDREG;
wire STALLFlUSH;
wire PCNOTCHANGE; 
wire [`RFIDX_WIDTH-1:0] ReadData2Add;
wire[4:0]  rdD     = INSTRUCTION[11:7];

	wire[4:0]  ReadData1Add   = INSTRUCTION[19:15];
	wire[11:0]  immD    = INSTRUCTION[31:20];
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
	wire[4:0] ReadData1AddE;

wire[4:0]ReadData2AddE;

 

	// for control signals
	wire       regwriteE, memwriteE, alusrcbE, memtoregE;
	wire [1:0] alusrcaE;
	wire lbE;
	wire lhE;
	wire sbE;
	wire shE;
	//wire  {sb,sh}E;
	wire [3:0] aluctrlE;
	wire [2:0] aluctrl1E;
	wire 	     flushE = pcsrc|STALLFlUSH;
	wire luE, jE, bE;
	
	
	// for data
	wire STYPEE;
	wire [`XLEN-1:0]	 ImmOut;
	wire [`XLEN-1:0]	ALUA;//先存寄存器读出来的
	wire [`XLEN-1:0]	 ALUB;//
	wire [`RFIDX_WIDTH-1:0] rdE;
	wire [`ADDR_SIZE-1:0] 	pcE, pcplus4E;
	wire [`XLEN-1:0]	srcaE;
	wire [`XLEN-1:0]	srcbE;
	wire [`XLEN-1:0]	aluoutE;
	wire[`ADDR_SIZE-1:0] PCoutE;
	//3 to1 的  控制信号 10 选 第三个输入信号， 控制信号 00选 第一个输入信号，01第二个	
	
	wire  [`XLEN-1:0] srcaEAddForward;
	wire [`XLEN-1:0]  srcbEAddForward;
	wire [1:0] ForwardResultA;
	wire [1:0] ForwardResultB;
	wire B;
	wire 		regwriteM, luM, memtoregM, jM, bM;
	wire 		flushM = 0;
	wire  lbM;
	wire lhM;
	wire   sbM;
	wire   shM;
	wire [`XLEN-1:0] srcb1M;
	wire[`ADDR_SIZE-1:0] PCoutM;
	wire [`ADDR_SIZE-1:0]	pcplus4M;
 	wire [`RFIDX_WIDTH-1:0]	 rdM;
	wire [`RFIDX_WIDTH-1:0] rs2M;
	wire MEMWBDATASELECT;
	wire [`XLEN-1:0] dmoutM;
	wire [`XLEN-1:0]REALINDMEM;
	 wire flushW = 0;//fulsh在后面调整
  wire memtoregW, bW;
  wire[`ADDR_SIZE-1:0] PCoutW;
  wire[`XLEN-1:0]		   AluOutW;//写寄存器的可能是ALU算出来的
  wire[`XLEN-1:0]		 dOutWr;//写寄存器的可能是DMEM读出来的
   wire[`RFIDX_WIDTH-1:0]	 rdW;
	wire [`ADDR_SIZE-1:0]	pcplus4W;
	//之后就在这儿弄一个冲指令的
	mux2to1	    pcsrcmux(pcplus4F, pcbranchD, pcsrc, nextpcF);
	
	//wire pcChangeEn; 
	// IF阶段
	pcenr      	 pcreg(clk, reset,  PCNOTCHANGE, nextpcF, pcF);

assign pcplus4F = pcF + `ADDR_SIZE'b100;
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	// IF/ID pipeline registers
	
//wire stall help
	floprcWITHNOCHANGE #(`INSTR_SIZE) 	pr1D(clk, resetHelp, flushD, NOCHANGEIFIDREG,instrF, INSTRUCTION);     // instruction,//contro register
	floprcWITHNOCHANGE #(`ADDR_SIZE)	  pr2D(clk, resetHelp, flushD,NOCHANGEIFIDREG, pcF, pcD);           // pc
	floprcWITHNOCHANGE #(`ADDR_SIZE)	  pr3D(clk, resetHelp, flushD,NOCHANGEIFIDREG, pcplus4F, pcplus4D); // pc+4


//stall 

hazard USEHAZARD(STYPE,clk,memtoregE,rdE,ReadData1Add,ReadData2Add, regwriteE,STALLFlUSH, NOCHANGEIFIDREG,PCNOTCHANGE);

	// ID阶段
	
	assign  opD 	= INSTRUCTION[6:0];
	//assign  rdD     = INSTRUCTION[11:7];

	assign  ReadData2Add   	= INSTRUCTION[24:20];
	assign  funct7D = INSTRUCTION[31:25];
	assign  funct3D = INSTRUCTION[14:12];
	
	

	imm 	im(ItypeIm, StypeIm, BtypeIm, UtypeIm, JtypeIm, immctrlD, ImmResult);
	//对立即数进行扩展
	
	regfile rf(clk, ReadData1Add, ReadData2Add, rdata1D, rdata2D, regwriteW, waddrW, WriRe, pcW);
	//寄存器读写数据
	/////////////////////////////////////////////////////////////////////////////////////////////////////
// ID/EX 
//for forwarding

	
	floprc #(1) 	prSTYPE(clk, reset, flushE, STYPE, STYPEE);        	
	floprc #(20) regE(clk, reset, flushE,
                  {regwriteD, memwriteD, memtoregD, {lb,lh}, {sb,sh}, lunsignedD, alusrcaD, alusrcbD, aluctrlD, aluctrl1D, jD, bD}, 
                  {regwriteE, memwriteE, memtoregE, {lbE,lhE}, {sbE,shE}, luE,		  alusrcaE, alusrcbE, aluctrlE, aluctrl1E, jE, bE});//通过这里写过来的，两位
	floprc #(`XLEN) 	pr1E(clk, reset, flushE, rdata1D, ALUA);        	// data from rs1
	floprc #(`XLEN) 	pr2E(clk, reset, flushE, rdata2D, ALUB);         // data from rs2
	floprc #(`XLEN) 	pr3E(clk, reset, flushE, ImmResult, ImmOut);        // imm output
 	floprc #(`RFIDX_WIDTH)  pr6E(clk, reset, flushE, rdD, rdE);         // rd
 	floprc #(`ADDR_SIZE)	pr8E(clk, reset, flushE, pcD, pcE);            // pc
 	floprc #(`ADDR_SIZE)	pr9E(clk, reset, flushE, pcplus4D, pcplus4E);  // pc+4

	//harzard flop
	floprc #(10)	addtohazard(clk, reset, flushE, {ReadData1Add,ReadData2Add}, {ReadData1AddE,ReadData2AddE});






	// EX阶段
	
	//wire [1:0] FORWARDAResult;
	//wire [1:0] FORWARDBResult;
	mux3to1   srcamux(ALUA, 0, pcE, alusrcaE, srcaE);   //倒数第二个是选择信号，在加了forwarding和 hazarding之后
	mux2to1  srcbmux(ALUB, ImmOut, alusrcbE, srcbE);			
	
	forward UseForward(STYPEE,regwriteM,rdM,ReadData1AddE,ReadData2AddE,regwriteW,rdW, ForwardResultA, ForwardResultB);
	mux3to1 sraForwardMux( srcaE	, WriRe,aluoutM  ,ForwardResultA,srcaEAddForward) ;	//这里要看好顺序
	mux3to1 srbForwardMux(	srcbE,WriRe ,aluoutM , ForwardResultB,srcbEAddForward);
	alu ALU(srcaEAddForward, srcbEAddForward ,  aluctrlE, aluctrl1E, aluoutE);
	//aluoutE还是正确的
	
	//用forward时把下面这个alu注释了

	//alu alu(srcaE, srcbE,  aluctrlE, aluctrl1E, aluoutE);
	
		assign  PCoutE = pcE+ImmOut;	//如果branch，下一个pc
	
	assign B = bE & aluoutE[0];
	mux2to1 brmux(aluoutE, PCoutE, B, pcbranchD);			 // pcsrc mux	

	assign pcsrc = jE | B;
		///////////////////////////////////////////////////////////////////////////////////
	// EX/MEM pipeline registers
	// for control signals
	
	floprc #(`XLEN+10) 	regM(clk, reset, flushM,
                  	{ALUB, regwriteE, memwriteE, memtoregE, {lbE,lhE}, luE, {sbE,shE}, jE, bE},
                  	{srcb1M, regwriteM, memwriteM, memtoregM, {lbM,lhM}, luM, {sbM,shM}, jM, bM});
	floprc #(`ADDR_SIZE) 	regpcM(clk, reset, flushM, PCoutE, PCoutM);


	// for data
	
	floprc #(`XLEN) 	        pr1M(clk, reset, flushM, aluoutE, aluoutM);
	floprc #(`RFIDX_WIDTH) 	 pr2M(clk, reset, flushM, rdE, rdM);
	floprc #(`ADDR_SIZE)	    pr3M(clk, reset, flushM, pcE, pcM);            // pc
	floprc #(`ADDR_SIZE)	    pr4M(clk, reset, flushM, pcplus4E, pcplus4M);            // pc+4
	
	
	
						//  为了WB-MEM写的传rs2
	
	floprc #(`RFIDX_WIDTH)	    pr5M(clk, reset, flushM, ReadData2AddE,rs2M); 
	//MEM阶段
	//这里对mem的处理有不一样！！

	
	WBMEM wbmem(memwriteM,rs2M,rdW,MEMWBDATASELECT);
	
	//应该是没报错
	
	
	mux2to1  WBMEMMUX(srcb1M,WriRe,MEMWBDATASELECT,REALINDMEM);
	//dmem dmem(clk, memwriteM, aluoutM, srcb1M, lbM,lhM,sbM,shM, luM, dmoutM);
dmem dmem(clk, memwriteM, aluoutM,REALINDMEM/*, srcb1M*/, lbM,lhM,sbM,shM, luM, dmoutM);
  ///////////////////////////////////////////////////////////////////////////////////
  // MEM/WB pipeline registers
  // for control signals
 
floprc #(`XLEN+4) regW(clk, reset, flushW, {dmoutM, regwriteM, memtoregM, jM, bM}, {dOutWr, regwriteW, memtoregW, jW, bW});
floprc #(`ADDR_SIZE) 	regpcW(clk, reset, flushW, PCoutM, PCoutW);
	
  // for data
								
 

  floprc #(`XLEN) 	       pr1W(clk, reset, flushW, aluoutM, AluOutW);//clk,reset,clear,datain,
  floprc #(`RFIDX_WIDTH)  pr2W(clk, reset, flushW, rdM, rdW);
  floprc #(`ADDR_SIZE)	   pr3W(clk, reset, flushW, pcM, pcW);            // pc
  floprc #(`ADDR_SIZE)	   pr4W(clk, reset, flushW, pcplus4M, pcplus4W);            // pc+4
	mux3to1  wdatamux(AluOutW, pcplus4W, dOutWr, {memtoregW, jW}, WriRe);		//三选一写到register,可能是跳转指令后存地址
	assign waddrW = rdW;
	

endmodule


