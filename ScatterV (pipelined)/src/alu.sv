module alu (
    input  logic        clk,               
    input  logic        rst,
    input  logic [1:0]  alu_op,
    input  logic [2:0]  funct3,
    input  logic [6:0]  funct7,
    input  logic [31:0] ex_operand1,
    input  logic [31:0] ex_operand2,
    input  logic [6:0]  id_ex_opcode,

    output logic [31:0] ex_alu_result,
    output logic        zero_flag,
    output logic        less_than,
    output logic        branch_condition_met
);
    logic [4:0] shamt;

    // Custom 32-bit Random Number Generator
    logic [31:0] lfsr_reg;
    logic        feedback_bit; //Gets fed into LSB

    // Shift LEFT every cycle, feeding the XOR feedback into the LSB (bit 0)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr_reg <= 32'hECEB; // Seed value
        end else begin
            lfsr_reg <= {lfsr_reg[30:0], feedback_bit}; // Drops bit 31, shifts everything left, places feedback in bit 0
        end
    end

    always_comb begin
        // XOR taps at bits 31, 21, 1, and 0, if result somehow becomes 0, inject a 1
        feedback_bit = (lfsr_reg == 32'b0) ? 1'b1 : (lfsr_reg[31] ^ lfsr_reg[21] ^ lfsr_reg[1] ^ lfsr_reg[0]);
        // flags
        zero_flag = (ex_operand1 == ex_operand2);
        less_than = ($signed(ex_operand1) < $signed(ex_operand2));
        // Starting assignments
        shamt = (id_ex_opcode == 7'b0010011) ? (ex_operand2[4:0] & 5'b11111) : ex_operand2[4:0];
        ex_alu_result           = 32'b0;
        branch_condition_met = 1'b0;

        case (alu_op)
            // 00 always add
            2'b00: begin
                ex_alu_result = ex_operand1 + ex_operand2;
            end

            // 01 always subtract and check branch condition
            2'b01: begin
                ex_alu_result = ex_operand1 - ex_operand2;
                case (funct3)
                    3'b000: branch_condition_met = zero_flag;                  // BEQ (Equal)
                    3'b001: branch_condition_met = !zero_flag;                 // BNE (Not Equal)
                    3'b100: branch_condition_met = less_than;                  // BLT (Less Than, Signed)
                    3'b101: branch_condition_met = !less_than;                 // BGE (Greater or Equal, Signed)
                    3'b110: branch_condition_met = (ex_operand1 < ex_operand2);       // BLTU (Less Than, Unsigned)
                    3'b111: branch_condition_met = (ex_operand1 >= ex_operand2);      // BGEU (Greater or Equal, Unsigned)
                    default: branch_condition_met = 1'b0;
                endcase
            end

            // 10 standard ALU use
            2'b10: begin
                case (funct3)
                    3'b000: begin
                        // ONLY subtract if R-Type and funct7[5] is 1.
                        if (funct7[5] && (id_ex_opcode == 7'b0110011)) begin
                            ex_alu_result = ex_operand1 - ex_operand2; // True R-type SUB
                        end else begin
                            ex_alu_result = ex_operand1 + ex_operand2; // True R-type ADD or I-type ADDI
                        end
                    end
                    3'b001: ex_alu_result = ex_operand1 << shamt;            // SLL / SLLI (Shift Left)
                    3'b010: ex_alu_result = {31'b0, less_than};                    // SLT / SLTI (Set Less Than, Signed)
                    3'b011: ex_alu_result = {31'b0, (ex_operand1 < ex_operand2)};        // SLTU / SLTIU (Set Less Than, Unsigned)
                    3'b100: ex_alu_result = ex_operand1 ^ ex_operand2;                  // XOR / XORI
                    3'b101: begin
                        // SRL or SRA depending on bit 5 of funct7
                        if (funct7[5]) 
                            ex_alu_result = $signed(ex_operand1) >>> ex_operand2[4:0];         // SRA / SRAI
                        else           
                            ex_alu_result = ex_operand1 >> ex_operand2[4:0];           // SRL / SRLI
                    end
                    3'b110: ex_alu_result = ex_operand1 | ex_operand2;                  // OR / ORI
                    3'b111: ex_alu_result = ex_operand1 & ex_operand2;                  // AND / ANDI
                    default: ex_alu_result = 32'b0;
                endcase
            end

            // 11 RANDOM NUMBER!
            2'b11: begin
                ex_alu_result = lfsr_reg;
            end

            default: begin
                ex_alu_result = 32'b0;
            end
        endcase
    end

endmodule
