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
        // Ĭ������ź�ֵ
        RegWrite = 0; MemRead = 0; MemWrite = 0;
        ALUOp = 2'b00; ALUSrc = 0;
        Branch = 0; Jal = 0; Jalr = 0;
        ResultSrc = 2'b00;
        case(opcode)
            7'b0110011: begin  // R����: add/sub/or
                RegWrite = 1;
                ALUSrc = 0;
                ResultSrc = 2'b00;
                if (funct3 == 3'b000) begin        // funct3=000: add��sub
                    if (funct7 == 7'b0100000)      // funct7=0x20: sub
                        ALUOp = 2'b01;
                    else                            // ����: add
                        ALUOp = 2'b00;
                end else if (funct3 == 3'b110) begin // funct3=110: or
                    ALUOp = 2'b10;
                end else begin
                    ALUOp = 2'b00;
                end
            end
            7'b0010011: begin  // I����: ADDI �ȣ�����ƽ���ADDI��
                if (funct3 == 3'b000) begin        // addi
                    RegWrite = 1;
                    ALUSrc = 1;
                    ALUOp = 2'b00;
                    ResultSrc = 2'b00;
                end
            end
            7'b0000011: begin  // I����: LOAD��LW��
                if (funct3 == 3'b010) begin        // lw
                    RegWrite = 1;
                    MemRead = 1;
                    ALUSrc = 1;
                    ALUOp = 2'b00;
                    ResultSrc = 2'b01;            // ��Դ�ڴ洢��
                end
            end
            7'b0100011: begin  // S����: STORE��SW��
                if (funct3 == 3'b010) begin        // sw
                    RegWrite = 0;
                    MemWrite = 1;
                    ALUSrc = 1;
                    ALUOp = 2'b00;
                end
            end
            7'b1100011: begin  // B����: BEQ
                if (funct3 == 3'b000) begin        // beq
                    RegWrite = 0;
                    Branch = 1;
                    ALUSrc = 0;
                    ALUOp = 2'b01;                // ��Ϊ���������ڱȽ��Ƿ����
                end
            end
            7'b0110111: begin  // U����: LUI
                RegWrite = 1;
                ALUSrc = 1;
                ALUOp = 2'b00;
                ResultSrc = 2'b00;
            end
            7'b1101111: begin  // J����: JAL
                RegWrite = 1;
                Jal = 1;
                ALUSrc = 1;
                ALUOp = 2'b00;
                ResultSrc = 2'b10;                // ��PC+4д��rd
            end
            7'b1100111: begin  // I����: JALR
                if (funct3 == 3'b000) begin        // jalr
                    RegWrite = 1;
                    Jalr = 1;
                    ALUSrc = 1;
                    ALUOp = 2'b00;
                    ResultSrc = 2'b10;            // ��PC+4д��rd
                end
            end
        endcase
    end
endmodule
