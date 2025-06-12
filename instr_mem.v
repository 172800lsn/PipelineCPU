module instr_mem(
    input wire [31:0] addr,
    output wire [31:0] instr
);
    // 1KB指令存储（256条指令），Little Endian按字编址
    reg [31:0] memory [0:255];
    initial begin
        memory[0]  = 32'h000012B7; // 0x000: LUI x5, 0x00001
        memory[1]  = 32'h23428293; // 0x004: ADDI x5, x5, 0x234
        memory[2]  = 32'h0052E333; // 0x008: OR   x6, x5, x5
        memory[3]  = 32'h00A00393; // 0x00C: ADDI x7, x0, 10
        memory[4]  = 32'h00728433; // 0x010: ADD  x8, x5, x7
        memory[5]  = 32'h407404B3; // 0x014: SUB  x9, x8, x7
        memory[6]  = 32'h40000193; // 0x018: ADDI x3, x0, 0x400
        memory[7]  = 32'h0091A023; // 0x01C: SW   x9, 0(x3)
        memory[8]  = 32'h0001A503; // 0x020: LW   x10, 0(x3)
        memory[9]  = 32'h00500593; // 0x024: ADDI x11, x0, 5
        memory[10] = 32'h00500613; // 0x028: ADDI x12, x0, 5
        memory[11] = 32'h00C58463; // 0x02C: BEQ  x11, x12, label
        memory[12] = 32'h00100693; // 0x030: ADDI x13, x0, 1       # (to be skipped)
        memory[13] = 32'h000066B3; // 0x034: OR   x13, x0, x0      # label: x13=0
        memory[14] = 32'h010000EF; // 0x038: JAL  x1, subroutine
        memory[15] = 32'h00200713; // 0x03C: ADDI x14, x0, 2      # after return
        memory[16] = 32'h00000063; // 0x040: BEQ  x0, x0, loop    # loop: halt
        memory[17] = 32'h00000033; // 0x044: ADD  x0, x0, x0      # NOP
        memory[18] = 32'h06300793; // 0x048: ADDI x15, x0, 99     # subroutine
        memory[19] = 32'h00008067; // 0x04C: JALR x0, x1, 0       # return
    end
    // 按字寻址取指（addr[1:0]恒为0），addr[9:2]作为ROM索引
    assign instr = memory[addr[9:2]];
endmodule
