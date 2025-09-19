`timescale 1 ps/1 ps
module dice_roller (
    input wire clk,
    input wire rst_n,
    input wire [1:0] die_select,  // 00: 4-sided, 01: 6-sided, 10: 8-sided, 11: 20-sided
    input wire roll,
    output reg [7:0] rolled_number  // Outputs the rolled number (up to 8 bits)
);

// State definitions
reg [3:0] max_sides;  // Maximum number of sides based on die selection
reg rolling;          // Rolling flag to indicate if we are currently rolling

// Random number generation using a simple linear feedback shift register (LFSR) or a dice logic
reg [7:0] random_number; // Random number generated

// Instantiate a simple LFSR for random number generation
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        random_number <= 8'b0;  // Reset random number
        rolled_number <= 8'b0;   // Reset rolled number
        rolling <= 1'b0;         // Reset rolling flag
    end else begin
        // Update the random number using a simple LFSR
        random_number <= {random_number[6:0], random_number[7] ^ random_number[5] ^ random_number[4] ^ random_number[3]}; 
    end
end

// Update max_sides based on die_select
always @(*) begin
    case (die_select)
        2'b00: max_sides = 4;   // 4-sided die
        2'b01: max_sides = 6;   // 6-sided die
        2'b10: max_sides = 8;   // 8-sided die
        2'b11: max_sides = 20;  // 20-sided die
        default: max_sides = 4; // Default to 4-sided if invalid
    endcase
end

// Rolling logic, roll when roll signal is high
always @(posedge clk) begin
    if (roll && !rolling) begin
        rolling <= 1'b1; // Set rolling state
        // Output a rolled number based on the selected die
        rolled_number <= (random_number % max_sides) + 1; // Calculate rolled number
    end else if (!roll) begin
        rolling <= 1'b0; // Reset rolling state when roll is de-asserted
    end
end


endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_dice_roller();
    reg clk;
    reg rst_n;
    reg [1:0] die_select;
    reg roll;
    wire [7:0] rolled_number;

    dice_roller dut (
        .clk(clk),
        .rst_n(rst_n),
        .die_select(die_select),
        .roll(roll),
        .rolled_number(rolled_number)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    integer i;
    integer j;
    integer error_count;
    reg [31:0] roll_counts [0:20]; // Declare roll_counts as a memory

    // Testbench stimulus
    initial begin

        clk = 0;
        rst_n = 0;
        die_select = 0;
        roll = 0;

        // Reset and initialization
        #10 rst_n = 1;
        #10 roll = 1;

        error_count = 0;

        // Test loop
        for (i = 0; i < 4; i++) begin
            die_select = i;

            // Clear roll_counts
            for (j = 1; j <= 20; j++) begin
                roll_counts[j] = 0;
            end

            // Perform 1000 rolls and count the results
            for (j = 0; j < 1000; j++) begin
                #10;
                roll = 0;
                #10;
                roll = 1;
                #10;
                roll = 0;
                #10;

                // Check the rolled_number is within the expected range
                case (die_select)
                    2'b00: begin
                        if (rolled_number < 1 || rolled_number > 4) begin
                            $display("Error: Invalid roll result for 4-sided die: %d", rolled_number);
                            error_count = error_count + 1;
                        end
                    end
                    2'b01: begin
                        if (rolled_number < 1 || rolled_number > 6) begin
                            $display("Error: Invalid roll result for 6-sided die: %d", rolled_number);
                            error_count = error_count + 1;
                        end
                    end
                    2'b10: begin
                        if (rolled_number < 1 || rolled_number > 8) begin
                            $display("Error: Invalid roll result for 8-sided die: %d", rolled_number);
                            error_count = error_count + 1;
                        end
                    end
                    2'b11: begin
                        if (rolled_number < 1 || rolled_number > 20) begin
                            $display("Error: Invalid roll result for 20-sided die: %d", rolled_number);
                            error_count = error_count + 1;
                        end
                    end
                endcase

                roll_counts[rolled_number] = roll_counts[rolled_number] + 1;
            end

            $display("Results for die_select %b:", die_select);
            for (j = 1; j <= 20; j++) begin
                if (roll_counts[j] > 0) begin
                    $display("  Rolled %d: %d times", j, roll_counts[j]);
                end
            end
        end

        if (error_count == 0) begin
            $display("Testbench completed successfully.");
        end else begin
            $display("Testbench completed with %d errors.", error_count);
        end

        $finish;
    end

reg vcd_clk;
initial begin
    $dumpfile("my_design.vcd");
    $dumpvars(0, tb_dice_roller);
end

always #5 vcd_clk = ~vcd_clk; // Toggle clock every 5 time units
final begin
$display("Hint: Total mismatched samples is %1d out of %1d samples", errors, clocks);
$display("Simulation finished at %0d ps", $time);
$display("Mismatches: %1d in %1d samples", errors, clocks);
end
endmodule
