module tb (
    input wire [4:0] binary_input, // 5-bit binary input
    output reg [7:0] bcd_output     // 8-bit BCD output (4 bits for tens, 4 bits for ones)
);

// Internal registers for BCD representation
reg [3:0] bcd_tens; // Tens place
reg [3:0] bcd_ones; // Ones place
integer i; // Loop variable

always @* begin
    // Initialize BCD values to 0
    bcd_tens = 4'b0000;
    bcd_ones = 4'b0000;

    // Convert binary to BCD using double-dabble algorithm
    for (i = 0; i < 5; i = i + 1) begin
        // Shift left the BCD digits to make room for the next binary bit
        if (bcd_tens >= 5)
            bcd_tens = bcd_tens + 4'b0011; // Add 3 to tens place if necessary

        if (bcd_ones >= 5)
            bcd_ones = bcd_ones + 4'b0011; // Add 3 to ones place if necessary

        // Shift BCD values left to add a new binary bit
        {bcd_tens, bcd_ones} = {bcd_tens, bcd_ones} << 1;

        // Add the next bit of the binary input
        bcd_ones[0] = binary_input[4 - i]; // Add the next bit of the binary input
    end

    // Combine BCD places into the final output
    bcd_output = {bcd_tens, bcd_ones};
end

endmodule
'''
filename = "binary_to_bcd/binary_to_bcd.v"
# Write the extracted Verilog code to the file
with open(filename, "w") as f:
    f.write(output_verilog_code)
