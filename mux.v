`include "xgriscv_defines.v"
module mux2to1 
(
    input  [31:0] d0, d1,
    input       select,
    output [31:0] y
);


assign y = select ? d1 : d0;
endmodule


module mux3to1 
(
    input  [31:0] d0, d1, d2,
    input  [1:0]       select,
    output [31:0] y
);
 assign y = select[1] ? d2 : (select[0] ? d1 : d0);

endmodule

