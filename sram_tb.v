`timescale 1ns/1ps

module tb;

  // DUT signals
  reg        clk;
  reg        cs;
  reg [5:0]  ramaddr;
  reg [7:0]  ramin;
  reg        rwbar;      // 0 = write, 1 = read
  wire [7:0] ramout;

  // Instantiate DUT
  sram dut (
    .clk    (clk),
    .cs     (cs),
    .ramaddr(ramaddr),
    .ramin  (ramin),
    .rwbar  (rwbar),
    .ramout (ramout)
  );

  // Clock generation: 10 ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  integer samples;
  integer mismatches;

  // Write procedure
  task do_write;
    input [5:0] a;
    input [7:0] d;
    begin
      @(negedge clk);
      cs      = 1'b1;
      rwbar   = 1'b0;   // write
      ramaddr = a;
      ramin   = d;
      @(posedge clk);   // perform write
      @(negedge clk);
      cs = 1'b0;
    end
  endtask

  // Read procedure
  task do_read;
    input [5:0] a;
    input [7:0] exp;
    reg   [7:0] q;
    begin
      @(negedge clk);
      cs      = 1'b1;
      rwbar   = 1'b1;   // read
      ramaddr = a;
      ramin   = 8'b0;
      @(posedge clk);   // assume sync read, valid at posedge
      @(negedge clk);
      q = ramout;

      samples = samples + 1;
      if (q !== exp) begin
        mismatches = mismatches + 1;
        $display("READ MISMATCH @ t=%0t addr=%0d exp=%0h got=%0h",
                  $time, a, exp, q);
      end
      cs = 1'b0;
    end
  endtask

  // Main test sequence
  initial begin
    cs      = 0;
    ramaddr = 0;
    ramin   = 0;
    rwbar   = 1;
    samples = 0;
    mismatches = 0;

    // wait some cycles
    repeat (2) @(posedge clk);

    // Case 1: write/read address 1
    do_write(6'd1, 8'hAA);
    do_read (6'd1, 8'hAA);

    // Case 2: write/read address 2
    do_write(6'd2, 8'hCC);
    do_read (6'd2, 8'hCC);

    // Case 3: chip select inactive (not counted)
    @(negedge clk);
    cs      = 0;
    rwbar   = 1;
    ramaddr = 6'd2;
    ramin   = 8'h00;
    @(posedge clk);

    // Final summary for AutoChip parser
    $display("SAMPLES=%0d MISMATCHES=%0d", samples, mismatches);
    if (mismatches == 0) begin
      $display("@@@PASS");
      $finish;
    end else begin
      $display("@@@FAIL");
      $finish;
    end
  end

endmodule
