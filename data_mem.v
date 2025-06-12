module data_mem(
    input wire clk,
    input wire reset,
    input wire MemRead,
    input wire MemWrite,
    input wire [31:0] addr,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);
    // 1KBÊı¾İ´æ´¢£¨256¡Á32-bit£©£¬µØÖ·0x400-0x7FF
    reg [31:0] memory [0:255];
    integer j;
    initial begin
        for(j=0; j<256; j=j+1)
            memory[j] = 32'b0;
    end
    wire [31:0] offset = addr - 32'h400;
    wire [7:0] index = offset[9:2];
    assign read_data = MemRead ? memory[index] : 32'b0;
    always @(posedge clk) begin
        if(reset) begin
            for(j=0; j<256; j=j+1)
                memory[j] <= 32'b0;
        end else if(MemWrite) begin
            memory[index] <= write_data;
        end
    end
endmodule
