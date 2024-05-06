//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The alu module implements the core's ALU.
//
// ====================================================================

`include "xgriscv_defines.v"
/*
module alu(
	input signed	[`XLEN-1:0]	a, b, 
	
	input	[3:0]   	aluctrl, 
	input [2:0]			bctrl, 

	output reg [`XLEN-1:0]	aluout
	
	);

	wire op_unsigned = ~aluctrl[3]&~aluctrl[2]&aluctrl[1]&~aluctrl[0]	//ALU_CTRL_ADDU	4'b0010
					| aluctrl[3]&~aluctrl[2]&aluctrl[1]&~aluctrl[0] 	//ALU_CTRL_SUBU	4'b1010
					| aluctrl[3]&aluctrl[2]&~aluctrl[1]&~aluctrl[0] 	//ALU_CTRL_SLTU	4'b1100
					| bctrl[2]&~bctrl[1]&bctrl[0]//bltu
					| bctrl[2]&bctrl[1]&~bctrl[0];//bgeu

	wire [`XLEN-1:0] 	b2;
	wire [`XLEN:0] 		sum; //adder of length XLEN+1
//	wire [`XLEN-1:0]	sll,srl,sra;
wire [`XLEN-1:0]	sll= a<<b;
wire [`XLEN-1:0]	srl=a>>b;
wire [`XLEN-1:0]	sra=a>>>b[9:0];
	wire [`XLEN-1:0]	XOR=a^b;
	wire [`XLEN-1:0]	OR=a|b;
	wire [`XLEN-1:0]	 AND=a&b;
	//wire [`XLEN-1:0]	XOR, OR, AND;
  	wire sub = aluctrl[3]&~aluctrl[2]&~aluctrl[1]&aluctrl[0]
				|aluctrl[3]&~aluctrl[2]&aluctrl[1]&~aluctrl[0]
				|aluctrl[3]&~aluctrl[2]&aluctrl[1]&aluctrl[0]
				|aluctrl[3]&aluctrl[2]&~aluctrl[1]&~aluctrl[0]
				|bctrl[2]|bctrl[1]|bctrl[0];
