module program_counter(
    input clk,
    input rst,
    input [31:0] pc_next,

    output reg [31:0] pc_out
);

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        pc_out <= 0;
    else 
        pc_out <= pc_next;
end

endmodule
