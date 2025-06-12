module wb_stage(
    // ����MEM/WB�Ĵ������ź�
    input wire [4:0] mem_wb_rd,
    input wire mem_wb_RegWrite,
    input wire [1:0] mem_wb_ResultSrc,
    input wire [31:0] mem_wb_alu_result,
    input wire [31:0] mem_wb_mem_data,
    input wire [31:0] mem_wb_link_val,
    // ������Ĵ�����д�˿ڵ��ź�
    output wire rf_write_en,
    output wire [4:0] rf_write_addr,
    output wire [31:0] rf_write_data,
    // ����ṩ��ת����Ԫ��д�����ݣ���rf_write_data��ͬ��
    output wire [31:0] wb_write_data
);
    assign rf_write_en = mem_wb_RegWrite;
    assign rf_write_addr = mem_wb_rd;
    // ����ResultSrcѡ��д�ص�����
    assign rf_write_data = (mem_wb_ResultSrc == 2'b01) ? mem_wb_mem_data :
                           (mem_wb_ResultSrc == 2'b10) ? mem_wb_link_val :
                                                         mem_wb_alu_result;
    assign wb_write_data = rf_write_data;
endmodule
