//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The controller module generates the controlling signals.
//
// ====================================================================

`include "xgriscv_defines.v"
//在进行解码后，要产生控制信号

module controller(
  
  input [6:0]	              opcode,
  input [2:0]               funct3,
  input [6:0]               funct7,
 
  output [4:0]              immctrl,            // for the ID stage
 
  output                    itype, 
  output              bunsigned, 
  output jal, jalr,
   output pcsrc,
  output reg  [3:0]         aluctrl,            // for the EX stage 
  output reg  [2:0]			aluBraCtr,
  output [1:0]              alusrca,//OP_JAL 和 OP_AUIPC 要把 当前pc写回寄存器
  output                      alusrcb,  
  output                    memtoreg, regwrite , // for the WB stage
  output memwrite, lunsigned, j, btype,  // for the MEM stage
  
  output  			lb, lh, sb, sh,
  output     stype);
 // output                    memtoreg, regwrite  // for the WB stage
//);
  //输出只用
//先判断是什么type，
  wire ISLUI		= (opcode == `OP_LUI);
  wire ISAUIPC	= (opcode == `OP_AUIPC);
  wire JAL		= (opcode == `OP_JAL);
  wire JALR	= (opcode == `OP_JALR);
  wire ISBRANCH= (opcode == `OP_BRANCH);
  wire ISLOAD	= (opcode == `OP_LOAD); 
  wire ISSTORE	= (opcode == `OP_STORE);
  wire ADDWITHIMM	= (opcode == `OP_ADDI);
  wire ADDWITH = (opcode == `OP_ADD);
  wire ISBGEU	= ISBRANCH && (funct3 == `FUNCT3_BGEU);
  wire ISBLTU	= ISBRANCH && (funct3 == `FUNCT3_BLTU);
  wire LB		= ISLOAD && (funct3 == `FUNCT3_LB);
  wire LH		= ISLOAD && (funct3 == `FUNCT3_LH);
  wire LW		= ISLOAD && (funct3 == `FUNCT3_LW);
  wire LHU		= ISLOAD && (funct3 == `FUNCT3_LHU);
  wire LBU		= ISLOAD && (funct3 == `FUNCT3_LBU);
  wire SB		= ISSTORE && (funct3 == `FUNCT3_SB);
  wire SW		= ISSTORE && (funct3 == `FUNCT3_SW);
   wire SH		= ISSTORE && (funct3 == `FUNCT3_SH);
  wire ADDI	= ADDWITHIMM && (funct3 == `FUNCT3_ADDI);
  assign itype = ISLOAD || ADDWITHIMM || JALR;
  assign stype = ISSTORE;
  wire utype = ISLUI || ISAUIPC;
  wire jtype = JAL;
	reg jtmp;
  assign immctrl = {itype, stype, btype, utype, jtype};
  assign jal = JAL;
  assign jalr = JALR;
  assign bunsigned = ISBLTU | ISBGEU;
 
  assign pcsrc = 0;
 
  assign alusrca = ISLUI ? 2'b01 : (JAL||ISAUIPC ? 2'b10 : 2'b00); //ISLUI的情况下只要立即数
  assign alusrcb = ISLUI || ISAUIPC || itype || ISLOAD || ISSTORE || JALR||JAL;
 
  assign memwrite = ISSTORE;
	
	assign lb=LW|LH|LHU;
	assign lh= LW|LB|LBU;
	assign  sb=SW|SH;
	assign sh=SW|SB;
  assign lunsigned = LBU | LHU;
  assign memtoreg = ISLOAD;
  assign regwrite = ISLUI | ISAUIPC | ADDI | ADDWITH | itype | JALR | JAL;
//这个地方，由于是
  always @(*)	begin
	
    case(opcode)
      `OP_LUI:   
      begin 
          aluBraCtr <= `ALU_EMP;
			    aluctrl <= `ALU_CTRL_LUI;
			end
      `OP_AUIPC:  begin aluBraCtr <= `ALU_EMP;
			aluctrl <= `ALU_CTRL_AUIPC;
			end
	  `OP_LOAD:	  begin aluBraCtr <= `ALU_EMP;
			aluctrl <= `ALU_CTRL_ADD;
			end
	  `OP_STORE:  begin aluBraCtr <= `ALU_EMP;
			aluctrl <= `ALU_CTRL_ADD;
			end
	  `OP_JAL:   begin aluBraCtr <= `ALU_EMP;
			aluctrl <= `ALU_CTRL_ADD;
			end
	  `OP_JALR:	  begin aluBraCtr <= `ALU_EMP;
			aluctrl <= `ALU_CTRL_ADD;
			end
      `OP_ADDI:	  begin aluBraCtr <= `ALU_EMP;
			case(funct3)
             `FUNCT3_ADDI:	aluctrl <= `ALU_CTRL_ADD;
			 `FUNCT3_SLTI:  aluctrl <= `ALU_CTRL_SLT;
			 `FUNCT3_SLTIU: aluctrl <= `ALU_CTRL_SLTU;
			 `FUNCT3_XORI:	aluctrl <= `ALU_CTRL_XOR;
		     `FUNCT3_ORI:	aluctrl <= `ALU_CTRL_OR;
			 `FUNCT3_ANDI:	aluctrl <= `ALU_CTRL_AND;
			 `FUNCT3_SL: case(funct7)
							`FUNCT7_SLLI: aluctrl <= `ALU_CTRL_SLL;
							default:		aluctrl <= `ALU_CTRL_ZERO;	
						endcase
			 `FUNCT3_SR: case(funct7)
				`FUNCT7_SRLI: aluctrl <= `ALU_CTRL_SRL;
				`FUNCT7_SRAI: aluctrl <= `ALU_CTRL_SRA;
              default:		aluctrl <= `ALU_CTRL_ZERO;	
                  endcase
			endcase
			end
	`OP_ADD:	begin aluBraCtr <= `ALU_EMP;
		case(funct3)
			`FUNCT3_ADD:
				case(funct7)
					`FUNCT7_ADD: aluctrl <= `ALU_CTRL_ADD;
					`FUNCT7_SUB: aluctrl <= `ALU_CTRL_SUB;
					default: aluctrl <= `ALU_CTRL_ZERO;	
				endcase
			`FUNCT3_SLL:	aluctrl <= `ALU_CTRL_SLL;
			`FUNCT3_SLT:	aluctrl <= `ALU_CTRL_SLT;
			`FUNCT3_SLTU:	aluctrl <= `ALU_CTRL_SLTU;
			`FUNCT3_XOR:	aluctrl <= `ALU_CTRL_XOR;
			`FUNCT3_OR:		aluctrl <= `ALU_CTRL_OR;
			`FUNCT3_AND:	aluctrl <= `ALU_CTRL_AND;
			`FUNCT3_SR:
				case(funct7)
					`FUNCT7_SRL: aluctrl <= `ALU_CTRL_SRL;
					`FUNCT7_SRA: aluctrl <= `ALU_CTRL_SRA;
					default:		aluctrl <= `ALU_CTRL_ZERO;	
				endcase
			endcase		
		end		
	`OP_BRANCH:	begin
			aluctrl <= `ALU_CTRL_ZERO;
			case(funct3)
			`FUNCT3_BEQ: aluBraCtr <= `ALU_BEQ;
			`FUNCT3_BNE: aluBraCtr <= `ALU_BNE;
			`FUNCT3_BLT: aluBraCtr <= `ALU_BLT;
			`FUNCT3_BGE: aluBraCtr <= `ALU_BGE;
			`FUNCT3_BLTU:aluBraCtr <= `ALU_BLTU;
			`FUNCT3_BGEU:aluBraCtr <= `ALU_BGEU;
			default:	aluBraCtr <= 3'b000;
		endcase
		end
      default:  begin aluctrl <= `ALU_CTRL_ZERO;
					aluBraCtr <= 3'b000;
				end
 endcase
	
	case(JAL | JALR) 
		1'b1:	jtmp <= 1'b1;
		default: jtmp<=1'b0;// avoid X
	endcase
end
	assign btype = aluBraCtr[2:0]?1:0;
	assign j = jtmp;
endmodule