//slt or b

	assign b2 = sub ? ~b:b; 
	assign sum = (op_unsigned & ({1'b0, a} + {1'b0, b2} + sub))
				| (~op_unsigned & ({a[`XLEN-1], a} + {b2[`XLEN-1], b2} + sub));
		

	always@(*)
		case(bctrl[2:0])
			`ALU_BEQ:	aluout <= sum[`XLEN-1:0]!=0?0:1;//ZERO
			`ALU_BNE:	aluout <= sum[`XLEN-1:0]!=0?1:0;//ZERO
			`ALU_BLT:	begin							//slt
							if(a[`XLEN-1]!=b[`XLEN-1])
								aluout <= a[`XLEN-1];
							else
								aluout <= sum[`XLEN-1];
						end
			`ALU_BGE:	begin							//slt
							if(a[`XLEN-1]!=b[`XLEN-1])
								aluout <= ~a[`XLEN-1];
							else
								aluout <= ~sum[`XLEN-1];
						end
			`ALU_BLTU:	aluout <= a[`XLEN-1:0]<b[`XLEN-1:0];
			`ALU_BGEU:	aluout <= a[`XLEN-1:0]>=b[`XLEN-1:0];
		default:
		case(aluctrl[3:0])
		`ALU_CTRL_MOVEA: 	aluout <= a;
		`ALU_CTRL_ADD: aluout <= sum[`XLEN-1:0];
		`ALU_CTRL_ADDU:		aluout <= sum[`XLEN-1:0];
		`ALU_CTRL_LUI:	aluout <= sum[`XLEN-1:0];
		`ALU_CTRL_AUIPC:	aluout <= sum[`XLEN-1:0]; //a = pc, b = immout
		`ALU_CTRL_ZERO:		aluout <= sum[`XLEN-1:0]!=0?1:0;
		`ALU_CTRL_SUB:	aluout <= sum[`XLEN-1:0];
		`ALU_CTRL_SLL:	aluout <= sll[`XLEN-1:0];
		`ALU_CTRL_SLT:	begin
							if(a[`XLEN-1]!=b[`XLEN-1])
								aluout <= a[`XLEN-1];
							else
								aluout <= sum[`XLEN-1];
						
						end
		`ALU_CTRL_SLTU:	begin
							aluout <= a[`XLEN-1:0]<b[`XLEN-1:0];
							
						end
		`ALU_CTRL_XOR:	aluout <= XOR[`XLEN-1:0];
		`ALU_CTRL_OR:	aluout <= OR[`XLEN-1:0];
		`ALU_CTRL_AND:	aluout <= AND[`XLEN-1:0];
		`ALU_CTRL_SRL: begin	aluout <= srl[`XLEN-1:0];
						
						end
		`ALU_CTRL_SRA: begin	aluout <= sra[`XLEN-1:0];
						
						end
		default: 			aluout <= `XLEN'b0; 
	 endcase
		endcase
	    

endmodule

*//*
`include "xgriscv_defines.v"

module alu(
    input signed [`XLEN-1:0] a, b, // 输入操作数A和B
    input [3:0] aluctrl, // ALU控制信号
    input [2:0] bctrl, // 分支控制信号
    output reg [`XLEN-1:0] aluout // ALU输出结果
);

// 判断是否为无符号操作
wire op_unsigned = ~aluctrl[3] & ~aluctrl[2] & aluctrl[1] & ~aluctrl[0] // 无符号加法 ALU_CTRL_ADDU
                | aluctrl[3] & ~aluctrl[2] & aluctrl[1] & ~aluctrl[0]  // 无符号减法 ALU_CTRL_SUBU
                | aluctrl[3] & aluctrl[2] & ~aluctrl[1] & ~aluctrl[0]  // 无符号小于 ALU_CTRL_SLTU
                | bctrl[2] & ~bctrl[1] & bctrl[0]                      // 无符号小于分支 BLTU
                | bctrl[2] & bctrl[1] & ~bctrl[0];                     // 无符号大于等于分支 BGEU

// 补码选择
wire [`XLEN-1:0] b2;
wire [`XLEN:0] sum; // 加法器长度为 XLEN+1

// 位移操作
wire [`XLEN-1:0] sll = a << b; // 逻辑左移
wire [`XLEN-1:0] srl = a >> b; // 逻辑右移
wire [`XLEN-1:0] sra = a >>> b[9:0]; // 算术右移

// 逻辑操作
wire [`XLEN-1:0] xor_res = a ^ b; // 异或
wire [`XLEN-1:0] or_res = a | b; // 或
wire [`XLEN-1:0] and_res = a & b; // 与

// 检查是否需要减法或分支相关操作
wire sub = aluctrl[3] & ~aluctrl[2] & ~aluctrl[1] & aluctrl[0] // 减法 ALU_CTRL_SUB
         | aluctrl[3] & ~aluctrl[2] & aluctrl[1] & ~aluctrl[0] // 无符号减法 ALU_CTRL_SUBU
         | aluctrl[3] & ~aluctrl[2] & aluctrl[1] & aluctrl[0]  // 设置小于 ALU_CTRL_SLT
         | aluctrl[3] & aluctrl[2] & ~aluctrl[1] & ~aluctrl[0] // 无符号小于 ALU_CTRL_SLTU
         | bctrl[2] | bctrl[1] | bctrl[0]; // 分支信号

// 生成补码
assign b2 = sub ? ~b : b;
// 计算加法/减法结果
assign sum = (op_unsigned & ({1'b0, a} + {1'b0, b2} + sub)) // 无符号操作
           | (~op_unsigned & ({a[`XLEN-1], a} + {b2[`XLEN-1], b2} + sub)); // 有符号操作

// ALU操作和分支逻辑
always @(*) begin
    case (bctrl[2:0])
        `ALU_BEQ: aluout <= sum[`XLEN-1:0] != 0 ? 0 : 1; // BEQ：相等输出1，否则输出0
        `ALU_BNE: aluout <= sum[`XLEN-1:0] != 0 ? 1 : 0; // BNE：不等输出1，否则输出0
        `ALU_BLT: // 有符号小于比较
            if (a[`XLEN-1] != b[`XLEN-1])
                aluout <= a[`XLEN-1];
            else
                aluout <= sum[`XLEN-1];
        `ALU_BGE: // 有符号大于等于比较
            if (a[`XLEN-1] != b[`XLEN-1])
                aluout <= ~a[`XLEN-1];
            else
                aluout <= ~sum[`XLEN-1];
        `ALU_BLTU: aluout <= a < b; // 无符号小于比较
        `ALU_BGEU: aluout <= a >= b; // 无符号大于等于比较
        default: case (aluctrl[3:0])
            `ALU_CTRL_MOVEA: aluout <= a; // 直接传递A
            `ALU_CTRL_ADD: aluout <= sum[`XLEN-1:0]; // 加法
            `ALU_CTRL_ADDU: aluout <= sum[`XLEN-1:0]; // 无符号加法
            `ALU_CTRL_LUI: aluout <= sum[`XLEN-1:0]; // 加载上位立即数
            `ALU_CTRL_AUIPC: aluout <= sum[`XLEN-1:0]; // 加上程序计数器
            `ALU_CTRL_ZERO: aluout <= sum[`XLEN-1:0] != 0 ? 1 : 0; // 判断结果是否为零
            `ALU_CTRL_SUB: aluout <= sum[`XLEN-1:0]; // 减法
            `ALU_CTRL_SLL: aluout <= sll; // 逻辑左移
            `ALU_CTRL_SLT: // 有符号小于比较
                if (a[`XLEN-1] != b[`XLEN-1])
                    aluout <= a[`XLEN-1];
                else
                    aluout <= sum[`XLEN-1];
            `ALU_CTRL_SLTU: aluout <= a < b; // 无符号小于比较
            `ALU_CTRL_XOR: aluout <= xor_res; // 异或
            `ALU_CTRL_OR: aluout <= or_res; // 或
            `ALU_CTRL_AND: aluout <= and_res; // 与
            `ALU_CTRL_SRL: aluout <= srl; // 逻辑右移
            `ALU_CTRL_SRA: aluout <= sra; // 算术右移
            default: aluout <= `XLEN'b0; // 默认输出为0
        endcase
    endcase
end
endmodule
*/
`include "xgriscv_defines.v"

module alu(
    input signed [`XLEN-1:0] opA, opB, // 输入操作数A和B
    input [3:0] ctrlSig, // ALU控制信号
    input [2:0] branchCtrl, // 分支控制信号
    output reg [`XLEN-1:0] result // ALU输出结果
);

// 判断操作是否为无符号操作
wire unsignedOp = ~ctrlSig[3] & ~ctrlSig[2] & ctrlSig[1] & ~ctrlSig[0]  // 无符号加法 ALU_CTRL_ADDU
                | ctrlSig[3] & ~ctrlSig[2] & ctrlSig[1] & ~ctrlSig[0]   // 无符号减法 ALU_CTRL_SUBU
                | ctrlSig[3] & ctrlSig[2] & ~ctrlSig[1] & ~ctrlSig[0]   // 无符号小于 ALU_CTRL_SLTU
                | branchCtrl[2] & ~branchCtrl[1] & branchCtrl[0]        // 无符号小于分支
                | branchCtrl[2] & branchCtrl[1] & ~branchCtrl[0];       // 无符号大于等于分支

// 根据操作选择适当的B操作数
wire [`XLEN-1:0] modifiedB;
wire [`XLEN:0] extendedSum; // 扩展加法器长度为XLEN+1

// 位移操作
wire [`XLEN-1:0] shiftLL = opA << opB; // 逻辑左移
wire [`XLEN-1:0] shiftLR = opA >> opB; // 逻辑右移
wire [`XLEN-1:0] shiftAR = opA >>> opB[9:0]; // 算术右移

// 逻辑操作
wire [`XLEN-1:0] bitwiseXOR = opA ^ opB;
wire [`XLEN-1:0] bitwiseOR = opA | opB;
wire [`XLEN-1:0] bitwiseAND = opA & opB;

// 检查是否需要减法或分支操作
wire needInvertB = ctrlSig[3] & ~ctrlSig[2] & ~ctrlSig[1] & ctrlSig[0]   // 减法
                 | ctrlSig[3] & ~ctrlSig[2] & ctrlSig[1] & ~ctrlSig[0]   // 无符号减法
                 | ctrlSig[3] & ~ctrlSig[2] & ctrlSig[1] & ctrlSig[0]    // 设置小于
                 | ctrlSig[3] & ctrlSig[2] & ~ctrlSig[1] & ~ctrlSig[0]   // 无符号小于
                 | branchCtrl[2] | branchCtrl[1] | branchCtrl[0];

assign modifiedB = needInvertB ? ~opB : opB;
assign extendedSum = (unsignedOp & ({1'b0, opA} + {1'b0, modifiedB} + needInvertB))
                   | (~unsignedOp & ({opA[`XLEN-1], opA} + {modifiedB[`XLEN-1], modifiedB} + needInvertB));

always @(*) begin
    case (branchCtrl)
        `ALU_BEQ:  result <= extendedSum[`XLEN-1:0] != 0 ? 0 : 1; // BEQ结果为零则输出1，否则输出0
        `ALU_BNE:  result <= extendedSum[`XLEN-1:0] != 0 ? 1 : 0; // BNE结果非零则输出1，否则输出0
        `ALU_BLT:  result <= (opA[`XLEN-1] != opB[`XLEN-1]) ? opA[`XLEN-1] : extendedSum[`XLEN-1]; // BLT比较
        `ALU_BGE:  result <= (opA[`XLEN-1] != opB[`XLEN-1]) ? ~opA[`XLEN-1] : ~extendedSum[`XLEN-1]; // BGE比较
        `ALU_BLTU: result <= opA < opB; // 无符号小于比较
        `ALU_BGEU: result <= opA >= opB; // 无符号大于等于比较
        default:   case (ctrlSig)
                       `ALU_CTRL_MOVEA: result <= opA; // 直接移动A到输出
                       `ALU_CTRL_ADD:   result <= extendedSum[`XLEN-1:0]; // 加法
                       `ALU_CTRL_ADDU:  result <= extendedSum[`XLEN-1:0]; // 无符号加法
                       `ALU_CTRL_LUI:   result <= extendedSum[`XLEN-1:0]; // 加载上位立即数
                       `ALU_CTRL_AUIPC: result <= extendedSum[`XLEN-1:0]; // 加上程序计数器
                       `ALU_CTRL_ZERO:  result <= extendedSum[`XLEN-1:0] != 0 ? 1 : 0; // 结果非零输出1，否则输出0
                       `ALU_CTRL_SUB:   result <= extendedSum[`XLEN-1:0]; // 减法
                       `ALU_CTRL_SLL:   result <= shiftLL; // 逻辑左移
                       `ALU_CTRL_SLT:   result <= (opA[`XLEN-1] != opB[`XLEN-1]) ? opA[`XLEN-1] : extendedSum[`XLEN-1]; // 设置小于
                       `ALU_CTRL_SLTU:  result <= opA < opB; // 无符号设置小于
                       `ALU_CTRL_XOR:   result <= bitwiseXOR; // 异或
                       `ALU_CTRL_OR:    result <= bitwiseOR; // 或
                       `ALU_CTRL_AND:   result <= bitwiseAND; // 与
                       `ALU_CTRL_SRL:   result <= shiftLR; // 逻辑右移
                       `ALU_CTRL_SRA:   result <= shiftAR; // 算术右移
                       default:         result <= `XLEN'b0; // 默认输出0
                   endcase
    endcase
end
endmodule
