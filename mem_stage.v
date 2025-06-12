module mem_stage(
    input wire clk,
    input wire reset,
    // 来自EX/MEM寄存器的信号
    input wire [31:0] ex_mem_alu_result,
    input wire [31:0] ex_mem_store_val,
    input wire [4:0] ex_mem_rd,
    input wire ex_mem_RegWrite,
    input wire ex_mem_MemRead,
    input wire ex_mem_MemWrite,
    input wire [1:0] ex_mem_ResultSrc,
    input wire [31:0] ex_mem_link_val,
    // 输出至MEM/WB寄存器的信号
    output reg [4:0] mem_wb_rd,
    output reg mem_wb_RegWrite,
    output reg [1:0] mem_wb_ResultSrc,
    output reg [31:0] mem_wb_alu_result,
    output reg [31:0] mem_wb_mem_data,
    output reg [31:0] mem_wb_link_val
);
    // 数据存储器实例
    wire [31:0] mem_data_out;
    data_mem dmem(
        .clk(clk),
        .reset(reset),
        .MemRead(ex_mem_MemRead),
        .MemWrite(ex_mem_MemWrite),
        .addr(ex_mem_alu_result),
        .write_data(ex_mem_store_val),
        .read_data(mem_data_out)
    );
    // 时钟上升沿更新MEM/WB流水寄存器
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            mem_wb_rd <= 5'b0;
            mem_wb_RegWrite <= 0;
            mem_wb_ResultSrc <= 2'b00;
            mem_wb_alu_result <= 32'b0;
            mem_wb_mem_data <= 32'b0;
            mem_wb_link_val <= 32'b0;
        end else begin
            mem_wb_rd <= ex_mem_rd;
            mem_wb_RegWrite <= ex_mem_RegWrite;
            mem_wb_ResultSrc <= ex_mem_ResultSrc;
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_mem_data <= mem_data_out;
            mem_wb_link_val <= ex_mem_link_val;
        end
    end
endmodule
