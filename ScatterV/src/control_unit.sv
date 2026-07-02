module control_unit(
    input [6:0] opcode,        // instruction opcode

    output logic [1:0] alu_op,
    output logic alu_src,
    output logic mem_read_en,
    output logic mem_write_en,
    output logic reg_write_en,
    output logic [1:0]wb_sel,
    output logic [1:0] pc_sel,
    output logic auipc_en
);

    always_comb begin
        alu_op       = 2'b00; 
        alu_src      = 0;
        mem_read_en  = 0;
        mem_write_en = 0;
        reg_write_en = 0;
        wb_sel       = 2'b00;
        auipc_en       = 0;
        pc_sel       = 2'b00; 

        case(opcode)
                7'b0110011: begin // R: ARITHMETIC
                alu_op       = 2'b10;
                reg_write_en = 1;
            end

            7'b0010011: begin // I: IMMEDIATE ARITHMATIC
                alu_op       = 2'b10;
                alu_src      = 1;
                reg_write_en = 1;
            end

            7'b0000011: begin // I: LOAD
                alu_op       = 2'b00;   // address = rs1 + imm
                alu_src      = 1;
                mem_read_en  = 1;
                reg_write_en = 1;
                wb_sel       = 2'b01;
            end

            7'b0100011: begin // STORE
                alu_op       = 2'b00;   // address = rs1 + imm
                alu_src      = 1;
                mem_write_en = 1;
            end

            7'b1100011: begin // BRANCH
                alu_op       = 2'b01;   // subtraction for comparison
                pc_sel       = 2'b10;
            end

            7'b0110111: begin // U: LUI
                alu_src      = 1;
                reg_write_en = 1;
                wb_sel       = 2'b11;
            end

            7'b0010111: begin // U: AUIPC
                alu_op       = 2'b00;
                alu_src      = 1;
                reg_write_en = 1;
                auipc_en     = 1;
            end

            7'b1101111: begin // J: JAL
                alu_src      = 1;
                reg_write_en = 1; // write PC+4 into register
                pc_sel       = 2'b01;
                wb_sel       = 2'b10;
            end

            7'b1100111: begin // JALR
                alu_src      = 1;
                reg_write_en = 1;   
                pc_sel       = 2'b11;
                wb_sel       = 2'b10;
            end

            7'b0001011: begin // RND
                alu_op       = 2'b11;
                reg_write_en = 1;
            end

            default: begin // INVALID
                pc_sel       = 2'b00; 
            end
            
        endcase
    end

endmodule
