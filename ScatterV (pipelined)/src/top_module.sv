module top_module (
    input clk,
    input rst
);
    //program_counter IO
    logic [31:0] pc_next;
    
    //control_unit IO

    logic [1:0] alu_op; //00 always add LOAD STORE. 01 always subtract BRANCH. 10 Normal ALU. 11 RND
    logic alu_src; //rs2 vs immediate for ALU
    logic ram_read_en;
    logic ram_write_en;
    logic [1:0] wb_sel; // Choose to load from ALU 00, DATA 01, or pc_out + 4 10
    logic reg_write_en;
    logic [1:0] pc_sel; // 00 PC + 4, 01 jal_en (PC + imm), 10 branch_en (PC + imm), 11 jalr_en (rs1 + imm)
    logic auipc_en; // Set operant1 to PC

    logic zero_flag;
    logic less_than;
    logic branch_condition_met; //Branch conditions met

    //stall hazard
    logic hazard_stall;


    // IF
    logic [31:0] if_pc;
    logic [31:0] if_instruction;
    //---------------------------------------------------------
    // 1. IF/ID Stage Registers
    //---------------------------------------------------------
    logic [31:0] if_id_pc;
    logic [31:0] if_id_instruction;
    // ID
    logic [4:0]  id_rs1;
    logic [4:0]  id_rs2;
    logic [31:0] id_rs1_data;
    logic [31:0] id_rs2_data;
    logic [31:0] id_imm;

    //---------------------------------------------------------
    // 2. ID/EX Stage Registers
    //---------------------------------------------------------
    logic [31:0] id_ex_pc;
    logic [31:0] id_ex_rs1_data;
    logic [31:0] id_ex_rs2_data;
    logic [31:0] id_ex_imm;
    logic [6:0]  id_ex_opcode;
    logic [4:0]  id_ex_rs1;
    logic [4:0]  id_ex_rs2;
    logic [4:0]  id_ex_rd;
    logic [6:0]  id_ex_funct7;
    logic [2:0]  id_ex_funct3;
    id_ex_ctrl_t id_ex_control; // Using our packed struct type
    // EX
    logic [31:0] ex_alu_result;
    logic [31:0] ex_operand1;
    logic [31:0] ex_operand2;

    //---------------------------------------------------------
    // 3. EX/MEM Stage Registers
    //---------------------------------------------------------
    logic [31:0]  ex_mem_pc;
    logic [31:0]  ex_mem_alu_result;
    logic [31:0]  ex_mem_rs2_data;
    logic [31:0]  ex_mem_imm;
    logic [4:0]   ex_mem_rd;
    logic [2:0]   ex_mem_funct3;
    ex_mem_ctrl_t ex_mem_control; // Using our packed struct type
    // MEM
    logic [31:0] mem_read_data;

    //---------------------------------------------------------
    // 4. MEM/WB Stage Registers
    //---------------------------------------------------------
    logic [31:0]  mem_wb_pc;
    logic [31:0]  mem_wb_alu_result;
    logic [31:0]  mem_wb_mem_data;
    logic [31:0]  mem_wb_imm;
    logic [4:0]   mem_wb_rd;
    mem_wb_ctrl_t mem_wb_control; // Using our packed struct type
    // WB
    logic [31:0] wb_rd_data;

    assign id_rs1 = if_id_instruction[24:20];  // Needed early for load hazard detection
    assign id_rs2 = if_id_instruction[19:15];

    assign wb_rd_data =
        (wb_sel == 2'b00) ? mem_wb_alu_result :
        (wb_sel == 2'b01) ? mem_wb_mem_data :
        (wb_sel == 2'b10) ? mem_wb_pc + 4 :
        (wb_sel == 2'b11) ? mem_wb_imm :
        32'b0;
    //load alu_result (ADD SUB), data (LOAD), pc + 4 (JAL JALR), or immediate_out (LUI)

    assign ex_operand1 = auipc_en ? id_ex_pc : id_ex_rs1_data; //pc for AUIPC, otherwise it'll be source register
    assign ex_operand2 = alu_src ? id_ex_imm : id_ex_rs2_data; //rs2 or immediate into ALU calculation
    
always_comb begin
        case (pc_sel)
            2'b00: pc_next = if_id_pc + 4; //NORMAL
            2'b01: pc_next = if_id_pc + id_ex_imm; // JAL
            2'b10: begin //BRANCH
                if (branch_condition_met)
                    pc_next = if_id_pc + id_ex_imm;
                else
                    pc_next = if_id_pc + 4;
            end
            2'b11: pc_next = (id_ex_rs1_data + id_ex_imm) & ~32'h1; // JALR alignment
            default: pc_next = if_id_pc + 4;
        endcase
    end


    // IF/ID Pipeline Register Stage
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        if_id_pc          <= 32'b0;
        if_id_instruction <= 32'h00000013;
    end
    else if (!hazard_stall) begin
        if_id_pc          <= if_pc;              // or pc_next, see note below
        if_id_instruction <= if_instruction;
    end
end

// ID/EX Pipeline Register Stage
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        id_ex_pc         <= 32'b0;
        id_ex_rs1_data   <= 32'b0;
        id_ex_rs2_data   <= 32'b0;
        id_ex_opcode     <= 7'b0;
        id_ex_imm        <= 32'b0;
        id_ex_rs1        <= 5'b0;
        id_ex_rs2        <= 5'b0;
        id_ex_rd         <= 5'b0;
        id_ex_control    <= 9'b0; // Cleared control signals = NOP
    end
    else if (hazard_stall) begin
        // Inject a NOP into EX to handle the load hazard
        id_ex_pc         <= 32'b0;
        id_ex_rs1_data   <= 32'b0;
        id_ex_rs2_data   <= 32'b0;
        id_ex_opcode     <= 7'b0;
        id_ex_imm        <= 32'b0;
        id_ex_rs1        <= 5'b0;
        id_ex_rs2        <= 5'b0;
        id_ex_rd         <= 5'b0;
        id_ex_control    <= 9'b0; // Insert the bubble
    end
    else begin
        // Normal operation: capture decoded data and control configurations
        id_ex_pc         <= if_id_pc;
        id_ex_rs1_data   <= id_rs1_data; // From register file
        id_ex_rs2_data   <= id_rs2_data; // From register file
        id_ex_opcode     <= if_id_instruction[6:0];
        id_ex_imm        <= id_imm;  // From immediate generator
        id_ex_rs1        <= id_rs1;
        id_ex_rs2        <= id_rs2;
        id_ex_rd         <= if_id_instruction[11:7];
        id_ex_funct7     <= if_id_instruction[31:25];
        id_ex_funct3     <= if_id_instruction[14:12];
        id_ex_control    <= control_word; // Packed control word from control unit
    end
end

// EX/MEM Pipeline Register Stage
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        ex_mem_pc         <= 32'b0;
        ex_mem_alu_result <= 32'b0;
        ex_mem_rs2_data   <= 32'b0;
        ex_mem_imm        <= 32'b0;
        ex_mem_rd         <= 5'b0;
        ex_mem_control    <= 5'b0; // Bits for mem_read, mem_write, reg_write, wb_sel
    end
    else begin
        ex_mem_pc         <= id_ex_pc;
        ex_mem_alu_result <= ex_alu_result;
        ex_mem_rs2_data   <= id_ex_rs2_data; // Needed if writing to memory (SW)
        ex_mem_imm        <= id_ex_imm;
        ex_mem_rd         <= id_ex_rd;
        ex_mem_funct3     <= id_ex_funct3;
        
        // Pass down only the remaining MEM and WB control signals
        // e.g., ex_mem_control = [mem_read, mem_write, reg_write, wb_sel]
        ex_mem_control    <= id_ex_control[5:1]; 
    end
end

// MEM/WB Pipeline Register Stage
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        mem_wb_pc         <= 32'b0;
        mem_wb_alu_result <= 32'b0;
        mem_wb_mem_data   <= 32'b0;
        mem_wb_imm        <= 32'b0;
        mem_wb_rd         <= 5'b0;
        mem_wb_control    <= 3'b0; // Bits for reg_write and wb_sel
    end
    else begin
        mem_wb_pc         <= ex_mem_pc;
        mem_wb_alu_result <= ex_mem_alu_result;
        mem_wb_mem_data   <= mem_read_data; // From data memory
        mem_wb_imm        <= ex_mem_imm;
        mem_wb_rd         <= ex_mem_rd;
        
        // Pass down only the final Writeback control signals
        // e.g., mem_wb_control = [reg_write, wb_sel]
        mem_wb_control    <= ex_mem_control[2:0]; 
    end
end

    program_counter f1 (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .hazard_stall(hazard_stall),

        .if_pc(if_pc)
    );

    instruction_memory f2(
        .if_id_pc(if_id_pc),

        .if_id_instruction(if_id_instruction)
    );

    control_unit f3 (
        .id_ex_opcode(id_ex_opcode),

        .alu_op(alu_op),
        .alu_src(alu_src),
        .ram_read_en(ram_read_en),
        .ram_write_en(ram_write_en),
        .reg_write_en(reg_write_en),
        .wb_sel(wb_sel),
        .pc_sel(pc_sel),
        .auipc_en(auipc_en),
        .hazard_stall(hazard_stall)
    );

    program_memory f4 (
        .clk(clk),
        .ex_mem_alu_result(ex_mem_alu_result), //memory address
        .ex_mem_rs2_data(ex_mem_rs2_data),
        .ex_mem_funct3(ex_mem_funct3),
        .ram_read_en(ram_read_en),
        .ram_write_en(ram_write_en),

        .mem_read_data(mem_read_data)
    );

    register_file f5 (
        .clk(clk),
        .rst(rst),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .mem_wb_rd(mem_wb_rd),
        .wb_rd_data(wb_rd_data),
        .reg_write_en(reg_write_en),

        .id_rs1_data(id_rs1_data),
        .id_rs2_data(id_rs2_data)
    );

    alu f6 (
        .clk(clk),
        .rst(rst),
        .alu_op(alu_op),
        .id_ex_funct3(id_ex_funct3),
        .id_ex_funct7(id_ex_funct7),
        .ex_operand1(ex_operand1),
        .ex_operand2(ex_operand2),
        .id_ex_opcode(id_ex_opcode),

        .ex_alu_result(ex_alu_result),
        .zero_flag(zero_flag),
        .less_than(less_than),
        .branch_condition_met(branch_condition_met)
    );

    immediate_generator f7 (
        .if_id_instruction(if_id_instruction),

        .id_imm(id_imm)
    );
    
endmodule
