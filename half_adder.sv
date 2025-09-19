 Design a SystemVerilog module for a Half Adder.

 Specifications:
 - Module name: half_adder
 - Ports:
     * Inputs: X, Y (1-bit each)
     * Outputs: S (sum), C (carry)

 Functionality:
 - Implements a combinational half adder circuit.
 - The sum (S) output is the XOR of X and Y.
 - The carry (C) output is the AND of X and Y.

 Constraints:
 - Write in SystemVerilog style (use `logic` for signals).
 - Use gate-level primitives (xor, and) or assign statements.
 - Ensure the design is synthesizable.
 - Do not include a testbench in this file.

Example truth table:
  X | Y || S | C
  0 | 0 || 0 | 0
  0 | 1 || 1 | 0
  1 | 0 || 1 | 0
  1 | 1 || 0 | 1

 End of specification.
