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
  //input                     clk, reset,
  input [6:0]	              opcode,
  input [2:0]               funct3,
  input [6:0]               funct7,
  input [`RFIDX_WIDTH-1:0]  rd, rs1,
  input [11:0]              imm,
  input                     zero, lt, // from cmp in the decode stage

  output [4:0]              immctrl,            // for the ID stage
  output                    itype, jal, jalr, bunsigned, pcsrc,
  output reg  [3:0]         aluctrl,            // for the EX stage 
  output reg  [2:0]			aluctrl1,
  output [1:0]              alusrca,
  output                    alusrcb,
  output                    memwrite, lunsigned, j, btype,  // for the MEM stage
  output [1:0]              lwhb, swhb,
  output                    memtoreg, regwrite  // for the WB stage
  );
  //输出只用
//先判断是什么type，
  wire LUI		= (opcode == `OP_LUI);
  wire AUIPC	= (opcode == `OP_AUIPC);
  wire JAL		= (opcode == `OP_JAL);//这里define里分别给出了，
  wire JALR	= (opcode == `OP_JALR);
  wire branch= (opcode == `OP_BRANCH);
  wire load	= (opcode == `OP_LOAD); 
  wire store	= (opcode == `OP_STORE);
  wire addwithImm	= (opcode == `OP_ADDI);
  wire addwith = (opcode == `OP_ADD);


  wire bltu	= branch && (funct3 == `FUNCT3_BLTU);
  wire bgeu	= branch && (funct3 == `FUNCT3_BGEU);

  wire lb		= load && (funct3 == `FUNCT3_LB);
  wire lh		= load && (funct3 == `FUNCT3_LH);
  wire lw		= load && (funct3 == `FUNCT3_LW);
  wire lbu		= load && (funct3 == `FUNCT3_LBU);
  wire lhu		= load && (funct3 == `FUNCT3_LHU);

  wire sb		= store && (funct3 == `FUNCT3_SB);
  wire sh		= store && (funct3 == `FUNCT3_SH);
  wire sw		= store && (funct3 == `FUNCT3_SW);

  wire addi	= addwithImm && (funct3 == `FUNCT3_ADDI);
 

  //wire rs1_x0= (rs1 == 5'b00000);
  //wire rd_x0 = (rd  == 5'b00000);
  //wire nop		= addi && rs1_x0 && rd_x0 && (imm == 12'b0); //addi x0, x0, 0 is nop

  assign itype = load || addwithImm || JALR;

  wire stype = store;


  wire utype = LUI || AUIPC;

  wire jtype = JAL;

	reg jtmp;

  assign immctrl = {itype, stype, btype, utype, jtype};

  assign jal = JAL;
  
  assign jalr = JALR;


  assign bunsigned = bltu | bgeu;

  assign pcsrc = 0;

  assign alusrca = LUI ? 2'b01 : (JAL||AUIPC ? 2'b10 : 2'b00);
  //assign alusrca = 2'b00;

  assign alusrcb = LUI || AUIPC || itype || load || store || JALR||JAL;
//0:reg2 1:imm

  assign memwrite = store;

  assign swhb = {sw|sh, sw|sb};//w:11, h:10, b:01

  assign lwhb = {lw|lh|lhu, lw|lb|lbu};//这个地方

  assign lunsigned = lbu | lhu;

  assign memtoreg = load;

  assign regwrite = LUI | AUIPC | addi | addwith | itype | JALR | JAL;

//这个地方，由于是
  always @(*)	begin
	
    case(opcode)
      `OP_LUI:   
      begin 
          aluctrl1 <= `ALU_EMP;
			    aluctrl <= `ALU_CTRL_LUI;
			end
      `OP_AUIPC:  begin aluctrl1 <= `ALU_EMP;
			aluctrl <= `ALU_CTRL_AUIPC;
			end
	  `OP_LOAD:	  begin aluctrl1 <= `ALU_EMP;
			aluctrl <= `ALU_CTRL_ADD;
			end
	  `OP_STORE:  begin aluctrl1 <= `ALU_EMP;
			aluctrl <= `ALU_CTRL_ADD;
			end
	  `OP_JAL:   begin aluctrl1 <= `ALU_EMP;
			aluctrl <= `ALU_CTRL_ADD;
			end
	  `OP_JALR:	  begin aluctrl1 <= `ALU_EMP;
			aluctrl <= `ALU_CTRL_ADD;
			end
      `OP_ADDI:	  begin aluctrl1 <= `ALU_EMP;
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
	`OP_ADD:	begin aluctrl1 <= `ALU_EMP;
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
			`FUNCT3_BEQ: aluctrl1 <= `ALU_BEQ;
			`FUNCT3_BNE: aluctrl1 <= `ALU_BNE;
			`FUNCT3_BLT: aluctrl1 <= `ALU_BLT;
			`FUNCT3_BGE: aluctrl1 <= `ALU_BGE;
			`FUNCT3_BLTU:aluctrl1 <= `ALU_BLTU;
			`FUNCT3_BGEU:aluctrl1 <= `ALU_BGEU;
			default:	aluctrl1 <= 3'b000;
		endcase
		end
      default:  begin aluctrl <= `ALU_CTRL_ZERO;
					aluctrl1 <= 3'b000;
				end
 endcase
	
	case(JAL | JALR) 
		1'b1:	jtmp <= 1'b1;
		default: jtmp<=1'b0;// avoid X
	endcase
end
	assign btype = aluctrl1[2:0]?1:0;
	assign j = jtmp;
endmodule