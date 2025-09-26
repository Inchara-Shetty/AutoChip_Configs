`timescale 1ns / 1ps

module tb;

  // ---------- DUT I/O ----------
  logic        clk;
  logic        cs;
  logic [5:0]  ramaddr;
  logic [7:0]  ramin;
  logic        rwbar;      // 0 = write, 1 = read
  logic [7:0]  ramout;

  // Instantiate DUT
  sram uut (
    .clk    (clk),
    .cs     (cs),
    .ramaddr(ramaddr),
    .ramin  (ramin),
    .rwbar  (rwbar),
    .ramout (ramout)
  );

  // ---------- Clock (10 ns period) ----------
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // ---------- VCD dump ----------
  initial begin
    $dumpfile("sram_tb.vcd");
    $dumpvars(0, sram_tb);
  end

  // ---------- Test machinery ----------
  int i;
  int samples;
  int mismatches;
  logic [7:0] expected;
  logic [7:0] write_data;

  initial begin
    $display("Testing SRAM (SystemVerilog TB)...");

    // Initialize
    cs         = 1'b0;
    rwbar      = 1'b1;       // start in read mode (idle)
    ramaddr    = '0;
    ramin      = '0;
    samples    = 0;
    mismatches = 0;

    // Settle a couple cycles
    repeat (2) @(posedge clk);

    // Write+Read all 64 locations
    for (i = 0; i < 64; i++) begin
      write_data = 8'hA5 ^ logic'(i[7:0]);  // deterministic per-address pattern

      // ---------- WRITE (sync @ posedge) ----------
      @(negedge clk);
        cs      = 1'b1;
        rwbar   = 1'b0;       // write
        ramaddr = logic'(i[5:0]);
        ramin   = write_data;
      @(posedge clk);         // perform write
      @(negedge clk);
        cs = 1'b0;

      // ---------- READ (assume 1-cycle sync read) ----------
      @(negedge clk);
        cs      = 1'b1;
        rwbar   = 1'b1;       // read
        ramaddr = logic'(i[5:0]);
        ramin   = '0;
      @(posedge clk);         // data registered into output
      @(negedge clk);         // sample away from edge

      expected = write_data;
      samples++;

      if (ramout !== expected) begin
        mismatches++;
        $display("Mismatch @ t=%0t addr=%0d exp=%02h got=%02h",
                 $time, i[5:0], expected, ramout);
      end

      cs = 1'b0;
    end

    // -------- EXACT summary line required by your parser --------
    $display("Mismatches: %0d in %0d samples", mismatches, samples);

    // (Optional) pass/fail banner
    // if (mismatches == 0) $display("@@@PASS"); else $display("@@@FAIL");

    #1 $finish;
  end

endmodule
