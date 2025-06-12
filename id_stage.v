module id_stage(
    input wire clk,
    input wire reset,
    input wire StallD,
    input wire FlushD,
    input wire FlushE,
    input wire [31:0] instruction_in,
    input wire [31:0] PC_in,
    input wire [31:0] reg1_data_in,
    input wire [31:0] reg2_data_in,
    output wire [4:0] rs1_idx_out,
    output wire [4:0] rs2_idx_out,
    // 输出给EX阶段的ID/EX流水寄存器信号
    output reg [31:0] id_ex_pc,
    output reg [31:0] id_ex_rs1_val,
    output reg [31:0] id_ex_rs2_val,
    output reg [4:0] id_ex_rs1_idx,
    output reg [4:0] id_ex_rs2_idx,
    output reg [4:0] id_ex_rd_idx,
    output reg [31:0] id_ex_imm,
    output reg id_ex_RegWrite,
    output reg id_ex_MemRead,
    output reg id_ex_MemWrite,
    output reg [1:0] id_ex_ALUOp,
    output reg id_ex_ALUSrc,
    output reg id_ex_Branch,
    output reg id_ex_Jal,
    output reg id_ex_Jalr,
    output reg [1:0] id_ex_ResultSrc
);
    // IF/ID流水寄存器
    reg [31:0] if_id_instr;
    reg [31:0] if_id_pc;
    // 实例化控制单元进行指令译码
    wire ctrl_RegWrite, ctrl_MemRead, ctrl_MemWrite;
    wire [1:0] ctrl_ALUOp;
    wire ctrl_ALUSrc, ctrl_Branch, ctrl_Jal, ctrl_Jalr;
    wire [1:0] ctrl_ResultSrc;
    control_unit CU(
        .instr(if_id_instr),
        .RegWrite(ctrl_RegWrite),
        .MemRead(ctrl_MemRead),
        .MemWrite(ctrl_MemWrite),
        .ALUOp(ctrl_ALUOp),
        .ALUSrc(ctrl_ALUSrc),
        .Branch(ctrl_Branch),
        .Jal(ctrl_Jal),
        .Jalr(ctrl_Jalr),
        .ResultSrc(ctrl_ResultSrc)
    );
    // 生成立即数（根据指令类型拼接sign extension）
    reg [31:0] imm;
    wire [6:0] opcode = if_id_instr[6:0];
    always @(*) begin
        case(opcode)
            7'b0010011,    // I-type (ADDI 等)
            7'b0000011,    // I-type (LW)
            7'b1100111:    // I-type (JALR)
                imm = {{20{if_id_instr[31]}}, if_id_instr[31:20]};
            7'b0100011:    // S-type (SW)
                imm = {{20{if_id_instr[31]}}, if_id_instr[31:25], if_id_instr[11:7]};
            7'b1100011:    // B-type (BEQ)
                imm = {{19{if_id_instr[31]}}, if_id_instr[31], if_id_instr[7],
                       if_id_instr[30:25], if_id_instr[11:8], 1'b0};
            7'b0110111:    // U-type (LUI)
                imm = {if_id_instr[31:12], 12'b0};
            7'b1101111:    // J-type (JAL)
                imm = {{11{if_id_instr[31]}}, if_id_instr[31], if_id_instr[19:12],
                       if_id_instr[20], if_id_instr[30:21], 1'b0};
            default:
                imm = 32'b0;
        endcase
    end
    // 确定当前指令源寄存器索引（无用操作数设为x0=寄存器0）
    wire use_rs1 = (opcode != 7'b1101111) && (opcode != 7'b0110111);  // 非JAL和非LUI指令需要rs1
    wire use_rs2 = (opcode == 7'b0110011) || (opcode == 7'b0100011) || (opcode == 7'b1100011);
    assign rs1_idx_out = use_rs1 ? if_id_instr[19:15] : 5'b00000;
    assign rs2_idx_out = use_rs2 ? if_id_instr[24:20] : 5'b00000;
    // 时钟上升沿更新流水寄存器
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            // 初始化IF/ID和ID/EX寄存器为NOP
            if_id_instr <= 32'h00000013;  // NOP (addi x0,x0,0)
            if_id_pc <= 32'b0;
            id_ex_pc <= 32'b0;
            id_ex_rs1_val <= 32'b0;
            id_ex_rs2_val <= 32'b0;
            id_ex_rs1_idx <= 5'b0;
            id_ex_rs2_idx <= 5'b0;
            id_ex_rd_idx <= 5'b0;
            id_ex_imm <= 32'b0;
            id_ex_RegWrite <= 0;
            id_ex_MemRead <= 0;
            id_ex_MemWrite <= 0;
            id_ex_ALUOp <= 2'b00;
            id_ex_ALUSrc <= 0;
            id_ex_Branch <= 0;
            id_ex_Jal <= 0;
            id_ex_Jalr <= 0;
            id_ex_ResultSrc <= 2'b00;
        end else begin
            // 更新IF/ID流水寄存器
            if(StallD) begin
                // 数据冒险暂停时，不更新IF/ID（保持上一周期指令）
            end else if(FlushD) begin
                // 控制冒险冲刷，插入NOP到译码级
                if_id_instr <= 32'h00000013;
                if_id_pc <= 32'b0;
            end else begin
                // 正常推进取指寄存器值
                if_id_instr <= instruction_in;
                if_id_pc <= PC_in;
            end
            // 更新ID/EX流水寄存器
            if(FlushE) begin
                // Load-Use气泡冲刷EX级
                id_ex_pc <= 32'b0;
                id_ex_rs1_val <= 32'b0;
                id_ex_rs2_val <= 32'b0;
                id_ex_rs1_idx <= 5'b0;
                id_ex_rs2_idx <= 5'b0;
                id_ex_rd_idx <= 5'b0;
                id_ex_imm <= 32'b0;
                id_ex_RegWrite <= 0;
                id_ex_MemRead <= 0;
                id_ex_MemWrite <= 0;
                id_ex_ALUOp <= 2'b00;
                id_ex_ALUSrc <= 0;
                id_ex_Branch <= 0;
                id_ex_Jal <= 0;
                id_ex_Jalr <= 0;
                id_ex_ResultSrc <= 2'b00;
            end else if(!StallD) begin
                // 将当前解码得到的信息送入EX阶段寄存器
                id_ex_pc <= if_id_pc;
                id_ex_rs1_val <= reg1_data_in;
                id_ex_rs2_val <= reg2_data_in;
                id_ex_rs1_idx <= rs1_idx_out;
                id_ex_rs2_idx <= rs2_idx_out;
                id_ex_rd_idx <= if_id_instr[11:7];
                id_ex_imm <= imm;
                id_ex_RegWrite <= ctrl_RegWrite;
                id_ex_MemRead <= ctrl_MemRead;
                id_ex_MemWrite <= ctrl_MemWrite;
                id_ex_ALUOp <= ctrl_ALUOp;
                id_ex_ALUSrc <= ctrl_ALUSrc;
                id_ex_Branch <= ctrl_Branch;
                id_ex_Jal <= ctrl_Jal;
                id_ex_Jalr <= ctrl_Jalr;
                id_ex_ResultSrc <= ctrl_ResultSrc;
            end
        end
    end
endmodule
