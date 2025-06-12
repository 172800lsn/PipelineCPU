`timescale 1ns / 1ps
module pipeline_cpu(
    input wire clk,
    input wire reset
);
    // IF½×¶Î
    wire [31:0] IF_PC;
    wire [31:0] IF_instruction;
    wire [31:0] IF_PC_plus4;
    // ID½×¶Î
    wire [4:0] ID_rs1_idx, ID_rs2_idx;
    wire [31:0] ID_EX_pc;
    wire [31:0] ID_EX_rs1_val, ID_EX_rs2_val;
    wire [4:0] ID_EX_rs1_idx, ID_EX_rs2_idx, ID_EX_rd_idx;
    wire [31:0] ID_EX_imm;
    wire ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite;
    wire [1:0] ID_EX_ALUOp;
    wire ID_EX_ALUSrc, ID_EX_Branch, ID_EX_Jal, ID_EX_Jalr;
    wire [1:0] ID_EX_ResultSrc;
    // EX½×¶Î
    wire [31:0] EX_MEM_alu_result, EX_MEM_store_val;
    wire [4:0] EX_MEM_rd;
    wire EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemWrite;
    wire [1:0] EX_MEM_ResultSrc;
    wire [31:0] EX_MEM_link_val;
    wire EX_PCSrc;
    wire [31:0] EX_PC_branch;
    // MEM½×¶Î
    wire [4:0] MEM_WB_rd;
    wire MEM_WB_RegWrite;
    wire [1:0] MEM_WB_ResultSrc;
    wire [31:0] MEM_WB_alu_result, MEM_WB_mem_data, MEM_WB_link_val;
    // WB½×¶Î£¨¼Ä´æÆ÷¶ÑÐ´Èë£©
    wire RF_write_en;
    wire [4:0] RF_write_addr;
    wire [31:0] RF_write_data;
    wire [31:0] WB_write_data;
    // ¼Ä´æÆ÷¶Ñ¶ÁÊä³ö
    wire [31:0] RF_read1_data, RF_read2_data;
    // Ã°ÏÕµ¥ÔªÊä³ö¿ØÖÆÐÅºÅ
    wire StallF, StallD;
    wire FlushD, FlushE;
    wire [1:0] ForwardAE, ForwardBE;
    // ³åÍ»¼ì²âÓëÊý¾ÝÇ°µÝ¿ØÖÆÄ£¿é
    hazard_unit hazard(
        .PCSrcE(EX_PCSrc),
        .RegWriteM(EX_MEM_RegWrite),
        .RegWriteW(MEM_WB_RegWrite),
        .Rs1D(ID_rs1_idx),
        .Rs2D(ID_rs2_idx),
        .Rs1E(ID_EX_rs1_idx),
        .Rs2E(ID_EX_rs2_idx),
        .RdE(ID_EX_rd_idx),
        .RdM(EX_MEM_rd),
        .RdW(MEM_WB_rd),
        .MemReadE(ID_EX_MemRead),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE)
    );
    // Ö¸Áî´æ´¢£¨ROM£©
    instr_mem IMEM(
        .addr(IF_PC),
        .instr(IF_instruction)
    );
    // IF½×¶ÎÄ£¿é
    if_stage if_stage_inst(
        .clk(clk),
        .reset(reset),
        .StallF(StallF),
        .PCSrc(EX_PCSrc),
        .PC_branch(EX_PC_branch),
        .PC_out(IF_PC),
        .PC_plus4(IF_PC_plus4)
    );
    // ID½×¶ÎÄ£¿é
    id_stage id_stage_inst(
        .clk(clk),
        .reset(reset),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE),
        .instruction_in(IF_instruction),
        .PC_in(IF_PC),
        .reg1_data_in(RF_read1_data),
        .reg2_data_in(RF_read2_data),
        .rs1_idx_out(ID_rs1_idx),
        .rs2_idx_out(ID_rs2_idx),
        .id_ex_pc(ID_EX_pc),
        .id_ex_rs1_val(ID_EX_rs1_val),
        .id_ex_rs2_val(ID_EX_rs2_val),
        .id_ex_rs1_idx(ID_EX_rs1_idx),
        .id_ex_rs2_idx(ID_EX_rs2_idx),
        .id_ex_rd_idx(ID_EX_rd_idx),
        .id_ex_imm(ID_EX_imm),
        .id_ex_RegWrite(ID_EX_RegWrite),
        .id_ex_MemRead(ID_EX_MemRead),
        .id_ex_MemWrite(ID_EX_MemWrite),
        .id_ex_ALUOp(ID_EX_ALUOp),
        .id_ex_ALUSrc(ID_EX_ALUSrc),
        .id_ex_Branch(ID_EX_Branch),
        .id_ex_Jal(ID_EX_Jal),
        .id_ex_Jalr(ID_EX_Jalr),
        .id_ex_ResultSrc(ID_EX_ResultSrc)
    );
    // ¼Ä´æÆ÷¶ÑÊµÀý
    reg_file regfile_inst(
        .clk(clk),
        .reset(reset),
        .read1_idx(ID_rs1_idx),
        .read2_idx(ID_rs2_idx),
        .read1_data(RF_read1_data),
        .read2_data(RF_read2_data),
        .write_idx(RF_write_addr),
        .write_data(RF_write_data),
        .write_en(RF_write_en)
    );
    // EX½×¶ÎÄ£¿é
    ex_stage ex_stage_inst(
        .clk(clk),
        .reset(reset),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .id_ex_pc(ID_EX_pc),
        .id_ex_rs1_val(ID_EX_rs1_val),
        .id_ex_rs2_val(ID_EX_rs2_val),
        .id_ex_rs1_idx(ID_EX_rs1_idx),
        .id_ex_rs2_idx(ID_EX_rs2_idx),
        .id_ex_rd_idx(ID_EX_rd_idx),
        .id_ex_imm(ID_EX_imm),
        .id_ex_RegWrite(ID_EX_RegWrite),
        .id_ex_MemRead(ID_EX_MemRead),
        .id_ex_MemWrite(ID_EX_MemWrite),
        .id_ex_ALUOp(ID_EX_ALUOp),
        .id_ex_ALUSrc(ID_EX_ALUSrc),
        .id_ex_Branch(ID_EX_Branch),
        .id_ex_Jal(ID_EX_Jal),
        .id_ex_Jalr(ID_EX_Jalr),
        .id_ex_ResultSrc(ID_EX_ResultSrc),
        .ex_mem_alu_result_in(EX_MEM_alu_result),
        .wb_data_in(WB_write_data),
        .PCSrc(EX_PCSrc),
        .PC_branch(EX_PC_branch),
        .ex_mem_alu_result(EX_MEM_alu_result),
        .ex_mem_store_val(EX_MEM_store_val),
        .ex_mem_rd(EX_MEM_rd),
        .ex_mem_RegWrite(EX_MEM_RegWrite),
        .ex_mem_MemRead(EX_MEM_MemRead),
        .ex_mem_MemWrite(EX_MEM_MemWrite),
        .ex_mem_ResultSrc(EX_MEM_ResultSrc),
        .ex_mem_link_val(EX_MEM_link_val)
    );
    // MEM½×¶ÎÄ£¿é
    mem_stage mem_stage_inst(
        .clk(clk),
        .reset(reset),
        .ex_mem_alu_result(EX_MEM_alu_result),
        .ex_mem_store_val(EX_MEM_store_val),
        .ex_mem_rd(EX_MEM_rd),
        .ex_mem_RegWrite(EX_MEM_RegWrite),
        .ex_mem_MemRead(EX_MEM_MemRead),
        .ex_mem_MemWrite(EX_MEM_MemWrite),
        .ex_mem_ResultSrc(EX_MEM_ResultSrc),
        .ex_mem_link_val(EX_MEM_link_val),
        .mem_wb_rd(MEM_WB_rd),
        .mem_wb_RegWrite(MEM_WB_RegWrite),
        .mem_wb_ResultSrc(MEM_WB_ResultSrc),
        .mem_wb_alu_result(MEM_WB_alu_result),
        .mem_wb_mem_data(MEM_WB_mem_data),
        .mem_wb_link_val(MEM_WB_link_val)
    );
    // WB½×¶ÎÄ£¿é
    wb_stage wb_stage_inst(
        .mem_wb_rd(MEM_WB_rd),
        .mem_wb_RegWrite(MEM_WB_RegWrite),
        .mem_wb_ResultSrc(MEM_WB_ResultSrc),
        .mem_wb_alu_result(MEM_WB_alu_result),
        .mem_wb_mem_data(MEM_WB_mem_data),
        .mem_wb_link_val(MEM_WB_link_val),
        .rf_write_en(RF_write_en),
        .rf_write_addr(RF_write_addr),
        .rf_write_data(RF_write_data),
        .wb_write_data(WB_write_data)
    );
endmodule
    