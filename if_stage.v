module if_stage(
    input wire clk,
    input wire reset,
    input wire StallF,
    input wire PCSrc,
    input wire [31:0] PC_branch,
    output wire [31:0] PC_out,
    output wire [31:0] PC_plus4
);
    reg [31:0] PC_reg;
    wire [31:0] PC_next;
    // 下一地址选择：跳转优先，其次正常+4，暂停则PC保持
    assign PC_next = PCSrc ? PC_branch :
                     (StallF ? PC_reg : (PC_reg + 32'd4));
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            PC_reg <= 32'h00000000;
        end else begin
            PC_reg <= PC_next;
        end
    end
    assign PC_out = PC_reg;
    assign PC_plus4 = PC_reg + 32'd4;
endmodule
