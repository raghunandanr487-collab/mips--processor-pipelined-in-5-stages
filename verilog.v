`timescale 1ns / 1ps
module misp(clk,jump,reset,current_addr,pc_out);
  input clk,jump,reset;
  output [4:0]pc_out;
  input [4:0]current_addr;
  wire[4:0]mux_wire;
  wire[4:0]mux_out_wire;
  wire[7:0]inst_wire;
  reg[7:0]if_id_ir;
  reg[4:0]if_id_npc;
  wire[1:0]rs_wire,rt_wire;
  wire[1:0]opcode_wire;
  wire[7:0]A_wire,B_wire;
  reg[7:0]id_ex_A;
  reg[7:0]id_ex_B;
  reg[4:0]id_ex_npc;
  reg[7:0]id_ex_ir;
  wire[8:0]alu_wire;
  reg[8:0]ex_mem_alu,mem_wb_aluout;
  wire[1:0]sign_ext_wire;
  reg[7:0]id_ex_imm;
  wire[7:0]imm_out_wire;
  wire[7:0]a1_wire,b1_wire;
  wire[4:0]npc_wire;
  wire load,loads,cond_wire;
  wire [7:0]mux1_out_wire,mux2_out_wire;
  reg ex_mem_cond;
  reg [7:0]ex_mem_B;
  reg[7:0]ex_mem_ir;
  reg[4:0]mem_wb_ir;
  wire[8:0]lmd_wire,out_wire;
  reg[8:0]mem_wb_lmd;
  wire ld,mem_write,mem_read;
 
  
  
  
assign load       = 1'b1;   // mux_1 picks A
assign loads      = 1'b1;   // mux_2 picks B
assign ld         = 1'b0;   // mux_3 picks ALU result, not LMD
assign mem_write  = 1'b0;   // no stores
assign mem_read   = 1'b1;   // no loads

  program_counter pc(.clk(clk),.reset(reset),.jump(jump),.npc(mux_wire),.current_addr(current_addr));
  intruction_mem ins(.clk(clk),.pc_output(mux_wire),.inst_out(inst_wire));
  mux m1(.npc(mux_wire),.mux_out(mux_out_wire),.ex_cond(ex_mem_cond),.ex_mem_alu_out(ex_mem_alu));
  
  decoder dc(.rs(rs_wire),.rt(rt_wire),.opcode(opcode_wire),.decoder_in(if_id_ir),.sign_ext(sign_ext_wire));
  regfile rg(.clk(clk),.rs_in(rs_wire),.rt_in(rt_wire),.A(A_wire),.B(B_wire), .wr(1'b1), .addr(mem_wb_ir[3:2]), .data_in(out_wire) );
  
  alu al(.a_in(mux1_out_wire),.b_in(mux2_out_wire),.alu_out(alu_wire),.opcode(opcode_wire));
  
  sign_extend si(.imm_in(sign_ext_wire),.imm_out(imm_out_wire));
  
  mux_1 ml(.a1(A_wire),.npc(id_ex_npc),.load_a(load),.mux_1_out(mux1_out_wire));
  mux_2 ml2(.b1(B_wire),.imm_out(id_ex_imm),.load_b(loads),.mux_2_out(mux2_out_wire));
  
  condition co(.cond(cond_wire),.a1(A_wire));
  
  data_mem dt(.clk(clk),.alu_input(ex_mem_alu),.b_input(ex_mem_B),.lmd(lmd_wire),.mem_write(mem_write),.mem_read(mem_read));
  
  mux_3 m3(.lmd_in(mem_wb_lmd),.alulast_in(ex_mem_alu),.ld(ld),.out(out_wire));
  
  
  
  always@(posedge clk)
    begin
      if_id_ir<=inst_wire;
      if_id_npc<=mux_out_wire;
       id_ex_A<=A_wire;
      id_ex_B<=B_wire;
      id_ex_npc<=if_id_npc;
      id_ex_ir<=if_id_ir;
      ex_mem_alu<=alu_wire;
      id_ex_imm<=imm_out_wire;
      ex_mem_cond<=cond_wire;
      ex_mem_B<=id_ex_B;
      ex_mem_ir<=id_ex_ir;
      mem_wb_ir<=ex_mem_ir;
      mem_wb_aluout<=ex_mem_alu;
      mem_wb_lmd<=lmd_wire;
      
    end
	 assign pc_out = mux_wire;
endmodule


module program_counter(current_addr,clk,reset,jump,npc);
  input clk,reset,jump;
  input [4:0]current_addr;
 
  output reg[4:0]npc;

  initial begin
    npc = 5'b00000;
  end
  always@(posedge clk) begin
    if(reset) begin
      npc<=5'b00000;
    end
    else if(jump) begin
      npc<=current_addr;
    end
    else begin
      npc<=npc +5'b00001;
    end
  end
endmodule


module intruction_mem(clk,pc_output,inst_out);
  input clk;
  input[4:0]pc_output;
  reg[7:0]mem[0:31];
  output reg[7:0]inst_out;

  initial begin
    mem[0]=8'b00000001;
    mem[1]=8'b00000011;
    mem[2]=8'b00000111;
    mem[3]=8'b00001111;
    mem[4]=8'b00011111;
    mem[5]=8'b00111111;
    mem[6]=8'b01111111;
    mem[7]=8'b11111111;
    mem[8]=8'b00001001;
  end

  always@(posedge clk) begin
    inst_out<=mem[pc_output];
  end
endmodule


module mux(npc,ex_cond,ex_mem_alu_out,mux_out);
  input [4:0]npc;
  input ex_cond;
  input [8:0]ex_mem_alu_out;
  output reg [4:0]mux_out;

  always@(*) begin
    if(ex_cond) begin
      mux_out<=ex_mem_alu_out;
    end
    else begin
      mux_out<=npc;
    end
  end
endmodule


module decoder(rs,rt,opcode,decoder_in,sign_ext);
  input [7:0]decoder_in;
  output[1:0]rs,rt,opcode,sign_ext;
  assign opcode=decoder_in[7:6];
  assign rs=decoder_in[5:4];
  assign rt=decoder_in[3:2];
  assign sign_ext=decoder_in[1:0];
endmodule


module regfile(A,B,rs_in,rt_in,wr,addr,data_in,clk);
  input wr,clk;
  input [1:0]rs_in,rt_in;
  input[8:0]data_in;
  input [1:0]addr;
  output reg[7:0]A,B;
  reg[8:0]regbank[0:255];
  
  integer i;
initial begin
  for (i = 0; i < 4; i = i+1) begin
    regbank[i] = i;   // preload registers with their index
  end
end

  
  always@(posedge clk)
    begin
      if(wr)
        begin
          regbank[addr]<=data_in;
        end
      
       A<=regbank[rs_in];
          B<=regbank[rt_in];
    end
endmodule

module alu(a_in,b_in,alu_out,opcode);
  
  input[7:0]a_in,b_in;
  input[1:0]opcode;
  output reg[8:0]alu_out;
  
  always@(*)
    begin
      case(opcode)
        2'b00:alu_out<=a_in+b_in;
        2'b01:alu_out<=a_in*b_in;
        2'b10:alu_out<=a_in-b_in;
        2'b11:alu_out<=a_in/b_in;
      endcase
    end
endmodule
  
module sign_extend(input [1:0]imm_in, output reg [7:0]imm_out);
  always @(*) begin
    imm_out = {{6{imm_in[1]}}, imm_in}; // replicate sign bit
  end
endmodule


module mux_1(a1,npc,mux_1_out,load_a);
  input load_a;
  input[7:0]a1;
  input[4:0]npc;
  output reg[7:0]mux_1_out;
 
  
  always@(*)
    begin
      if(load_a)
        begin
        mux_1_out<=a1;
        end
      else
        begin
        mux_1_out<=npc;
    end
    end

      endmodule
  
      module mux_2( b1,imm_out,load_b,mux_2_out);
        input load_b;
        input[7:0]b1;
        input[7:0]imm_out;
        output reg[7:0]mux_2_out;
        
        always@(*)
          begin
            if(load_b)
              begin
              mux_2_out<=b1;
              end
            else
              begin
                mux_2_out<=imm_out;
              end
          end
            endmodule
            
module condition(cond,a1);
  input [7:0]a1;
  output  cond;
  
  assign cond=(a1==0)?1'b1:1'b0;
endmodule

module data_mem(
    input clk,                
    input mem_write,          
    input mem_read,          
    input [8:0] alu_input,    
    input [7:0] b_input,      
    output reg [8:0] lmd     
);

    reg [8:0] datamem [0:7];  

    always @(posedge clk) begin
        if (mem_write) begin
            datamem[alu_input[2:0]] <= b_input;  // store
        end
    end

    always @(*) begin
        if (mem_read)
            lmd = datamem[alu_input[2:0]];  // load
        else
            lmd = 9'b0;
    end

endmodule

module mux_3(lmd_in,alulast_in,ld,out);
  input[8:0]lmd_in,alulast_in;
  input ld;
  output reg[8:0]out;
  
  always@(*)
    begin
      if(ld)
        begin
          out<=lmd_in;
        end 
      else
        begin
        out<=alulast_in;
        end
    end
endmodule
  
