`timescale 1ns/1ps

module misp_tb;

reg clk;
reg reset;
reg jump;
reg [4:0] current_addr;

wire [4:0] pc_out;

// Instantiate DUT
misp uut (
    .clk(clk),
    .jump(jump),
    .reset(reset),
    .current_addr(current_addr),
    .pc_out(pc_out)
);

// Clock generation
always #5 clk = ~clk;

initial begin

    // Initialize signals
    clk = 0;
    reset = 1;
    jump = 0;
    current_addr = 5'b00000;

    // Apply reset
    #10 reset = 0;

    // Let processor run sequentially
    #100;

    // Test jump instruction
    jump = 1;
    current_addr = 5'b00101;  // jump to instruction 5

    #10 jump = 0;

    // Run more instructions
    #100;

    // Finish simulation
    $finish;

end

// Monitor values
initial begin
    $monitor("Time=%0t | PC=%d | Jump=%b | Addr=%d",
              $time, pc_out, jump, current_addr);
end

endmodule
