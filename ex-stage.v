module ex_stage(
    input wire clk,
    input wire reset,
    // ����ð�յ�Ԫ��ת������
    input wire [1:0] ForwardAE,
    input wire [1:0] ForwardBE,
    // ����ID/EX�Ĵ��������ݺͿ����ź�
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
    // ���Ժ����׶���������ǰ�ݵ�����
    input wire [31:0] ex_mem_alu_result_in,  // ����MEM�׶ε�������������ǰ�ݣ�
    input wire [31:0] wb_data_in,           // ����WB�׶�д�ص����ݣ�����ǰ�ݣ�
    // �����IF�׶ε���ת�ź�
    output wire PCSrc,
    output wire [31:0] PC_branch,
    // EX/MEM�׶���ˮ�Ĵ������
    output reg [31:0] ex_mem_alu_result,
    output reg [31:0] ex_mem_store_val,
    output reg [4:0] ex_mem_rd,
    output reg ex_mem_RegWrite,
    output reg ex_mem_MemRead,
    output reg ex_mem_MemWrite,
    output reg [1:0] ex_mem_ResultSrc,
    output reg [31:0] ex_mem_link_val
);
    // ����ǰ�ݿ���ѡ��ALU������������ֵ
    wire [31:0] forwardA_val = (ForwardAE == 2'b10) ? ex_mem_alu_result_in :
                               (ForwardAE == 2'b01) ? wb_data_in :
                                                       id_ex_rs1_val;
    wire [31:0] forwardB_val = (ForwardBE == 2'b10) ? ex_mem_alu_result_in :
                               (ForwardBE == 2'b01) ? wb_data_in :
                                                       id_ex_rs2_val;
    // ȷ������ALU�Ĳ�����A��B��ALUSrc=1��B����������
    wire [31:0] alu_in_A = forwardA_val;
    wire [31:0] alu_in_B = id_ex_ALUSrc ? id_ex_imm : forwardB_val;
    // ʵ����ALUִ������
    wire [31:0] alu_out;
    alu ALU_unit(
        .A(alu_in_A),
        .B(alu_in_B),
        .ALUOp(id_ex_ALUOp),
        .result(alu_out)
    );
    // ��֧/��ת�ж��߼�
    wire branch_taken = (id_ex_Branch && (alu_out == 32'b0));  // BEQ���������Ϊ0����ת
    wire pcsrc_int = branch_taken || id_ex_Jal || id_ex_Jalr;
    // ������תĿ���ַ
    wire [31:0] branch_addr = id_ex_pc + id_ex_imm;
//    wire [31:0] jalr_addr = { (alu_in_A + id_ex_imm)[31:1], 1'b0 };  // JALRĿ�� = rs1 + imm �����룩
//    assign PC_branch = id_ex_Jalr ? jalr_addr : branch_addr;
    // ����JALRĿ���ַʱ���ȴ洢�ӷ�����ٽ���λƴ��
    wire [31:0] jalr_sum = alu_in_A + id_ex_imm;  // ������ʱ�����洢rs1+imm�Ľ��
    wire [31:0] jalr_addr = { jalr_sum[31:1], 1'b0 };  // ʹ����ʱ��������λƴ�ӣ�ȷ����ַ����

    assign PC_branch = id_ex_Jalr ? jalr_addr : branch_addr;
    assign PCSrc = pcsrc_int;
    // ���㷵�ص�ַPC+4��linkֵ��
    wire [31:0] link_val = id_ex_pc + 32'd4;
    // ȷ����Ҫд�ص�ALU���ֵ����ΪJAL/JALR����ʵ��д��PC+4��Ϊ"ALU���"����ǰ�ݣ�
    wire [31:0] actual_alu_result = (id_ex_ResultSrc == 2'b10) ? link_val : alu_out;
    // ʱ�������ظ���EX/MEM��ˮ�Ĵ���
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
