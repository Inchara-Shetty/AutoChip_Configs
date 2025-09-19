Design a Verilog module (use Verilog-2001) and testbench for a 64×8 single-port SRAM.
 Module name: sram
Inputs:

ramaddr [5:0]: 6-bit address input.

ramin [7:0]: 8-bit data input.

rwbar: read/write control (active low = write, high = read).

clk: system clock.

cs: chip select (active high).

Outputs:

ramout [7:0]: 8-bit data output.

Functional requirements:

On rising clock edge, if cs=1 and rwbar=0, write ramin into memory at ramaddr.

On rising clock edge, latch ramaddr into an internal register addr_reg.

On read (cs=1 and rwbar=1), output data stored at the last latched address.

When chip select is inactive (cs=0), output should drive 0.

Memory should be implemented as a 64×8 logic array.
