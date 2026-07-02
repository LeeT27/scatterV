module immediate_generator (
    input  logic [31:0] instruction,
    output logic [31:0] immediate_out
);

    always_comb begin
        case (instruction[6:0])
            // 1. I-type
            7'b0010011, 
            7'b0000011, 
            7'b1100111: begin
                immediate_out = {{20{instruction[31]}}, instruction[31:20]};
            end

            // 2. S-type
            7'b0100011: begin
                immediate_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // 3. B-type
            7'b1100011: begin
                immediate_out = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end

            // 4. U-type
            7'b0110111, 
            7'b0010111: begin
                immediate_out = {instruction[31:12], 12'b0};
            end

            // 5. J-type
            7'b1101111: begin
                immediate_out = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end

            // Default
            default: begin
                immediate_out = 32'b0;
            end
        endcase
    end

endmodule
