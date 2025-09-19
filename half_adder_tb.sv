module half_adder (S, C, X, Y);
input X, Y;
output S, C;


xor sum (S, X, Y);
and carry (C, X, Y);

endmodule

module test;
reg X, Y;
wire S, C;


parameter STDIN = 32'h8000_0000;
integer testid;
integer ret;

half_adder hs ( S, C, X, Y);

initial
begin
        ret = $fscanf(STDIN, "%d", testid);
        case (testid)
                0: begin #10 X=0; Y=0; end
                1: begin #10 X=0; Y=1; end
                2: begin #10 X=1; Y=0; end
                3: begin #10 X=1; Y=1; end
                default : begin
                        $display ("Bad testcase id %d", testid);
                        $finish();
                end
        endcase

        #5;

        if ((testid == 0 && {S, C} == 2'b00) ||
            (testid == 1 && {S, C} == 2'b10) ||
            (testid == 2 && {S, C} == 2'b10) ||
            (testid == 3 && {S, C} == 2'b11) )
            pass();
        else
            fail();

end

task pass;
begin
        $display ("PASS: (X=%b, Y=%b, S=%b, C=%b", X, Y, S, C);
        $finish();
end
endtask;

task fail;
begin
        $display ("FAIL: (X=%b, Y=%b, S=%b, C=%b", X, Y, S, C);
        $finish();
end
endtask;

endmodule
