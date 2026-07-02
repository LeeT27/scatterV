module top_module (
    input clk,
    input rst
);
    //program_counter IO
    logic [31:0] pc_out;
    logic [31:0] pc_next;
    
    //instruction_memory IO
    logic [31:0] instruction;

    //control_unit IO
    logic [6:0] opcode;

    logic [1:0] alu_op; //00 always add LOAD STORE. 01 always subtract BRANCH. 10 Normal ALU. 11 RND
    logic alu_src; //rs2 vs immediate for ALU
    logic mem_read_en;
    logic mem_write_en;
    logic [1:0] wb_sel; // Choose to load from ALU 00, DATA 01, or pc_out + 4 10
    logic reg_write_en;
    logic [1:0] pc_sel; // 00 PC + 4, 01 jal_en (PC + imm), 10 branch_en (PC + imm), 11 jalr_en (rs1 + imm)
    logic auipc_en; // Set operant1 to PC

    //program_memory IO
    logic [31:0] write_data;
    logic [31:0] mem_address;

    logic [31:0] read_data;

    //register_file IO
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [31:0] rd_data;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    
    //alu IO
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [31:0] operand1;
    logic [31:0] operand2;

    logic [31:0] alu_result;
    logic zero_flag;
    logic less_than;
    logic branch_condition_met; //Branch conditions met

    //immediate_generator IO
    logic [31:0] immediate_out;

    //General
    // funct7 Strictly for SUB, SRA, and SRAI
    assign funct7 = instruction[31:25];
    assign rs2 = instruction[24:20];
    assign rs1 = instruction[19:15];
    assign funct3 = instruction[14:12];
    assign rd = instruction[11:7];
    assign opcode = instruction[6:0];

    assign rd_data =
        (wb_sel == 2'b00) ? alu_result :
        (wb_sel == 2'b01) ? read_data :
        (wb_sel == 2'b10) ? pc_out + 4 :
        (wb_sel == 2'b11) ? immediate_out :
        32'b0;
    //Choose whether to load alu_result (ADD SUB), data (LOAD), pc + 4 (JAL JALR), or immediate_out (LUI)

    assign operand1 = auipc_en ? pc_out : rs1_data; //pc for AUIPC, otherwise it'll be source register
    assign operand2 = alu_src ? immediate_out : rs2_data; //rs2 or immediate into ALU calculation
    assign mem_address = alu_result; // Only access memory when loading or storing to prevent out of bounds
    assign write_data  = rs2_data; // Storing uses rs2's data, hazard prevention
    
    always_comb begin
        case (pc_sel)
            2'b00: pc_next = pc_out + 4; //NORMAL
            2'b01: pc_next = pc_out + immediate_out; // JAL
            2'b10: begin //BRANCH
                if (branch_condition_met)
                    pc_next = pc_out + immediate_out;
                else
                    pc_next = pc_out + 4;
            end
            2'b11: pc_next = (rs1_data + immediate_out) & ~32'h1; // JALR alignment
            default: pc_next = pc_out + 4;
        endcase
    end

    program_counter f1 (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),

        .pc_out(pc_out)
    );

    instruction_memory f2(
        .pc_out(pc_out),

        .instruction(instruction)
    );

    control_unit f3 (
        .opcode(opcode),

        .alu_op(alu_op),
        .alu_src(alu_src),
        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .reg_write_en(reg_write_en),
        .wb_sel(wb_sel),
        .pc_sel(pc_sel),
        .auipc_en(auipc_en)
    );

    program_memory f4 (
        .clk(clk),
        .mem_address(mem_address),
        .write_data(write_data),
        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .funct3(funct3),

        .read_data(read_data)
    );

    register_file f5 (
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rd_data(rd_data),
        .reg_write_en(reg_write_en),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    alu f6 (
        .clk(clk),
        .rst(rst),
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .operand1(operand1),
        .operand2(operand2),
        .opcode(opcode),

        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .less_than(less_than),
        .branch_condition_met(branch_condition_met)
    );

    immediate_generator f7 (
        .instruction(instruction),

        .immediate_out(immediate_out)
    );
    
endmodule
