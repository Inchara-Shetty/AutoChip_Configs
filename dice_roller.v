I am trying to create a Verilog model for a simulated dice roller. It must meet the following specifications:
    - Module : dice_roller

    - Inputs:
        - Clock -> clk
        - Active-low reset -> rst_n
        - Die select (2-bits) -> die_select
        - Roll -> roll
    - Outputs:
        - Rolled number (up to 8-bits) -> rolled_number

The design should simulate rolling either a 4-sided, 6-sided, 8-sided, or 20-sided die, based on the input die select. It should roll when the roll input goes high and output the random number based on the number of sides of the selected die.

How would I write a design that meets these specifications?
