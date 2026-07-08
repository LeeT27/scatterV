package pipeline_pkg;

    typedef struct packed {
        logic [1:0] pc_sel;     // needed in EX, 00 PC + 4, 01 jal_en (PC + imm), 10 branch_en (PC + imm), 11 jalr_en (rs1 + imm)
        logic       alu_src;    // needed in EX, rs2 vs immediate for operand2
        logic [1:0] alu_op;     // needed in EX, 00 add, 01 subtract, 10 Normal, 11 RND
        logic       auipc_en;   // needed in EX, Set operand1 to PC
        logic       ram_read;   // needed in MEM
        logic       ram_write;  // needed in MEM
        logic       reg_write;  // needed in WB
        logic [1:0] wb_sel;     // needed in WB, 00 alu_result (ADD SUB), 01 data (LOAD), 10 pc + 4 (JAL JALR), 11 immediate_out (LUI)
    } id_ex_ctrl_t;

    typedef struct packed {
        logic       ram_read;   // needed in MEM
        logic       ram_write;  // needed in MEM
        logic       reg_write;  // needed in WB
        logic [1:0] wb_sel;     // needed in WB
    } ex_mem_ctrl_t;

    typedef struct packed {
        logic       reg_write;  // needed in WB
        logic [1:0] wb_sel;     // needed in WB
    } mem_wb_ctrl_t;

endpackage

import pipeline_pkg::*;

module control_unit(
    input [6:0] id_opcode,        // instruction opcode

    output id_ex_ctrl_t id_control
);

    always_comb begin
        id_control.alu_op    = 2'b00;
        id_control.alu_src   = 1'b0;
        id_control.ram_read  = 1'b0;
        id_control.ram_write = 1'b0;
        id_control.reg_write = 1'b0;
        id_control.wb_sel    = 2'b00;
        id_control.auipc_en  = 1'b0;
        id_control.pc_sel    = 2'b00;

        case(id_opcode)
            7'b0110011: begin // R: ARITHMETIC
                id_control.alu_op    = 2'b10;
                id_control.reg_write = 1'b1;
            end

            7'b0010011: begin // I: IMMEDIATE ARITHMATIC
                id_control.alu_op    = 2'b10;
                id_control.alu_src   = 1'b1;
                id_control.reg_write = 1'b1;
            end

            7'b0000011: begin // I: LOAD
                id_control.alu_op    = 2'b00;   // address = rs1 + imm
                id_control.alu_src   = 1'b1;
                id_control.ram_read  = 1'b1;
                id_control.reg_write = 1'b1;
                id_control.wb_sel    = 2'b01;
            end

            7'b0100011: begin // STORE
                id_control.alu_op    = 2'b00;   // address = rs1 + imm
                id_control.alu_src   = 1'b1;
                id_control.ram_write = 1'b1;
            end

            7'b1100011: begin // BRANCH
                id_control.alu_op = 2'b01;   // subtraction for comparison
                id_control.pc_sel = 2'b10;
            end

            7'b0110111: begin // U: LUI
                id_control.alu_src   = 1'b1;
                id_control.reg_write = 1'b1;
                id_control.wb_sel    = 2'b11;
            end

            7'b0010111: begin // U: AUIPC
                id_control.alu_op    = 2'b00;
                id_control.alu_src   = 1'b1;
                id_control.reg_write = 1'b1;
                id_control.auipc_en  = 1'b1;
            end

            7'b1101111: begin // J: JAL
                id_control.alu_src   = 1'b1;
                id_control.reg_write = 1'b1; // write PC+4 into register
                id_control.pc_sel    = 2'b01;
                id_control.wb_sel    = 2'b10;
            end

            7'b1100111: begin // JALR
                id_control.alu_src   = 1'b1;
                id_control.reg_write = 1'b1;
                id_control.pc_sel    = 2'b11;
                id_control.wb_sel    = 2'b10;
            end

            7'b0001011: begin // RND
                id_control.alu_op    = 2'b11;
                id_control.reg_write = 1'b1;
            end

            default: begin // INVALID
                id_control.pc_sel    = 2'b00;
            end

        endcase
    end

endmodule
