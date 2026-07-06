module program_counter(
    input clk,
    input rst,
    input [31:0] pc_next,
    input hazard_stall,

    output reg [31:0] if_id_pc
);

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        if_pc <= 0;
    else if (!hazard_stall) begin
        if_pc <= pc_next;
    end
end

endmodule
