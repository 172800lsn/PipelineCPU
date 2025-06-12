module reg_file(
    input wire clk,
    input wire reset,
    input wire [4:0] read1_idx,
    input wire [4:0] read2_idx,
    output wire [31:0] read1_data,
    output wire [31:0] read2_data,
    input wire [4:0] write_idx,
    input wire [31:0] write_data,
    input wire write_en
);
    reg [31:0] regs [0:31];
    integer i;
    always @(posedge clk) begin
        if(reset) begin
            for(i=0; i<32; i=i+1)
                regs[i] <= 32'b0;
        end else if(write_en && (write_idx != 5'b0)) begin
            regs[write_idx] <= write_data;  // ºöÂÔ¶Ôx0¼Ä´æÆ÷µÄĞ´Èë
        end
    end
    assign read1_data = regs[read1_idx];
    assign read2_data = regs[read2_idx];
endmodule
