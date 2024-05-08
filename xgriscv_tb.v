//`include "xgriscv_defnes.v"
`include "xgriscv_defines.v"

module xgriscv_tb();
    
   reg    clk, rstn;
   wire[`ADDR_SIZE-1:0] pc;
    
   // instantiation of xgriscv_sc
   xgriscv_pipeline pipeline(clk, rstn, pc);

   integer counter = 0;
   
   initial begin
      // input instruction for simulation
    // $readmemh("riscv32_sim1.dat", pipeline.U_imem.RAM);
   //$readmemh("riscv32_sim1 2.dat", pipeline.U_imem.RAM);
    // $readmemh("FORWARD.dat", pipeline.U_imem.RAM);
    //  $readmemh("8.dat", pipeline.U_imem.RAM);
     
// $readmemh("SwLw.dat", pipeline.U_imem.RAM);
  $readmemh("final.dat", pipeline.U_imem.RAM);
      clk = 1;
      rstn = 1;
      #5 ;
      rstn = 0;
   end
      initial begin
    $dumpfile("name.vcd"); // 设置VCD文件名
    $dumpvars(0, xgriscv_tb);  // 0表示记录所有级别的信号，xgriscv_tb是顶层模块名
end
   always begin
      #(50) clk = ~clk;
     
      if (clk == 1'b1) 
      begin
         counter = counter + 1;
         //comment out all display line(s) for online judge
         if (pc == 32'h000000FC) // set to the address of the last instruction
          begin

            $stop;
          end
      end
      
   end //end always

endmodule
