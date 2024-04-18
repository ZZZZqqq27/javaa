`include "xgriscv_defines.v"
module mux2to1 
(
    input  [31:0] d0, d1,
    input       select,
    output [31:0] y
);

always @(*) begin
    case (select)
        1'b0: y = d0;
        1'b1: y = d1;
    endcase
end

endmodule


module mux3to1 
(
    input  [31:0] d0, d1, d2,
    input  [1:0]       select,
    output [31:0] y
);

always @(*) begin
    case (select)
        2'b00: y = d0;
        2'b01: y = d1;
        2'b10: y = d2;
        default: y = d0;  // 默认情况可以根据需要调整
    endcase
end

endmodule

