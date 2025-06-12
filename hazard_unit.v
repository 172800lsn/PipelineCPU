module hazard_unit(
    input wire PCSrcE,             // EX阶段确定发生跳转时的信号
    input wire RegWriteM,          // MEM阶段指令会写寄存器
    input wire RegWriteW,          // WB阶段指令会写寄存器
    input wire [4:0] Rs1D,
    input wire [4:0] Rs2D,         // ID阶段指令的源寄存器号
    input wire [4:0] Rs1E,
    input wire [4:0] Rs2E,         // EX阶段指令的源寄存器号
    input wire [4:0] RdE,          // EX阶段指令的目标寄存器号
    input wire [4:0] RdM,          // MEM阶段指令的目标寄存器号
    input wire [4:0] RdW,          // WB阶段指令的目标寄存器号
    input wire MemReadE,           // EX阶段指令是否为Load（从存储器读数据）
    output reg StallF,             // IF阶段暂停信号
    output reg StallD,             // ID阶段暂停信号
    output reg FlushD,             // ID阶段冲刷信号
    output reg FlushE,             // EX阶段冲刷信号
    output reg [1:0] ForwardAE,    // 转发选择控制（ALU操作数A）
    output reg [1:0] ForwardBE     // 转发选择控制（ALU操作数B）
);
    always @(*) begin
        // 默认无暂停、无冲刷、无转发
        StallF = 0; StallD = 0; FlushD = 0; FlushE = 0;
        ForwardAE = 2'b00; ForwardBE = 2'b00;
        // 数据前递控制：EX阶段源操作数与上一条或上两条指令目标相同时进行转发
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs1E))
            ForwardAE = 2'b10;
        else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs1E))
            ForwardAE = 2'b01;
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs2E))
            ForwardBE = 2'b10;
        else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs2E))
            ForwardBE = 2'b01;
        // Load-Use数据冒险检测：如果EX阶段的指令为Load且其目标寄存器将被当前ID阶段指令使用，则暂停流水线一个周期
        if (MemReadE && ((RdE == Rs1D) || (RdE == Rs2D)) && (RdE != 5'b0)) begin
            StallF = 1;
            StallD = 1;
            FlushE = 1;  // 向EX阶段插入气泡
        end
        // 控制冒险处理：当EX阶段确定发生跳转/分支时，冲刷掉已取出的下一条指令
        if (PCSrcE) begin
            FlushD = 1;
        end
    end
endmodule
