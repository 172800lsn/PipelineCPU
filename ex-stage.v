module ex_stage(
    input wire clk,
    input wire reset,
    // 来自冒险单元的转发控制
    input wire [1:0] ForwardAE,
    input wire [1:0] ForwardBE,
    // 来自ID/EX寄存器的数据和控制信号
    input wire [31:0] id_ex_pc,
    input wire [31:0] id_ex_rs1_val,
    input wire [31:0] id_ex_rs2_val,
    input wire [4:0] id_ex_rs1_idx,
    input wire [4:0] id_ex_rs2_idx,
    input wire [4:0] id_ex_rd_idx,
    input wire [31:0] id_ex_imm,
    input wire id_ex_RegWrite,
    input wire id_ex_MemRead,
    input wire id_ex_MemWrite,
    input wire [1:0] id_ex_ALUOp,
    input wire id_ex_ALUSrc,
    input wire id_ex_Branch,
    input wire id_ex_Jal,
    input wire id_ex_Jalr,
    input wire [1:0] id_ex_ResultSrc,
    // 来自后续阶段用于数据前递的数据
    input wire [31:0] ex_mem_alu_result_in,  // 来自MEM阶段的运算结果（用于前递）
    input wire [31:0] wb_data_in,           // 来自WB阶段写回的数据（用于前递）
    // 输出到IF阶段的跳转信号
    output wire PCSrc,
    output wire [31:0] PC_branch,
    // EX/MEM阶段流水寄存器输出
    output reg [31:0] ex_mem_alu_result,
    output reg [31:0] ex_mem_store_val,
    output reg [4:0] ex_mem_rd,
    output reg ex_mem_RegWrite,
    output reg ex_mem_MemRead,
    output reg ex_mem_MemWrite,
    output reg [1:0] ex_mem_ResultSrc,
    output reg [31:0] ex_mem_link_val
);
    // 根据前递控制选择ALU操作数的最终值
    wire [31:0] forwardA_val = (ForwardAE == 2'b10) ? ex_mem_alu_result_in :
                               (ForwardAE == 2'b01) ? wb_data_in :
                                                       id_ex_rs1_val;
    wire [31:0] forwardB_val = (ForwardBE == 2'b10) ? ex_mem_alu_result_in :
                               (ForwardBE == 2'b01) ? wb_data_in :
                                                       id_ex_rs2_val;
    // 确定送入ALU的操作数A和B（ALUSrc=1则B用立即数）
    wire [31:0] alu_in_A = forwardA_val;
    wire [31:0] alu_in_B = id_ex_ALUSrc ? id_ex_imm : forwardB_val;
    // 实例化ALU执行运算
    wire [31:0] alu_out;
    alu ALU_unit(
        .A(alu_in_A),
        .B(alu_in_B),
        .ALUOp(id_ex_ALUOp),
        .result(alu_out)
    );
    // 分支/跳转判断逻辑
    wire branch_taken = (id_ex_Branch && (alu_out == 32'b0));  // BEQ若减法结果为0则跳转
    wire pcsrc_int = branch_taken || id_ex_Jal || id_ex_Jalr;
    // 计算跳转目标地址
    wire [31:0] branch_addr = id_ex_pc + id_ex_imm;
//    wire [31:0] jalr_addr = { (alu_in_A + id_ex_imm)[31:1], 1'b0 };  // JALR目标 = rs1 + imm （对齐）
//    assign PC_branch = id_ex_Jalr ? jalr_addr : branch_addr;
    // 计算JALR目标地址时，先存储加法结果再进行位拼接
    wire [31:0] jalr_sum = alu_in_A + id_ex_imm;  // 新增临时变量存储rs1+imm的结果
    wire [31:0] jalr_addr = { jalr_sum[31:1], 1'b0 };  // 使用临时变量进行位拼接，确保地址对齐

    assign PC_branch = id_ex_Jalr ? jalr_addr : branch_addr;
    assign PCSrc = pcsrc_int;
    // 计算返回地址PC+4（link值）
    wire [31:0] link_val = id_ex_pc + 32'd4;
    // 确定需要写回的ALU输出值（若为JAL/JALR，则实际写回PC+4作为"ALU结果"用于前递）
    wire [31:0] actual_alu_result = (id_ex_ResultSrc == 2'b10) ? link_val : alu_out;
    // 时钟上升沿更新EX/MEM流水寄存器
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            ex_mem_alu_result <= 32'b0;
            ex_mem_store_val <= 32'b0;
            ex_mem_rd <= 5'b0;
            ex_mem_RegWrite <= 0;
            ex_mem_MemRead <= 0;
            ex_mem_MemWrite <= 0;
            ex_mem_ResultSrc <= 2'b00;
            ex_mem_link_val <= 32'b0;
        end else begin
            ex_mem_alu_result <= actual_alu_result;
            ex_mem_store_val <= forwardB_val;
            ex_mem_rd <= id_ex_rd_idx;
            ex_mem_RegWrite <= id_ex_RegWrite;
            ex_mem_MemRead <= id_ex_MemRead;
            ex_mem_MemWrite <= id_ex_MemWrite;
            ex_mem_ResultSrc <= id_ex_ResultSrc;
            ex_mem_link_val <= link_val;
        end
    end
endmodule
