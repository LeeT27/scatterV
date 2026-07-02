module program_memory (
    input  logic        clk,
    input  logic [31:0] mem_address,
    input  logic [31:0] write_data,
    input  logic        mem_read_en,
    input  logic        mem_write_en,
    input  logic [2:0]  funct3,
    
    output logic [31:0] read_data
);
    logic [31:0] ram [0:1023];

    //Synchronous writes
    always_ff @(posedge clk) begin
        if (mem_write_en) begin
            case (funct3)
                3'b000: begin // SB
                    case (mem_address[1:0])
                        2'b00: ram[mem_address[11:2]][7:0]   <= write_data[7:0];
                        2'b01: ram[mem_address[11:2]][15:8]  <= write_data[7:0];
                        2'b10: ram[mem_address[11:2]][23:16] <= write_data[7:0];
                        2'b11: ram[mem_address[11:2]][31:24] <= write_data[7:0];
                    endcase
                end
                3'b001: begin // SH
                    if (mem_address[1] == 1'b0)
                        ram[mem_address[11:2]][15:0]  <= write_data[15:0];
                    else
                        ram[mem_address[11:2]][31:16] <= write_data[15:0];
                end
                3'b010: begin // SW
                    ram[mem_address[11:2]] <= write_data;
                end
                default: ram[mem_address[11:2]] <= write_data;
            endcase
        end
    end

    //Asynchronous reads
    always_comb begin
        if (mem_read_en) begin
            case (funct3)
                3'b000: begin // LB
                    case (mem_address[1:0])
                        2'b00: read_data = {{24{ram[mem_address[11:2]][7]}},  ram[mem_address[11:2]][7:0]};
                        2'b01: read_data = {{24{ram[mem_address[11:2]][15]}}, ram[mem_address[11:2]][15:8]};
                        2'b10: read_data = {{24{ram[mem_address[11:2]][23]}}, ram[mem_address[11:2]][23:16]};
                        2'b11: read_data = {{24{ram[mem_address[11:2]][31]}}, ram[mem_address[11:2]][31:24]};
                    endcase
                end
                3'b001: begin // LH
                    if (mem_address[1] == 1'b0)
                        read_data = {{16{ram[mem_address[11:2]][15]}}, ram[mem_address[11:2]][15:0]};
                    else
                        read_data = {{16{ram[mem_address[11:2]][31]}}, ram[mem_address[11:2]][31:16]};
                end
                3'b010: begin // LW
                    read_data = ram[mem_address[11:2]];
                end
                default: read_data = ram[mem_address[11:2]];
            endcase
        end else begin
            read_data = 32'b0; // Default state when memory isn't active
        end
    end

endmodule
