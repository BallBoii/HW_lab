    module Mux2to1 #(
    parameter size = 32
) 
(
    input sel,                      // Selector
    input signed [size-1:0] s0,     // Input 0
    input signed [size-1:0] s1,     // Input 1
    output signed [size-1:0] out    // Output
);
    // TODO: implement your 2to1 multiplexer here
    assign out = sel ? s1 : s0;
    
endmodule

