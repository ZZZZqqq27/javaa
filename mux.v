`include "xgriscv_defines.v"
module mux2to1 
(
    input  [31:0] d0, d1,
    input              select,
    output [31:0] y
);

always @(*) begin
    case (s)
        1'b0: y = d0;
        1'b1: y = d1;
    endcase
end

endmodule


module mux3to1 
             (input  [31:0] d0, d1, d2,
              input  [1:0]       select, 
              output [31:0] y);

  assign  y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule
