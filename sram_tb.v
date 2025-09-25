`timescale 1ns/1ps

module tb;
    reg clk;                   // System clock
    reg cs;                    // Chip select
    reg [5:0] ramaddr;        // Address input
    reg [7:0] ramin;          // Data input
    reg rwbar;                // Read/write control
    wire [7:0] ramout;        // Data output

    // Instantiate the SRAM module
    sram uut (
        .clk(clk),
        .cs(cs),
        .ramaddr(ramaddr),
        .ramin(ramin),
        .rwbar(rwbar),
        .ramout(ramout)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        cs = 0;
        ramaddr = 6'b0;
        ramin = 8'b0;
        rwbar = 1; // Start with read mode

        // Test case 1: Write to memory
        #10;
        cs = 1;           // Enable chip select
        ramaddr = 6'b000001; // Address 1
        ramin = 8'b10101010; // Data to write
        rwbar = 0;        // Set to write
        #10;              // Wait for a clock edge

        // Test case 2: Read from memory
        ramaddr = 6'b000001; // Address 1
        rwbar = 1;          // Set to read
        #10;                // Wait for a clock edge
        $display("Read from address %b: %b", ramaddr, ramout); // Check output

        // Test case 3: Write to another memory location
        ramaddr = 6'b000010;  // Address 2
        ramin = 8'b11001100;  // Data to write
        rwbar = 0;            // Set to write
        #10;                  // Wait for a clock edge

        // Test case 4: Read from the new address
        ramaddr = 6'b000010; // Address 2
        rwbar = 1;           // Set to read
        #10;                 // Wait for a clock edge
        $display("Read from address %b: %b", ramaddr, ramout); // Check output

        // Test case 5: Chip select inactive
        cs = 0;
        #10; // Wait for a clock edge
        $display("Chip select inactive, output: %b", ramout); // Should be 0
        
        // End of test
        $finish;
    end
endmodule
