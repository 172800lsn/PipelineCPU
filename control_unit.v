module control_unit(
    input wire [31:0] instr,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg [1:0] ALUOp,
    output reg ALUSrc,
    output reg Branch,
    output reg Jal,
    output reg Jalr,
    output reg [1:0] ResultSrc
);
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];
    always @(*) begin
        // 默认输出信号值
        RegWrite = 0; MemRead = 0; MemWrite = 0;
        ALUOp = 2'b00; ALUSrc = 0;
        Branch = 0; Jal = 0; Jalr = 0;
        ResultSrc = 2'b00;
        case(opcode)
            7'b0110011: begin  // R类型: add/sub/or
                RegWrite = 1;
                ALUSrc = 0;
                ResultSrc = 2'b00;
                if (funct3 == 3'b000) begin        // funct3=000: add或sub
                    if (funct7 == 7'b0100000)      // funct7=0x20: sub
                        ALUOp = 2'b01;
                    else                            // 其他: add
                        ALUOp = 2'b00;
                end else if (funct3 == 3'b110) begin // funct3=110: or
                    ALUOp = 2'b10;
                end else begin
                    ALUOp = 2'b00;
                end
            end
            7'b0010011: begin  // I类型: ADDI 等（本设计仅需ADDI）
                if (funct3 == 3'b000) begin        // addi
                    RegWrite = 1;
                    ALUSrc = 1;
                    ALUOp = 2'b00;
                    ResultSrc = 2'b00;
                end
            end
            7'b0000011: begin  // I类型: LOAD（LW）
                if (funct3 == 3'b010) begin        // lw
                    RegWrite = 1;
                    MemRead = 1;
                    ALUSrc = 1;
                    ALUOp = 2'b00;
                    ResultSrc = 2'b01;            // 来源于存储器
                end
            end
            7'b0100011: begin  // S类型: STORE（SW）
                if (funct3 == 3'b010) begin        // sw
                    RegWrite = 0;
                    MemWrite = 1;
                    ALUSrc = 1;
                    ALUOp = 2'b00;
                end
            end
            7'b1100011: begin  // B类型: BEQ
                if (funct3 == 3'b000) begin        // beq
                    RegWrite = 0;
                    Branch = 1;
                    ALUSrc = 0;
                    ALUOp = 2'b01;                // 设为减法，用于比较是否相等
                end
            end
            7'b0110111: begin  // U类型: LUI
                RegWrite = 1;
                ALUSrc = 1;
                ALUOp = 2'b00;
                ResultSrc = 2'b00;
            end
            7'b1101111: begin  // J类型: JAL
                RegWrite = 1;
                Jal = 1;
                ALUSrc = 1;
                ALUOp = 2'b00;
                ResultSrc = 2'b10;                // 将PC+4写入rd
            end
            7'b1100111: begin  // I类型: JALR
                if (funct3 == 3'b000) begin        // jalr
                    RegWrite = 1;
                    Jalr = 1;
                    ALUSrc = 1;
                    ALUOp = 2'b00;
                    ResultSrc = 2'b10;            // 将PC+4写入rd
                end
            end
        endcase
    end
endmodule
