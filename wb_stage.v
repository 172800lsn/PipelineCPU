module wb_stage(
    // 来自MEM/WB寄存器的信号
    input wire [4:0] mem_wb_rd,
    input wire mem_wb_RegWrite,
    input wire [1:0] mem_wb_ResultSrc,
    input wire [31:0] mem_wb_alu_result,
    input wire [31:0] mem_wb_mem_data,
    input wire [31:0] mem_wb_link_val,
    // 输出至寄存器堆写端口的信号
    output wire rf_write_en,
    output wire [4:0] rf_write_addr,
    output wire [31:0] rf_write_data,
    // 输出提供给转发单元的写回数据（与rf_write_data相同）
    output wire [31:0] wb_write_data
);
    assign rf_write_en = mem_wb_RegWrite;
    assign rf_write_addr = mem_wb_rd;
    // 根据ResultSrc选择写回的数据
    assign rf_write_data = (mem_wb_ResultSrc == 2'b01) ? mem_wb_mem_data :
                           (mem_wb_ResultSrc == 2'b10) ? mem_wb_link_val :
                                                         mem_wb_alu_result;
    assign wb_write_data = rf_write_data;
endmodule
