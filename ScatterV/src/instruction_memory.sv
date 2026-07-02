module instruction_memory (
    input  logic [31:0] pc_out,
    output logic [31:0] instruction
);
    logic [31:0] mem [0:63];

    initial begin
        // =========================================================================
        // 1. SETUP CONSTANTS
        // =========================================================================
        mem[0]  = 32'h00700093; // addi x1, x0, 7         (Bitmask: 0b111 (restrict to 0-7))
        mem[1]  = 32'h00100113; // addi x2, x0, 1         (Constant 1 to shift range 0-7 to 1-8)
        mem[2]  = 32'h00400193; // addi x3, x0, 4         (Byte address of mem[1] (writeback pointer))

        // =========================================================================
        // 2. GENERATE, BITMASK, AND SHIFT RANDOM NUMBER (1 to 8)
        // =========================================================================
        mem[3]  = 32'h0000020B; // RND x4                 (Custom: load 32-bit random into x4)
        mem[4]  = 32'h00727293; // andi x5, x4, 7         (x5 = x4 & 7  -> restricts to 0-7)
        mem[5]  = 32'h00128293; // addi x5, x5, 1         (x5 = x5 + 1  -> shifts to 1-8, x5 is target)

        // =========================================================================
        // 3. SQUARE LOOP LOGIC (x6 = x5 * x5)
        // =========================================================================
        mem[6]  = 32'h00000313; // addi x6, x0, 0         (Initialize accumulator x6 = 0)
        mem[7]  = 32'h00000393; // addi x7, x0, 0         (Initialize loop counter x7 = 0)

        // --- Loop Condition Check ---
        mem[8]  = 32'h0053D863; // bge x7, x5, +16        (If x7 >= x5, exit loop to sw at mem[12])
        mem[9]  = 32'h00530333; // add x6, x6, x5         (x6 = x6 + x5 (accumulate))
        mem[10] = 32'h00138393; // addi x7, x7, 1         (x7++ (increment loop counter))
        mem[11] = 32'hFF5FF06F; // j -12                  (Jump back to bge condition at mem[8])

        // =========================================================================
        // 4. WRITEBACK & TERMINATION
        // =========================================================================
        mem[12] = 32'h0061A023; // sw x6, 0(x3)           (Store squared result into mem[1])
        mem[13] = 32'h0000006F; // j 0                    (Halt trap)

        // Fill remaining instructions with NOPs
        for (int i = 14; i < 64; i++) begin
            mem[i] = 32'h00000013; // NOP (addi x0, x0, 0)
        end
    end

    assign instruction = mem[pc_out[7:2]];
endmodule
